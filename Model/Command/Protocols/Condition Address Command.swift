// DRAMASimulator © 2018–2020 Constantino Tsarouhas

/// A command that can be stated with only a condition and an address argument.
protocol ConditionAddressCommand : Command {
	
	/// Initialises a command with given instruction, addressing mode (if any), condition, and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: ValueOperand) throws
	
	/// The condition, or `nil` if no such operand has been set on this command.
	var conditionOperand: Condition? { get }
	
	/// The addressing mode.
	var addressingMode: AddressingMode { get }
	
	/// The address operand, or `nil` if no such operand has been set on this command.
	var addressOperand: ValueOperand? { get }
	
}
