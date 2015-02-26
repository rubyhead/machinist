require File.dirname(__FILE__) + '/spec_helper'
require 'ostruct'

RSpec.describe Machinist::Blueprint do

  it "makes an object of the given class" do
    blueprint = Machinist::Blueprint.new(OpenStruct) { }.make
    expect(blueprint)
      .to be_an OpenStruct
  end

  it "constructs an attribute from the blueprint" do
    name = Machinist::Blueprint.new(OpenStruct) do
            name { "Fred" }
          end.make.name

    expect(name)
      .to eq "Fred"
  end

  it "constructs an array for an attribute in the blueprint" do
    blueprint = Machinist::Blueprint.new(OpenStruct) do
      things(3) { Object.new }
    end
    things = blueprint.make.things

    expect(things)
      .to be_an Array

    expect(things.size)
      .to eq 3

    things.each do |thing| 
      expect(thing)
        .to be_an Object
    end

    expect(things.uniq)
      .to eq things
  end

  it "allows passing in attributes to override the blueprint" do
    block_called = false
    blueprint = Machinist::Blueprint.new(OpenStruct) do
      name { block_called = true; "Fred" }
    end

    bill = blueprint.make(:name => "Bill").name

    expect(bill)
      .to eq "Bill"

    expect(block_called)
      .to eq false
  end

  it "provides a serial number within the blueprint" do
    blueprint = Machinist::Blueprint.new(OpenStruct) do
      name { "Fred #{sn}" }
    end

    expect(blueprint.make.name)
      .to eq "Fred 0001"

    expect(blueprint.make.name)
      .to eq "Fred 0002"
  end

  it "provides access to the object being constructed within the blueprint" do
    body = Machinist::Blueprint.new(OpenStruct) do
             title { "Test" }
             body  { object.title }
           end.make.body

    expect(body)
      .to eq "Test"
  end

  it "allows attribute names to be strings" do
    name = Machinist::Blueprint.new(OpenStruct) do
      name { "Fred" }
    end.make("name" => "Bill").name
    
    expect(name)
      .to eq "Bill"
  end

  # These are normally a problem because of name clashes with the standard (but
  # deprecated) Ruby methods. This test makes sure we work around this.
  it "works with type and id attributes" do
    klass = Class.new do
      attr_accessor :id, :type
    end
    blueprint = Machinist::Blueprint.new(klass) do
      id   { "custom id" }
      type { "custom type" }
    end
    object = blueprint.make

    expect(object.id)
      .to eq "custom id"

    expect(object.type)
      .to eq "custom type"
  end

end
