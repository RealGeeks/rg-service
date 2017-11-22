require "spec_helper"

RSpec.describe RG::Service::Result do
  def new_result(**kwargs)
    described_class.new(**kwargs)
  end

  describe ":status" do
    it "can be :success" do
      r = new_result(status: :success)
      expect( r.status ).to eq( :success )

      expect( r ).to     be_success
      expect( r ).to_not be_failure
    end

    it "can be :failure" do
      r = new_result(status: :failure)
      expect( r.status ).to eq( :failure )

      expect( r ).to_not be_success
      expect( r ).to     be_failure
    end

    it "cannot be anything else" do
      expect {
        new_result(status: :replete)
      }.to raise_error( ArgumentError )
    end
  end

  describe "other arguments" do
    #TODO: see if there's an RSpec-approved way to add synonyms for #specify
    class << self
      alias :they :specify
    end

    they "include :message" do
      r = new_result(status: :success, message: "yey")
      expect( r.message ).to eq( "yey" )
    end

    they "include :object" do
      foo = Object.new
      r = new_result(status: :success, object: foo)
      expect( r.object ).to be( foo ) # #be is object identity comparison
    end

    they "include :data" do
      data = { foo: "spam", bar: "eggs" }
      r = new_result(status: :success, data: data)
      expect( r.data.slice(:foo, :bar) ).to eq( data )
    end

    they "include :errors" do
      errors = [ "nope", "nope nope nope" ]
      r = new_result(status: :success, errors: errors)
      expect( r.errors ).to eq( errors )
    end
  end

  describe "special handling of the :data attribute" do
    it "includes whatever was given to it already" do
      data = { foo: "spam", bar: "eggs" }
      r = new_result(status: :success, data: data)
      expect( r.data.slice(:foo, :bar) ).to eq( data )
    end

    it "includes the (non-nil) :object argument under its :object key" do
      foo = Object.new
      r = new_result(status: :success, object: foo)
      expect( r.data[:object] ).to be( foo )
    end

    it "includes a human-friendly status under its :status key" do
      r = new_result(status: :success)
      expect( r.data[:status] ).to eq( "Success" )
    end
  end

  specify "#description shows the friendly status and the mssage, if there is a message" do
    r = new_result(status: :success, message: "omg congrats")
    expect( r.description ).to eq( "Success:\nomg congrats" )
  end

  describe "convenience constructors for results" do
    specify ".success returns a successful result" do
      r = RG::Service.success
      expect( r ).to be_success
    end

    specify ".disabled returns a successful result (we believe in optimism here at Real Geeks, LLC)" do
      r = RG::Service.disabled
      expect( r ).to be_success
    end

    specify ".nothingtodohere returns a successful result, including an optional message arg" do
      r = RG::Service.nothingtodohere("well, that was easy")
      expect( r ).to be_success
      expect( r.message ).to eq( "well, that was easy" )
    end

    specify ".failure returns a failure" do
      r = RG::Service.failure
      expect( r ).to be_failure
    end

    describe ".result_from_exception" do
      let(:err_msg) { "Nope. No way, nohow." }
      let(:err) {
        begin
          raise ArgumentError, err_msg
        rescue => e
          break e # break will return from the begin/end block
        end
      }
      let(:r) { RG::Service.result_from_exception(err) }

      it "wraps an exception, putting it in result.data[:exception]" do
        expect( r.data[:exception] ).to be( err )
      end

      it "puts the exception class name, message, and backtrace in result.data[:error]" do
        err_data = r.data[:error]
        aggregate_failures do
          expect( err_data[:class] ).to eq( "ArgumentError" )
          expect( err_data[:msg] ).to eq( "Nope. No way, nohow." )
          expect( err_data[:class] ).to eq( "ArgumentError" )
        end
      end

      it "formats the error message and puts it in result.message" do
        aggregate_failures do
          expect( r.message ).to match( /Exception:\s+ArgumentError/ )
          expect( r.message ).to match( /Message:\s+#{err_msg}/ )
          expect( r.message ).to match( /Backtrace:\n#{__FILE__}/ ) # current file should be at top of backtrace... until Ruby reverses backtrace :D
        end
      end

    end
  end
end
