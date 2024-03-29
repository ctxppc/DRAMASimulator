// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A value that identifies the kind of operation a command performs.
enum Instruction : String, Hashable {
	
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
	
	/// Returns the instruction represented by given opcode or `nil` if the opcode isn't known.
	init?(opcode: Int) {
		switch opcode {
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
			case 41:	self = .subroutineJump
			case 42:	self = .subroutineReturn
			case 71:	self = .read
			case 72:	self = .printInteger
			case 73:	self = .printNewline
			case 74:	self = .printString
			case 99:	self = .halt
			default:	return nil
		}
	}
	
	/// The opcode for the instruction, or `nil` if the instruction cannot be represented natively.
	var opcode: Int? {
		switch self {
			case .load:				return 11
			case .store:			return 12
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
			case .printInteger:		return 72
			case .printString:		return 74
			case .printNewline:		return 73
			case .push:				return nil
			case .pop:				return nil
			case .halt:				return 99
		}
	}
	
	/// The command type that implements the instruction, or `nil` if the instruction isn't implemented.
	var commandType: Command.Type? {
		return supportedCommandTypes.first(where: { $0.supportedInstructions.contains(self) })
	}
	
}

extension Instruction {
	
	init(in source: String, at range: SourceRange) throws {
		let mnemonic = source[range].uppercased()
		guard let instruction = Instruction(rawValue: mnemonic) else { throw ParsingError.unknownMnemonic(mnemonic) }
		self = instruction
	}
	
	enum ParsingError : LocalizedError {
		
		/// An unknown mnemonic is specified.
		case unknownMnemonic(String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .unknownMnemonic(let mnemonic):	return "Onbekend bevel “\(mnemonic)”"
			}
		}
		
	}
	
}

/// The command types supported by the DRAMA Simulator.
private let supportedCommandTypes: [Command.Type] = [
	LoadCommand.self,
	StoreCommand.self,
	ArithmeticCommand.self,
	CompareCommand.self,
	JumpCommand.self,
	ConditionalJumpCommand.self,
	ReadCommand.self,
	PrintCommand.self,
	StackCommand.self,
	SubroutineJumpCommand.self,
	SubroutineReturnCommand.self,
	HaltCommand.self
]
