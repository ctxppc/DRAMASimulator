// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct ArithmeticCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.add, .subtract, .multiply, .divide, .remainder]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		self.instruction = instruction
		firstOperand = primaryRegister
		secondOperand = .register(secondaryRegister)
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: ValueOperand) {
		self.instruction = instruction
		firstOperand = register
		secondOperand = .memory(address: address, mode: addressingMode ?? .direct)
	}
	
	// See protocol.
	let instruction: Instruction
	
	/// The register whose value is the first operand and becomes the result.
	let firstOperand: Register
	
	/// The register or memory address whose value is the second operand.
	let secondOperand: Source
	enum Source {
		case register(Register)
		case memory(address: ValueOperand, mode: AddressingMode)
	}
	
	/// The operation that the command performs on signed integers, given a mutable first operand and an immutable second operand, without any overflow wrapping.
	///
	/// Note that division by zero is defined as yielding zero, regardless of the numerator.
	var primitiveOperation: Operation {
		
		func folding(_ operation: @escaping Operation) -> Operation {
			return { a, b in
				if b == 0 {
					a = 0
				} else {
					operation(&a, b)
				}
			}
		}
		
		switch instruction {
			case .add:			return (+=)
			case .subtract:		return (-=)
			case .multiply:		return (*=)
			case .divide:		return folding(/=)
			case .remainder:	return folding(%=)
			default:			preconditionFailure("Illegal instruction in arithmetic command")
		}
		
	}
	
	/// A function that takes two signed integers, performs some arithmetic operation on them, and stores the result in the first operand.
	typealias Operation = (inout Int, Int) -> ()
	
	// See protocol.
	func execute(on machine: inout Machine) {
		
		let secondOperandValue: Int
		switch secondOperand {
			
			case .register(let register):
			secondOperandValue = machine[register: register].signedValue
			
			case .memory(address: let valueOperand, mode: .value):
			secondOperandValue = machine.evaluate(valueOperand).signedValue
			
			case .memory(address: let addressOperand, mode: .address):
			secondOperandValue = machine.evaluate(addressOperand).unsignedValue
			
			case .memory(address: let addressOperand, mode: .direct):
			secondOperandValue = machine.memory[machine.evaluateAddress(addressOperand)].signedValue
			
			case .memory(address: let addressOperand, mode: .indirect):
			secondOperandValue = machine.memory[.init(truncating: machine.memory[machine.evaluateAddress(addressOperand)])].signedValue
			
		}
		
		machine[register: firstOperand, updatingConditionState: true].modifySignedValueWithWrapping { firstOperandValue in
			primitiveOperation(&firstOperandValue, secondOperandValue)
		}
		
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
	var addressOperand: ValueOperand? {
		switch secondOperand {
			case .register:									return nil
			case .memory(address: let address, mode: _):	return address
		}
	}
	
}
