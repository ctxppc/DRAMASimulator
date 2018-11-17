// DRAMASimulator © 2018 Constantino Tsarouhas

/// An address specified in assembly code.
struct AddressSpecification {
	
	/// The base address.
	///
	/// The base address is written as a signed value in assembly (since it supports negative offsets for indexation operations) but they're evaluated as unsigned values on the machine.
	var base: AddressWord
	
	/// The index to apply on the constant, or `nil` if no indexing is to be applied.
	var index: Index?
	struct Index {
		
		/// The register that contains the index.
		var indexRegister: Register
		
		/// The modification to perform on the index register before or after indexation, or `nil` if the index register is unaffected by indexing.
		var modification: Modification?
		enum Modification {
			case preincrement
			case postincrement
			case predecrement
			case postdecrement
		}
		
	}
	
	/// Evaluates the effective address given the value of the index register.
	///
	/// The method is only meaningful for address specifications with indexation.
	func address(atIndex index: Word) -> AddressWord {
		return AddressWord(truncating: base.rawValue + index.rawValue)
	}
	
}
