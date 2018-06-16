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

  #iterate over the options hash to send and create
  #the hash key (interpolate the column name) and its value
  def initialize(options={})
    options.each do |property,value|
      self.send("#{property}=",value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    #removes id from the array returned from the method above
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def self.find_by(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

end
