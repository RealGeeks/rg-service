module RG
class Service

  module ExceptionFormatting
    EXCEPTION_TEMPLATE = <<-EOF
Exception:  %<err_class>s
Message:    %<err_msg>s

Backtrace:
%<err_backtrace>s"
    EOF

    def format_exception(e, originating_file: nil)
      EXCEPTION_TEMPLATE % {
        err_class:     e.class.name,
        err_msg:       e.message,
        err_backtrace: format_backtrace( e, originating_file: originating_file ),
      }
    end

    def format_backtrace(e, originating_file: nil)
      if originating_file.present?
        truncate_below = e.backtrace.index {|line|
          line.include?(originating_file)
        }
        range = (0..truncate_below)
        e.backtrace[range].join("\n")
      else
        e.backtrace.join("\n")
      end
    end
  end

end
end
