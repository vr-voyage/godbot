class_name OpenAiModelsList extends Resource

@export var models:Array[String] = []

static func from_v1_json(json_raw:String) -> OpenAiModelsList:
	var parsed_json = JSON.parse_string(json_raw)
	if not parsed_json is Dictionary:
		printerr("[OpenAiModelLists:from_v1_json] Expected a Dictionary, but got a %s" % type_string(typeof(parsed_json)))
		return null

	var json:Dictionary = parsed_json as Dictionary
	if not json.has_all(["object", "data"]) or json["object"] != "list":
		printerr("[OpenAiModelLists:from_v1_json] Missing required values")
		return null

	var data_raw = json["data"]
	if not data_raw is Array:
		printerr("[OpenAiModelLists:from_v1_json] Expected json['data'] to be an Array but got a %s" % type_string(typeof(data_raw)))
		return null

	var ret := OpenAiModelsList.new()
	var data:Array = data_raw as Array
	for model_info in data:
		if not model_info.has("id"):
			continue
		ret.models.append(model_info["id"])
	return ret
