// DRAMASimulator © 2018–2021 Constantino Tsarouhas

import SwiftUI

/// A view that presents two views stacked horizontally or vertically depending on the view's horizontal size class, and provides a resizing control.
struct SplitView<First : View, Second : View> : View {
	
	/// Creates a split view with given contents.
	init(ratio: CGFloat = 0.5, range: ClosedRange<CGFloat> = 0.1...0.9, @ViewBuilder content: () -> TupleView<(First, Second)>) {
		(first, second) = content().value
		_ratio = .init(initialValue: ratio)
		self.range = range
	}
	
	/// The first view.
	let first: First
	
	/// The second view.
	let second: Second
	
	/// The view's horizontal size class.
	@Environment(\.horizontalSizeClass)
	private var sizeClass
	
	/// The ratio of the first view's size to the total size.
	@State
	private var ratio: CGFloat
	
	/// The ratio of the first view's size to the total size.
	let range: ClosedRange<CGFloat>
	
	/// The split view's namespace.
	@Namespace
	private var namespace
	
	// See protocol.
    var body: some View {
		GeometryReader { geometry in
			if sizeClass == .compact {
				VStack {
					first
						.frame(height: geometry.size.height * ratio)
					SplitViewControl(ratio: $ratio, range: range, axis: .vertical, splitViewSize: geometry.size.height, splitViewCoordinateSpace: namespace)
					second
						.frame(minHeight: 0, maxHeight: .infinity, alignment: .center)
				}
			} else {
				HStack {
					first
						.frame(width: geometry.size.width * ratio)
					SplitViewControl(ratio: $ratio, range: range, axis: .horizontal, splitViewSize: geometry.size.width, splitViewCoordinateSpace: namespace)
					second
						.frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
				}
			}
		}.coordinateSpace(name: namespace)
    }
	
}

/// A control that resizes a view in a split view.
private struct SplitViewControl : View {
	
	/// Creates a split view control.
	init(ratio: Binding<CGFloat>, range: ClosedRange<CGFloat>, axis: Axis, splitViewSize: CGFloat, splitViewCoordinateSpace: Namespace.ID) {
		self._ratio = ratio
		self.range = range
		self.axis = axis
		self.splitViewSize = splitViewSize
		self.splitViewCoordinateSpace = splitViewCoordinateSpace
	}
	
	/// The ratio.
	@Binding
	private var ratio: CGFloat
	
	/// The ratio before any dragging, or `nil` if no dragging is occuring.
	@GestureState
	private var originalRatio: CGFloat?
	
	/// The axis in which the control moves.
	let axis: Axis
	
	/// The size of the split view over `axis`.
	let splitViewSize: CGFloat
	
	/// The coordinate space of the split view.
	let splitViewCoordinateSpace: Namespace.ID
	
	// See protocol.
	var body: some View {
		ZStack {
			switch axis {
				
				case .vertical:
				HStack {
					Spacer()
					capsule
						.frame(width: 50, height: 8)
					Spacer()
				}.background(separatorBackground)
					
				case .horizontal:
				VStack {
					Spacer()
					capsule
						.frame(width: 8, height: 50)
					Spacer()
				}.background(separatorBackground)
				
			}
		}
	}
	
	/// The capsule.
	private var capsule: some View {
		Capsule()
			.foregroundColor(.init(.separator))
			.gesture(
				DragGesture(coordinateSpace: .named(splitViewCoordinateSpace))
					.updating($originalRatio) { (_, originalRatio, _) in
						originalRatio = originalRatio ?? ratio
					}.onChanged(dragged)
			)
	}
	
	/// The background of the separator line.
	private var separatorBackground: some View {
		Color(.tertiarySystemFill)
			.ignoresSafeArea()
	}
	
	/// Updates the ratio in response to a drag update.
	private func dragged(value: DragGesture.Value) {
		
		guard let originalRatio = originalRatio else { return }	// first drag update can be ignored safely
		
		let translation: CGFloat
		switch axis {
			case .vertical:		translation = value.translation.height
			case .horizontal:	translation = value.translation.width
		}
		
		ratio = (originalRatio + translation / splitViewSize).capped(to: range)
		
	}
	
	/// The permissible range of the ratio.
	let range: ClosedRange<CGFloat>
	
}

struct SplitViewPreviews : PreviewProvider {
    static var previews: some View {
		SplitView(ratio: 0.5) {
			Text("a")
			Text("b")
		}
    }
}
