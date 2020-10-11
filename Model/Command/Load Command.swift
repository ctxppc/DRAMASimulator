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
	init(instruction: Instruction, addressingMode: AddressingMode? = nil, register: Register, address: ValueOperand) {
		source = .memory(address: address, mode: addressingMode ?? .direct)
		destination = register
	}
	
	// See protocol.
	let instruction = Instruction.load
	
	/// The register or memory address being loaded from.
	let source: Source
	enum Source {
		case register(Register)
		case memory(address: ValueOperand, mode: AddressingMode)
	}
	
	/// The register being loaded into.
	let destination: Register
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		let value: MachineWord
		switch source {
			
			case .register(let register):
			value = machine[register: register]
			
			case .memory(address: let operand, mode: .value):
			value = machine.evaluate(operand)					// no truncation, even if the index register pushes it beyond the address space
			
			case .memory(address: let operand, mode: .address):
			value = .init(machine.evaluateAddress(operand))		// round-trip to AddressWord because truncation is required here
			
			case .memory(address: let addressSpec, mode: .direct):
			value = machine.memory[machine.evaluateAddress(addressSpec)]
			
			case .memory(address: let addressSpec, mode: .indirect):
			value = machine.memory[.init(truncating: machine.memory[machine.evaluateAddress(addressSpec)])]
			
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
	var addressOperand: ValueOperand? {
		switch source {
			case .register:									return nil
			case .memory(address: let address, mode: _):	return address
		}
	}
	
}
