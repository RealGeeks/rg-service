require "spec_helper"
require 'active_support/core_ext/integer/time'

RSpec.describe RG::Clock do
  Clock = described_class
  PRECISION = described_class::SUBSECOND_PRECISION_DIGITS
  DELTA = 10 ** PRECISION

  let(:time) { Time.now }
  let(:clock) { described_class.new(time) }

  it "has a time" do
    expect( clock.to_time ).to eq( time )
  end

  specify "two clocks that are very close together return the same time" do
    delta = 1.to_f / 10 ** (PRECISION + 1)
    clock2 = described_class.new( clock.to_time + delta )

    expect( clock2.to_time ).to eq( clock.to_time )
    expect( clock.to_time  ).to eq( clock2.to_time )
  end

  it "has a convenience constructor that reads better than 'Clock.new(5.seconds.ago)" do
    recent_time = time - 5.seconds
    recently = Clock.as_of( recent_time )
    expect( recently.to_time ).to be_within( DELTA ).of( recent_time )
    expect( recently.to_time ).to eq( recent_time )
  end

  it "has a convenience constructor for the current time" do
    now = Clock.for_current_time
    expect( now.to_time ).to be_within( 0.01.seconds ).of( Time.now )
  end

  describe "other constructors" do
    specify "#plus gives you a later time" do
      later = clock.plus( 5.seconds )
      expect( later.to_time ).to eq( time + 5.seconds )
    end

    specify "#minus gives you a later time" do
      later = clock.minus( 5.seconds )
      expect( later.to_time ).to eq( time - 5.seconds )
    end
  end
end

