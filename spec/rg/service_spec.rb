require "spec_helper"

RSpec.describe RG::Service do
  it "has a version number" do
    expect(Rg::Service::VERSION).not_to be nil
  end

  class SuccessfulService < RG::Service
    def perform
      return RG::Service::Result.new(status: :success)
    end
  end

  specify "calling .perform on a service class returns a Result instance" do
    result = SuccessfulService.perform
    expect( result ).to be_kind_of( RG::Service::Result )
    expect( result ).to be_success
  end

  #TOOD: allow callbacks to be specified for service lifecycle events

  #TODO: specify KillSwitch behavior when I have more brain

end
