indexing
	description: "Retrieves a list of FLICKR_PHOTOs matching certain search criterias."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_PHOTOS_SEARCH

inherit
	FLICKR_REQUEST
		redefine make end

create {FLICKR_SERVICE}
	make

feature -- Access
	photos: FLICKR_PHOTO_LIST	-- The photos matching the search criterias

feature {NONE} -- Private attributes
	xml_parser: FLICKR_XML_PHOTOS_SEARCH

feature -- Creation
	make is
		-- Creation procedure
	do
		precursor
		set_param ("method", "flickr.photos.search")
	end

feature {NONE} -- XML
	photos_handler (a_photos: FLICKR_PHOTO_LIST)
		-- Receives a list of photos returned by the search and passes it to the `finished_event' subscribers.
	require
		photos_not_void: a_photos /= void
	do
		photos := a_photos.deep_twin
		finished_event.publish ([Current])
	end

	parse_xml (a_string: STRING)
		-- Creates the `xml_parser' and lets it translate the raw xml data
	do
		create xml_parser.make
		xml_parser.photos_handler.subscribe (agent photos_handler (?))
		xml_parser.parse_from_string (a_string)
	end

feature -- Flickr API Parameters
	set_user_id (value: STRING)
	is
		-- Sets the NSID of the person whose photos are to be searched in.
		-- Can also be set to "me" in order to only include own photos.
	do
		set_param ("user_id", value)
	end

	set_tags (value: STRING)
	is
		-- A string containing comma-delimited tags to be searched for
	do
		set_param ("tags", value)
	end

	set_tag_mode (value: STRING)
	is
		-- 'any': any of the tags must be found
		-- 'all': all of the tags must be found
	do
		set_param ("tag_mode", value)
	end

	set_text (value: STRING)
	is
		-- Can be set for a free text search in title, description and tags.
	do
		set_param ("text", value)
	end


    set_min_upload_date (value: INTEGER) is
		-- Only photos uploaded on or after the given date (a unix timestamp) are returned.
	do
		set_param ("min_upload_date", value.out)
	end

    set_max_upload_date (value: INTEGER) is
		-- Only photos uploaded on the given date (a unix timestamp) or before are returned.
	do
		set_param ("max_upload_date", value.out)
	end

    set_min_taken_date (value: INTEGER) is
		-- Only photos taken on the given date or after are returned.
	do
		set_param ("min_taken_date", value.out)
	end

    set_max_taken_date (value: INTEGER) is
		-- Only photos taken on the given date or before are returned.
	do
		set_param ("max_taken_date", value.out)
	end

    set_license (value: STRING) is
		-- The license ids for photos, separated by commas
	do
		set_param ("license", value)
	end

    set_sort (value: STRING) is
		-- Sets how the photos are sorted
		-- "date-posted-asc", "date-posted-desc"
		-- "date-taken-asc", "date-taken-desc"
		-- "interestingness-desc", "interestingness-asc"
	do
		set_param ("sort", value)
	end

    set_privacy_filter (value: INTEGER) is
    	-- Only photos matching a certain privacy level are returned
		-- 1 public photos
		-- 2 private photos visible to friends
		-- 3 private photos visible to family
		-- 4 private photos visible to friends and family
		-- 5 completely private photos
	do
		set_param ("privacy_filter", value.out)
	end

    set_bbox (value: STRING) is
		-- Set bounding box for geo data
		-- currently disabled
	require
		disabled: false
	do
		set_param ("bbox", value)
	end

    set_accuracy (value: INTEGER) is
		-- Recored accuracy for level of the location information
		--  1	World level
		-- ~3	Country level
		-- ~6	Region level
		-- ~11	City level
		-- ~16	Street level
	require
		value_in_range: value >= 1 and value <= 16
	do
		set_param ("accuracy", value.out)
	end

    set_group_id (value: STRING) is
		-- The id of the group to be searched
	do
		set_param ("group_id", value)
	end


    set_extras (value: STRING) is
		-- A comma-delimited list of extra information to fetch for each returned record
		-- might be:
		-- license, date_upload, date_taken, owner_name, icon_server, original_format, last_update or geo
	do
		set_param ("extras", value)
	end

    set_per_page (value: INTEGER) is
		-- Number of photos to be returned per page (1-500)
	require
		value_in_range: value >= 1 and value <= 500
	do
		set_param ("per_page", value.out)
	end

    set_page (value: INTEGER) is
		-- Number of the page to return
	do
		set_param ("page", value.out)
	end

end
