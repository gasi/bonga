indexing
	description: "Base class for Flickr web service methods."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	FLICKR_REQUEST

inherit
	FLICKR_CONSTANTS

feature {NONE} -- Private attributes
	params: HASH_TABLE[STRING, STRING]
	http_request: HTTP_GET_REQUEST

feature -- Access
	has_failed: BOOLEAN	-- Has an error occured during processing the request?
	finished_event: EM_EVENT_CHANNEL [TUPLE []] -- Event that is published when the request has finished

feature {NONE} -- Callback
	on_http_finished is
		-- Called when the HTTP_REQUEST has finished loading or an error occured
	do
		has_failed := http_request.has_failed
		if not http_request.has_failed then
			parse_xml (http_request.data.out)
		end
	end

feature {NONE} -- XML
	parse_xml (a_string: STRING)
		-- Translates raw xml data
		-- Needs to be implemented by the child class
	deferred

	end


feature {NONE} -- Creation
	make is
		-- Creation procedure
	do
		create params.make (20)
		create http_request.make (Flickr_http_host, Flickr_http_port, Flickr_http_file)
		http_request.finished_event.subscribe (agent on_http_finished)
		create finished_event
		has_failed := false
	end


feature -- Public features
	send
	is
		-- Creates the http request and sends it to the server
	local
		http_path: STRING -- The encoded path
	do
		has_failed := false

		-- Create path by appending encoded keys and values
		create http_path.make_from_string (Flickr_http_file)
		http_path.append ("?")
		from
			params.start
		until
			params.after
		loop
			http_path.append (create {HTTP_ENCODED_STRING}.make_from_string (params.key_for_iteration) + "=" + create {HTTP_ENCODED_STRING}.make_from_string (params.item_for_iteration) + "&")
			params.forth
		end
		http_path.remove_tail (1)
		http_request.set_path (http_path)

		-- Start the request
		http_request.start
	end

	get_param (name: STRING): STRING
	is
		-- Returns the value of a parameter if it has
		-- already been set or an empty string otherwise
	require
		name_not_void: name /= Void
		name_not_empty: not name.is_empty
	do
		params.search (name)

		Result := ""
		if (params.found) then
			Result := params.found_item.twin
		end
	ensure
		result_set: Result /= void
	end

	set_param (name: STRING; value: STRING)
	is
		-- Generic feature to set any of the request's parameters
	require
		name_not_void: name /= Void
		name_not_empty: not name.is_empty
		value_not_void: value /= Void
	do
		params.put (value.twin, name)
	ensure
		param_is_set: get_param (name).is_equal (value)
	end

end
