note
	description: "{
			CREATE DATABASE todo;
			CREATE TABLE tasks (
  				  id INT PRIMARY KEY AUTO_INCREMENT,
    			  title VARCHAR(255) NOT NULL,
  				  completed BOOLEAN
			);
	}"
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Connection string", "src=https://en.wikipedia.org/wiki/Connection_string", "protocol=uri"
	EIS: "name=MySQL Sarabase", "src=https://www.mysqltutorial.org/mysql-boolean/", "protocol=uri"

class
	APPLICATION

inherit

	SHARED_ERROR

create
	make

feature {NONE} -- Initialization


	make
			-- Run application.
		do
				-- The first step: connect to the database.
			login_and_connect

				-- Set the database handler with the connection.
			set_database_handler

				-- Set the error handler
			create error_handler.make

				-- Delete all ask
			db_handler.set_query (delete_tasks)
			db_handler.execute_change

				-- Reset task autoincrement sequence
			db_handler.set_query (reset_task_sequence)
			db_handler.execute_change

				-- Create
			db_handler.set_query (insert_task (task_1))
			db_handler.execute_change
			if attached db_handler.db_change as l_change and then l_change.is_affected_row_count_supported then
				check added_country: l_change.affected_row_count = 1 end
			end

			db_handler.set_query (insert_task (task_2))
			db_handler.execute_change
			if attached db_handler.db_change as l_change and then l_change.is_affected_row_count_supported then
				check added_country: l_change.affected_row_count = 1 end
			end

				-- List database tasks
			across task_list as ic loop
				print ("%N")
				print (ic.item.debug_output)
			end

				-- Search task id 1 adn update it.
			if attached {TASK} task_by_id (1) as l_task then
					-- Update completed
				if not l_task.completed then
					l_task.set_completed (True)
					db_handler.set_query (update_task (l_task))
					db_handler.execute_change
				end
			end

				-- List database tasks
			across task_list as ic loop
				print ("%N")
				print (ic.item.debug_output)
			end
		end

	login_and_connect

		do
			create {DATABASE_CONNECTION_MYSQL} db_connection.login_with_connection_string (connection_string)
		end

	set_database_handler
		do
			create {DATABASE_HANDLER_IMPL} db_handler.make (db_connection)
		end

feature -- Connection

	db_connection: DATABASE_CONNECTION
			-- database connection handle.e

	db_handler: DATABASE_HANDLER
			-- database handler (query, sp)

	error_handler: ERROR_HANDLER
			-- Error handler.

feature -- Country

	task_by_id (a_id: like {TASK}.id): detachable TASK
		do
			error_handler.reset
			write_information_log (generator + ".task_by_id")

			db_handler.set_query (query_task_by_id (a_id))
			db_handler.execute_query
			sql_post_execution
			db_handler.start
			if attached fetch_task as l_task then
				Result := l_task
			end
			db_handler.forth
		end

	task_list: LIST [TASK]
			-- all tasks.
		do
			error_handler.reset
			write_information_log (generator + ".task")
			create {ARRAYED_LIST [TASK]} Result.make (0)

			db_handler.set_query (query_tasks)
			db_handler.execute_query
			sql_post_execution

			from
				db_handler.start
			until
				db_handler.after or error_handler.has_error
			loop
				if attached fetch_task as l_task then
					Result.force (l_task)
				end
				db_handler.forth
			end
		end

	fetch_task: detachable TASK
			-- Fetch task from fields: 1:id, 2:title, 3:completed
		local
			l_id: INTEGER_64
			l_name: detachable READABLE_STRING_32
		do
			if attached db_handler.read_integer_32 (1) as i then
				l_id := i
			end
			if attached db_handler.read_string (2) as s and then not s.is_whitespace then
				l_name := s
			end

			if l_name /= Void then
				create Result.make (l_name)
				if l_id > 0 then
					Result.set_id (l_id)
				end
			elseif l_id > 0 then
				create Result.make_with_id (l_id)
			end

			if Result /= Void then
				if attached db_handler.read_boolean (3) as l_completed then
					Result.set_completed (l_completed)
				end
			else
				check expected_valid_task: False end
			end
		end

feature -- SQL Postexecution

	sql_post_execution
			-- Post database execution.
		do
			error_handler.append (db_handler.database_error_handler)
			if error_handler.has_error then
				write_critical_log (generator + ".post_execution " +  error_handler.as_string_representation)
			end
		end

feature -- SQL query

	query_tasks: DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (0)
			create Result.make_query (sql_select_tasks, l_parameters)
		end

	query_task_by_id (a_id: like {TASK}.id): DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (1)
			l_parameters.put (a_id, "id")
			create Result.make_query (sql_select_task_by_id, l_parameters)
		end

	insert_task (a_task: TASK): DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (2)
			l_parameters.put (a_task.title, "title")
			l_parameters.put (a_task.completed, "completed")
			create Result.make_query (sql_insert_task, l_parameters)
		end

	update_task (a_task: TASK): DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (2)
			l_parameters.put (a_task.id, "id")
			l_parameters.put (a_task.completed, "completed")
			create Result.make_query (sql_update_task, l_parameters)
		end

	delete_task_by_id (a_task_id: like {TASK}.id): DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (1)
			l_parameters.put (a_task_id, "id")
			create Result.make_query (sql_delete_task_by_id, l_parameters)
		end

	delete_tasks: DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (0)
			create Result.make_query (Sql_delete_tasks, l_parameters)
		end

	reset_task_sequence: DATABASE_QUERY
		local
			l_parameters: STRING_TABLE [detachable ANY]
		do
			create l_parameters.make (0)
			create Result.make_query (sql_reset_task_sequence, l_parameters)
		end

	sql_select_tasks : STRING = "SELECT * from tasks;"
		-- Select all tasks

	sql_select_task_by_id : STRING = "SELECT * from tasks  WHERE id = :id;"
		-- Select a task by a id

	sql_insert_task : STRING = "INSERT INTO tasks (title, completed) VALUES (:title, :completed);"
		-- Insert a new task.

	sql_update_task : STRING = "UPDATE tasks SET completed = :completed WHERE id = :id";
		-- Update an existing task

	sql_delete_task_by_id: STRING = "DELETE FROM tasks WHERE id = :id;"
		-- Delete a task by id.

	sql_delete_tasks: STRING = "DELETE FROM tasks;"
		-- Delete all tasks.

	sql_reset_task_sequence: STRING = "ALTER TABLE todo.tasks AUTO_INCREMENT = 1;"
		-- Reset task sequence.


feature -- Countries

	task_1: TASK
		do
			create Result.make ("Fix Database SQL Query")
			Result.set_completed (False)
		end

	task_2: TASK
		do
			create Result.make ("Update minmax algoritm")
			Result.set_completed (False)
		end

feature {NONE} -- Connection String

	connection_string:STRING = "Server=localhost;Port=3306;Database=todo;Uid=root;Pwd=password;"
			-- database connection string.

end
