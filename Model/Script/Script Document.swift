// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptDocument : UIDocument {
	
	/// The source text.
	var sourceText: String = "" {
		didSet { delegate?.scriptDocumentSourceTextDidChange(self) }
	}
	
	/// Returns a machine after loading the program.
	func initialMachine() throws -> Machine {
		return Machine(memoryWords: try Program(from: Script(from: sourceText)).machineWords())
	}
	
	/// The document's delegate.
	weak var delegate: ScriptDocumentDelegate?
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data else { throw ReadingError.unsupportedFormat }
		guard let text = String(data: data, encoding: .utf8) else { throw ReadingError.decodingError }
		sourceText = text
	}
	
	/// An error that occurs during reading a script file.
	enum ReadingError : Error {
		case unsupportedFormat
		case decodingError
	}
	
    override func contents(forType typeName: String) throws -> Any {
		guard let data = sourceText.data(using: .utf8) else { throw WritingError.encodingError }
        return data
    }
	
	/// An error that occurs during writing a script file.
	enum WritingError : Error {
		case encodingError
	}
	
}

protocol ScriptDocumentDelegate : class {
	
	/// Notifies the delegate that the source text has been modified.
	func scriptDocumentSourceTextDidChange(_ document: ScriptDocument)
	
}
