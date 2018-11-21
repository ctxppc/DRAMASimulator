// DRAMASimulator © 2018 Constantino Tsarouhas

struct CommandWord {
	
	/// Creates a command word with fully unitialised digits (i.e., 9).
	init() {
		self.init(Word(rawValue: 99999_99999)!)
	}
	
	/// Creates a command word for given word.
	init(_ base: Word) {
		self.base = base
	}
	
	/// The command represented as a word.
	var base: Word
	
	/// A code identifying the instruction.
	var opcode: Int {
		get { return base[digitsAt: 8...9] }
		set { base[digitsAt: 8...9] = newValue }
	}
	
	/// A code identifying the addressing mode.
	var addressingMode: Int {
		get { return base[digitAt: 7] }
		set { base[digitAt: 7] = newValue }
	}
	
	/// A code identifying the indexing mode.
	var indexingMode: Int {
		get { return base[digitAt: 6] }
		set { base[digitAt: 6] = newValue }
	}
	
	/// The (primary) register, or alternatively the code identifying the condition for a condition address command.
	var register: Int {
		get { return base[digitAt: 5] }
		set { base[digitAt: 5] = newValue }
	}
	
	/// The index register, or alternatively the secondary register for a binary register command.
	var indexRegister: Int {
		get { return base[digitAt: 4] }
		set { base[digitAt: 4] = newValue }
	}
	
	/// The address or value.
	var address: Int {
		get { return base[digitsAt: 0...3] }
		set { base[digitsAt: 0...3] = newValue }
	}
	
}

extension CommandWord {
	
	/// Encodes given command or a native representation thereof into a word.
	///
	/// - Requires: `command` is encodable as a word.
	///
	/// - Parameter command: The command to convert into a word.
	init(_ c: Command) {
		
		self.init()
		
		let command: Command
		(command, self.opcode) = {
			if let opcode = c.instruction.opcode {
				return (c, opcode)
			} else {
				let c = c.nativeRepresentation
				guard let opcode = c.instruction.opcode else { preconditionFailure("Native command has no opcode") }
				return (c, opcode)
			}
		}()
		
		if let command = command as? ConditionAddressCommand, let condition = command.conditionOperand, let address = command.addressOperand {
			self.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
			self.indexingMode = address.mode
			self.register = condition.code
			self.indexRegister = address.index?.indexRegister.rawValue ?? 0
			self.address = address.base.rawValue
		} else if let command = command as? RegisterAddressCommand, let register = command.registerOperand, let address = command.addressOperand {
			self.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
			self.indexingMode = address.mode
			self.register = register.rawValue
			self.indexRegister = address.index?.indexRegister.rawValue ?? 0
			self.address = address.base.rawValue
		} else if let command = command as? AddressCommand, let address = command.addressOperand {
			self.addressingMode = command.addressingMode.code(directAccessOnly: type(of: command).directAccessOnly)
			self.indexingMode = address.mode
			self.register = 0
			self.indexRegister = address.index?.indexRegister.rawValue ?? 0
			self.address = address.base.rawValue
		} else if let command = command as? BinaryRegisterCommand, let primaryRegister = command.registerOperand, let secondaryRegister = command.secondaryRegisterOperand {
			self.addressingMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
			self.indexingMode = 2
			self.register = primaryRegister.rawValue
			self.indexRegister = secondaryRegister.rawValue
			self.address = 0
		} else if let command = command as? UnaryRegisterCommand, let register = command.registerOperand {
			self.addressingMode = AddressingMode.value.code(directAccessOnly: type(of: command).directAccessOnly)
			self.register = register.rawValue
		}
		
	}
	
	/// Decodes a command from the word.
	func command() throws -> Command {
		
		guard let instruction = Instruction(opcode: opcode) else { throw DecodingError.illegalInstruction(opcode: opcode) }
		guard let commandType = supportedCommandTypes.first(where: { $0.supportedInstructions.contains(instruction) })
			else { throw DecodingError.unimplementedInstruction(instruction) }
		
		func addressingMode() throws -> AddressingMode {
			guard let mode = AddressingMode(code: self.addressingMode, directAccessOnly: commandType.directAccessOnly) else { throw DecodingError.illegalAddressingMode(code: self.addressingMode) }
			return mode
		}
		
		let address = AddressSpecification(base: AddressWord(rawValue: self.address)!, indexRegister: Register(rawValue: indexRegister)!, mode: indexingMode)
		
		switch commandType {
			
			case let type as NullaryCommand.Type:
			return try type.init(instruction: instruction)
			
			case let type as UnaryRegisterCommand.Type:
			return try type.init(instruction: instruction, register: Register(rawValue: register)!)
			
			case let type as BinaryRegisterCommand.Type where try addressingMode() == .value:
			return try type.init(instruction: instruction, primaryRegister: Register(rawValue: register)!, secondaryRegister: Register(rawValue: indexRegister)!)
			
			case let type as AddressCommand.Type:
			return try type.init(instruction: instruction, addressingMode: addressingMode(), address: address)
			
			case let type as RegisterAddressCommand.Type:
			return try type.init(instruction: instruction, addressingMode: addressingMode(), register: Register(rawValue: register)!, address: address)
			
			case let type as ConditionAddressCommand.Type:
			guard let condition = Condition(code: register) else { throw DecodingError.illegalCondition(code: register) }
			return try type.init(instruction: instruction, addressingMode: addressingMode(), condition: condition, address: address)
			
			default:
			throw DecodingError.undecodableCommand(type: commandType)
			
		}
		
	}
	
	enum DecodingError : Error {
		
		/// The opcode is illegal.
		case illegalInstruction(opcode: Int)
		
		/// The instruction is not implemented.
		case unimplementedInstruction(Instruction)
		
		/// The addressing mode code is illegal.
		case illegalAddressingMode(code: Int)
		
		/// The condition code is illegal.
		case illegalCondition(code: Int)
		
		/// The command type does not have a decodable structure.
		case undecodableCommand(type: Command.Type)
		
	}
	
}
