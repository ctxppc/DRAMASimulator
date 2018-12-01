// DRAMASimulator © 2018 Constantino Tsarouhas

import UIKit

/// A view controller that presents the contents of a machine.
final class MachineViewController : UICollectionViewController {
	
	/// The machine being presented.
	var machine = Machine() {
		didSet { collectionView?.reloadData() }
	}
	
	/// The words that are selected.
	var selectedWords: Set<Int> = []
	
	/// The formatter used to format machine words.
	private static let wordFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.formattingContext = .standalone
		formatter.minimumIntegerDigits = 10
		formatter.maximumIntegerDigits = 10
		return formatter
	}()
	
	/// The text colour used for zeroes and leading zeroes in words.
	private static let zeroColour = UIColor.lightGray
	
	/// Returns an attributed string formatting given word.
	private static func attributedString(for word: Word) -> NSAttributedString {
		let string = wordFormatter.string(from: word.rawValue as NSNumber)!
		if let indexOfLeadingDigit = string.firstIndex(where: { $0 != "0" }) {
			let attributedString = NSMutableAttributedString(string: string)
			attributedString.addAttributes([.foregroundColor : zeroColour], range: NSRange(string.startIndex..<indexOfLeadingDigit, in: string))
			return attributedString
		} else {
			return NSAttributedString(string: string, attributes: [.foregroundColor : zeroColour])
		}
	}
	
	private enum Section : Int, CaseIterable {
		
		init(for indexPath: IndexPath) {
			self.init(rawValue: indexPath.section)!
		}
		
		case terminal
		case registers
		case memory
		
		var title: String {
			switch self {
				case .terminal:		return "In- en uitvoer"
				case .registers:	return "Accumulatoren"
				case .memory:		return "Geheugen"
			}
		}
		
	}
	
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Section.allCases.count
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! SectionHeaderView
		cell.titleLabel.text = Section(for: indexPath).title
		return cell
	}
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch Section(rawValue: section)! {
			case .terminal:		return machine.ioMessages.count
			case .registers:	return Register.indices.count + 1
			case .memory:		return AddressWord.unsignedUpperBound
		}
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		func cell(for word: Word, title: String, marking: Marking = .none) -> UICollectionViewCell {
			
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Word Cell", for: indexPath) as! WordCell
			
			cell.addressLabel.text = title
			cell.wordLabel.attributedText = MachineViewController.attributedString(for: word)
			cell.contentView.backgroundColor = {
				switch marking {
					case .none:		return nil
					case .selected:	return #colorLiteral(red: 0.933940772, green: 0.7935731027, blue: 1, alpha: 1)
					case .active:	return #colorLiteral(red: 0.7922119131, green: 0.9374318384, blue: 1, alpha: 1)
				}
			}()
			
			return cell
			
		}
		
		enum Marking {
			case none
			case selected
			case active
		}
		
		var marking: Marking {
			if machine.programCounter == AddressWord(rawValue: indexPath.item) {
				return .active
			} else if selectedWords.contains(indexPath.item) {
				return .selected
			} else {
				return .none
			}
		}
		
		switch Section(for: indexPath) {
			
			case .terminal:
			switch machine.ioMessages[indexPath.item] {
				case .input(let word):	return cell(for: word, title: "\(indexPath.item + 1): Invoer")
				case .output(let word):	return cell(for: word, title: "\(indexPath.item + 1): Uitvoer")
			}
			
			case .registers where indexPath.item == Register.indices.count:
			return cell(for: Word(machine.programCounter), title: "Bevelenteller")
				
			case .registers:
			return cell(for: machine[register: Register(rawValue: indexPath.item)!], title: "R\(indexPath.item)")
			
			case .memory:
			return cell(for: machine[address: AddressWord(rawValue: indexPath.item)!], title: "\(indexPath.item)", marking: marking)
			
		}
		
	}
	
}

final class WordCell : UICollectionViewCell {
	@IBOutlet var addressLabel: UILabel!
	@IBOutlet var wordLabel: UILabel!
}

final class SectionHeaderView : UICollectionReusableView {
	@IBOutlet weak var titleLabel: UILabel!
}
