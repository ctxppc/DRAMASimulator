// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A command to the preprocessor.
protocol Directive {
	
	init?(from preprocessor: inout Preprocessor) throws
	
	// TODO
	
}
