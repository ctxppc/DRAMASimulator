// DRAMASimulator © 2018 Constantino Tsarouhas

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
	
}
