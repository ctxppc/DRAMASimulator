// DRAMASimulator © 2018 Constantino Tsarouhas

struct CommandWord {
	
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
