note
	description: "Database configuration"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	DATABASE_CONFIG

feature -- Database access

	is_keep_connection: BOOLEAN
			-- Keep Connection to database?
		do
			Result := True
		end

end
