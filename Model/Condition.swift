// DRAMASimulator © 2018–2020 Constantino Tsarouhas

enum Condition : String {
	
	case positive = "POS"
	case negative = "NEG"
	case zero = "NUL"
	case nonpositive = "NPOS"
	case nonnegative = "NNEG"
	case nonzero = "NNUL"
	
	init?(rawComparisonValue: String) {
		switch rawComparisonValue {
			case "GR":		self = .positive
			case "KL":		self = .negative
			case "GEL":		self = .zero
			case "KLG":		self = .nonpositive
			case "GRG":		self = .nonnegative
			case "NGEL":	self = .nonzero
			default:		return nil
		}
	}
	
	init?(code: Int) {
		switch code {
			case 1:	self = .zero
			case 2:	self = .nonnegative
			case 3:	self = .nonpositive
			case 6:	self = .positive
			case 7:	self = .negative
			case 8:	self = .nonzero
			case _:	return nil
		}
	}
	
	var rawComparisonValue: String {
		switch self {
			case .positive:		return "GR"
			case .negative:		return "KL"
			case .zero:			return "GEL"
			case .nonpositive:	return "KLG"
			case .nonnegative:	return "GRG"
			case .nonzero:		return "NGEL"
		}
	}
	
	var code: Int {
		switch self {
			case .zero:			return 1
			case .nonnegative:	return 2
			case .nonpositive:	return 3
			case .positive:		return 6
			case .negative:		return 7
			case .nonzero:		return 8
		}
	}
	
}
