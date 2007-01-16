indexing
	description: "Represents a photo hosted on Flickr"
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_PHOTO

inherit
	FLICKR_CONSTANTS
	EM_SHARED_BITMAP_FACTORY

create
	make

feature -- Attributes
	id: STRING			-- Photo's unique ID
	secret: STRING		-- Photo's secret
	title: STRING		-- Photo's title
	owner: STRING		-- Photo's owner
	server_id: INTEGER	-- ID of the server the photo is hosted on
	farm_id: INTEGER	-- ID of the photo's farm

	is_loaded: BOOLEAN	-- Has the binary representation of the image already been loaded?
	has_loading_failed: BOOLEAN -- Did an error occur while trying to download the photo?

	service: FLICKR_SERVICE -- Service that was used to retrieve the photo

	finished_event: EM_EVENT_CHANNEL [TUPLE []] -- Event that is published when the photo has been loaded or en error occured

	bitmap: EM_BITMAP -- Loaded photo

feature {NONE} -- Private attributes
	http_request: HTTP_GET_REQUEST

feature -- Creation
	make (	a_id: STRING;
			a_secret: STRING;
			a_title: STRING;
			a_owner: STRING;
			a_farm_id: INTEGER;
			a_server_id: INTEGER
		 )
		-- Creates a photo with the given info
	require
		id_not_void_or_empty: a_id /= Void and then not a_id.is_empty
		secret_not_void_or_empty: a_secret /= Void and then not a_secret.is_empty
		title_not_void_or_empty: a_title /= Void
		pwner_not_void_or_empty: a_owner /= Void and then not a_owner.is_empty
		farm_id_non_negative: a_farm_id >= 0
		server_id_non_negative: a_server_id >= 0
	do
		create id.make_from_string (a_id)
		create secret.make_from_string (a_secret)
		create title.make_from_string (a_title)
		create owner.make_from_string (a_owner)

		farm_id := a_farm_id
		server_id := a_server_id

		is_loaded := false
		has_loading_failed := false

		create finished_event
	ensure
		id_set: id.is_equal (a_id)
		secret_set: secret.is_equal (a_secret)
		title_set: title.is_equal (a_title)
		owner_set: owner.is_equal (a_owner)
		farm_id_set: farm_id = a_farm_id
		server_id_set: server_id = a_server_id
	end

feature {NONE} -- Callbacks

	on_http_finished is
		-- Called when the photo has finished loading or an error has occured
	local
		p: ANY
	do
		is_loaded := not http_request.has_failed
		has_loading_failed := http_request.has_failed

		if http_request.has_failed then
			io.put_string ("Loading failed..")
		else
			-- Using SDL, create a EM_BITMAP from the picture in memory
			p := http_request.data.to_c
			bitmap_factory.create_bitmap_from_c_array ($p, http_request.data.count)
			bitmap := bitmap_factory.last_bitmap

			-- Resize image to 180px width so it fits into the existing city3d GUI
			bitmap.transform (180 / bitmap.width, 180 / bitmap.width, 0)
		end
		finished_event.publish ([])

	end

feature -- Status

	http_host: STRING is
		-- Returns the http host of the farm
	do
		Result := "farm" + farm_id.out + ".static.flickr.com"
	end

	http_file: STRING is
		-- Returns the path where the photo is stored on the server
	do
		Result := "/" + server_id.out + "/" + id + "_" + secret + "_m.jpg"
	end

feature -- Public features
	load is
		-- Loads the binary photo data from the server
	require
		photo_not_yet_loaded: not is_loaded
	do
		has_loading_failed := false

		io.put_string ("http_host: " + http_host + "%N")
		io.put_string ("http_file: " + http_file + "%N")

		create http_request.make (http_host, Flickr_http_port, http_file)

		http_request.finished_event.subscribe (agent on_http_finished)
		http_request.start
	ensure

	end
end
