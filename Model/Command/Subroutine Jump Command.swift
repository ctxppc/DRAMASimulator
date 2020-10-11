// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct SubroutineJumpCommand : AddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.subroutineJump]
	
	// See protocol.
	static let directAccessOnly = true
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, address: ValueOperand) throws {
		self.destination = address
		self.addressingMode = addressingMode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.subroutineJump
	
	/// The jump destination.
	let destination: ValueOperand
	
	/// The addressing mode for the destination.
	let addressingMode: AddressingMode
	
	// See protocol.
	var addressOperand: ValueOperand? {
		return destination
	}
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		machine[register: .r9].decrement()
		machine.memory[AddressWord(wrapping: machine[register: .r9].signedValue)] = .init(machine.programCounter)
		
		switch addressingMode {
			case .value:	fallthrough
			case .address:	fallthrough
			case .direct:	machine.programCounter = machine.evaluateAddress(destination)
			case .indirect:	machine.programCounter = .init(truncating: machine.memory[machine.evaluateAddress(destination)])
		}
		
	}
	
}
