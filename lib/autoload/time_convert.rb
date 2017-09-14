# Module containing functions used to convert the time visualization according to the time format in different languages. The time language is configured in the corresponding translation file
module TimeConvert
  
  # Subclass used to encapsulate the models of TimeConvert
  class TimeConverter
    
    # Main method that converts a time. The argument must be of type Time
    def to_string(a_time)
      return '' if !a_time.kind_of?(Time)
      case I18n.t('time.format')
        when 'english'
          return convert_in_english a_time
        when 'chinese'
          return convert_in_chinese a_time
        when 'italian'
          return convert_in_italian a_time
        else
          return a_time.to_s
      end
    end
    
    # Converts seconds into a nice time difference
    def time_difference_to_s(seconds)
      seconds = seconds.to_i
      return I18n.t('time.time_difference.seconds') if seconds < 0
      case seconds
        when (0...60)             then I18n.t('time.time_difference.seconds')
        when (60...3600)          then time_difference_single('minutes', seconds, 60)
        when (3600...86400)       then time_difference_single('hours', seconds, 3600)
        when (86400...2629800)    then time_difference_single('days', seconds, 86400)
        when (2629800...31557600) then time_difference_single('months', seconds, 2629800)
        else                           time_difference_single('years', seconds, 31557600)
      end
    end
    
    private
    
    # Gets the correct translation of a time difference
    def time_difference_single(symbol, seconds, offset)
      items = seconds / offset
      if items == 1
        I18n.t("time.time_difference.#{symbol.chop}")
      else
        I18n.t("time.time_difference.#{symbol}", :"#{symbol}" => items)
      end
    end
    
    # Convert a time according to standard english format
    def convert_in_english(a_time)
      day = a_time.day
      month = a_time.month
      year = a_time.year
      return "#{english_month(month)} #{day}#{english_day_suffix(day)}, #{year}"
    end
    
    # Suffix for the english days
    def english_day_suffix(x)
      if [1, 21, 31].include? x
        return 'st'
      elsif [2, 22].include? x
        return 'nd'
      elsif [3, 23].include? x
        return 'rd'
      else
        return 'th'
      end
    end
    
    # English translations for the month
    def english_month(x)
      case x
        when 1
          return 'January'
        when 2
          return 'February'
        when 3
          return 'March'
        when 4
          return 'April'
        when 5
          return 'May'
        when 6
          return 'June'
        when 7
          return 'July'
        when 8
          return 'August'
        when 9
          return 'September'
        when 10
          return 'October'
        when 11
          return 'November'
        when 12
          return 'December'
        else
          return ''
      end
    end
    
    # Italian translation for the month
    def italian_month(x)
      case x
        when 1
          return 'gennaio'
        when 2
          return 'febbraio'
        when 3
          return 'marzo'
        when 4
          return 'aprile'
        when 5
          return 'maggio'
        when 6
          return 'giugno'
        when 7
          return 'luglio'
        when 8
          return 'agosto'
        when 9
          return 'settembre'
        when 10
          return 'ottobre'
        when 11
          return 'novembre'
        when 12
          return 'dicembre'
        else
          return ''
      end
    end
    
    # Convert a time according to standard chinese format
    def convert_in_chinese(a_time)
      day = a_time.day
      month = a_time.month
      year = a_time.year
      return "#{english_month(month)} #{day}#{english_day_suffix(day)}, #{year}"
    end
    
    # Convert a time according to standard italian format
    def convert_in_italian(a_time)
      day = a_time.day
      month = a_time.month
      year = a_time.year
      return "#{(day)} #{italian_month(month)} #{year}"
    end
    
  end
  
  # Main method, that calls the class TimeConverter
  def self.to_string(a_time)
    x = TimeConverter.new
    x.to_string a_time
  end
  
  def self.time_difference_to_s(seconds)
    x = TimeConverter.new
    x.time_difference_to_s seconds
  end
  
end
