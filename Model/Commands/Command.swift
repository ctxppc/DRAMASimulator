// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value that performs modifications on a machine.
protocol Command {
	
	/// The instructions supported by instances of this type.
	static var supportedInstructions: Set<Instruction> { get }
	
	/// The instruction.
	var instruction: Instruction { get }
	
	/// The native representation of `self`.
	///
	/// - Invariant: `nativeRepresentation.instruction.opcode` is not `nil`.
	///
	/// The default implementation returns `self` and must be overridden by conforming types if `self.instruction.opcode` is `nil`.
	var nativeRepresentation: Command { get }
	
	/// Executes the command on given machine.
	func execute(on machine: inout Machine) throws
	
}

extension Command {
	var nativeRepresentation: Command {
		return self
	}
}

enum CommandArgumentError : Error {
	
	/// The addressing mode is invalid for this command.
	case invalidAddressingMode
	
}
