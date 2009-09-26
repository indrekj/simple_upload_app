class CalendarsController < ApplicationController
  def index
  end

  def create
    @calendar = Calendar.new
    
    if !params[:ois_url].blank?
      return if !fetch_from_ois_using_url(params[:ois_url])
    else
      return if !fetch_from_ois_using_pw(params[:username], params[:password])
    end

    begin
      @calendar.ois_data_to_hash!
    rescue Exception => e
      Rails.logger.error e.inspect
      flash[:error] = 'Juhtus midagi süsteemi formaati konventeerimisel. Proovi paari tunni pärast uuesti'
      redirect_to calendars_path and return
    end

    begin
      data = @calendar.to_ics!
    rescue Exception => e
      Rails.logger.error e.inspect
      flash[:error] = 'Juhtus midagi ics faili tegemisel. Proovi paari tunni pärast uuesti'
      redirect_to calendars_path and return
    end

    send_data(data, :filename => 'calendar.ics', :disposition => 'attachment')
  end

  private

  def fetch_from_ois_using_pw(username, password)
    begin
      @calendar.fetch_from_ois_using_pw!(username, password)
    rescue Calendar::InvalidLogin
      flash[:error] = 'Logimine ebaõnnestus'
      redirect_to calendars_path and return false
    rescue Calendar::NoScheduleFound
      flash[:error] = 'Miskipärast me ei leidnud teie tunniplaani aadressit'
      redirect_to calendars_path and return false
    rescue Exception => e
      Rails.logger.error e.inspect
      flash[:error] = 'Juhtus midagi, mida oodata ei osanud. Proovi paari tunni pärast uuesti'
      redirect_to calendars_path and return false
    end
  end

  def fetch_from_ois_using_url(ois_url)
    begin
      @calendar.fetch_from_ois_using_url!(ois_url)
    rescue Calendar::NoScheduleFound => e
      flash[:error] = 'Juhtus midagi. Äkki sisestasid vale aadressi?'
      redirect_to calendars_path and return false
    rescue Exception => e
      Rails.logger.error e.inspect
      flash[:error] = 'Juhtus midagi, mida oodata ei osanud. Proovi paari tunni pärast uuesti'
      redirect_to calendars_path and return false
    end
  end
end
