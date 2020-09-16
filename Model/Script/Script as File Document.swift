// DRAMASimulator © 2020 Constantino Tsarouhas

import DepthKit
import SwiftUI
import UniformTypeIdentifiers

extension Script : FileDocument {
	
	// See protocol.
	static let readableContentTypes = [UTType("me.ctxppc.drama.script") !! "Expected registered UTI"]
	
	// See protocol.
	init(configuration: ReadConfiguration) throws {
		try self.init(fileWrapper: configuration.file, contentType: configuration.contentType)
	}
	
	// See protocol.
	init(fileWrapper: FileWrapper, contentType: UTType) throws {
		guard let data = fileWrapper.regularFileContents else { throw ReadingError.unsupportedFormat }
		guard let text = String(data: data, encoding: .utf8) else { throw ReadingError.decodingError }
		self.init(from: text)
	}
	
	/// An error that occurs during reading a script file.
	enum ReadingError : Error {
		case unsupportedFormat
		case decodingError
	}
	
	// See protocol.
	func write(to fileWrapper: inout FileWrapper, contentType: UTType) throws {
		fileWrapper = .init(regularFileWithContents: .init(sourceText.utf8))
	}
	
	// See protocol.
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
		.init(regularFileWithContents: .init(sourceText.utf8))
	}
	
}
