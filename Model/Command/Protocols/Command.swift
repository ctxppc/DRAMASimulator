// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A value that performs modifications on a machine.
protocol Command {
	
	/// The instructions supported by instances of this type.
	static var supportedInstructions: Set<Instruction> { get }
	
	/// A Boolean value indicating whether commands of this type support direct memory access only.
	///
	/// This property is used to determine how the addressing mode is encoded.
	///
	/// The default implementation returns `false`.
	static var directAccessOnly: Bool { get }
	
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
	
	static var directAccessOnly: Bool {
		return false
	}
	
	var nativeRepresentation: Command {
		return self
	}
	
}
