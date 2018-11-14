// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be stated with only a register argument.
protocol UnaryRegisterCommand : Command {
	
	/// Initialises a command with given instruction and register.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, register: Register) throws
	
}
