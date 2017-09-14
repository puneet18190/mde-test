require 'media'

module Media

  # Standard class of media errors. It can take an +Hash+ of objects which will be logged with the error
  class Error < StandardError

    # Construct a new Exception object, passing a message and optionally debug data
    #
    # ### Args
    #
    # * *msg*: error message
    # * *data*: data useful for debugging
    def initialize(msg, data = {})
      @msg, @data = msg, data
    end

    # The error message plus the data informations (taken calling Media::Error#data)
    def to_s
      "#{@msg}#{data}"
    end

    private
    # Formats <tt>@data</tt> for the error message
    def data
      @data.map{ |k, v| "\n  #{k}: #{v.is_a?(String) ? v : v.inspect}" }.join ''
    end

  end
end