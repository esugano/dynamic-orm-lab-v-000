require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    #creates a table with the name of the class - downcase puralized
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #return hash instead of a nested array
    DB[:conn].results_as_hash = true
    #grabs table info
    sql = "pragma table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    #creates column_names
    column_names = []
    #goes through array of hashes to just grab the column name
    table_info.each do |row|
      column_names << row["name"]
    end
    #remove any columns that = nil
    column_names.compact
  end

  self.column_names.each do |col_name|
      attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property,value|
      self.send("#{property}=",value)
    end
  end
end
