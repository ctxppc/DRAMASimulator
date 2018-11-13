// DRAMASimulator © 2018 Constantino Tsarouhas

/// A value representing an assembled program, ready to be loaded into a machine.
struct Executable {
	
	/// The executable's commands.
	var commands: [NativeCommand] = []
	
	/// The executable's globals.
	var globals: [Global] = []
	
}
