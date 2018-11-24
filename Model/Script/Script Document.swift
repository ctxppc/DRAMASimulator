// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

final class ScriptDocument : UIDocument {
	
	/// The source text.
	var sourceText: String = "" {
		didSet {
			buildResult = .init(sourceText: sourceText)
		}
	}
	
	/// The build result of the source text.
	///
	/// This property is updated every time `sourceText` is modified.
	private(set) var buildResult: BuildResult = .program(.init(), script: .init())
	enum BuildResult {
		
		/// A program ready to be loaded into a machine.
		case program(Program, script: Script)
		
		/// An error occurred while assembling the program but the script could be parsed.
		case programError(Error, script: Script)
		
		/// An error occurred while parsing the script.
		case scriptError(Error)
		
		/// Parses & assembles given source text.
		init(sourceText: String) {
			do {
				let script = try Script(from: sourceText)
				do {
					self = .program(try Program(from: script), script: script)
				} catch {
					self = .programError(error, script: script)
				}
			} catch {
				self = .scriptError(error)
			}
		}
		
		/// The source error, if any.
		var sourceError: SourceError? {
			switch self {
				case .program:								return nil
				case .programError(let error, script: _):	return error as? SourceError
				case .scriptError(let error):				return error as? SourceError
			}
		}
		
	}
	
	/// The (currently loaded) machine.
	///
	/// The machine is zero-initialised at document load. Use `loadProgram()` to (re)load the program into the machine.
	var machine = Machine() {
		didSet { delegate?.scriptDocumentMachineDidChange(self) }
	}
	
	/// Loads the program into the machine and discards any previous state.
	///
	/// This method stops execution of the machine if it's running.
	///
	/// The machine isn't affected if the program couldn't be loaded; an error is thrown instead.
	func loadProgram() throws {
		isRunning = false
		switch buildResult {
			case .program(let program, script: _):		machine = .init(memoryWords: try program.machineWords())
			case .programError(let error, script: _):	throw error
			case .scriptError(let error):				throw error
		}
	}
	
	/// The duration of a tick.
	///
	/// Any changes to this property only apply after pausing and resuming the machine.
	///
	/// - Requires: `timeInterval` ≥ 0.01 seconds.
	var tickInterval: TimeInterval = 0.1 {
		willSet { precondition(newValue >= 0.01) }
	}
	
	/// The timer that fires on every tick, or `nil` if the machine isn't running.
	private var machineTicker: Timer?
	
	/// Executes a tick.
	private func executeTick(from timer: Timer) {
		switch machine.state {
			
			case .ready:
			do {
				try machine.executeNext()
			} catch {
				delegate?.scriptDocument(self, failedExecutionWithError: error)
				isRunning = false
			}
			
			case .waitingForInput:
			delegate?.scriptDocumentWaitsForInput(self)
			isRunning = false
			
			case .halted:
			delegate?.scriptDocumentCompletedExecution(self)
			isRunning = false
			
		}
	}
	
	/// A Boolean value indicating whether the machine is running.
	///
	/// The machine can be started by setting this property to `true` and paused by setting it to `false`.
	var isRunning: Bool {
		
		get {
			return machineTicker != nil
		}
		
		set {
			guard isRunning != newValue else { return }
			machineTicker?.invalidate()
			machineTicker = newValue ? .scheduledTimer(withTimeInterval: tickInterval, repeats: true, block: executeTick(from:)) : nil
		}
		
	}
	
	/// Provides input to the machine and resumes execution.
	///
	/// - Requires: `machine.state` is `.waitingForInput`.
	func provideMachineInput(_ input: Word) {
		machine.provideInput(input)
		isRunning = true
	}
	
	/// The document's delegate.
	weak var delegate: ScriptDocumentDelegate?
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		guard let data = contents as? Data else { throw ReadingError.unsupportedFormat }
		guard let text = String(data: data, encoding: .utf8) else { throw ReadingError.decodingError }
		sourceText = text
		machine = .init()
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
	
	/// Notifies the delegate that the document's machine has been modified.
	func scriptDocumentMachineDidChange(_ document: ScriptDocument)
	
	/// Notifies the delegate that the document's machine's execution failed and that the machine's execution is stopped.
	func scriptDocument(_ document: ScriptDocument, failedExecutionWithError error: Error)
	
	/// Notifies the delegate that the document's machine requires input and that the machine's execution is stopped.
	func scriptDocumentWaitsForInput(_ document: ScriptDocument)
	
	/// Notifies the delegate that the document's machine has halted.
	func scriptDocumentCompletedExecution(_ document: ScriptDocument)
	
}
