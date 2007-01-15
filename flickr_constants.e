indexing
	description: "Provides classes that inherit from it with constants that are needed for the FLICKR_* classes."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_CONSTANTS

feature {NONE} -- API Configuration
	Flickr_http_file: STRING is "/services/rest/"					-- File to request from the server
	Flickr_http_host: STRING is "api.flickr.com" 					-- Server's hostname
	Flickr_http_port: INTEGER is 80									-- Server port
	Flickr_api_key: STRING is ""									-- API key

feature {NONE} -- Method parameters
	-- tag_mode
	Flickr_tag_mode_any: STRING is "any"
	Flickr_tag_mode_all: STRING is "all"

end
