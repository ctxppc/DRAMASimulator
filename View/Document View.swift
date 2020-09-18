// DRAMASimulator © 2020 Constantino Tsarouhas

import SwiftUI

/// A view that presents a document.
struct DocumentView : View {
	
	/// Creates a view for emulating and editing given script.
	init(name: String, document: Binding<Document>) {
		self.name = name
		self._document = document
	}
	
	/// The document's name.
	let name: String
	
	/// The document being presented.
	@Binding
	private var document: Document
	
	/// The split view's ratio.
	@SceneStorage(wrappedValue: 0.25, "splitRatio")
	private var splitRatio
	
	/// The view's horizontal size class.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// A timer publisher for animating executions.
	private let clock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	
	/// A value indicating whether and how the timeline is animated.
	@State
	private var timelineAnimation: TimelineAnimation = .still
	enum TimelineAnimation {
		case forward, backward, still
	}
	
	// See protocol.
	var body: some View {
		contents
			.navigationTitle(name)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarLeading) {
					Button(action: rewind) {
						Label("Step Backward", systemImage: "backward.frame")
					}.disabled(!document.timeline.canRewind)
					Button(action: advance) {
						Label("Step Forward", systemImage: "forward.frame")
					}.disabled(!document.timeline.canAdvance)
				}
				ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarTrailing) {
					Button(action: { timelineAnimation = .backward }) {
						Label("Reverse", systemImage: "backward.fill")
					}.disabled(!document.timeline.canRewind || timelineAnimation == .backward)
					Button(action: { timelineAnimation = .still }) {
						Label("Stop", systemImage: "stop.fill")
					}.disabled(timelineAnimation == .still)
					Button(action: { timelineAnimation = .forward }) {
						Label("Play", systemImage: "forward.fill")
					}.disabled(!document.timeline.canAdvance || timelineAnimation == .forward)
				}
			}
	}
	
	@ViewBuilder
	private var contents: some View {
		if timelineAnimation == .still {
			panels
		} else {
			panels.onReceive(clock) { _ in
				switch timelineAnimation {
					
					case .still:
					break
					
					case .forward:
					if document.timeline.canAdvance {
						advance()
					} else {
						timelineAnimation = .still
					}
						
					case .backward:
					if document.timeline.canRewind {
						rewind()
					} else {
						timelineAnimation = .still
					}
					
				}
			}
		}
	}
	
	@ViewBuilder
	private var panels: some View {
		SplitView(ratio: $splitRatio.cgFloat) {
			ScriptEditor(script: $document.script)
			MachineView(machine: document.machine)
		}.overlay(
			StatusBar(
				machine:		$document.machine,
				scriptErrors:	document.script.program.errors
			), alignment: .top
		)
	}
	
	private func rewind() {
		withAnimation {
			document.timeline.rewind()
		}
	}
	
	private func advance() {
		withAnimation {
			document.timeline.advance()
		}
	}
	
}

private struct StatusBar : View {
	
	/// Creates a status bar.
	init(machine: Binding<Machine>, scriptErrors: [Error]) {
		self._machine = machine
		self.scriptErrors = scriptErrors
	}
	
	/// The machine whose status is being presented.
	@Binding
	private var machine: Machine
	
	/// Any errors in the script.
	let scriptErrors: [Error]
	
	/// The input.
	@State
	private var input: Int = 0
	
	// See protocol.
	var body: some View {
		if machine.state.isWaitingForInput || machine.state.error != nil || !scriptErrors.isEmpty {
			VStack(alignment: .leading, spacing: 8) {
				if machine.state.isWaitingForInput {
					HStack {
						Label("Invoer vereist:", systemImage: "text.cursor")
						TextField("Invoer", value: $input, formatter: Self.inputFormatter, onCommit: submitInput)
							.keyboardType(.asciiCapableNumberPad)
							.frame(maxWidth: 200)
							.padding()
						Button("Ga door", action: submitInput)
					}
				}
				if let error = machine.state.error {
					Label((error as? LocalizedError)?.errorDescription ?? error.localizedDescription, systemImage: "xmark.octagon.fill")
				}
				ForEach(scriptErrors.indices, id: \.self) { index in
					Label((scriptErrors[index] as? LocalizedError)?.errorDescription ?? scriptErrors[index].localizedDescription, systemImage: "xmark.octagon.fill")
				}
			}.padding()
			.background(Color(.secondarySystemBackground).opacity(0.75))
			.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
			.padding()
		}
	}
	
	func submitInput() {
		machine.provideInput(.init(truncating: input))
	}
	
	private static let inputFormatter: NumberFormatter = {
		let f = NumberFormatter()
		f.numberStyle = .none
		f.usesGroupingSeparator = true
		f.allowsFloats = false
		f.minimum = MachineWord.signedRange.lowerBound as NSNumber
		f.maximum = MachineWord.signedRange.upperBound as NSNumber
		f.isLenient = true
		return f
	}()
	
}

private extension Double {
	var cgFloat: CGFloat {
		get { .init(self) }
		set { self = .init(newValue) }
	}
}

#if DEBUG
struct DocumentViewPreviews : PreviewProvider {
	
	static var previews: some View {
		Demo()
	}
	
	private struct Demo : View {
		
		@State var document = Document(script: templateScript)
		
		var body: some View {
			NavigationView {
				DocumentView(name: "Preview", document: $document)
			}.navigationViewStyle(StackNavigationViewStyle())
		}
		
	}
	
}

let templateScript = Script(from:
	"""
	HIA.w R0, 20
	OPT R0, R1
	STP
	"""
)
#endif
