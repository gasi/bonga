indexing
	description: "Encapsulates all functionality to display contextual photos from Flickr."
	author: "Daniel Gasienica <gdani@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_FLICKR_WIDGET


inherit
	EM_PANEL
	FLICKR_CONSTANTS

creation
	make


feature -- Creation

	make is
		-- Default creation procedure
	do
		make_void_surface

		create service.make_with_key (Flickr_api_key)

		-- Network support is needed
		-- for Flickr API requests
		-- [TODO] disable again
		Network_subsystem.enable
		create_components

	ensure
		-- Flickr API
		service_set: service /= Void

		-- Widget
		info_exists: info /= Void
		logo_exists: logo /= Void

		-- Widget Navigation
		previous_button_exists: service /= Void
		next_button_exists: service /= Void
		status_exists: service /= Void
	end


feature -- Callbacks

	on_photos_search_finished (a_search: FLICKR_PHOTOS_SEARCH)
			-- The search has finished
	require
		search_not_void: a_search /= void
	do
		if a_search.photos.count > 0 then
			current_photo := 1
			photo := a_search.photos.first.twin
			photo.finished_event.subscribe (agent on_photo_loaded)
			photo.load
		else
			status.set_text ("(0/0)")
			info.set_text ("No photos were found.")

			-- Remove old image if present
			if image /= void then
				remove_widget (image)
			end
		end
	end


	on_photo_loaded
			-- photo has finished loading
	do
		if not photo.has_loading_failed then
			-- Remove old image if present
			if image /= void then
				remove_widget (image)
			end

			update_status

			-- Load new image into an image widget
			create image.make_from_bitmap (photo.bitmap)
			image.set_position (10, previous_button.y + previous_button.height + 10)
			add_widget (image)

			redraw

			-- Fill label with information about the picture
			info.set_text (photo.title)

			-- Move the information label, so it's not overlapping with the picture
			info.set_position (10, image.y + image.height + 10)
		else
			info.set_text ("Loading the photo has failed.")
		end
	ensure
		image_exists: image /= Void
	end

	on_map_click (event: EM_MOUSEBUTTON_EVENT) is
		-- User clicked on map - he might have selected a stop
	do
		-- Has a new origin been selected?
		if map.marked_origin /= void and then map.marked_origin /= place then

			-- Improve responsivity by displaying
			-- a status message
			info.set_text ("Searching...")

			-- Search for the given tags
			search := service.new_photos_search
			search.set_tag_mode (Flickr_tag_mode_all)
			search.set_per_page (8)
			search.set_tags ("zurich" + "," +  map.marked_origin.name)
			search.finished_event.subscribe (agent on_photos_search_finished)
			search.send

			place := map.marked_origin
		end
	end

	on_previous_click
		-- Previous button handler
	do
		if
			search /= Void
			and then not search.photos.is_empty
			and then current_photo > 1
		then
			current_photo := current_photo - 1
			update_status
			load_current_photo
		end

	end

	on_next_click
		-- Next button handler
	do
		if
			search /= Void
			and then not search.photos.is_empty
			and then current_photo < search.photos.count
		then
			current_photo := current_photo + 1
			update_status
			load_current_photo
		end
	end


feature -- Access

	set_map (a_map: CITY_3D_MAP_WIDGET)
		-- Defines the map which this
		-- widget pulls information from
	require
		map_not_void: a_map /= Void
	do
		if
			map /= a_map
		then
			-- Add map
			map := a_map

			-- Subscribe to map events
			map.mouse_clicked_event.subscribe (agent on_map_click (?))
		end

	ensure
		map_set: map = a_map
	end


feature {NONE} -- Assets

	-- Flickr API
	service: FLICKR_SERVICE
	search: FLICKR_PHOTOS_SEARCH

	-- Traffic
	place: TRAFFIC_PLACE
	map: CITY_3D_MAP_WIDGET

	-- Widget
	image: EM_IMAGEPANEL
	info: EM_LABEL
	logo: EM_IMAGEPANEL
	photo: FLICKR_PHOTO

	-- Widget Navigation
	previous_button: EM_BUTTON
	next_button: EM_BUTTON
	status: EM_LABEL


feature {NONE} -- Implementation

	current_photo: INTEGER
		-- Index of current photo in photo list

	update_status
		-- Updates the navigation status field
	do
		if search /= Void then
			status.set_text ("(" + current_photo.out + "/" + search.photos.count.out + ")")
		else
			status.set_text ("(0/0)")
		end

		if search /= void and then search.photos /= void then
			-- When the last photo is displayed, disable the `next_button'
			if current_photo = search.photos.count then
				next_button.disable
			else
				next_button.enable
			end

			-- When the first photo is displayed, disable the `previous_button'
			if current_photo = 1 then
				previous_button.disable
			else
				previous_button.enable
			end
		end
	end

	load_current_photo
		-- Loads the currently selected photo and displays it
	do
		if photo.finished_event.has (agent on_photo_loaded) then
			photo.finished_event.unsubscribe (agent on_photo_loaded)
		end

		photo := search.photos.i_th (current_photo).twin
		photo.finished_event.subscribe (agent on_photo_loaded)
		photo.load

		-- Improve responsivity by displaying a status message
		info.set_text ("Loading photo...")
	end

	create_components
		-- Set up components
	do
		-- Logo
		create logo.make_from_file ("logo.png")
		logo.set_position (10, 0)
		add_widget (logo)

		-- Navigation
		create previous_button.make_from_text ("Previous")
		previous_button.set_position (logo.x, logo.y + logo.height + 12)
		previous_button.clicked_event.subscribe (agent on_previous_click)
		add_widget (previous_button)

		create next_button.make_from_text ("Next")
		next_button.set_position (previous_button.x + previous_button.width + 5, previous_button.y)
		next_button.clicked_event.subscribe (agent on_next_click)
		add_widget (next_button)

		-- Status
		create status.make_from_text ("(0/0)")
		status.set_position (next_button.x + next_button.width + 5, next_button.y)
		add_widget (status)
		update_status


		-- Info
		create info.make_from_text ("Please select a stop.")
		info.set_position (previous_button.x, previous_button.y + previous_button.height + 5)
		info.set_width (180)
		info.set_multilined (true)
		add_widget (info)

	ensure
		-- Widget
		info_exists: info /= Void
		logo_exists: logo /= Void

		-- Widget Navigation
		previous_button_exists: service /= Void
		next_button_exists: service /= Void
		status_exists: service /= Void
	end

invariant
--	-- Flickr API
--	service_exists: service /= Void

--	-- Widget
--	info_exists: info /= Void
--	logo_exists: logo /= Void

--	-- Widget Navigation
--	previous_button_exists: service /= Void
--	next_button_exists: service /= Void
--	status_exists: service /= Void
end
