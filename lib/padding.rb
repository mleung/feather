class Padding
  class << self
    def pad_single_digit(number)
      number = "0#{number}" if number.to_s.length == 1
      number
    end
  end
end