// DRAMASimulator © 2018–2020 Constantino Tsarouhas

import DepthKit
import SwiftUI
import UniformTypeIdentifiers

struct Document : FileDocument {
	
	// See protocol.
	static let readableContentTypes = [UTType("me.ctxppc.drama.script") !! "Expected registered UTI"]
	
	/// Creates a document with given script and machine.
	init(script: Script = .init(from: "")) {
		self.script = script
		self.machine = Machine(for: script)
	}
	
	// See protocol.
	init(configuration: ReadConfiguration) throws {
		try self.init(fileWrapper: configuration.file, contentType: configuration.contentType)
	}
	
	// See protocol.
	init(fileWrapper: FileWrapper, contentType: UTType) throws {
		guard let data = fileWrapper.regularFileContents else { throw ReadingError.unsupportedFormat }
		guard let text = String(data: data, encoding: .utf8) else { throw ReadingError.decodingError }
		self.init(script: .init(from: text))
	}
	
	/// An error that occurs during reading a script file.
	enum ReadingError : Error {
		case unsupportedFormat
		case decodingError
	}
	
	/// The document's script.
	var script: Script {
		didSet {
			machine = Machine(for: script)
		}
	}
	
	/// The document's machine (not persisted).
	var machine: Machine
	
	// See protocol.
	func write(to fileWrapper: inout FileWrapper, contentType: UTType) throws {
		fileWrapper = .init(regularFileWithContents: .init(script.sourceText.utf8))
	}
	
	// See protocol.
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		.init(regularFileWithContents: .init(script.sourceText.utf8))
	}
	
}

private extension Machine {
	
	/// Creates a machine loaded with given script.
	///
	/// An empty machine is created if the script can't be compiled.
	init(for script: Script) {
		if case .program(let program) = script.program {
			self = .init(memoryWords: program.words)
		} else {
			self = .init(memoryWords: .init(repeating: .zero, count: MachineWord.unsignedUpperBound))
		}
	}
	
}
