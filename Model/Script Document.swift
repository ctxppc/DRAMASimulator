// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptDocument : UIDocument {
	
	/// The script.
	var script = Script(from: "") {
		didSet {
			partialProgram = .init(with: script)
		}
	}
	
	/// Returns a program compiled from the script.
	///
	/// - Throws: A `PartialScriptError` if the script has unparsed statements.
	/// - Throws: An error if the program can't be assembled.
	func program() throws -> Program {
		switch partialProgram {
			case .program(let program):	return program
			case .error(let error):		throw error
		}
	}
	
	private var partialProgram: PartialProgram = .program(.init())
	private enum PartialProgram {
		
		case program(Program)
		case error(Error)
		
		init(with script: Script) {
			
			let errors = script.sourceErrors()
			guard errors.isEmpty else {
				self = .error(PartialScriptError(sourceErrors: errors))
				return
			}
			
			do {
				self = .program(try Program(statements: try script.statements(), statementIndicesBySymbol: script.statementIndicesBySymbol))
			} catch Program.AssemblyError.incorrectFormat(statementIndex: let index) {
				self = .error(SourceError(
					underlyingError:	Program.AssemblyError.incorrectFormat(statementIndex: index),
					range:				script.sourceRangeByStatementIndex[index]
				))
			} catch Program.AssemblyError.undefinedSymbol(let symbol, statementIndex: let index) {
				self = .error(SourceError(
					underlyingError:	Program.AssemblyError.undefinedSymbol(symbol, statementIndex: index),
					range:				script.sourceRangeByStatementIndex[index]
				))
			} catch {
				self = .error(error)
			}
			
		}
		
	}
	
	struct PartialScriptError : Error {
		let sourceErrors: [SourceError]
	}
	
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
		guard let data = script.text.data(using: .utf8) else { throw WritingError.encodingError }
        return data
    }
	
	/// An error that occurs during writing a script file.
	enum WritingError : Error {
		case encodingError
	}
	
}
