indexing
	description: "'Typedef' for a list of `FLICKR_PHOTO's"
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_PHOTO_LIST

inherit
	LINKED_LIST [FLICKR_PHOTO]
		export {ANY} all end

create
	make

end
