require 'json'
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should notify new post" do
    assert User::NotifyPolicy.new({}.to_json).new_post_notify?
    assert User::NotifyPolicy.new({:new_post => true}.to_json).new_post_notify?
    assert !User::NotifyPolicy.new({:new_post => false}.to_json).new_post_notify?
  end

  test "should notify new comment" do
    assert User::NotifyPolicy.new({}.to_json).new_comment_notify?
    assert User::NotifyPolicy.new({:new_comment => true}.to_json).new_comment_notify?
    assert !User::NotifyPolicy.new({:new_comment => false}.to_json).new_comment_notify?
  end
end
