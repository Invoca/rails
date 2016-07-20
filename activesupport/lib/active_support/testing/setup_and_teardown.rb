require 'active_support/concern'
require 'active_support/callbacks'

module ActiveSupport
  module Testing
    module SetupAndTeardown
      extend ActiveSupport::Concern

      included do
        include ActiveSupport::Callbacks
        define_callbacks :setup, :teardown
      end

      module ClassMethods
        def setup(*args, &block)
          set_callback(:setup, :before, *args, &block)
        end

        def teardown(*args, &block)
          set_callback(:teardown, :after, *args, &block)
        end
      end

      def before_setup
        super
        run_callbacks :setup
      end

      def after_teardown
        # TODO Rails4 ORabani - walk through a test(s) to see if test-unit teardowns cause any exceptions that aren't caught, causing subsequent teardown callbacks to not run
        # this can cause transactional fixtures to not be rolled back
        run_callbacks :teardown
        super
      end
    end
  end
end
