class_name Option
var inner: Variant

static func Some(data: Variant) -> Option:
	return _Some.new(data)

static func None() -> Option:
	return _Some.new(null)

func unwrap() -> Variant:
	return null
func is_none() -> bool:
	return inner == null

class _Some extends Option:
	func _init(data: Variant):
		inner = data
	func unwrap() -> Variant:
		return inner
