class Padding
  class << self
    ##
    # This adds 0 to the beginning of the number if it's a single digit, or just returns the number as a string if it isn't a single digit
    # e.g. 7 => "07", 11 => "11"
    def pad_single_digit(number)
      number.to_s.length == 1 ? "0#{number}" : number.to_s
    end
  end
end