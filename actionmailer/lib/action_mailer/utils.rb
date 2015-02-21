module ActionMailer
  module Utils #:nodoc:

    # imported from http://rubydoc.info/docs/rails/2.3.8/TMail/Unquoter#unquote_and_convert_to-class_method
    def self.unquote_and_convert_to(text, to_charset, from_charset = "iso-8859-1", preserve_underscores=false)
      return "" if text.nil?
      text.gsub!(/\?=(\s*)=\?/, '?==?') # Remove whitespaces between 'encoded-word's
      text.gsub(/(.*?)(?:(?:=\?(.*?)\?(.)\?(.*?)\?=)|$)/) do
        before = $1
        from_charset = $2
        quoting_method = $3
        text = $4

        before = convert_to(before, to_charset, from_charset) if before.length > 0
        before + case quoting_method
                   when "q", "Q" then
                     unquote_quoted_printable_and_convert_to(text, to_charset, from_charset, preserve_underscores)
                   when "b", "B" then
                     unquote_base64_and_convert_to(text, to_charset, from_charset)
                   when nil then
                     # will be nil at the end of the string, due to the nature of
                     # the regex used.
                     ""
                   else
                     raise "unknown quoting method #{quoting_method.inspect}"
                 end
      end
    end

    # imported from http://rubydoc.info/docs/rails/2.3.8/TMail/Unquoter#unquote_and_convert_to-class_method
    def self.unquote_base64_and_convert_to(text, to, from)
      convert_to(Base64.decode(text), to, from)
    end

    # imported from http://rubydoc.info/docs/rails/2.3.8/TMail/Unquoter#unquote_and_convert_to-class_method
    def self.unquote_quoted_printable_and_convert_to(text, to, from, preserve_underscores=false)
      text = text.gsub(/_/, " ") unless preserve_underscores
      text = text.gsub(/\r\n|\r/, "\n") # normalize newlines
      convert_to(text.unpack("M*").first, to, from)
    end

    # imported from http://rubydoc.info/docs/rails/2.3.8/TMail/Unquoter#unquote_and_convert_to-class_method
    def self.convert_to(text, to, from)
      return text unless to && from
      text ? Iconv.iconv(to, from, text).first : ""
    rescue Iconv::IllegalSequence, Iconv::InvalidEncoding, Errno::EINVAL
      # the 'from' parameter specifies a charset other than what the text
      # actually is...not much we can do in this case but just return the
      # unconverted text.
      #
      # Ditto if either parameter represents an unknown charset, like
      # X-UNKNOWN.
      text
    end
  end
end
