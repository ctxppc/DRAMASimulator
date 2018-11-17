// DRAMASimulator © 2018 Constantino Tsarouhas

struct JumpCommand : AddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.jump]
	
	// See protocol.
	static let directAccessOnly = true
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, address: AddressSpecification) {
		self.destination = address
		self.addressingMode = addressingMode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.jump
	
	/// The jump destination.
	let destination: AddressSpecification
	
	/// The addressing mode for the destination.
	let addressingMode: AddressingMode
	
	// See protocol.
	func execute(on machine: inout Machine) throws {
		switch addressingMode {
			case .value:	fallthrough
			case .address:	fallthrough
			case .direct:	machine.programCounter = machine.evaluate(destination)
			case .indirect:	machine.programCounter = .init(truncating: machine[memoryCellAt: machine.evaluate(destination)])
		}
	}
	
}
