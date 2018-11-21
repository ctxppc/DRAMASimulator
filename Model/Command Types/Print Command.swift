// DRAMASimulator © 2018 Constantino Tsarouhas

struct PrintCommand : NullaryCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.printInteger]
	
	// See protocol.
	init(instruction: Instruction) {}
	
	// See protocol.
	let instruction = Instruction.printInteger
	
	// See protocol.
	func execute(on machine: inout Machine) {
		// TODO
	}
	
}
