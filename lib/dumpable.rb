# Provides a methods to convert exceptions and hashes to dumpable objects, filtering the associated objects that are not <tt>marshal_dump</tt>able
module Dumpable

  # Provides a dumpable version of NoMethodError
  class NoMethodError < ::NoMethodError
    attr_reader :message, :name, :args, :backtrace
    def initialize(e)
      @message, @name, @args, @backtrace = e.message.to_s, e.name, e.args, e.backtrace
    end

    def encode_with(coder)
      instance_variables.each do |iv|
        coder["#{iv.to_s.sub(/^@/, '')}"] = instance_variable_get(iv)
      end
    end
  end

  # converts an exception to a dumpable one (if it isn't)
  def self.exception(e)
    case e
    when ::NoMethodError
      NoMethodError.new(e)
    when ActionView::Template::Error
      case e.original_exception
      when ::NoMethodError
        template      = e.instance_variable_get(:@template)
        # @assigns can contain active record relations and things that
        # can break the YAML dumping, so we reset it
        assigns       = ''
        sub_templates = e.instance_variable_get(:@sub_templates)
        e = ActionView::Template::Error.new(template, assigns, NoMethodError.new(e.original_exception))
        e.instance_variable_set :@sub_templates, sub_templates
        e
      else e
      end
    else e
    end
  end

  # converts an hash to a dumpable version of it
  # XXX It's recursive thus prone to a +stack level too deep+ error :-/ this is not Haskell!
  #     (it shouldn't be a problem since it should be used only for "short chain" hashes)
  def self.hash(hash)
    Hash[ hash.map do |k, v|
      [ k,
        case v
        when Hash
          hash(v)
        when ActionDispatch::RemoteIp::GetIp
          v.to_s
        else
          begin
            Marshal.dump(v)
            v
          rescue TypeError
            v.inspect
          end
        end ]
    end ]
  end
end