extends Reference
class_name BitwiseUtil

static func isBitEnabled(bitmask : int, flag : int) -> bool:
	return bitmask & flag != 0
	
static func setBit(bitmask : int, flag : int) -> int:
	bitmask = bitmask | flag
	return bitmask
	
static func unsetBit(bitmask : int, flag : int) -> int:
	bitmask = bitmask & ~flag
	return bitmask
