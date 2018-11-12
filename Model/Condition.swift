// DRAMASimulator © 2018 Constantino Tsarouhas

enum Condition : String {
	
	case positive = "POS"
	case negative = "NEG"
	case zero = "NUL"
	case nonnegative = "NNEG"
	case nonpositive = "NPOS"
	case nonzero = "NNUL"
	
	init?(rawComparisonValue: String) {
		switch rawComparisonValue {
			case "GR":		self = .positive
			case "KL":		self = .negative
			case "GEL":		self = .zero
			case "GRG":		self = .nonnegative
			case "KLG":		self = .nonpositive
			case "NGEL":	self = .nonzero
			default:		return nil
		}
	}
	
	var rawComparisonValue: String {
		switch self {
			case .positive:		return "GR"
			case .negative:		return "KL"
			case .zero:			return "GEL"
			case .nonnegative:	return "GRG"
			case .nonpositive:	return "KLG"
			case .nonzero:		return "NGEL"
		}
	}
	
}
