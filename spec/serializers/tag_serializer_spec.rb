# frozen_string_literal: true

require 'rails_helper'

describe REST::TagSerializer do
  let(:current_user) { nil }
  let(:tag) { Fabricate(:tag) }

  def serialize_via_ams
    REST::TagSerializer.new(tag, scope: current_user, scope_name: :current_user).to_json
  end

  def serialize_via_panko
    REST::TagSerializerPanko.new(scope: { current_user: current_user }).serialize(tag).to_json
  end

  def serialize_via_panko_oj
    REST::TagSerializerPanko.new(scope: { current_user: current_user }).serialize_to_json(tag)
  end

  it "produces equal output" do
    Benchmark.bmbm do |x|
      x.report("ams:") { 25.times do serialize_via_ams; end }
      x.report("panko:") { 25.times do serialize_via_panko; end }
      x.report("panko (oj):") { 25.times do serialize_via_panko_oj; end }
    end

    ams_json_string = serialize_via_ams
    panko_json_string = serialize_via_panko
    panko_oj_json_string = serialize_via_panko_oj

    ams_json = JSON.parse(ams_json_string)
    panko_json = JSON.parse(panko_json_string)
    panko_oj_json = JSON.parse(panko_oj_json_string)

    expect(ams_json).to eq panko_json
    expect(ams_json).to eq panko_oj_json
  end
end
