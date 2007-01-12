indexing
	description: "Represents a photo hosted on flickr.com."
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
	tags: STRING		-- Tags on the photo, separated by commas
	owner: STRING		-- Photo's owner
	server_id: INTEGER	-- ID of the server the photo is hosted on
	farm_id: INTEGER	-- ID of the photo's farm

	is_loaded: BOOLEAN	-- Has the binary representation of the image already been loaded?
	loading_has_failed: BOOLEAN -- Did an error occur while trying to download the photo?

	service: FLICKR_SERVICE -- Service that was used to retrieve the photo

	finished_event: EM_EVENT_CHANNEL [TUPLE []] -- Event that is published when the photo has been loaded / en error occured

	bitmap: EM_BITMAP -- Loaded photo

feature {NONE} -- Private attributes
	http_request: HTTP_GET_REQUEST

feature -- Creation
	make (	a_service: FLICKR_SERVICE;
			a_id: STRING;
			a_secret: STRING;
			a_title: STRING;
			a_tags: STRING;
			a_owner: STRING;
			a_farm_id: INTEGER;
			a_server_id: INTEGER
		 )
		-- Creates a photo with the given info
	require
		service_not_void: a_service /= Void
		id_not_void_or_empty: a_id /= Void and then not a_id.is_empty
		secret_not_void_or_empty: a_secret /= Void and then not a_secret.is_empty
		title_not_void_or_empty: a_title /= Void and then not a_title.is_empty
		tags_not_void_or_empty: a_tags /= Void and then not a_tags.is_empty
		owner_not_void_or_empty: a_owner /= Void and then not a_owner.is_empty
		farm_id_non_negative: a_farm_id >= 0
		server_id_non_negative: a_server_id >= 0
	do
		service := a_service

		create id.make_from_string (a_id)
		create secret.make_from_string (a_secret)
		create title.make_from_string (a_title)
		create tags.make_from_string (a_tags)
		create owner.make_from_string (a_owner)

		farm_id := a_farm_id
		server_id := a_server_id

		is_loaded := false
		loading_has_failed := false

		create finished_event
	ensure
		service_set: service = a_service
		id_set: id.is_equal (a_id)
		secret_set: secret.is_equal (a_secret)
		title_set: title.is_equal (a_title)
		tags_set: tags.is_equal (a_tags)
		owner_set: owner.is_equal (a_owner)
		farm_id_set: farm_id = a_farm_id
		server_id_set: server_id = a_server_id
	end

feature {NONE} -- Callbacks
	on_http_finished is
		-- Called when the photo has finished loaded / a error has occured
	local
		p: ANY
	do
		is_loaded := not http_request.has_failed
		loading_has_failed := http_request.has_failed

		if http_request.has_failed then
			io.put_string ("Loading failed..")
		else
			p := http_request.data.to_c
			bitmap_factory.create_bitmap_from_c_array ($p, http_request.data.count)
			--bitmap_factory.create_bitmap_from_image ("D:/Development/Projects/Eiffel/traffic_3_1_801/example/bonga_svn/test.bmp")
			bitmap := bitmap_factory.last_bitmap
		end
		finished_event.publish ([])

	end

feature -- Status
	http_host: STRING is
		-- Returns the http host of the farm
	once
		Result := "farm" + farm_id.out + ".static.flickr.com"
	end

	http_file: STRING is
		-- Returns the path where the photo is stored on the server
	once
		Result := "/" + server_id.out + "/" + id + "_" + secret + "_s.jpg"
	end

feature -- Public features
	load is
		-- Loads the binary photo data from the server
	require
		photo_not_yet_loaded: not is_loaded
	do
		loading_has_failed := false

		io.put_string ("http_host: " + http_host + "%N")
		io.put_string ("http_file: " + http_file + "%N")

		create http_request.make (http_host, Flickr_http_port, http_file)

		http_request.finished_event.subscribe (agent on_http_finished)
		http_request.start
	ensure

	end


end
