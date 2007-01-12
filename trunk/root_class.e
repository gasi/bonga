indexing
	description	: "System's root class"
	date: "$Date$"
	revision: "$Revision$"

class
	ROOT_CLASS

inherit
	EM_APPLICATION
	FLICKR_CONSTANTS

create
	make

feature -- Member variables
	http: HTTP_GET_REQUEST
	flickr: FLICKR_SERVICE
	photos_search: FLICKR_PHOTOS_SEARCH
	photo: FLICKR_PHOTO

	my_finished is
		-- test
	do
		if http.has_failed then
			io.put_string ("http.has_failed = true%N")
		else
			io.put_string ("Data:%N" + http.data + "%N%N")
		end
	end

	on_photo_loaded is
			--
	do
		if photo.loading_has_failed then

		else

		end
	end


feature -- Initialization

	make is
			-- Creation procedure.
		local
			my_loop: EM_EVENT_LOOP

		do
			io.put_string ("Enabling network subsystem.. ")
			network_subsystem.enable
			io.put_string ("OK%N")

			create flickr.make_with_key ("eb67de26011147f6cf0176e79506e2d0")
			photos_search := flickr.new_photos_search
			photos_search.set_tags ("zurich,bellevue")
			photos_search.set_tag_mode (Flickr_tag_mode_all)
			photos_search.send

			create photo.make (	flickr,
								"348064128",
								"effac0c55f",
								"Cool photo",
								"photo,blabla",
								"jasdlkfjsafd@N01",
								1,
								125
						)
			photo.finished_event.subscribe (agent on_photo_loaded)
			photo.load

			create my_loop.make_poll

			my_loop.dispatch

			network_subsystem.disable
		end

feature -- Handler features



end -- class ROOT_CLASS
