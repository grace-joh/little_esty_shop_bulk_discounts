# require 'HTTParty'
require 'JSON'

class HolidayService
  def holidays
    get_url("https://date.nager.at/api/v3/PublicHolidays/#{Date.today.year}/US")
  end

  def get_url(url)
    response = HTTParty.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end
