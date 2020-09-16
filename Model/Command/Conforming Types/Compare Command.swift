// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct CompareCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.compare]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		firstOperand = primaryRegister
		secondOperand = .register(secondaryRegister)
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: AddressSpecification) {
		firstOperand = register
		secondOperand = .memory(address: address, mode: addressingMode ?? .direct)
	}
	
	// See protocol.
	let instruction = Instruction.compare
	
	/// The register whose value is the first operand and becomes the result.
	let firstOperand: Register
	
	/// The register or memory address whose value is the second operand.
	let secondOperand: Source
	enum Source {
		case register(Register)
		case memory(address: AddressSpecification, mode: AddressingMode)
	}
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		let secondOperandValue: Int
		switch secondOperand {
			
			case .register(let register):
			secondOperandValue = machine[register: register].signedValue
			
			case .memory(address: let valueSpec, mode: .value):
			secondOperandValue = machine.evaluate(valueSpec).signedValue
			
			case .memory(address: let addressSpec, mode: .address):
			secondOperandValue = machine.evaluate(addressSpec).unsignedValue
			
			case .memory(address: let addressSpec, mode: .direct):
			secondOperandValue = machine.memory[machine.evaluate(addressSpec)].signedValue
			
			case .memory(address: let addressSpec, mode: .indirect):
			let addressOfReference = machine.evaluate(addressSpec)
			let referencedAddress = AddressWord(truncating: machine.memory[addressOfReference])
			secondOperandValue = machine.memory[referencedAddress].signedValue
			
		}
		
		machine.conditionState = ConditionState(comparing: machine[register: firstOperand].signedValue, to: secondOperandValue)
		
	}
	
	// See protocol.
	var addressingMode: AddressingMode {
		switch secondOperand {
			case .register:								return .value
			case .memory(address: _, mode: let mode):	return mode
		}
	}
	
	var registerOperand: Register? {
		return firstOperand
	}
	
	var secondaryRegisterOperand: Register? {
		switch secondOperand {
			case .register(let register):	return register
			case .memory:					return nil
		}
	}
	
	// See protocol.
	var addressOperand: AddressSpecification? {
		switch secondOperand {
			case .register:									return nil
			case .memory(address: let address, mode: _):	return address
		}
	}
	
}
