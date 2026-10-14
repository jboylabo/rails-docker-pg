class Task < ApplicationRecord
  STATUS_LABELS = {
    "pending" => "未着手",
    "in_progress" => "進行中",
    "completed" => "完了"
  }.freeze

  PRIORITY_LABELS = {
    "low" => "低",
    "medium" => "中",
    "high" => "高"
  }.freeze

  belongs_to :user

  attribute :due_at, :local_datetime
  attribute :completed_at, :local_datetime

  enum :status, { pending: 0, in_progress: 1, completed: 2 }
  enum :priority, { low: 0, medium: 1, high: 2 }

  validates :title, presence: true

  before_validation :sync_completed_at

  def status_label
    STATUS_LABELS[status]
  end

  def priority_label
    PRIORITY_LABELS[priority]
  end

  private

  def sync_completed_at
    if completed?
      self.completed_at ||= Time.current
    else
      self.completed_at = nil
    end
  end
end
