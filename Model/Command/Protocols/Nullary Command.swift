// DRAMASimulator © 2018–2020 Constantino Tsarouhas

/// A command that can be stated with no arguments.
protocol NullaryCommand : Command {
	
	/// Initialises a command with given instruction.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction) throws
	
}
