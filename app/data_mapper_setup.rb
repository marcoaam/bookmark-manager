env = ENV["RACK_ENV"] || "development"
DataMapper.setup(:default, "postgres://localhost/book_manager_#{env}")
DataMapper.finalize
# DataMapper.auto_upgrade!