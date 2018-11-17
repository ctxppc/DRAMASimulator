// DRAMASimulator © 2018 Constantino Tsarouhas

struct LoadCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.load]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		source = .register(secondaryRegister)
		destination = primaryRegister
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: AddressSpecification) {
		source = .memory(address: address, mode: addressingMode ?? .direct)
		destination = register
	}
	
	// See protocol.
	let instruction = Instruction.load
	
	/// The register or memory address being loaded from.
	let source: Source
	enum Source {
		case register(Register)
		case memory(address: AddressSpecification, mode: AddressingMode)
	}
	
	/// The register being loaded into.
	let destination: Register
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		let value: Word
		switch source {
			
			case .register(let register):
			value = machine[registerAt: register]
			
			case .memory(address: let valueSpec, mode: .value):
			value = Word(rawValue: machine.evaluate(valueSpec).signedValue)!
			
			case .memory(address: let addressSpec, mode: .address):
			value = Word(machine.evaluate(addressSpec))
			
			case .memory(address: let addressSpec, mode: .direct):
			value = machine[memoryCellAt: machine.evaluate(addressSpec)]
			
			case .memory(address: let addressSpec, mode: .indirect):
			let addressOfReference = machine.evaluate(addressSpec)
			let referencedAddress = AddressWord(truncating: machine[memoryCellAt: addressOfReference])
			value = machine[memoryCellAt: referencedAddress]
			
		}
		
		machine[registerAt: destination, updatingConditionState: true] = value
		
	}
	
}
