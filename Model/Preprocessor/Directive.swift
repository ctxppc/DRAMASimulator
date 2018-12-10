// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A command to the preprocessor.
///
/// Directives are removed from the text being processed but may output text at their location.
protocol Directive {
	
	/// A regular expression matching directives of this type.
	static var regularExpression: NSRegularExpression { get }
	
	/// Initialises a directive with given match.
	///
	/// - Requires: `match` is produced by `Self.regularExpression`.
	///
	/// - Parameter match: The match.
	/// - Parameter source: The source text on which `match` was generated.
	///
	/// - Throws: An error if the matched groups cannot be interpreted.
	init(match: NSTextCheckingResult, in source: String) throws
	
	/// The range in the unprocessed source where the directive is written.
	var fullSourceRange: SourceRange { get }
	
	/// Executes the directive on given preprocessor within given macro expansion.
	///
	/// - Note: The preprocessor automatically removes the directive from the source, i.e., the source substring at `fullSourceRange` is replaced by the empty string.
	func execute(on preprocessor: inout Preprocessor, in expansion: inout MacroExpansion) throws
	
}
