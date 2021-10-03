// DRAMASimulator © 2018–2021 Constantino Tsarouhas

struct HaltCommand : NullaryCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.halt]
	
	// See protocol.
	init(instruction: Instruction) throws {}
	
	// See protocol.
	let instruction = Instruction.halt
	
	// See protocol.
	func execute(on machine: inout Machine) {
		machine.state = .halted
	}
	
}
