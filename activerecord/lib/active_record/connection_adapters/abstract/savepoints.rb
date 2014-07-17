module ActiveRecord
  module ConnectionAdapters
    module Savepoints #:nodoc:
      def supports_savepoints?
        true
      end

      def create_savepoint(name = current_savepoint_name)
        execute("SAVEPOINT #{name}")
      end

      def rollback_to_savepoint(name = current_savepoint_name)
        execute("ROLLBACK TO SAVEPOINT #{name}")
      rescue => ex
        STDERR.puts("ROLLBACK TO SAVEPOINT failed with #{ex}\n#{caller.join("\n")}\n+++++++++++")
      end

      def release_savepoint(name = current_savepoint_name)
        execute("RELEASE SAVEPOINT #{name}")
      rescue => ex
        STDERR.puts("RELEASE SAVEPOINT failed with #{ex}\n#{caller.join("\n")}\n+++++++++++")
      end
    end
  end
end
