indexing
	description: "Processes XML response coming from a Flickr API request."
	author: "Daniel Gasienica <gdani@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_XML_PHOTOS_PROCESSOR

inherit
	XM_NODE_PROCESSOR

redefine
	process_document
end

feature -- Access
	photos: FLICKR_PHOTO_LIST

feature -- Processing
	process_document (doc: XM_DOCUMENT)
		-- Processes response from Flickr photo search
	local
		photos_elements: DS_LIST[XM_ELEMENT]
		index: INTEGER

		-- Flickr Photo metadata
		photo_id: STRING
		photo_secret: STRING
		photo_title: STRING
		photo_owner: STRING
		photo_farm: INTEGER
		photo_server: INTEGER
	do
		io.put_string ("FLICKR_XML_PHOTOS_PROCESSOR::process_document%N")

		create photos

		photos_elements := doc.root_element.element_by_name ("photos").elements

		from
			index := 1
		until
			index > photos_elements.count
		loop
			io.put_string ("Flickr Photo ID: " + photos_elements.item (index).attribute_by_name ("id").value + "%N")
			io.put_string ("Flickr Photo Secret: " + photos_elements.item (index).attribute_by_name ("secret").value + "%N")
			io.put_string ("Flickr Photo Title: " + photos_elements.item (index).attribute_by_name ("title").value + "%N")
			io.put_string ("Flickr Photo Owner: " + photos_elements.item (index).attribute_by_name ("owner").value + "%N")
			io.put_string ("Flickr Photo Farm: " + photos_elements.item (index).attribute_by_name ("farm").value + "%N")
			io.put_string ("Flickr Photo Server: " + photos_elements.item (index).attribute_by_name ("server").value + "%N")

			photo_id := photos_elements.item (index).attribute_by_name ("id").value
			photo_secret := photos_elements.item (index).attribute_by_name ("secret").value
			photo_title := photos_elements.item (index).attribute_by_name ("title").value
			photo_owner := photos_elements.item (index).attribute_by_name ("owner").value
			photo_farm := photos_elements.item (index).attribute_by_name ("farm").value.to_integer
			photo_server := photos_elements.item (index).attribute_by_name ("server").value.to_integer

		 	photos.extend (create {FLICKR_PHOTO}.make_from_metadata(photo_id, photo_secret, photo_title, photo_owner, photo_farm, photo_server))

			index := index + 1
		end
	end
end
