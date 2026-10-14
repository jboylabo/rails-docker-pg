class ConvertDatetimesToTimestamptz < ActiveRecord::Migration[8.0]
  def up
    {
      "users" => %w[reset_password_sent_at remember_created_at created_at updated_at],
      "tasks" => %w[due_at completed_at created_at updated_at]
    }.each do |table, columns|
      columns.each do |column|
        execute <<~SQL.squish
          ALTER TABLE #{table}
          ALTER COLUMN #{column}
          TYPE timestamptz
          USING #{column} AT TIME ZONE 'UTC'
        SQL
      end
    end
  end

  def down
    {
      "users" => %w[reset_password_sent_at remember_created_at created_at updated_at],
      "tasks" => %w[due_at completed_at created_at updated_at]
    }.each do |table, columns|
      columns.each do |column|
        execute <<~SQL.squish
          ALTER TABLE #{table}
          ALTER COLUMN #{column}
          TYPE timestamp
          USING #{column} AT TIME ZONE 'UTC'
        SQL
      end
    end
  end
end
