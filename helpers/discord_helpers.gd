class_name DiscordHelpers extends Node

const code_block:String = "```"
static var regex_alnum:RegEx = RegEx.create_from_string(r"(\w+)")

static func get_last_code_block_language(message:String) -> String:
	var code_block_index:int = message.rfind(code_block)
	if code_block_index == -1:
		return ""

	var got_a_match:RegExMatch = regex_alnum.search(message, code_block_index)
	if got_a_match:
		return got_a_match.get_string()
	return ""

# TODO: Oh boy, factorize this...
static func cut_messages_for_discord(original_content:String) -> PackedStringArray:
	var cut_messages:PackedStringArray = []
	
	# I'm convinced, these are BYTES, not CHARACTERS
	# I got owned so many times trying to get an answer in Chinese
	# from an LLM, and then see a Discord message size LIMIT error instead...
	
	const carriage_return:int = 0x0A
	const carriage_return_size:int = 1
	# Let's just say that if your programming language needs more than
	# 24 characters after the code block to get the right coloring
	# Then... Go fuck yourself
	const max_language_name_size:int = 24 

	const discord_message_size_limit:int = 2000
	var code_block_size:int = len(code_block.to_utf8_buffer())
	# So we might need to repeat the previous message code block
	# AND close the current message's one
	var code_block_delimitation_size:int = (
		(code_block_size + max_language_name_size + carriage_return_size) + (code_block_size + carriage_return_size))

	var used_limit:int = discord_message_size_limit - code_block_delimitation_size
	
	var buffer:PackedByteArray = original_content.to_utf8_buffer()
	var buffer_size:int = len(buffer)
	var cursor:int = 0
	var repeat_code_block:bool = false

	var current_language:String = ""

	while cursor < buffer_size:
		var slice:PackedByteArray = buffer.slice(cursor, cursor+used_limit)
		var slice_size:int = len(slice)
		if slice_size < used_limit:
			# TODO FACTORIZE !!
			var cut_string2:String = slice.get_string_from_utf8()
			if repeat_code_block:
				cut_string2 = code_block + current_language + "\n" + cut_string2
				repeat_code_block = false

			var n_code_blocks2:int = cut_string2.count(code_block)
			# If we got an odd number, we should close it before switching
			# to the next message
			if (n_code_blocks2 & 1) == 1:
				current_language = get_last_code_block_language(cut_string2)
				cut_string2 = cut_string2 + code_block
				repeat_code_block = true
			cut_messages.append(cut_string2)
			break

		var last_char:int = slice[slice_size-1]

		# Make sure we don't cut in the middle of an UTF-8 sequence !

		# Looking for a complete character or an UTF-8 sequence start
		while ((last_char & 0b1000_0000) != 0) && (last_char & 0b1100_0000 != 0b1100_0000):
			print_debug("Middle of a character")
			slice_size -= 1
			last_char = slice[slice_size-1]
		# Let's get one step back if we actually hit the sequence start
		if ((last_char >> 7) != 0b0) && ((last_char >> 6) == 0b11):
			slice_size -= 1

		var last_carriage_return_index:int = slice.rfind(carriage_return, slice_size-1)
		if last_carriage_return_index != -1:
			slice_size = last_carriage_return_index
		slice.resize(slice_size)

		# Now, get the string and make sure we're handling code blocks
		# nicely
		var cut_string:String = slice.get_string_from_utf8()
		if repeat_code_block:
			cut_string = code_block + current_language + "\n" + cut_string
			repeat_code_block = false

		var n_code_blocks:int = cut_string.count(code_block)
		# If we got an odd number, we should close it before switching
		# to the next message
		if (n_code_blocks & 1) == 1:
			current_language = get_last_code_block_language(cut_string)
			cut_string = cut_string + code_block
			repeat_code_block = true

		cut_messages.append(cut_string)
		cursor += slice_size
	return cut_messages
