module ActiveRecord
  module Type
    class Varbinary < Binary # :nodoc:
      # Invoca Patch - custom data type
      def type
        :varbinary
      end
    end
  end
end
