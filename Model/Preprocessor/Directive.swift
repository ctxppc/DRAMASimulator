// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A command to the preprocessor.
///
/// Directives are removed from the text being processed but may output text at their location.
protocol Directive {
	
	/// The range in the unprocessed source where the directive is written.
	var fullSourceRange: SourceRange { get }
	
	// TODO
	
}
