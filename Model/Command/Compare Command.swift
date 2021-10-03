// DRAMASimulator © 2018–2021 Constantino Tsarouhas

struct CompareCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.compare]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		self.addressingMode = .value
		self.firstOperand = primaryRegister
		self.secondOperand = .init(base: 0, index: .init(indexRegister: secondaryRegister, modification: nil))
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode?, register: Register, address: ValueOperand) {
		self.addressingMode = addressingMode ?? .direct
		self.firstOperand = register
		self.secondOperand = address
	}
	
	// See protocol.
	let instruction = Instruction.compare
	
	// See protocol.
	let addressingMode: AddressingMode
	
	/// The register whose value is the first operand and becomes the result.
	let firstOperand: Register
	
	/// The register or memory address whose value is the second operand.
	let secondOperand: ValueOperand
	
	// See protocol.
	func execute(on machine: inout Machine) {
		let secondOperandValue = machine.evaluate(secondOperand, mode: addressingMode)
		machine.conditionState = ConditionState(comparing: machine[register: firstOperand].signedValue, to: secondOperandValue.signedValue)
	}
	
	// See protocol.
	var registerOperand: Register? {
		firstOperand
	}
	
	// See protocol.
	var secondaryRegisterOperand: Register? {
		secondOperand.index?.indexRegister
	}
	
	// See protocol.
	var addressOperand: ValueOperand? {
		secondOperand
	}
	
}
