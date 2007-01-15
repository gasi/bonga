indexing
	description: "Responsible for parsing the Flickr request data into an FLICKR_PHOTO_LIST object."
	author: "Daniel Gasienica <gdani@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	FLICKR_XML_PHOTOS_SEARCH


feature -- Access
	photos: FLICKR_PHOTO_LIST


feature -- Implementation
	parse_from_string (a_string:STRING)
			-- Parses the raw xml data
	local
		parser: XM_PARSER
		tree_pipe: XM_TREE_CALLBACKS_PIPE 		-- tree generating callbacks
		processor: FLICKR_XML_PHOTOS_PROCESSOR 	-- parsing processor

		response: STRING -- Test response
	do
		-- Test response
		response := "<rsp stat=%"ok%"><photos page=%"1%" pages=%"4967%" perpage=%"10%" total=%"49662%"><photo id=%"355880247%" owner=%"98775937@N00%" secret=%"5a8b4059c8%" server=%"130%" farm=%"1%" title=%"P1000118%" ispublic=%"1%" isfriend=%"0%" isfamily=%"0%"/><photo id=%"355873391%" owner=%"98775937@N00%" secret=%"e2c6e752d1%" server=%"131%" farm=%"1%" title=%"P1000115%" ispublic=%"1%" isfriend=%"0%" isfamily=%"0%"/></photos></rsp>"

		io.put_string ("FLICKR_XML_PHOTOS_SEARCH: Initializing...%N")

		parser := new_xml_parser

		create tree_pipe.make
		create processor

		parser.set_string_mode_unicode
		parser.set_callbacks (tree_pipe.start)

		-- Sample Data
		parser.parse_from_string (response)

		-- Real Data
		-- parser.parse_from_string (a_string)

		if not parser.is_correct then
			io.put_string ("FLICKR_XML_PHOTOS_SEARCH: Error!%N")
		else
			io.put_string ("FLICKR_XML_PHOTOS_SEARCH Processing...%N")
			processor.process_document (tree_pipe.document)
			photos := processor.photos
		end
	end


feature {NONE} -- Implementation

	new_xml_parser: XM_PARSER
			-- Create new parser
		local
			factory: XM_EXPAT_PARSER_FACTORY
		do
			create factory
			if factory.is_expat_parser_available then
				Result := factory.new_expat_parser
			else
				create {XM_EIFFEL_PARSER} Result.make
			end
		end
end
