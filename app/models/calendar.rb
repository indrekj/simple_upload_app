require 'net/https'
require 'uri'
require 'cgi'
require 'hpricot'

class Calendar
  class InvalidLogin < Exception
  end

  class NoScheduleFound < Exception
  end

  OIS_ADDR = 'https://www.is.ut.ee/'

  module Certs
    JUUR_SK_FILE = RAILS_ROOT + '/config/certs/Juur-SK'
  end

  def initialize
    @calendar = {}
    (1..7).each do |day|
      @calendar.merge!({day => []})
    end

    @ois_data = nil
    @ics_data = nil
  end

  def fetch_from_ois_using_pw!(user, pw)
    url = URI.parse(OIS_ADDR)
    
    # Certs
    store = OpenSSL::X509::Store.new
    store.set_default_paths
    store.add_file(Certs::JUUR_SK_FILE)

    # Set http params
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.cert_store = store

    http.start do
      begin
        headers = {
          'User-Agent' => 'Firefox v1337', 
          'Accept' => '*/*',
          'Content-Type' => 'text/html'
        }

        # Log in
        resp, body = http.post('/pls/ois/!tere.tulemast', "kasutaja=#{user}&salasona=#{pw}")
        raise InvalidLogin if body.include?('Veateade')

        # Try to get the link to the schedule page
        addr_to_schedule = body.match(/window.open\(\'(.*)\'\);/)[1]
        addr_to_schedule.gsub!(OIS_ADDR, '/')
        req = Net::HTTP::Get.new(addr_to_schedule, headers)
        resp, body = http.request(req)
        raise NoScheduleFound unless resp['Location']

        # Get data
        headers.merge!('Referer' => resp['Location'])

        addr_to_schedule = resp['Location'].gsub(OIS_ADDR, '/')
        addr_to_schedule.gsub!('HTML', 'XML')
        addr_to_schedule.gsub!('text/html', 'application/xml')
        addr_to_schedule.gsub!('https://www.is.ut.ee', '')

        req = Net::HTTP::Get.new(addr_to_schedule, headers)
        resp, body = http.request(req)
      rescue Exception => e
        raise e
      end

      @ois_data = Iconv.conv('UTF-8', 'ISO-8859-15', body)
    end
  end

  def fetch_from_ois_using_url!(url)
    url.gsub!('https', 'http')
    url.gsub!('HTML', 'XML')
    url.gsub!('text/html', 'application/xml')
    url.gsub!('https://www.is.ut.ee', '')
    
    res = Net::HTTP.get_response(URI.parse(url))
    @ois_data = Iconv.conv('UTF-8', 'ISO-8859-15', res.body)
    unless @ois_data.include?('KL_NADALAPAEV')
      raise NoScheduleFound
    end
    @ois_data
  end

  def ois_data_to_hash!
    doc = Hpricot::XML(@ois_data)
    (doc/:G_KL_NADALAPAEV).each do |kl_day|
      day = kl_day.at(:KL_NADALAPAEV).innerText.to_i
      (kl_day/:G_ALGUSKELL).each do |kl_class|
        class_hash = {}

        start_time = fix_time(kl_class.at(:ALGUSKELL).innerText)
        end_time = fix_time(kl_class.at(:LOPPKELL).innerText)

        class_hash.merge!(:start_time => start_time)
        class_hash.merge!(:end_time => end_time)
        class_hash.merge!(:location => kl_class.at(:CP_KOHT).innerText)
        class_hash.merge!(:class_name => kl_class.at(:CP_AINE_NIMETUS).innerText)
        
        description = "Aine kood: #{kl_class.at(:CP_AINE_KOOD).innerText}, "
        description += "õppejõud: #{kl_class.at(:CF_OPPEJOUD).innerText}"

        class_hash.merge!(:description => description)

        weeks = []
        kl_weeks = kl_class.at(:NADALAD).innerText
        kl_weeks.split(', ').each do |week|
          if week.include?('-')
            first, last = week.split('-')
            weeks += (first.to_i..last.to_i).to_a
          else
            weeks << week.to_i
          end
        end
        class_hash.merge!(:weeks => weeks)

        @calendar[day] << class_hash
      end
    end  
  end

  def to_ics!
    str = "BEGIN:VCALENDAR\n"
    str += "X-WR-CALNAME:Tartu ülikooli tunniplaan\n"
    str += "PRODID:-//University Of Tartu tunniplaan//Urgas.eu//EN\n"
    str += "VERSION:2.0\n"
    str += "CALSCALE:GREGORIAN\n"
    str += "METHOD:PUBLISH\n"
    str += "X-WR-TIMEZONE:Europe/Tallinn\n"

    @calendar.each do |day, classes|
      classes.each do |klass|
        weeks = klass[:weeks]
        interval = nil

        # interval 1 week
        start_week = weeks[0]
        if weeks[1]
          end_week = start_week + 1
          weeks.each do |week|
            if end_week + 1 == week
              end_week = week
              interval = 1
            end
          end
        end

        # interval 2 weeks
        start_week = weeks[0]
        if weeks[2] && !interval
          end_week = start_week + 2
          weeks.each do |week|
            if end_week + 2 == week
              end_week = week
              interval = 2
            end
          end
        end

        # Time.local(Time.now.year, 9, 1) + 1.week => Sep 08. We need Sep 07.
        date = Time.local(Time.now.year, 9, 1) + (day - 2).days

        if interval
          weeks[weeks.rindex(start_week)..weeks.rindex(end_week)] = nil

          class_date = date + start_week.weeks - 1.week
          class_date = class_date.strftime("%Y%m%d")

          end_date = (date + end_week.weeks - 1.week).strftime("%Y%m%d")

          str += "BEGIN:VEVENT\n"
          
          str += "RRULE:FREQ=WEEKLY;INTERVAL=#{interval};WKST=MO;"
          str += "UNTIL=#{end_date};BYDAY=#{to_ics_day(day)}\n"
          
          str += "DTSTART;TZID=Europe/Tallinn:#{class_date}T#{klass[:start_time]}\n"
          str += "DTEND;TZID=Europe/Tallinn:#{class_date}T#{klass[:end_time]}\n"
          str += "LOCATION:#{klass[:location]}\n"
          str += "SUMMARY:#{klass[:class_name]}\n"
          str += "DESCRIPTION:#{klass[:description]}\n"
          str += "END:VEVENT\n"
        end

        weeks.each do |week|
          class_date = date + week.weeks - 1.week
          class_date = class_date.strftime("%Y%m%d")

          str += "BEGIN:VEVENT\n"
          str += "DTSTART;TZID=Europe/Tallinn:#{class_date}T#{klass[:start_time]}\n"
          str += "DTEND;TZID=Europe/Tallinn:#{class_date}T#{klass[:end_time]}\n"
          str += "LOCATION:#{klass[:location]}\n"
          str += "SUMMARY:#{klass[:class_name]}\n"
          str += "DESCRIPTION:#{klass[:description]}\n"
          str += "END:VEVENT\n"
        end
      end
    end

    str = add_week_numbers(str, :ics)

    str += "END:VCALENDAR"
    @ics_data = str
    @ics_data
  end

  private

  def add_week_numbers(str, status = :ics)
    # start date (first day of week)
    date = Time.mktime(2009, 8, 31)

    44.times do |week|
      week += 1
      start = date.strftime("%Y%m%d")
      finish = (date + 1.day).strftime("%Y%m%d")
      date = date + 1.week

      str += "BEGIN:VEVENT\n"
      str += "DTSTART;VALUE=DATE:#{start}\n"
      str += "DTEND;VALUE=DATE:#{finish}\n"
      str += "SUMMARY:Week #{week}\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-TITLE:Week #{week}\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-ICON:http://urgas.eu/weeks/week#{week}.png\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-URL:http://urgas.eu/weekcredit.html\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-TYPE:text/html\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-WIDTH:205\n"
      str += "X-GOOGLE-CALENDAR-CONTENT-HEIGHT:50\n"
      str += "END:VEVENT\n\n"
    end
    str
  end

  def fix_time(time)
    time.gsub!('.', '')
    if time.length == 1 || time.length == 3
      time = '0' + time
    end
    time[2] || time << '0'
    time[3] || time << '0'
    time << '00'
    time
  end

  def to_ics_day(i)
    case i
    when 1 then 'MO'
    when 2 then 'TU'
    when 3 then 'WE'
    when 4 then 'TH'
    when 5 then 'FR'
    when 6 then 'SA'
    when 7 then 'SU'
    else
      'MO'
    end
  end
end