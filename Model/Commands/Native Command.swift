// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that is representable in machine code.
protocol NativeCommand : Command {
	
	/// The code used to identify the instruction in machine code.
	static var code: Int { get }
	
	/// Returns the addressing mode represented by given code.
	///
	/// The default implementation uses the canonical mapping.
	static func addressingMode(withCode: Int) -> AddressingMode?
	
}
