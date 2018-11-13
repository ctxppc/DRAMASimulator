// DRAMASimulator © 2018 Constantino Tsarouhas

/// A command that can be translated into a native command.
protocol TranslatableCommand : Command {
	
	/// Returns the native representation of `self`.
	func nativeRepresentation() throws -> NativeCommand
	
}
