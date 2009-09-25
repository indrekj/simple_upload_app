class CalendarsController < ApplicationController
  def index
  end

  def create
    @calendar = Calendar.new
    begin
      @calendar.fetch_from_ois!(params[:username], params[:password])
    rescue Calendar::InvalidLogin
      flash[:error] = 'Logimine ebaõnnestus'
      redirect_to calendars_path and return
    rescue Calendar::NoScheduleFound
      flash[:error] = 'Miskipärast me ei leidnud teie tunniplaani aadressit'
      redirect_to calendars_path and return
    rescue Exception => e
      Rails.logger.error e.inspect
      flash[:error] = 'Juhtus midagi, mida oodata ei osanud. Proovi paari tunni pärast uuesti'
      redirect_to calendars_path and return
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
end
