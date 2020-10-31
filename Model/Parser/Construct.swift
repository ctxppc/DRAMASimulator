// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// A syntax tree generated during parsing.
protocol Construct {
	
	/// Parses a construct of this type using given parser.
	///
	/// - Parameter parser: The parser. It may be affected, even if this initialiser fails.
	///
	/// - Throws: An error if parsing fails.
	init(from parser: inout Parser) throws
	
}
