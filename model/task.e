note
	description: "Object Representing a TASK"
	date: "$Date$"
	revision: "$Revision$"

class
	TASK

create
	make,
	make_with_id

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create an object with title `a_name'.
		require
			a_name_not_empty: not a_name.is_whitespace
		do
			title := a_name
		ensure
			title_set: title.same_string (a_name)
		end


	make_with_id (a_id: INTEGER_64)
		require
			a_id_valid: a_id > 0
		do
			id := a_id
			title := ""
		ensure
			id_set: id = a_id
		end


feature -- Access

	id: INTEGER_64
		-- Unique database id.

	title: READABLE_STRING_8
		-- name of the task.


	completed: BOOLEAN
		-- Is the task completed?	


feature -- Status report

	has_id: BOOLEAN
		do
			Result := id > 0
		end


	debug_output: STRING_32
		do
			create Result.make_empty
			if has_id then
				Result.append_character (' ')
				Result.append_character ('<')
				Result.append_integer_64 (id)
				Result.append_character ('>')
				Result.append_character (' ')
				Result.append_character ('<')
				Result.append_string (title)
				Result.append_character ('>')
				Result.append_character (' ')
				Result.append_character ('<')
				Result.append_boolean (completed)
				Result.append_character ('>')
			end
		end

feature -- Element Change.


	set_id (a_id: like id)
			-- Set `id' with `a_id'.
		do
			id := a_id
		ensure
			id_set: id = a_id
		end

	set_title (n: like title)
			-- Set `title` with `n`.
		do
			title := n
		ensure
			title_set: title = n
		end

	set_completed (n: like completed)
			-- Set `completed` with `n'.
		do
			completed := n
		ensure
			completed_set: completed = n
		end
end
