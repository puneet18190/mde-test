require 'pathname'

WINDOWS = Gem.win_platform?

# +Rails+ patches
module Rails
  # +Rails.public_pathname+ returns Rails public path as Pathname instance
  def self.public_pathname
    @public_pathname ||= Pathname.new public_path
  end
end

class ActiveRecord::Base
  # Get the first base error of a record if any; otherwise returns +""+
  def get_base_error
    errors.messages[:base].try(:first) || ''
  end
end

# PostgreSQL enums support (taken from https://coderwall.com/p/azi3ka)
# Should be fixed in Rails >= 4.2 (https://github.com/rails/rails/pull/13244)
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLAdapter
      module OID
        class Enum < Type
          def type_cast(value)
            value.to_s
          end
        end
      end

      def enum_types
        @enum_types ||= begin
          result = execute 'SELECT DISTINCT t.oid, t.typname FROM pg_type t JOIN pg_enum e ON t.oid = e.enumtypid', 'SCHEMA'
          result.map { |v| [ v['oid'], v['typname'] ] }.to_h
        end
      end

      private

      def initialize_type_map_with_enum_types_support
        initialize_type_map_without_enum_types_support

        # populate enum types
        enum_types.reject { |_, name| OID.registered_type? name }.each do |oid, name|
          OID::TYPE_MAP[oid.to_i] = OID::Enum.new
        end
      end
      alias_method_chain :initialize_type_map, :enum_types_support
    end

    class PostgreSQLColumn
      private

      def simplified_type_with_enum_types(field_type)
        case field_type
        when *Base.connection.enum_types.values
          field_type.to_sym
        else
          simplified_type_without_enum_types(field_type)
        end
      end
      alias_method_chain :simplified_type, :enum_types
    end
  end
end

module ActiveRecord
  class Base
    def self.implicit_join_references_warning_disabled
      previous_value = disable_implicit_join_references

      begin
        self.disable_implicit_join_references = true
        return yield
      ensure
        self.disable_implicit_join_references = previous_value
      end
    end
  end
end
