require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.column_names
    #return hash instead of a nested array
    DB[:conn].execute.results_as_hash = true
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end
end
