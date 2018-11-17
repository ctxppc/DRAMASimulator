// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value representing a virtual DRAMA machine in some state.
struct Machine {
	
	/// Initialises a machine with given registers, memory cells, program counter, and condition state.
	init(registers: [Word] = defaultRegisters, memoryCells: [Word] = emptyMemory, startingExecutionAt programCounter: AddressWord = .zero, conditionState: ConditionState = .zero) {
		
		precondition(registers.count == Machine.defaultRegisters.count, "Invalid register count")
		precondition(memoryCells.count == Machine.emptyMemory.count, "Invalid memory cell count")
		
		self.registers = registers
		self.memoryCells = memoryCells
		self.programCounter = programCounter
		self.conditionState = conditionState
		
	}
	
	/// The values stored in the registers.
	private var registers: [Word]
	
	/// Accesses a value stored in given register.
	subscript (registerAt register: Register) -> Word {
		get { return registers[register.rawValue] }
		set { registers[register.rawValue] = newValue }
	}
	
	/// Accesses a value stored in given register and updates the condition state based on that value.
	subscript (registerAt register: Register, updatingConditionState updatesConditionState: Bool) -> Word {
		
		mutating get {
			let value = registers[register.rawValue]
			if updatesConditionState {
				conditionState = .init(for: value)
			}
			return value
		}
		
		set {
			registers[register.rawValue] = newValue
			if updatesConditionState {
				conditionState = .init(for: newValue)
			}
		}
		
	}
	
	/// An array representing 10 empty registers.
	static let defaultRegisters = Array(repeating: Word.zero, count: 9) + [stackBase]
	static let stackBase = Word(rawValue: 9000)!
	
	/// The values stored in memory.
	private var memoryCells: [Word]
	
	/// Accesses a memory cell at given address.
	subscript (memoryCellAt address: AddressWord) -> Word {
		get { return memoryCells[address.rawValue] }
		set { memoryCells[address.rawValue] = newValue }
	}
	
	/// Evaluates an address specified by given address specification and performs any specified indexation.
	///
	/// - Parameter specification: A value specifying a base address and any indexation on it.
	///
	/// - Returns: The effective address specified by `specification`.
	mutating func evaluate(_ specification: AddressSpecification) -> AddressWord {
		if let index = specification.index {
			
			switch index.modification {
				case .preincrement?:	self[registerAt: index.indexRegister].increment()
				case .predecrement?:	self[registerAt: index.indexRegister].decrement()
				default:				break
			}
			
			let result = specification.address(atIndex: self[registerAt: index.indexRegister])
			
			switch index.modification {
				case .postincrement?:	self[registerAt: index.indexRegister].increment()
				case .postdecrement?:	self[registerAt: index.indexRegister].decrement()
				default:				break
			}
			
			return result
			
		} else {
			return specification.base
		}
	}
	
	/// An array representing empty memory.
	static let emptyMemory = Array(repeating: Word.zero, count: AddressWord.upperUnsignedValue)
	
	/// The address in memory of the next command to be executed.
	var programCounter: AddressWord
	
	/// The condition state.
	///
	/// The machine does not use or modify the condition state but rather commands executed on the machine.
	var conditionState: ConditionState
	
	/// Whether the machine is halted.
	var halted: Bool = false
	
	/// Executes the next command.
	///
	/// - Requires: The machine is not halted.
	mutating func executeCommand() throws {
		
		precondition(!halted, "The machine is halted.")
		
		let w = self[memoryCellAt: programCounter].digits
		let (opcode, addrMode, indMode, reg, indReg, address) = (partialWord(from: w[0...1]), w[2], w[3], w[4], w[5], partialWord(from: w[6...9]))
		programCounter.increment()
		
		guard let instruction = Instruction(opcode: opcode) else { throw ExecutionError.illegalInstruction(opcode: opcode) }
		guard let commandType = Machine.supportedCommandTypes.first(where: { $0.supportedInstructions.contains(instruction) })
			else { throw ExecutionError.unimplementedInstruction(instruction) }
		
		func addressingMode() throws -> AddressingMode {
			guard let mode = AddressingMode(code: addrMode, directAccessOnly: commandType.directAccessOnly) else { throw ExecutionError.illegalAddressingMode(code: addrMode) }
			return mode
		}
		
		let addressSpecification = AddressSpecification(base: AddressWord(rawValue: address)!, indexRegister: Register(rawValue: indReg)!, mode: indMode)
		
		let command: Command
		switch commandType {
			
			case let type as NullaryCommand.Type:
			command = try type.init(instruction: instruction)
			
			case let type as UnaryRegisterCommand.Type:
			command = try type.init(instruction: instruction, register: Register(rawValue: reg)!)
			
			case let type as BinaryRegisterCommand.Type where try addressingMode() == .value:
			command = try type.init(instruction: instruction, primaryRegister: Register(rawValue: reg)!, secondaryRegister: Register(rawValue: indReg)!)
			
			case let type as RegisterAddressCommand.Type:
			command = try type.init(instruction: instruction, addressingMode: addressingMode(), register: Register(rawValue: reg)!, address: addressSpecification)
			
			case let type as ConditionAddressCommand.Type:
			guard let condition = Condition(code: reg) else { throw ExecutionError.illegalCondition(code: reg) }
			command = try type.init(instruction: instruction, addressingMode: addressingMode(), condition: condition, address: addressSpecification)
			
			default:
			throw ExecutionError.undecodableCommand(type: commandType)
			
		}
		
		try command.execute(on: &self)
		
	}
	
	enum ExecutionError : Error {
		
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
	
	/// The command types that machines natively support.
	static let supportedCommandTypes: [Command.Type] = [
		LoadCommand.self,
		StoreCommand.self,
		ArithmeticCommand.self,
		CompareCommand.self,
		JumpCommand.self,
		ConditionalJumpCommand.self,
		HaltCommand.self
	]
	
}

private func partialWord(from digits: ArraySlice<Int>) -> Int {
	guard let digit = digits.last else { return 0 }
	return partialWord(from: digits.dropLast()) * 10 + digit
}
