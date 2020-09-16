// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct LoadCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.load]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		source = .register(secondaryRegister)
		destination = primaryRegister
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode? = nil, register: Register, address: AddressSpecification) {
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
		
		let value: MachineWord
		switch source {
			
			case .register(let register):
			value = machine[register: register]
			
			case .memory(address: let valueSpec, mode: .value):
			value = MachineWord(wrapping: machine.evaluate(valueSpec).signedValue)
			
			case .memory(address: let addressSpec, mode: .address):
			value = MachineWord(machine.evaluate(addressSpec))
			
			case .memory(address: let addressSpec, mode: .direct):
			value = machine.memory[machine.evaluate(addressSpec)]
			
			case .memory(address: let addressSpec, mode: .indirect):
			let addressOfReference = machine.evaluate(addressSpec)
			let referencedAddress = AddressWord(truncating: machine.memory[addressOfReference])
			value = machine.memory[referencedAddress]
			
		}
		
		machine[register: destination, updatingConditionState: true] = value
		
	}
	
	// See protocol.
	var addressingMode: AddressingMode {
		switch source {
			case .register:								return .value
			case .memory(address: _, mode: let mode):	return mode
		}
	}
	
	// See protocol.
	var registerOperand: Register? {
		return destination
	}
	
	// See protocol.
	var secondaryRegisterOperand: Register? {
		switch source {
			case .register(let register):	return register
			case .memory:					return nil
		}
	}
	
	// See protocol.
	var addressOperand: AddressSpecification? {
		switch source {
			case .register:									return nil
			case .memory(address: let address, mode: _):	return address
		}
	}
	
}
