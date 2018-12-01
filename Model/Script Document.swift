// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptDocument : UIDocument {
	
	/// The script.
	var script = Script(from: "")
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data else { throw ReadingError.unsupportedFormat }
		guard let text = String(data: data, encoding: .utf8) else { throw ReadingError.decodingError }
		script = .init(from: text)
	}
	
	/// An error that occurs during reading a script file.
	enum ReadingError : Error {
		case unsupportedFormat
		case decodingError
	}
	
    override func contents(forType typeName: String) throws -> Any {
		guard let data = script.sourceText.data(using: .utf8) else { throw WritingError.encodingError }
        return data
    }
	
	/// An error that occurs during writing a script file.
	enum WritingError : Error {
		case encodingError
	}
	
}
