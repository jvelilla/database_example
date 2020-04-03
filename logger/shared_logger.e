note
	description: "Summary description for {SHARED_LOGGER}."
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_LOGGER

feature -- Logging

	write_debug_log (m: READABLE_STRING_8)
		do
			print ("%NDEBUG:  ")
			print (m)
			print ("%N")
		end

	write_information_log (m: READABLE_STRING_8)
		do
			print ("%NINFORMATION:  ")
			print (m)
			print ("%N")
		end

	write_warning_log (m: READABLE_STRING_8)
		do

			print ("%NWARNING:  ")
			print (m)
			print ("%N")
		end

	write_error_log (m: READABLE_STRING_8)
		do
			print ("%NERROR:  ")
			print (m)
			print ("%N")
		end

	write_critical_log (m: READABLE_STRING_8)
		do
			print ("%NCRITICAL:  ")
			print (m)
			print ("%N")
		end

	write_alert_log (m: READABLE_STRING_8)
		do
			print ("%NALERT:  ")
			print (m)
			print ("%N")
		end

end
