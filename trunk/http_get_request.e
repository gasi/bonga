indexing
	description: "A small, simple wrapper around the EM_HTTP_PROTOCOL class that allows to very easily send get requests to HTTP servers."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_GET_REQUEST

create
	make

feature -- Access
	http: EM_HTTP_PROTOCOL
	data: STRING

	finished_event: EM_EVENT_CHANNEL [TUPLE []]

	hostname: STRING


feature {NONE} -- Creation
	make (a_hostname: STRING; a_port: INTEGER; a_path: STRING) is
		-- Default creation procedure
	do
		create data.make_empty

		create finished_event

		create http.make
		set_hostname (a_hostname)
		http.set_port (a_port)
		http.set_path (a_path)
		http.connection_established_event.subscribe (agent connection_established_handler)
		http.connection_closed_event.subscribe (agent connection_closed_handler)
		http.connection_failed_event.subscribe (agent connection_failed_handler)
		http.data_received_event.subscribe (agent data_handler (?))
	end

feature -- Status

	failed: BOOLEAN
	has_failed: BOOLEAN is
		-- Has the request failed?
	do
		Result := failed
	end


feature -- Implementation

	set_hostname (new_hostname: STRING) is
		-- Sets the hostname
	do
		hostname := new_hostname
		http.set_hostname (new_hostname)
	end

	set_path (path: STRING) is
		-- Sets the path
	do
		http.set_path (path)
	end

	start is
		-- Starts the request
	do
		data.clear_all
		failed := false
		http.connect
	end


	finished is
		-- Called when the request has succeded or failed
	do
		finished_event.publish ([])
	end

feature -- Callback

	data_handler (new_data: STRING_8) is
		-- Called when some data arrives
	do
		data.append (new_data)
	end

	connection_established_handler is
		-- Called when the connection has been established
	do
		io.put_string (hostname + ": connection established%N")
	    http.get
	end

	connection_failed_handler is
		-- Called when the connection could not be established
	do
		io.put_string (hostname + ": connection failed%N")
		failed := true
		finished
	end

	connection_closed_handler is
		-- Called when the connection has been closed
	do
		finished
	end

end
