class_name DictionaryHelpers

static func get_missing_keys(keys:PackedStringArray, dict:Dictionary) -> PackedStringArray:
	var not_in_dict:PackedStringArray = []
	for key in keys:
		if not dict.has(key):
			not_in_dict.append(key)
	return not_in_dict
