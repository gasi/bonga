indexing
	description: ""
	author: "Daniel Gasienica <gdani@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	TRAFFIC_FLICKR_WIDGET

inherit
	EM_COMPONENT
		redefine
			prepare_drawing,
			draw
		end

creation
	make

feature -- Access

feature -- Sub-widgets
	photo_title: EM_LABEL

feature -- Creation
	make is
		-- Default creation procedure
	do
		create photo_title.make_from_text ("This is a text")
		photo_title.set_position (x, y)
		
	end

feature -- GUI
	draw is
		-- Draw the widget
	do

	end

	prepare_drawing is
		-- Our beloved widget prepares for drawing
	do

	end

	finish_drawing is
		-- Our beloved widget finished drawing
	do

	end


end
