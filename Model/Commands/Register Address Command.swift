// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be stated with only a register and an address argument.
protocol RegisterAddressCommand : Command {
	
	/// Initialises a command with given instruction, addressing mode (if any), register, and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: AddressSpecification) throws
	
	/// The register operand, or `nil` if no such operand has been set on this command.
	var registerOperand: Register? { get }
	
	/// The addressing mode.
	var addressingMode: AddressingMode { get }
	
	/// The address operand, or `nil` if no such operand has been set on this command.
	var addressOperand: AddressSpecification? { get }
	
}
