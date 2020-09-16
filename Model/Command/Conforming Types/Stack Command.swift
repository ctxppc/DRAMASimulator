// DRAMASimulator © 2018–2020 Constantino Tsarouhas

struct StackCommand : UnaryRegisterCommand {
	
	// See protocol.
	static let supportedInstructions: Set = [Instruction.push, .pop]
	
	// See protocol.
	init(instruction: Instruction, register: Register) {
		self.instruction = instruction
		self.register = register
	}
	
	// See protocol.
	let instruction: Instruction
	
	/// The register whose value is pushed to the stack or wherein the popped value is written.
	let register: Register
	
	// See protocol.
	var registerOperand: Register? {
		return register
	}
	
	// See protocol.
	var nativeRepresentation: Command {
		switch instruction {
			case .push:	return StoreCommand(instruction: .store, register: register, address: .init(base: .zero, index: .init(indexRegister: .r9, modification: .preincrement)))
			case .pop:	return LoadCommand(instruction: .load, register: register, address: .init(base: .zero, index: .init(indexRegister: .r9, modification: .postdecrement)))
			default:	preconditionFailure("Unsupported instruction for stack command")
		}
	}
	
	// See protocol.
	func execute(on machine: inout Machine) throws {
		try nativeRepresentation.execute(on: &machine)
	}
	
}
