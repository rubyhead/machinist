require File.dirname(__FILE__) + '/spec_helper'

module MachinableSpecs
  class Post
    extend Machinist::Machinable
    attr_accessor :title, :body, :comments
  end

  class Comment
    extend Machinist::Machinable
    attr_accessor :post, :title
  end
end

RSpec.describe Machinist::Machinable do

  before(:each) do
    MachinableSpecs::Post.clear_blueprints!
  end

  it "makes an object" do
    MachinableSpecs::Post.blueprint do
      title { "First Post" }
    end
    post = MachinableSpecs::Post.make

    expect_post post, title: "First Post"
  end

  it "makes an object from a named blueprint" do
    MachinableSpecs::Post.blueprint do
      title { "First Post" }
      body  { "Woot!" }
    end

    MachinableSpecs::Post.blueprint(:extra) do
      title { "Extra!" }
    end

    post = MachinableSpecs::Post.make(:extra)

    expect_post post, title: "Extra!", body: "Woot!"
  end

  it "makes an array of objects" do
    MachinableSpecs::Post.blueprint do
      title { "First Post" }
    end

    posts = MachinableSpecs::Post.make(3)

    expect(posts)
      .to be_an Array

    expect(posts.size)
      .to eq 3

    posts.each do |post|
      expect_post post, title: "First Post"
    end
  end

  it "makes array attributes from the blueprint" do
    MachinableSpecs::Comment.blueprint { }
    MachinableSpecs::Post.blueprint do
      comments(3) { MachinableSpecs::Comment.make }
    end

    post = MachinableSpecs::Post.make
    comments = post.comments

    expect(comments)
      .to be_an Array

    expect(comments.size)
      .to eq 3

    comments.each do |comment|
      expect(comment)
        .to be_a MachinableSpecs::Comment
    end
  end

  it "fails without a blueprint" do
    expect{ MachinableSpecs::Post.make }
      .to raise_error(Machinist::NoBlueprintError) do |exception|
      expect(exception.klass)
        .to eq MachinableSpecs::Post

      expect(exception.name)
        .to eq :master
    end

    expect {MachinableSpecs::Post.make(:some_name) }
      .to raise_error(Machinist::NoBlueprintError) do |exception|
        expect(exception.klass)
          .to eq MachinableSpecs::Post

        expect(exception.name)
          .to eq :some_name
      end
  end

  it "fails when calling make! on an unsavable object" do
    MachinableSpecs::Post.blueprint { }

    expect{ MachinableSpecs::Post.make! }
      .to raise_error(Machinist::BlueprintCantSaveError) do |exception|
        expect(exception.blueprint.klass)
          .to eq MachinableSpecs::Post
      end
  end

  def expect_post(post, options={})
    expect(post)
      .to be_a MachinableSpecs::Post

    options.each do |k,v|
      expect(post.send(k))
        .to eq v
    end
  end
end
