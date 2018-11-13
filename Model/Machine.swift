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
	subscript (registerAt index: AddressWord) -> Word {
		get { return registers[index.rawValue] }
		set { registers[index.rawValue] = newValue }
	}
	
	/// An array representing 10 empty registers.
	static let defaultRegisters = Array(repeating: Word.zero, count: 9) + [stackBase]
	static let stackBase = Word(rawValue: 9000)!
	
	/// The values stored in memory.
	private var memoryCells: [Word]
	subscript (memoryCellAt index: AddressWord) -> Word {
		get { return registers[index.rawValue] }
		set { registers[index.rawValue] = newValue }
	}
	
	/// An array representing empty memory.
	static let emptyMemory = Array(repeating: Word.zero, count: AddressWord.range.upperBound - 1)
	
	/// The index of the next command to be executed, i.e., program counter value.
	var programCounter: AddressWord
	
	/// The condition state.
	var conditionState: ConditionState
	enum ConditionState : Int {
		
		case zero		= 0
		case positive	= 1
		case negative	= 2
		
		init(for value: Int) {
			switch value {
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
	
}
