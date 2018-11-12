// DRAMASimulator © 2018 Constantino Tsarouhas

enum Instruction : String {
	
	case load				= "HIA"
	case store				= "BIG"
	
	case add				= "OPT"
	case subtract			= "AFT"
	case multiply			= "VER"
	case divide				= "DEL"
	case remainder			= "MOD"
	
	case read				= "LEZ"
	case printInteger		= "DRU"
	case printString		= "DRS"
	case printNewline		= "NWL"
	
	case jump				= "SPR"
	case compare			= "VGL"
	case conditionalJump	= "VSP"
	
	case subroutineJump		= "SBR"
	case subroutineReturn	= "KTG"
	
	case push				= "BST"
	case pop				= "HST"
	
	case halt				= "STP"
	
	init?(code: Int) {
		switch code {
			case 11:	self = .load
			case 12:	self = .store
			case 21:	self = .add
			case 22:	self = .subtract
			case 23:	self = .multiply
			case 24:	self = .divide
			case 25:	self = .remainder
			case 31:	self = .compare
			case 32:	self = .jump
			case 33:	self = .conditionalJump
			case 71:	self = .read
			case 73:	self = .printInteger
			case 74:	self = .printString
			case 99:	self = .halt
			default:	return nil
		}
	}
	
	var code: Int {
		switch self {
			case .load:				return 11
			case .pop:				return 11
			case .store:			return 12
			case .push:				return 12
			case .add:				return 21
			case .subtract:			return 22
			case .multiply:			return 23
			case .divide:			return 24
			case .remainder:		return 25
			case .compare:			return 31
			case .jump:				return 32
			case .conditionalJump:	return 33
			case .subroutineJump:	return 41
			case .subroutineReturn:	return 42
			case .read:				return 71
			case .printInteger:		return 73
			case .printNewline:		return 73
			case .printString:		return 74
			case .halt:				return 99
		}
	}
	
}
