// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be stated with only an address argument.
protocol AddressCommand : Command {
	
	/// Initialises a command with given instruction, addressing mode (if any), and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, address: AddressSpecification) throws
	
}
