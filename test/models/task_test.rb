require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires a title" do
    task = users(:one).tasks.new(title: "")

    assert_not task.valid?
    assert_includes task.errors[:title], "を入力してください"
  end

  test "stores a Tokyo local datetime as UTC" do
    task = users(:one).tasks.create!(title: "期限確認", due_at: "2026-10-14T18:00")

    assert_equal Time.utc(2026, 10, 14, 9, 0), task.reload.due_at.utc
    assert_equal "2026-10-14 18:00", task.due_at.in_time_zone("Tokyo").strftime("%Y-%m-%d %H:%M")
  end

  test "uses timestamptz for task and user datetime columns" do
    task_columns = %w[due_at completed_at created_at updated_at]
    user_columns = %w[reset_password_sent_at remember_created_at created_at updated_at]

    task_columns.each do |name|
      assert_equal "timestamp with time zone", Task.columns_hash.fetch(name).sql_type, name
    end
    user_columns.each do |name|
      assert_equal "timestamp with time zone", User.columns_hash.fetch(name).sql_type, name
    end
  end
end
