class HolidayFacade
  def upcoming_holidays(number)
    find_next_holidays(holidays)[0..(number - 1)]
  end

  def find_next_holidays(holiday_list)
    until holiday_list.first.date > Date.today.strftime('%Y-%m-%d')
      holiday_list.push(holiday_list.shift)
      find_next_holidays(holiday_list)
    end
    holiday_list
  end

  def holidays
    service.holidays.map do |holiday_data|
      Holiday.new(holiday_data)
    end
  end

  def service
    HolidayService.new
  end
end
