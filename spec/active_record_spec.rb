require File.dirname(__FILE__) + '/spec_helper'
require 'support/active_record_environment'

# TODO:
# The updates to this spec is to bring the specs
# up to current version of RSpec.  Requires actual
# work and clean up.

RSpec.shared_examples "saved object" do
  let(:post) { Post.make! }

  it "is a Post" do
    expect(post)
      .to be_a Post
  end

  it "is not a new record" do
    expect(post)
      .to_not be_new_record
  end
end

RSpec.describe Machinist::ActiveRecord do
  include ActiveRecordEnvironment

  before(:each) do
    empty_database!
  end

  context "make" do
    subject(:post) { Post.make }

    before { Post.blueprint { } }

    it "is a Post" do
      expect(post)
        .to be_a Post
    end

    it "is a new record" do
      expect(post)
        .to be_new_record
    end
  end

  context "make!" do
    it_behaves_like "saved object" do
      before { Post.blueprint { } }
    end

    it "raises an exception for an invalid object" do
      User.blueprint { }

      expect{ User.make!(:username => "") }
        .to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context "associations support" do
    context "handles belongs_to associations" do
      subject(:post) { Post.make! }

      before do
        User.blueprint do
          username { "user_#{sn}" }
        end
        Post.blueprint do
          author
        end
      end

      it_behaves_like "saved object"

      it "has an author that is a User" do
        author = post.author

        expect(author)
          .to be_a User
        expect(author)
          .to_not be_new_record
      end
    end

    context "handles has_many associates" do
      subject(:post) { Post.make! }

      before do
        Post.blueprint do
          comments(3)
        end
        Comment.blueprint { }
      end

      it_behaves_like "saved object"

      it "has three comments" do
        post_comments = post.comments

        expect(post_comments.count)
          .to eq 3

        post_comments.each do |comment|
          expect(comment)
            .to be_a Comment
          expect(comment)
            .to_not be_new_record
        end
      end
    end

    # TODO: clean up
    it "handles habtm associations" do
      Post.blueprint do
        tags(3)
      end
      Tag.blueprint do
        name { "tag_#{sn}" }
      end

      post = Post.make!
      tags = post.tags

      expect(tags.size)
        .to eq 3

      tags.each do |tag|
        expect(tag)
          .to be_a Tag
        expect(tag)
          .to_not be_new_record
      end
    end

    # TODO: clean up
    it "handles overriding associations" do
      User.blueprint do
        username { "user_#{sn}" }
      end
      Post.blueprint do
        author { User.make(:username => "post_author_#{sn}") }
      end

      post = Post.make!
      author = post.author

      expect(post)
        .to_not be_new_record

      expect(author)
        .to be_a User

      expect(author)
        .to_not be_new_record

      expect(author.username)
        .to match /^post_author_\d+$/
    end
  end

  context "error handling" do
    it "raises an exception for an attribute with no value" do
      User.blueprint { username }
      expect{ User.make }
        .to raise_error(ArgumentError)
    end
  end

end
