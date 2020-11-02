// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import Foundation

/// A command to the preprocessor.
///
/// Directives are removed from the text being processed but may output text at their location.
protocol Directive {
	
	init?(from preprocessor: inout Preprocessor) throws
	
	// TODO
	
}
