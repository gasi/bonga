indexing
	description: "Objects that ..."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_SERVICE

feature -- Constants


feature -- Access
	http_request: HTTP_REQUEST
	api_key: STRING

feature -- Creation
	make_with_key (a_api_key: STRING)
		is
			-- Creates a new instance of FLICKR_SERVICE with the given API key.
		require
			api_key_not_void: a_api_key /= Void
		do
			api_key := a_api_key
		ensure
			api_key_set: api_key = a_api_key
		end

feature -- Photos
	new_photos_search: FLICKR_PHOTOS_SEARCH

feature {NONE} -- Implementation

invariant
	invariant_clause: True -- Your invariant here

end
