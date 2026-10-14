class LocalDateTimeType < ActiveRecord::Type::DateTime
  def cast(value)
    return if value.blank?
    return super unless value.is_a?(String)

    Time.zone.parse(value)
  end
end

ActiveRecord::Type.register(:local_datetime, LocalDateTimeType)
