// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value that performs modifications on a machine.
protocol Command {
	
	/// The instructions supported by instances of this type.
	static var supportedInstructions: Set<Instruction> { get }
	
	/// Initialises a command with given instruction and register (if any).
	init(instruction: Instruction, register: Int?)
	
	/// Initialises a command with given instruction, addressing mode (if any), register (if any), and address.
	///
	/// - Requires: `supportedInstructions.contains(instruction)`.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Int?, address: AddressSpecification) throws
	
	/// Initialises a command with given instruction, addressing mode (if any), register, and address.
	init(instruction: Instruction, addressingMode: AddressingMode?, condition: Condition, address: AddressSpecification) throws
	
	/// Replaces any instances of given labels by their assigned address.
	///
	/// This procedure must be performed before
	mutating func replaceLabels(_ addressesByLabel: [String : AddressWord]) throws
	
	/// Executes the command on given machine.
	///
	/// - Throws: `ExecutionError.nontrivialAddress` if the command's address specification isn't a single address literal.
	func execute(on machine: inout Machine) throws
	
}

enum ArgumentError : Error {
	
	/// The addressing mode is invalid for this command or this command does not take an addressing mode.
	case invalidAddressingMode
	
	/// This command does not take a register.
	case nonnilRegister
	
	/// This command does not take a condition argument.
	case nonnilCondition
	
}

enum ExecutionError : Error {
	
	/// The command could not be executed because the address specification isn't a single address literal.
	///
	/// Replace any labels and fold any constants using the `replaceLabels(_:)` method.
	case nontrivialAddress
	
}
