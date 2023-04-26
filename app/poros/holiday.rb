class Holiday
  attr_reader :date,
              :name

  def initialize(attributes)
    @date = attributes[:date]
    @name = attributes[:localName]
  end
end
