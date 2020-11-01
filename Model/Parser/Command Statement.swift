// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A statement that represents a command.
struct CommandStatement : Statement {
	
	// See protocol.
	init(from parser: inout Parser) throws {
		
		guard let instructionUnit = parser.consume(IdentifierLexicalUnit.self) else { throw Error.missingInstruction }
		let mnemonic = instructionUnit.identifier
		guard let instruction = Instruction(rawValue: mnemonic) ?? Instruction(rawValue: mnemonic.uppercased())
				?? Instruction(rawValue: mnemonic.lowercased()) else { throw Error.unknownInstruction(mnemonic: mnemonic) }
		self.instruction = instruction
		
		self.addressingMode = parser.consume(AddressingModeLexicalUnit.self)?.addressingMode
		
		if let firstArgument = try? parser.parse(Argument.self) {
			var arguments = [firstArgument]
			while parser.consume(ArgumentSeparatorLexicalUnit.self) != nil {
				arguments.append(try parser.parse(Argument.self))
			}
			self.arguments = arguments
		} else {
			self.arguments = []
		}
		
		self.lexicalUnits = .init(parser.consumedLexicalUnits)
		
	}
	
	/// The instruction.
	let instruction: Instruction
	
	/// The addressing mode.
	let addressingMode: AddressingMode?
	
	/// The command's arguments.
	let arguments: [Argument]
	
	// See protocol.
	let lexicalUnits: [LexicalUnit]
	
	// See protocol.
	let wordCount = 1
	
	/// Returns the command encoded by this statement.
	func command(addressesBySymbol: [String : Int]) throws -> Command {
		
		let type = instruction.commandType
		switch arguments.count {
			
			case 0:
			if let type = type as? NullaryCommand.Type {
				return try type.init(instruction: instruction)
			}
			
			case 1:
			if case .register(let register) = arguments[0], let type = type as? UnaryRegisterCommand.Type {
				return try type.init(instruction: instruction, register: register)
			} else if case .address(let address) = arguments[0], let type = type as? AddressCommand.Type {
				return try type.init(
					instruction:	instruction,
					addressingMode:	addressingMode,
					address:		ValueOperand(
						base:	address.effectiveValue(addressesBySymbol: addressesBySymbol),
						index:	ValueOperand.Index(from: address.indexRegister)
					)
				)
			}
				
			case 2:
			if case .register(let first) = arguments[0], case .register(let second) = arguments[1], let type = type as? BinaryRegisterCommand.Type {
				return try type.init(instruction: instruction, primaryRegister: first, secondaryRegister: second)
			} else if case .register(let register) = arguments[0], case .address(let address) = arguments[1], let type = type as? RegisterAddressCommand.Type {
				return try type.init(
					instruction:	instruction,
					addressingMode:	addressingMode,
					register: 		register,
					address:		ValueOperand(
						base:	address.effectiveValue(addressesBySymbol: addressesBySymbol),
						index:	ValueOperand.Index(from: address.indexRegister)
					)
				)
			} else if case .condition(let condition) = arguments[0], case .address(let address) = arguments[1], let type = type as? ConditionAddressCommand.Type {
				return try type.init(
					instruction:	instruction,
					addressingMode:	addressingMode,
					condition:		condition,
					address:		ValueOperand(
						base:	address.effectiveValue(addressesBySymbol: addressesBySymbol),
						index:	ValueOperand.Index(from: address.indexRegister)
					)
				)
			}
			
			default:
			break
			
		}
		
		throw Error.incorrectArgumentFormat(instruction: instruction)
		
	}
	
	// See protocol.
	func words(addressesBySymbol: [String : Int]) throws -> AnyCollection<MachineWord> {
		.init(CollectionOfOne(try CommandWord(command(addressesBySymbol: addressesBySymbol)).base))
	}
	
	/// An error parsing or lowering a command statement.
	enum Error : LocalizedError {
		
		/// The command is missing an instruction.
		case missingInstruction
		
		/// The command's mnemonic c.
		case unknownInstruction(mnemonic: String)
		
		/// The command has an incorrect format, e.g., register operands for an address–condition command type.
		case incorrectArgumentFormat(instruction: Instruction)
		
		/// The command has a disallowed operator for forming the address operand.
		case disallowedAddressOperator
		
		/// The command has a disallowed operator on the index register.
		case disallowedIndexRegisterOperator
		
		/// The command has a missing operator for forming the address operand.
		case missingAddressOperator
		
		/// The command has an invalid address format.
		case invalidAddressFormat
		
		/// The command references a symbol that isn't defined in the program.
		case undefinedSymbol(String)
		
		// See protocol.
		var errorDescription: String? {
			switch self {
				case .missingInstruction:							return "Geen bevel"
				case .unknownInstruction(mnemonic: let m):			return "“\(m)”-bevel niet gekend of ondersteund"
				case .incorrectArgumentFormat(instruction: let i):	return "\(i.rawValue)-bevel met onjuiste soort argumenten"
				case .disallowedAddressOperator:					return "Bevel met adres met andere operator dan + of -"
				case .disallowedIndexRegisterOperator:				return "Bevel met ongeldige operators in indexregister"
				case .missingAddressOperator:						return "Bevel met adres met ontbrekende operator"
				case .invalidAddressFormat:							return "Bevel met ongeldig adres"
				case .undefinedSymbol(let symbol):					return "“\(symbol)” is niet gedefiniëerd"
			}
		}
		
	}
	
}
