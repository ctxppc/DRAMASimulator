// DRAMASimulator © 2018–2021 Constantino Tsarouhas

struct ReadCommand : NullaryCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.read]
	
	// See protocol.
	init(instruction: Instruction) {}
	
	// See protocol.
	let instruction = Instruction.read
	
	// See protocol.
	func execute(on machine: inout Machine) {
		machine.state = .waitingForInput
	}
	
}
