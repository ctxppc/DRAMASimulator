// DRAMASimulator © 2018–2021 Constantino Tsarouhas

/// A command that can be stated with only a register argument.
protocol UnaryRegisterCommand : Command {
	
	/// Initialises a command with given instruction and register.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, register: Register) throws
	
	/// The register operand, or `nil` if no such operand has been set on this command.
	var registerOperand: Register? { get }
	
}
