indexing
	description: "Objects that ..."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_CONSTANTS

feature {NONE} -- API Configuration
	Flickr_http_file: STRING is "/services/rest/"	-- File to request from the server
	Flickr_http_host: STRING is "api.flickr.com" -- Server's hostname
	Flickr_http_port: INTEGER is 80

feature {NONE} -- Method parameters
	-- tag_mode
	Flickr_tag_mode_any: STRING is "any"
	Flickr_tag_mode_all: STRING is "all"

-- For identifiers denoting complex notions, use underscores to separate successive words, as in My_route or bus_station. This also works for class names, always in upper case: PUBLIC_TRANSPORT. Don't overdo it: for most identifiers, a single word, or two words separated by an underscore, are enough.

end
