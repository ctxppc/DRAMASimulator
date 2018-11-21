// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value representing a virtual DRAMA machine in some state.
struct Machine {
	
	/// Initialises a machine with given registers, memory cells, program counter, and condition state.
	init(registers: [Word] = defaultRegisters, memoryWords: [Word] = emptyMemory, startingAt programCounter: AddressWord = .zero, conditionState: ConditionState = .zero) {
		
		precondition(registers.count == Machine.defaultRegisters.count, "Invalid register count")
		precondition(memoryWords.count == Machine.emptyMemory.count, "Invalid memory cell count")
		
		self.registers = registers
		self.memoryWords = memoryWords
		self.programCounter = programCounter
		self.conditionState = conditionState
		
	}
	
	/// The words stored in the machine's registers.
	private var registers: [Word]
	
	/// Accesses a word stored in given register.
	subscript (register register: Register) -> Word {
		get { return registers[register.rawValue] }
		set { registers[register.rawValue] = newValue }
	}
	
	/// Accesses a word stored in given register and optionally updates the condition state based on that value.
	subscript (register register: Register, updatingConditionState updatesConditionState: Bool) -> Word {
		
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
	
	/// The words stored in the machine's memory.
	private var memoryWords: [Word]
	
	/// Accesses a memory word at given address.
	subscript (address address: AddressWord) -> Word {
		get { return memoryWords[address.rawValue] }
		set { memoryWords[address.rawValue] = newValue }
	}
	
	/// Evaluates an address specified by given address specification and performs any specified indexation.
	///
	/// - Parameter specification: A value specifying a base address and any indexation on it.
	///
	/// - Returns: The effective address specified by `specification`.
	mutating func evaluate(_ specification: AddressSpecification) -> AddressWord {
		if let index = specification.index {
			
			switch index.modification {
				case .preincrement?:	self[register: index.indexRegister].increment()
				case .predecrement?:	self[register: index.indexRegister].decrement()
				default:				break
			}
			
			let result = specification.address(atIndex: self[register: index.indexRegister])
			
			switch index.modification {
				case .postincrement?:	self[register: index.indexRegister].increment()
				case .postdecrement?:	self[register: index.indexRegister].decrement()
				default:				break
			}
			
			return result
			
		} else {
			return specification.base
		}
	}
	
	/// An array representing empty memory.
	static let emptyMemory = Array(repeating: Word.zero, count: AddressWord.unsignedUpperBound)
	
	/// The address in memory of the next command to be executed.
	var programCounter: AddressWord
	
	/// The condition state.
	///
	/// The machine does not use or modify the condition state but rather commands executed on the machine.
	var conditionState: ConditionState
	
	/// The state in which the machine is.
	var state: State = .ready
	enum State {
		
		/// The machine can perform the next command.
		case ready
		
		/// The machine waits for input in register 0.
		///
		/// The client of a machine must request an input value (or use a predefined buffer), put it in register 0, and set the machine to the ready state before resuming execution.
		case waiting
		
		/// The machine is stopped and can no longer perform commands.
		case halted
		
	}
	
	/// Executes the next command.
	///
	/// - Requires: The machine is ready, i.e., `state == .ready`.
	mutating func executeNext() throws {
		precondition(state == .ready, "The machine is not ready.")
		let command = try CommandWord(self[address: programCounter]).command()
		programCounter.increment()
		try command.execute(on: &self)
	}
	
}
