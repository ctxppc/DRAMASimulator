// DRAMASimulator © 2018 Constantino Tsarouhas

struct SubroutineReturnCommand : NullaryCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.subroutineReturn]
	
	// See protocol.
	init(instruction: Instruction) {}
	
	// See protocol.
	let instruction = Instruction.subroutineReturn
	
	// See protocol.
	func execute(on machine: inout Machine) {
		machine.programCounter = AddressWord(truncating: machine[register: .r9])
		machine[register: .r9].increment()
	}
	
}
