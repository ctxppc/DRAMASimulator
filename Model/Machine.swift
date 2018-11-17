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
	///
	/// - Requires: The machine is not halted.
	mutating func executeCommand() throws {
		precondition(!halted, "The machine is halted.")
		// TODO
	}
	
	/// The command types that machines natively support.
	static let supportedCommands: [Command.Type] = [
		LoadCommand.self,
		StoreCommand.self,
		ArithmeticCommand.self
	]
	
}
