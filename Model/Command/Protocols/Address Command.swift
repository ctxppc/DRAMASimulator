// DRAMASimulator © 2018–2020 Constantino Tsarouhas

/// A command that can be stated with only an address argument.
protocol AddressCommand : Command {
	
	/// Initialises a command with given instruction, addressing mode (if any), and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, address: ValueOperand) throws
	
	/// The addressing mode.
	var addressingMode: AddressingMode { get }
	
	/// The address operand, or `nil` if no such operand has been set on this command.
	var addressOperand: ValueOperand? { get }
	
}
