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
	has_failed: BOOLEAN
	finished_event: EM_EVENT_CHANNEL [TUPLE []]

feature {NONE} -- Callback
	on_http_finished is
		-- Called when the HTTP_REQUEST has finished loading / an error occured
	do
		io.put_string ("on_http_finish%N%N" + http_request.data + "%N%N")
		parse_xml (http_request.data.out)
	end

feature {NONE} -- XML
	parse_xml (a_string: STRING)
		-- Translates raw xml data
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
		-- Sends the request to the server
	require
	local
		http_path: STRING
		encoded_key: HTTP_ENCODED_STRING
		encoded_value: HTTP_ENCODED_STRING
	do
		has_failed := false
		create http_path.make_from_string (Flickr_http_file)
		http_path.append ("?")

		from
			params.start
		until
			params.after
		loop
			create encoded_key.make_from_string (params.key_for_iteration)
			create encoded_value.make_from_string (params.item_for_iteration)
			http_path.append (encoded_key + "=" + encoded_value + "&")
			params.forth
		end
		http_path.remove_tail (1)
		io.put_string (http_path)

		http_request.set_path (http_path)
		http_request.start

	ensure

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
			Result := params.found_item
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
		params.put (value, name)
	ensure
		param_is_set: get_param (name).is_equal (value)
	end

end