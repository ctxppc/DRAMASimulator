// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct StoreCommand : RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.store]
	
	// See protocol.
	static let directAccessOnly = true
	
	// See protocol.
	init(instruction: Instruction, addressingMode mode: AddressingMode? = nil, register: Register, address: AddressSpecification) {
		source = register
		destination = address
		addressingMode = mode ?? .direct
	}
	
	// See protocol.
	let instruction = Instruction.store
	
	/// The addressing mode.
	let addressingMode: AddressingMode
	
	/// The register whose value is being stored.
	let source: Register
	
	/// The memory address being stored into.
	let destination: AddressSpecification
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		let destinationAddress: AddressWord
		switch addressingMode {
			case .value:	fallthrough
			case .address:	fallthrough
			case .direct:	destinationAddress = machine.evaluate(destination)
			case .indirect:	destinationAddress = .init(truncating: machine.memory[machine.evaluate(destination)])
		}
		
		machine.memory[destinationAddress] = machine[register: source, updatingConditionState: true]
		
	}
	
	// See protocol.
	var registerOperand: Register? {
		return source
	}
	
	// See protocol.
	var addressOperand: AddressSpecification? {
		return destination
	}
	
}
