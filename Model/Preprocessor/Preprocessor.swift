// DRAMASimulator © 2018 Constantino Tsarouhas

import Foundation

/// A value that transforms an unprocessed source into a processed source.
struct ProcessableSource {
	
	/// Initialises a preprocessor with given source text.
	init(from text: String) throws {
		unprocessedSourceText = text
		macros = []		// TODO
		directives = []	// TODO
	}
	
	/// The unprocessed source text.
	let unprocessedSourceText: String
	
	/// The macros defined in the source.
	let macros: [Macro]
	
	/// The directives in the source.
	let directives: [Directive]
	
}
