# Module used to extract the object associated to a standard association
module Valid
  
  # Class used to encapsulate the methods of Valid
  class Validness
    
    # Main method of the class. It extracts from +object+ the record corresponding to +column+, using +class+ as associated class. If the field is not valid, or the associated object is not present, it returns nil. If the column is +id+, it returns nil if +object+ is new record and the object itself otherwise.
    def get(object, column, my_class)
      column = column.to_s
      if column == 'id'
        return object.new_record? ? nil : object.class.where(:id => object.id).first
      else
        my_class = get_class_from_column_name column if my_class.nil?
        original_column = object.read_attribute_before_type_cast(column)
        return (original_column.class == String && (original_column =~ /\A\d+\Z/) == 0 || original_column.kind_of?(Integer)) ? my_class.where(:id => original_column).first : nil
      end
    end
    
    private
    
    # Submethod of Validness#get
    def get_class_from_column_name(x)
      resp = ''
      x.split('_').each do |my_split|
        if my_split != 'id'
          resp = "#{resp}#{my_split.capitalize}"
        end
      end
      return resp.constantize
    end
    
  end
  
  # White list of allowed characters in email
  def self.char_for_email?(i)
    [
      33, 35, 36, 37, 38, 39, 42, 43, 45, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
      61, 63, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82,
      83, 84, 85, 86, 87, 88, 89, 90, 92, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103,
      104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119,
      120, 121, 122, 123, 124, 125, 126
    ].include?(i)
  end
  
  # Method that validates the format of an e-mail address (used in User and MailingListAddress)
  def self.email?(email)
    index = 0
    at = false
    after_point = false
    count_after_point = 0
    after_at = false
    point_after_at = false
    email.each_byte do |i|
      if !Valid.char_for_email?(i)
        return false if index == 0
        if i == 64
          return false if at || after_point
          at = true
          after_at = true
          after_point = false
        elsif i == 46
          return false if after_at || after_point
          point_after_at = at
          after_point = true
          count_after_point = 0
        else
          return false
        end
      else
        after_at = false
        after_point = false
        count_after_point += 1
      end
      index += 1
    end
    return (point_after_at && count_after_point > 1)
  end
  
  # Method that uses Validness to validate and extract the object associated to a field
  def self.get_association(object, column, my_class=nil)
    x = Validness.new
    x.get object, column, my_class
  end
  
end
