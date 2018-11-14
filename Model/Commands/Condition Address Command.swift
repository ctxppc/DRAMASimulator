// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be stated with only a condition and an address argument.
protocol ConditionAddressCommand : Command {
	
	/// Initialises a command with given instruction, addressing mode (if any), condition, and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: AddressSpecification) throws
	
}
