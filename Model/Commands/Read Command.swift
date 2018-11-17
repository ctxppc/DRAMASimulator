// DRAMASimulator © 2018 Constantino Tsarouhas

struct ReadCommand : NullaryCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.read]
	
	// See protocol.
	init(instruction: Instruction) throws {}
	
	// See protocol.
	let instruction = Instruction.read
	
	// See protocol.
	func execute(on machine: inout Machine) throws {
		machine.state = .waiting
	}
	
}
