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
	
	/// The view's horizontal size class.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// A timer publisher for animating executions.
	private let normalClock = Timer.publish(every: 0.75, on: .main, in: .common).autoconnect()
	
	/// A timer publisher for animating executions quickly.
	private let fastClock = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
	
	/// A value indicating whether and how the timeline is animated.
	@State
	private var timelineAnimation: TimelineAnimation = .paused
	enum TimelineAnimation {
		case rewind, paused, play, fastForward
	}
	
	/// A value indicating whether and how the timeline is animated when resuming automatically, e.g., after providing input.
	@State
	private var timelineAnimationWhenResumingAutomatically: TimelineAnimation = .paused
	
	/// The user input.
	@State
	private var input: Int = 0
	
	// See protocol.
	var body: some View {
		contents
			.navigationTitle(name)
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarLeading) {
					Button(action: rewind) {
						Label("Step Backward", systemImage: "backward.frame")
					}.disabled(!document.timeline.canRewind || timelineAnimation != .paused)
					bottomBarSpacer
					Button(action: advance) {
						Label("Step Forward", systemImage: "forward.frame")
					}.disabled(!document.timeline.canAdvance || timelineAnimation != .paused)
					bottomBarSpacer
				}
				ToolbarItemGroup(placement: sizeClass == .compact ? .bottomBar : .navigationBarTrailing) {
					Button(action: { timelineAnimation = .rewind }) {
						Label("Rewind", systemImage: "backward.fill")
					}.disabled(!document.timeline.canRewind)
					bottomBarSpacer
					if timelineAnimation != .paused {
						Button(action: { timelineAnimation = .paused }) {
							Label("Pause", systemImage: "pause.fill")
						}
					} else {
						Button(action: { timelineAnimation = .play }) {
							Label("Play", systemImage: "play.fill")
						}.disabled(!document.timeline.canAdvance)
					}
					bottomBarSpacer
					Button(action: { timelineAnimation = .fastForward }) {
						Label("Fast Forward", systemImage: "forward.fill")
					}.disabled(!document.timeline.canAdvance)
				}
			}
	}
	
	@ViewBuilder
	private var bottomBarSpacer: some View {
		if sizeClass == .compact {
			Spacer()
		}
	}
	
	@ViewBuilder
	private var contents: some View {
		switch timelineAnimation {
			case .rewind:		splitView.onReceive(fastClock) { _ in rewind() }
			case .paused:		splitView
			case .play:			splitView.onReceive(normalClock) { _ in advance() }
			case .fastForward:	splitView.onReceive(fastClock) { _ in advance() }
		}
	}
	
	@ViewBuilder
	private var splitView: some View {
		SplitView(ratio: 0.4, range: 0.25...0.75) {
			ScriptEditor(script: $document.script, programCounter: $document.machine.programCounter)
			MachineView(machine: document.machine)
		}.overlay(statusBar, alignment: .top)
	}
	
	private func rewind() {
		withAnimation {
			if document.timeline.canRewind {
				document.timeline.rewind()
			} else {
				timelineAnimationWhenResumingAutomatically = timelineAnimation
				timelineAnimation = .paused
			}
		}
	}
	
	private func advance() {
		withAnimation {
			if document.timeline.canAdvance {
				document.timeline.advance()
			} else {
				timelineAnimationWhenResumingAutomatically = timelineAnimation
				timelineAnimation = .paused
			}
		}
	}
	
	private var statusBar: some View {
		let machine = document.machine
		let scriptErrors = document.script.product.errors
		return Group {
			if machine.state.isWaitingForInput || machine.state.error != nil || !scriptErrors.isEmpty {
				VStack(alignment: .leading, spacing: 8) {
					if machine.state.isWaitingForInput {
						HStack {
							Label("Invoer vereist:", systemImage: "text.cursor")
							TextField("Invoer", value: $input, formatter: Self.inputFormatter, onCommit: provideInput)
								.keyboardType(.asciiCapableNumberPad)
								.frame(maxWidth: 200)
								.padding()
							Button("Ga door", action: provideInput)
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
	}
	
	func provideInput() {
		document.machine.provideInput(.init(truncating: input))
		timelineAnimation = timelineAnimationWhenResumingAutomatically
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
