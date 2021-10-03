// DRAMASimulator © 2018–2021 Constantino Tsarouhas

struct JumpCommand : AddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.jump]
	
	// See protocol.
	static let directAccessOnly = true
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, address: ValueOperand) {
		self.destination = address
		self.addressingMode = addressingMode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.jump
	
	/// The jump destination.
	let destination: ValueOperand
	
	/// The addressing mode for the destination.
	let addressingMode: AddressingMode
	
	// See protocol.
	func execute(on machine: inout Machine) {
		switch addressingMode {
			case .value:	fallthrough
			case .address:	fallthrough
			case .direct:	machine.programCounter = machine.evaluateAddress(destination)
			case .indirect:	machine.programCounter = .init(truncating: machine.memory[machine.evaluateAddress(destination)])
		}
		
		
		
	}
	
	// See protocol.
	var addressOperand: ValueOperand? {
		return destination
	}
	
}
