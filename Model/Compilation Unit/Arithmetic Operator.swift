// DRAMASimulator © 2020 Constantino Tsarouhas

import Foundation

/// An arithmetic operator.
enum ArithmeticOperator : String {
	
	case sum		= "+"
	case difference	= "-"
	case product	= "*"
	case division	= "/"
	case modulo		= "%"
	
	func callAsFunction(_ firstOperand: Int, _ secondOperand: Int) -> Int {
		switch self {
			case .sum:			return firstOperand &+ secondOperand
			case .difference:	return firstOperand &- secondOperand
			case .product:		return firstOperand &* secondOperand
			case .division:		return firstOperand.dividedReportingOverflow(by: secondOperand).partialValue
			case .modulo:		return firstOperand.remainderReportingOverflow(dividingBy: secondOperand).partialValue
		}
	}
	
}
