require "spec_helper"

RSpec.describe RG::Service::Result do
  def new_result(**kwargs)
    described_class.new(**kwargs)
  end

  it "can have a :status of :success" do
    r = new_result(status: :success)
    expect( r.status ).to eq( :success )
  end

  it "can have a :status of :failure" do
    r = new_result(status: :failure)
    expect( r.status ).to eq( :failure )
  end

  it "cannot have any other :status" do
    expect {
      new_result(status: :replete)
    }.to raise_error( ArgumentError )
  end
end
