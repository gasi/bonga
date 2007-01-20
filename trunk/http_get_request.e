indexing
	description: "A small, simple wrapper around the EM_HTTP_PROTOCOL class that allows to easily send get requests to HTTP servers."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_GET_REQUEST

create
	make

feature -- Access
	http: EM_HTTP_PROTOCOL -- The `EM_HTTP_PROTOCOL' we're wrapping here
	data: STRING -- Raw returned data
	hostname: STRING -- The hostname
	path: STRING -- The path to the file we are requesting
	port: INTEGER -- The remote port
	finished_event: EM_EVENT_CHANNEL [TUPLE []] -- Event that is published when the event has finished or failed

feature {NONE} -- Creation
	make (a_hostname: STRING; a_port: INTEGER; a_path: STRING) is
		-- Creation procedure
	require
		a_hostname_not_void_or_empty: a_hostname /= void and then not a_hostname.is_empty
		a_path_not_void_or_empty: a_path /= void and then not a_path.is_empty
		a_port_not_void_or_negative: a_port /= void and then a_port >= 0
	do
		create data.make_empty
		create finished_event

		create http.make
		set_hostname (a_hostname)
		set_port (a_port)
		set_path (a_path)
		http.connection_established_event.subscribe (agent connection_established_handler)
		http.connection_closed_event.subscribe (agent connection_closed_handler)
		http.connection_failed_event.subscribe (agent connection_failed_handler)
		http.data_received_event.subscribe (agent data_handler (?))
	ensure
		hostname_is_set: hostname.is_equal (a_hostname)
		path_is_set: path.is_equal (a_path)
		port_is_set: port = a_port
	end

feature -- Status

	failed: BOOLEAN
	has_failed: BOOLEAN is
		-- Has the request failed?
	do
		Result := failed
	end

feature -- Setters

	set_hostname (a_hostname: STRING) is
		-- Sets the hostname
	require
		a_hostname_not_void_or_empty: a_hostname /= void and then not a_hostname.is_empty
	do
		hostname := a_hostname.twin
		http.set_hostname (a_hostname)
	ensure
		hostname_is_set: hostname.is_equal (a_hostname)
	end

	set_path (a_path: STRING) is
		-- Sets the path
	require
		a_path_not_void_or_empty: a_path /= void and then not a_path.is_empty
	do
		path := a_path.twin
		http.set_path (path)
	ensure
		path_is_set: path.is_equal (a_path)
	end

	set_port (a_port: INTEGER) is
		-- Sets the path
	require
		a_port_not_void_or_negative: a_port /= void and then a_port >= 0
	do
		port := a_port
		http.set_port (port)
	ensure
		port_is_set: port = a_port
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
	    http.get
	end

	connection_failed_handler is
		-- Called when the connection could not be established
	do
		failed := true
		finished
	end

	connection_closed_handler is
		-- Called when the connection has been closed
	do
		finished
	end

end
