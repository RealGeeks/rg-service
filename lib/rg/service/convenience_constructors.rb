module RG
class Service

  module ConvenienceConstructors
    def success(message: nil, object: nil, data: {}, errors: [])
      ::RG::Service::Result.new( status: :success, message: message, object: object, data: data, errors: errors )
    end

    def disabled
      RG::Service::Result.new( status: :success )
    end

    def nothingtodohere(message=nil)
      RG::Service::Result.new( status: :success, message: message )
    end

    def failure(message: nil, object: nil, data: {}, errors: [])
      RG::Service::Result.new( status: :failure, message: message, object: object, data: data, errors: errors )
    end

    def result_from_exception(e)
      message = format_exception(e)
      data = {
        error: {
          class:     e.class.name,
          msg:       e.message,
          backtrace: e.backtrace,
        },
        exception: e,
      }
      RG::Service::Result.new( status: :failure, message: message, data: data )
    end
  end

end
end
