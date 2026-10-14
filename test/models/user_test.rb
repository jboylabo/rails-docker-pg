require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "registers a user with email and password" do
    user = User.new(email: "new-user@example.com", password: "password123", password_confirmation: "password123")

    assert user.save
    assert user.persisted?
  end
end
