// DRAMASimulator © 2018–2021 Constantino Tsarouhas

struct LoadCommand : BinaryRegisterCommand, RegisterAddressCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.load]
	
	// See protocol.
	init(instruction: Instruction, primaryRegister: Register, secondaryRegister: Register) {
		self.addressingMode = .value
		self.source = .init(base: 0, index: .init(indexRegister: secondaryRegister, modification: nil))
		self.destination = primaryRegister
	}
	
	// See protocol.
	init(instruction: Instruction, addressingMode: AddressingMode? = nil, register: Register, address: ValueOperand) {
		self.addressingMode = addressingMode ?? .direct
		self.source = address
		self.destination = register
	}
	
	// See protocol.
	let instruction = Instruction.load
	
	// See protocol.
	let addressingMode: AddressingMode
	
	/// The value being loaded or loaded from.
	let source: ValueOperand
	
	/// The register being loaded into.
	let destination: Register
	
	// See protocol.
	func execute(on machine: inout Machine) {
		machine[register: destination, updatingConditionState: true] = machine.evaluate(source, mode: addressingMode)
	}
	
	// See protocol.
	var registerOperand: Register? {
		return destination
	}
	
	// See protocol.
	var secondaryRegisterOperand: Register? {
		source.index?.indexRegister
	}
	
	// See protocol.
	var addressOperand: ValueOperand? {
		source
	}
	
}
