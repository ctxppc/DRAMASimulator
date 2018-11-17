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
	subscript (registerAt register: Register) -> Word {
		get { return registers[register.rawValue] }
		set { registers[register.rawValue] = newValue }
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
	
	/// Evaluates an address specified by given address specification, and performs any pre-indexation or post-indexation before or after invoking a closure handler.
	///
	/// - Parameter specification: A value specifying the address and any indexation on it.
	/// - Parameter handler: A function that uses the evaluated and appropriately indexed address and the machine, a copy of `self` that is copied back upon completion.
	mutating func useAddress(specifiedBy specification: AddressSpecification, handler: (AddressWord, inout Machine) -> ()) {
		if let index = specification.index {
			
			switch index.modification {
				case .preincrement?:	self[registerAt: index.indexRegister].increment()
				case .predecrement?:	self[registerAt: index.indexRegister].decrement()
				default:				break
			}
			
			let computedAddressValue = specification.base.rawValue + self[registerAt: index.indexRegister].rawValue
			let computedAddressWord = AddressWord(wrapping: computedAddressValue)
			handler(computedAddressWord, &self)
			
			switch index.modification {
				case .postincrement?:	self[registerAt: index.indexRegister].increment()
				case .postdecrement?:	self[registerAt: index.indexRegister].decrement()
				default:				break
			}
			
		} else {
			handler(specification.base, &self)
		}
	}
	
	/// Accesses a memory cell specified by given address specification.
	///
	/// - Parameter specification: A value specifying the address and any indexation on it.
	/// - Parameter handler: A function that uses the accessed memory cell's value.
	mutating func accessMemoryCell(specifiedBy specification: AddressSpecification, handler: (Word) -> ()) {
		useAddress(specifiedBy: specification) { address, machine in
			handler(machine[memoryCellAt: address])
		}
	}
	
	/// Accesses a memory cell specified by given address specification.
	///
	/// - Parameter specification: A value specifying the address and any indexation on it.
	/// - Parameter handler: A function that uses and modifies the accessed memory cell's value.
	mutating func accessMemoryCell(specifiedBy specification: AddressSpecification, handler: (inout Word) -> ()) {
		useAddress(specifiedBy: specification) { address, machine in
			handler(&machine[memoryCellAt: address])
		}
	}
	
	/// Accesses a memory cell reference in another memory cell specified by given address specification.
	///
	/// - Parameter referenceSpecification: A value specifying the address to the pointer and any indexation on the first address.
	/// - Parameter handler: A function that uses the referenced memory cell's value (not the pointer).
	mutating func accessReferencedMemoryCell(referenceSpecifiedBy referenceSpecification: AddressSpecification, handler: (Word) -> ()) {
		useAddress(specifiedBy: referenceSpecification) { pointer, machine in
			let truncatedPointer = AddressWord(truncating: machine[memoryCellAt: pointer])
			handler(machine[memoryCellAt: truncatedPointer])
		}
	}
	
	/// Accesses a memory cell reference in another memory cell specified by given address specification.
	///
	/// - Parameter referenceSpecification: A value specifying the address to the pointer and any indexation on the first address.
	/// - Parameter handler: A function that uses and modifies the referenced memory cell's value (not the pointer).
	mutating func accessReferencedMemoryCell(referenceSpecifiedBy referenceSpecification: AddressSpecification, handler: (inout Word) -> ()) {
		useAddress(specifiedBy: referenceSpecification) { pointer, machine in
			let truncatedPointer = AddressWord(truncating: machine[memoryCellAt: pointer])
			handler(&machine[memoryCellAt: truncatedPointer])
		}
	}
	
	/// An array representing empty memory.
	static let emptyMemory = Array(repeating: Word.zero, count: AddressWord.upperUnsignedValue)
	
	/// The index of the next command to be executed, i.e., program counter value.
	var programCounter: AddressWord
	
	/// The condition state.
	///
	/// The machine does not use or modify the condition state but rather commands executed on the machine.
	var conditionState: ConditionState
	enum ConditionState : Int {
		
		case zero		= 0
		case positive	= 1
		case negative	= 2
		
		init(for word: Word) {
			switch word.signedValue {
				case 0:		self = .zero
				case 1...:	self = .positive
				default:	self = .negative
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
	
	/// Whether the machine is halted.
	var halted: Bool = false
	
	/// Executes the next command.
	mutating func executeCommand() throws {
		guard !halted else { return }
		// TODO
	}
	
	/// The command types that machines natively support.
	static let supportedCommands: [Command.Type] = [
		ArithmeticCommand.self
	]
	
}
