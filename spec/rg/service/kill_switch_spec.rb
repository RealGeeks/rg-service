require "spec_helper"

RSpec.describe RG::Service::KillSwitch do
  class DangerousService < RG::Service
    include RG::Service::KillSwitch

    class DangerousOperationPerformed < StandardError ; end

    def perform
      return RG::Service.success(message: "crisis averted!") if disabled?
      raise DangerousOperationPerformed, "Probably shouldn't have done that"
    end
  end

  context "when the service is disabled" do
    before do
      DangerousService.disable!
    end

    specify "calling .perform short-circuits" do
      result = DangerousService.perform
      expect( result ).to be_success
      expect( result.message ).to eq( "crisis averted!" )
    end
  end

  context "when the service is enabled" do
    before do
      DangerousService.enable!
    end

    specify "calling .perform does the dangerous thing" do
      expect { DangerousService.perform }.to \
        raise_error( DangerousService::DangerousOperationPerformed )
    end
  end
end
