// DRAMASimulator © 2018–2021 Constantino Tsarouhas

/// A value representing a virtual DRAMA machine in some state.
struct Machine {
	
	/// Initialises a machine with given registers, memory cells, program counter, and condition state.
	///
	/// - Requires: `registers` has exactly 10 elements.
	/// - Requires: `memoryWords` does not exceed the machine's address space.
	///
	/// - Parameter registers: The machine's registers. The default value is `defaultRegisters`.
	/// - Parameter programCounter: The address of the next instruction to execute. The default value is zero.
	/// - Parameter conditionState: The condition state. The default value is `.zero`.
	init(registers: [MachineWord] = defaultRegisters, programCounter: AddressWord = .zero, conditionState: ConditionState = .zero) {
		precondition(registers.count == Machine.defaultRegisters.count, "Invalid register count")
		self.registers = registers
		self.programCounter = programCounter
		self.conditionState = conditionState
	}
	
	/// The words stored in the machine's registers.
	private var registers: [MachineWord]
	
	/// Accesses a word stored in given register.
	subscript (register register: Register) -> MachineWord {
		get { registers[register.rawValue] }
		set { registers[register.rawValue] = newValue }
	}
	
	/// Accesses a word stored in given register and optionally updates the condition state based on that value.
	subscript (register register: Register, updatingConditionState updatesConditionState: Bool) -> MachineWord {
		
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
	static let defaultRegisters = Array(repeating: MachineWord.zero, count: 9) + [stackBase]
	static let stackBase = MachineWord(rawValue: 9000)!
	
	/// The machine's memory.
	var memory = Memory()
	
	/// Evaluates given operand.
	///
	/// - Parameter operand: A value specifying a base value and any indexation on it.
	///
	/// - Returns: The value specified by `operand`.
	mutating func evaluate(_ operand: ValueOperand) -> MachineWord {
		if let index = operand.index {
			
			switch index.modification {
				case .preincrement?:	self[register: index.indexRegister].increment()
				case .predecrement?:	self[register: index.indexRegister].decrement()
				default:				break
			}
			
			let result = operand.value(adding: self[register: index.indexRegister])
			
			switch index.modification {
				case .postincrement?:	self[register: index.indexRegister].increment()
				case .postdecrement?:	self[register: index.indexRegister].decrement()
				default:				break
			}
			
			return result
			
		} else {
			return operand.value(adding: .zero)
		}
	}
	
	/// Evaluates given operand in given addressing mode.
	///
	/// - Parameter operand: A value specifying a base value and any indexation on it.
	/// - Parameter mode: The addressing mode.
	///
	/// - Returns: The value specified by `operand` and `mode`.
	mutating func evaluate(_ operand: ValueOperand, mode: AddressingMode) -> MachineWord {
		switch mode {
			case .value:	return evaluate(operand)
			case .address:	return .init(evaluateAddress(operand))
			case .direct:	return memory[evaluateAddress(operand)]
			case .indirect:	return memory[.init(truncating: memory[evaluateAddress(operand)])]
		}
	}
	
	/// Evaluates given operand as an address.
	///
	/// This method first evaluates the operand with full precision as a machine word, then truncates the resulting value to get a valid address word.
	///
	/// - Parameter specification: A value specifying a base value and any indexation on it.
	///
	/// - Returns: The value specified by `operand`.
	mutating func evaluateAddress(_ operand: ValueOperand) -> AddressWord {
		.init(truncating: evaluate(operand))
	}
	
	/// The address in memory of the next command to be executed.
	var programCounter: AddressWord
	
	/// The condition state.
	///
	/// The machine does not use or modify the condition state but rather commands executed on the machine.
	var conditionState: ConditionState
	
	/// The general state of the machine.
	var state: State = .ready
	enum State {
		
		/// The machine can perform the next command.
		case ready
		
		/// The machine waits for input.
		///
		/// The client of a machine must request an input value (or use a predefined buffer) and invoke `provideInput()` before resuming execution.
		case waitingForInput
		
		/// The machine has crashed due to an error.
		case crashed(Error)
		
		/// The machine is stopped and can no longer perform commands.
		case halted
		
		var isReady: Bool {
			if case .ready = self {
				return true
			} else {
				return false
			}
		}
		
		var error: Error? {
			if case .crashed(let error) = self {
				return error
			} else {
				return nil
			}
		}
		
		var isWaitingForInput: Bool {
			if case .waitingForInput = self {
				return true
			} else {
				return false
			}
		}
		
		var isHalted: Bool {
			if case .halted = self {
				return true
			} else {
				return false
			}
		}
		
	}
	
	/// Provides input to the machine (in register 0).
	///
	/// - Requires: The machine is waiting for input, i.e., `state == .waitingForInput`.
	mutating func provideInput(_ word: MachineWord) {
		precondition(state.isWaitingForInput, "The machine is not waiting for input.")
		ioMessages.append(.input(word))
		self[register: .r0, updatingConditionState: true] = word
		state = .ready
	}
	
	/// Provides output from the machine (from register 0).
	mutating func provideOutput() {
		ioMessages.append(.output(self[register: .r0, updatingConditionState: true]))
	}
	
	/// The messages inputted into or outputted by the machine.
	private(set) var ioMessages = [IOMessage]()
	enum IOMessage {
		case input(MachineWord)
		case output(MachineWord)
	}
	
	/// Executes the next command.
	///
	/// - Requires: The machine is ready, i.e., `state.isReady`.
	mutating func executeNext() {
		precondition(state.isReady, "The machine is not ready.")
		do {
			let command = try CommandWord(memory[programCounter]).command()
			programCounter.increment()
			try command.execute(on: &self)
		} catch {
			state = .crashed(error)
		}
	}
	
}
