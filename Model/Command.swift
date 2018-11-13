// DRAMASimulator © 2018 Constantino Tsarouhas

protocol Command {
	
	/// The instruction represented by commands of this type.
	static var instruction: Instruction { get }
	
	/// Initialises a commend of this type without operands.
	init()
	
	/// Initialises a commend of this type with given addressing mode (if any) and address.
	init(addressingMode: AddressingMode?, address: AddressSpecification) throws
	
	/// Initialises a commend of this type with given addressing mode (if any), register, and address.
	init(addressingMode: AddressingMode?, register: Int, address: AddressSpecification) throws
	
	/// Initialises a commend of this type with given addressing mode (if any), register, and address.
	init(addressingMode: AddressingMode?, condition: Condition, address: AddressSpecification) throws
	
}
