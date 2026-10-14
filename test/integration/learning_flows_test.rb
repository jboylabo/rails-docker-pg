require "test_helper"

class LearningFlowsTest < ActionDispatch::IntegrationTest
  test "registers a user" do
    assert_difference "User.count", 1 do
      post user_registration_path, params: {
        user: {
          email: "flow@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "logs in an existing user" do
    post user_session_path, params: {
      user: { email: users(:one).email, password: "password123" }
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_match "ログアウト", response.body
  end

  test "rejects guests from tasks" do
    get tasks_path

    assert_redirected_to new_user_session_path
  end

  test "creates lists updates and deletes only the current user's tasks" do
    sign_in users(:one)

    assert_difference "Task.count", 1 do
      post tasks_path, params: {
        task: {
          title: "レポート",
          description: "下書き",
          status: "pending",
          priority: "high",
          due_at: "2026-10-14T18:00"
        }
      }
    end

    task = users(:one).tasks.order(:id).last
    assert_redirected_to task_path(task)
    assert_equal Time.utc(2026, 10, 14, 9, 0), task.due_at.utc

    get tasks_path
    assert_response :success
    assert_match "レポート", response.body
    assert_no_match "秘密のタスク", response.body

    get edit_task_path(task)
    assert_match "2026-10-14T18:00", response.body

    patch task_path(task), params: { task: { title: "レポート改訂", status: "in_progress" } }
    assert_redirected_to task_path(task)
    assert_equal "レポート改訂", task.reload.title
    assert task.in_progress?
    assert_nil task.completed_at

    assert_difference "Task.count", -1 do
      delete task_path(task)
    end
    assert_redirected_to tasks_path
  end

  test "hides another user's task" do
    sign_in users(:one)
    get task_path(tasks(:two))
    assert_response :not_found

    sign_in users(:one)
    patch task_path(tasks(:two)), params: { task: { title: "書き換え" } }
    assert_response :not_found
    assert_equal "秘密のタスク", tasks(:two).reload.title

    sign_in users(:one)
    delete task_path(tasks(:two))
    assert_response :not_found
    assert Task.exists?(tasks(:two).id)
  end
end
