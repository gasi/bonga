indexing
	description: "A string class that allows to encode strings for HTTP transfer."
	author: "Boris Bluntschli <borisb@student.ethz.ch>"
	date: "$Date$"
	revision: "$Revision$"

class
	HTTP_ENCODED_STRING

inherit
	STRING
		rename make_from_string as make_from_encoded_string
		export {ANY} all end

create
	make_from_string,
	make_from_encoded_string

feature -- Creation
	make_from_string (a_string: STRING) is
			-- Creates an HTTP_ENCODED_STRING from an unencoded STRING `astring'
	local
		encoded_char: STRING	-- The current character encoded
		encoded_string: STRING	-- The complete string encoded
		i: INTEGER
		c: CHARACTER
		hex_string: STRING
	do
		create encoded_string.make_empty

		-- Encode every single character
		from i := 1 until i > a_string.count
		loop
			c := a_string.item (i)

			-- Allowed characters don't need to be changed
			if	(c >= '0' and c <= '9') or (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or (c = '&') or (c = '-') or (c = '_') or (c = '.') or (c = '+') or (c = '!') or (c = '*') or (c = '%'') or (c = '(') or (c = ')') or (c = ',') then
				encoded_string.append_character (c)
			else
				hex_string := c.code.to_hex_string
				encoded_string.append ("%%" + hex_string.substring (hex_string.count-1, hex_string.count))
			end
			i := i + 1
		end
		make_from_encoded_string (encoded_string)
	end

 end
