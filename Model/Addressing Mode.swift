// DRAMASimulator © 2018 Constantino Tsarouhas

enum AddressingMode : String {
	
	/// The operand is to be interpreted as a signed value.
	case value		= "w"
	
	/// The operand is to be interpreted as an unsigned value.
	case address	= "a"
	
	/// The operand is to be interpreted as a location in memory.
	case direct		= "d"
	
	/// The operand is to be interpreted as a location in memory whose value points to the desired location in memory.
	case indirect	= "i"
	
	/// Determines the addressing mode encoded by given code.
	///
	/// - Parameter code: The encoded addressing mode.
	/// - Parameter directAccessOnly: `true` if the applicable command only supports direct memory access.
	init?(code: Int, directAccessOnly: Bool) {
		switch (code, directAccessOnly) {
			case (1, _):		self = .value
			case (2, false):	self = .address
			case (2, true):		self = .direct
			case (3, false):	self = .direct
			case (3, true):		self = .indirect
			case (4, false):	self = .indirect
			default:			return nil
		}
	}
	
	/// Returns the code encoding this addressing mode.
	///
	/// - Parameter directAccessOnly: `true` if the applicable command only supports direct memory access.
	func code(directAccessOnly: Bool) -> Int {
		switch (self, directAccessOnly) {
			case (.value, _):			return 1
			case (.address, _):			return 2
			case (.direct, false):		return 3
			case (.direct, true):		return 2
			case (.indirect, false):	return 4
			case (.indirect, true):		return 3
		}
	}
	
}
