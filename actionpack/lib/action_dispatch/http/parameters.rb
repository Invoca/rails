require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/deprecation'

module ActionDispatch
  module Http
    module Parameters
      # Invoca Patch - strip string parameters patch, methods implemented in ActionController::Base
      attr_accessor :do_not_strip_string_parameters

      PARAMETERS_KEY = 'action_dispatch.request.path_parameters'

      # Returns both GET and POST \parameters in a single hash.
      def parameters
        @env["action_dispatch.request.parameters"] ||= begin
          @do_not_strip_string_parameters ||= [] # Invoca Patch
          params = begin
            request_parameters.merge(query_parameters)
          rescue EOFError
            query_parameters.dup
          end
          params.merge!(path_parameters)
          strip_string_params!(params) # Invoca Patch
          params
        end
      end
      alias :params :parameters

      def path_parameters=(parameters) #:nodoc:
        @env.delete('action_dispatch.request.parameters')
        @env[PARAMETERS_KEY] = parameters
      end

      def symbolized_path_parameters
        ActiveSupport::Deprecation.warn(
          '`symbolized_path_parameters` is deprecated. Please use `path_parameters`.'
        )
        path_parameters
      end

      # Returns a hash with the \parameters used to form the \path of the request.
      # Returned hash keys are strings:
      #
      #   {'action' => 'my_action', 'controller' => 'my_controller'}
      def path_parameters
        @env[PARAMETERS_KEY] ||= {}
      end

    private

      # Invoca Patch
      # Recursively walks a Hash/Array/String hierarchy and strips any Strings found.
      # Strings are stripped with strip! unless they are frozen in which casea a copy is made.
      # Returns the original value or if copied, the copied value.
      def strip_string_params!(value_to_strip)
        case value_to_strip
        when String
          if value_to_strip.frozen?
            value_to_strip = value_to_strip.strip
          else
            value_to_strip.strip!
          end
        when Hash
          value_to_strip.each do |key, value|
            if !key.respond_to?(:to_sym) || !do_not_strip_string_parameters || !do_not_strip_string_parameters.include?(key.to_sym)
              value_to_strip[key] = strip_string_params!(value)
            end
          end
        when Array
          value_to_strip.each.with_index { |value, index| value_to_strip[index] = strip_string_params!(value) }
        end
        value_to_strip
      end

      # Convert nested Hash to HashWithIndifferentAccess.
      #
      def normalize_encode_params(params)
        case params
        when Hash
          if params.has_key?(:tempfile)
            UploadedFile.new(params)
          else
            params.each_with_object({}) do |(key, val), new_hash|
              new_hash[key] = if val.is_a?(Array)
                val.map! { |el| normalize_encode_params(el) }
              else
                normalize_encode_params(val)
              end
            end.with_indifferent_access
          end
        else
          params
        end
      end
    end
  end
end
