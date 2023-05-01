extends Node
const LOG_PATH = "log.json"

enum FilterType {
	Lint,
	Json
}

var path = ""
var debug_log = []

func Log(msg: String, args: Array = []):
	msg = str(Time.get_ticks_msec()) + ": " + msg.format(args, "{}")
	print(msg)
	debug_log.push_back(msg)
	Serialisation.save_to_json(debug_log, LOG_PATH)
