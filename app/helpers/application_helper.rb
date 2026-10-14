module ApplicationHelper
  def datetime_local_value(time)
    return if time.blank?

    time.in_time_zone.strftime("%Y-%m-%dT%H:%M")
  end

  def format_timestamp(time)
    return "未設定" if time.blank?

    l(time.in_time_zone, format: :short)
  end
end
