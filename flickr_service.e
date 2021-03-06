indexing
	description: "Main interface to the flickr web service. Needed in order to create any FLICKR_REQUEST objects."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_SERVICE

create
	make_with_key

feature -- Access
	api_key: STRING -- The API key that is needed to access the flickr services

feature -- Creation
	make_with_key (a_api_key: STRING)
		is
			-- Creates a new instance of FLICKR_SERVICE with the given API key.
		require
			api_key_not_empty: a_api_key /= Void and then not a_api_key.is_empty
		do
			api_key := a_api_key
		ensure
			api_key_set: api_key = a_api_key
		end

feature -- Photos
	new_photos_search: FLICKR_PHOTOS_SEARCH is
		-- Returns an unique FLICKR_PHOTOS_SEARCH object
	do
		create Result.make
		Result.set_param ("api_key", api_key)
	ensure
		result_not_void: Result /= Void
	end

invariant
	api_key_set: api_key /= void and then not api_key.is_empty

end
