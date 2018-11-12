// DRAMASimulator © 2018 Constantino Tsarouhas

enum Global {
	
	/// The global is initialised with given literal value.
	case literal(name: String, value: Int)
	
	/// The global is a zero-initialised array of given size.
	case array(name: String, size: Int)
	
	/// The global's name.
	var name: String {
		switch self {
			case .literal(name: let name, value: _):	return name
			case .array(name: let name, size: _):		return name
		}
	}
	
}
