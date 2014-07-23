module ActionController
  class Failsafe
    def log_failsafe_exception( exception )
      ExceptionHandling.log_error( exception, "FAILSAFE Status: 500 Internal Server Error" )
      Rails.logger.flush if Rails.logger.respond_to?(:flush)
    end
  end
end