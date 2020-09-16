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
		machine.attemptReload(from: script)
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
		didSet { machine.attemptReload(from: script) }
	}
	
	/// The document's machine (not persisted).
	var machine = Machine()
	
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
	
	/// Attempts to load given script, resetting `self` in the process.
	///
	/// This method does nothing if the script cannot be compiled.
	mutating func attemptReload(from script: Script) {
		guard case .program(let program) = script.program else { return }
		self = .init()
		memory.load(program.words, startingFrom: .zero)
	}
	
}
