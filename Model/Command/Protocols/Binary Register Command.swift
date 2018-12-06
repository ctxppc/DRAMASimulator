// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be stated with only two register arguments.
protocol BinaryRegisterCommand : Command {
	
	/// Initialises a command with given instruction, primary register, and secondary register.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) throws
	
	/// The primary register operand, or `nil` if no such operand has been set on this command.
	var registerOperand: Register? { get }
	
	/// The secondary register operand, or `nil` if no such operand has been set on this command.
	var secondaryRegisterOperand: Register? { get }
	
}
