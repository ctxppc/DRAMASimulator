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
	
	/// Returns the addressing mode associated with given canonical code.
	init?(canonicalCode: Int) {
		switch canonicalCode {
			case 1:	self = .value
			case 2:	self = .address
			case 3:	self = .direct
			case 4:	self = .indirect
			case _:	return nil
		}
	}
	
	/// Returns the addressing mode associated with given direct access code.
	///
	/// Instructions that operate directly on memory use represent the addressing mode with the direct access code instead of the canonical one.
	init?(directAccessCode: Int) {
		switch canonicalCode {
			case 1:	self = .value
			case 2:	self = .direct
			case 3:	self = .indirect
			case _:	return nil
		}
	}
	
	/// Returns the canonical code associated with this addressing mode.
	var canonicalCode: Int {
		switch self {
			case .value:	return 1
			case .address:	return 2
			case .direct:	return 3
			case .indirect:	return 4
		}
	}
	
	/// Returns the direct access code associated with this addressing mode.
	var directAccessCode: Int {
		switch self {
			case .value:	return 1
			case .address:	return 2
			case .direct:	return 2
			case .indirect:	return 3
		}
	}
	
}
