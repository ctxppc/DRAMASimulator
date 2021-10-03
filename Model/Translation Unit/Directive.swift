// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import Foundation

/// A command to the preprocessor.
protocol Directive : Construct {
	
	// TODO
	
}

enum DirectiveError : Error {
	
	/// The type identifier does not apply to this type of directive.
	case nonapplicableTypeIdentifier
	
}
