// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value indicating whether another value is smaller than, equal to, or greater than some other value or zero.
enum ConditionState : Int {
	
	case zero		= 0
	case positive	= 1
	case negative	= 2
	
	/// Creates a condition state for given word.
	init(for word: Word) {
		switch word.signedValue {
			case 0:		self = .zero
			case 1...:	self = .positive
			default:	self = .negative
		}
	}
	
	/// Creates a condition state comparing two given operands.
	init(comparing firstOperand: Int, to secondOperand: Int) {
		if firstOperand < secondOperand {
			self = .negative
		} else if firstOperand == secondOperand {
			self = .zero
		} else {
			self = .positive
		}
	}
	
	/// Returns a Boolean value indicating whether the condition state matches given condition.
	func matches(_ condition: Condition) -> Bool {
		switch condition {
			case .positive:		return self == .positive
			case .negative:		return self == .negative
			case .zero:			return self == .zero
			case .nonpositive:	return self != .positive
			case .nonnegative:	return self != .negative
			case .nonzero:		return self != .zero
		}
	}
	
}
