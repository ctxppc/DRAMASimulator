// DRAMASimulator © 2018 Constantino Tsarouhas

/// An address specified in assembly code.
struct AddressSpecification {
	
	/// The base address.
	var base: AddressWord
	
	/// The index to apply on the constant, or `nil` if no indexing is to be applied.
	var index: Index?
	struct Index {
		
		/// The register that contains the index.
		var indexRegister: Register
		
		/// The modification to perform on the index register before or after indexation.
		var modification: Modification?
		enum Modification {
			case preincrement
			case postincrement
			case predecrement
			case postdecrement
		}
		
	}
	
}
