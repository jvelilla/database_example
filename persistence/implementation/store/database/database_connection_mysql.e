note
	description: "Object that handle a database connection for ODBC"
	date: "$Date$"
	revision: "$Revision$"

class
	DATABASE_CONNECTION_MYSQL

inherit
	DATABASE_CONNECTION
		redefine
			db_application
		end

create
	login, login_with_connection_string

feature -- Initialization

	login (a_username: STRING; a_password: STRING; a_hostname: STRING; a_database_name: STRING; a_keep_connection: BOOLEAN)

			-- Create a database handler for MySQL and set `username' to `a_username',
			-- `password' to `a_password'
			-- `database_name' to `a_database_name'
			-- `keep_connection' to `a_keep_connection'
		local
			retried: BOOLEAN
			l_database_error_handler: detachable like database_error_handler
		do
			create l_database_error_handler.make
			database_error_handler := l_database_error_handler
			create db_application.login (a_username, a_password)
			if not retried then
				db_application.set_hostname (a_hostname)
				db_application.set_data_source (a_database_name)
				db_application.set_base
				create db_control.make
				keep_connection := a_keep_connection
				if keep_connection then
					connect
				end
			else
				create db_control.make
				if is_connected then
					disconnect
				end
			end
		rescue
			if l_database_error_handler = Void then
				create l_database_error_handler.make
			end
			database_error_handler := l_database_error_handler
			exception_as_error ((create {EXCEPTION_MANAGER}).last_exception)
			retried := True
			retry
		end

	login_with_connection_string (a_string: STRING)
			-- Login with `a_connection_string' and immediately connect to database.
		local
			l_server: STRING
			l_port: STRING
			l_database: STRING
			l_user: STRING
			l_password: STRING
		do
			create database_error_handler.make
			l_server := connection_string_item (a_string, "Server", default_hostname)
			l_database := connection_string_item (a_string, "Database", default_database_name)
			l_port := connection_string_item (a_string, "Port", "3306")
			l_user := connection_string_item (a_string, "Uid", default_username)
			l_password := connection_string_item (a_string, "Pwd", default_password)

			create db_application
			db_application.set_application (l_database)
			db_application.set_hostname (l_server + ":" + l_port)
			db_application.login_and_connect (l_user, l_password)
			db_application.set_base
			create db_control.make
			keep_connection := is_keep_connection
		end

	connection_string_item (a_connection_string: STRING; k: STRING; dft: STRING): STRING
		local
			i,j: INTEGER
		do
			i := a_connection_string.substring_index (k + "=", 1)
			if i = 0 then
				i := a_connection_string.substring_index (k.as_lower + "=", 1)
			end
			if i > 0 then
				i := i + k.count + 1
				j := a_connection_string.index_of (';', i)
				if j = 0 then
					j := a_connection_string.count + 1
				end
				Result := a_connection_string.substring (i, j - 1)
			else
				Result := dft
			end
		end

	login_with_schema (a_schema: STRING; a_username: STRING; a_password: STRING)
			-- Login with `a_connection_string'and immediately connect to database.
		do
			create database_error_handler.make
			create db_application
			db_application.set_application (a_schema)
			db_application.login_and_connect (a_username, a_password)
			db_application.set_base
			create db_control.make
			keep_connection := is_keep_connection
		end
feature -- Databse Connection

	db_application: DATABASE_APPL [MYSQL]
			-- Database application.


	default_hostname: STRING = "localhost"

	default_database_name: STRING = "mysql"

	default_username: STRING = "root"

	default_password: STRING = ""

end
