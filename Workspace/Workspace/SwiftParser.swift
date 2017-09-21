//
//  SwiftParser.swift
//  Workspace
//
//  Created by Bernardo Breder on 14/02/16.
//  Copyright © 2016 breder. All rights reserved.
//

import Foundation

enum SwiftLexerType: Int {
    
    case id, integer, number, string
    
    case `if`, `else`, `do`, `while`, `for`, `repeat`, `switch`
    
    case `let`, `var`, `return`, this, `super`
    
    case add, sub, mul, div, mod
    
    case equal, notEqual, greater, lower, greaterEqual, lowerEqual
    
    case compareRange, compareGreater, compareLower
    
    case optional, require
    
}

class SwiftLexer: Lexer {
    
    override init(code: String) {
        super.init(code: code)
    }
    
    override func execute() -> [Token]? {
        var tokens: [Token] = []
        while !eof() {
            whiteSpace()
            let line = self.line
            let column = self.column
            if let range: Range<String.Index> = has(pattern: "[_a-zA-Z][_a-zA-Z0-9_$]*") {
                var type: Int
                let word: String = code.substring(with: range)
                switch word {
                case "if": type = SwiftLexerType.if.rawValue
                case "do": type = SwiftLexerType.do.rawValue
                case "let": type = SwiftLexerType.let.rawValue
                case "var": type = SwiftLexerType.var.rawValue
                default: type = SwiftLexerType.id.rawValue
                }
                tokens.append(Token(type: type, word: word, line: line, column: column))
            } else if let range: Range<String.Index> = has(pattern: "[+-]?[0-9]+") {
                tokens.append(Token(type: SwiftLexerType.integer.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(pattern: "[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?") {
                tokens.append(Token(type: SwiftLexerType.number.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(pattern: "\"[^\"]*\"") {
                tokens.append(Token(type: SwiftLexerType.string.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "+") {
                tokens.append(Token(type: SwiftLexerType.add.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "-") {
                tokens.append(Token(type: SwiftLexerType.add.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "*") {
                tokens.append(Token(type: SwiftLexerType.add.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "/") {
                tokens.append(Token(type: SwiftLexerType.add.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "/") {
                tokens.append(Token(type: SwiftLexerType.add.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "...") {
                tokens.append(Token(type: SwiftLexerType.compareRange.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "..<") {
                tokens.append(Token(type: SwiftLexerType.compareLower.rawValue, word: code.substring(with: range), line: line, column: column))
            } else if let range: Range<String.Index> = has(prefix: "..>") {
                tokens.append(Token(type: SwiftLexerType.compareGreater.rawValue, word: code.substring(with: range), line: line, column: column))
            } else {
                return nil
            }
        }
        return tokens
    }
        
}

class SwiftParser: Parser {
    
    var nodes: [SwiftNode] = []
    
    init(code: String) {
        super.init(tokens: code)
    }
    
    func parse() -> SwiftNode? {
        while true {
            if let node: SwiftNode = parseCommand() {
                nodes.append(node)
            } else {
                break;
            }
        }
        return nil
    }
    
    func parseCommand() -> SwiftCommandNode? {
        if has(query: "let") {
            return parseDeclare()
        } else if has(query: "if") {
            return parseDeclare()
        } else if has(query: "while") {
            return parseWhile()
        } else if has(query: "for") {
            return parseFor()
        } else if has(query: "repeat") {
            return parseRepeat()
        } else if let value: SwiftValueNode = parseExpr() {
            return SwiftExpressionCommandNode(value: value)
        } else {
            return nil;
        }
    }
    
    func parseIf() -> SwiftIfCommandNode? {
        if let _: Token = next(query: "if") {
            if let value: SwiftValueNode = parseExpr() {
                if let _: Token = next(query: "{") {
                    if let command: SwiftCommandNode = parseCommand() {
                        if let _: Token = next(query: "}") {
                            return SwiftIfCommandNode(value: value, command: command)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func parseWhile() -> SwiftWhileCommandNode? {
        if let _: Token = next(query: "while") {
            if let value: SwiftValueNode = parseExpr() {
                if let _: Token = next(query: "{") {
                    if let command: SwiftCommandNode = parseCommand() {
                        if let _: Token = next(query: "}") {
                            return SwiftWhileCommandNode(value: value, command: command)
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func parseRepeat() -> SwiftRepeatCommandNode? {
        if let _: Token = next(query: "repeat") {
            if let _: Token = next(query: "{") {
                if let command: SwiftCommandNode = parseCommand() {
                    if let _: Token = next(query: "}") {
                        if let _: Token = next(query: "while") {
                            if let value: SwiftValueNode = parseExpr() {
                                return SwiftRepeatCommandNode(value: value, command: command)
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func parseFor() -> SwiftForCommandNode? {
        if let _: Token = next(query: "for") {
            if let token: Token = canIdentifier() {
                var type: SwiftTypeNode?
                if let _: Token = next(query: ":") {
                    if let _type: SwiftTypeNode = parseType() {
                        type = _type
                    } else {
                        return nil
                    }
                }
                if let _: Token = next(query: "in") {
                    if let begin: SwiftValueNode = parseExpr() {
                        if let compare = parseComparator() {
                            if let end: SwiftValueNode = parseExpr() {
                                if let _: Token = next(query: "{") {
                                    if let command: SwiftCommandNode = parseCommand() {
                                        if let _: Token = next(query: "}") {
                                            return SwiftForEachCommandNode(token: token, type: type, begin: begin, compare: compare, end: end, command: command)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                let declares: SwiftDeclaresCommandNode? = parseDeclares()
                if let _: Token = next(query: ";") {
                    let condition: SwiftValueNode? = parseExpr()
                    if let _: Token = next(query: ";") {
                        let nexts: SwiftExpressionsCommandNode? = parseExprs()
                        if let _: Token = next(query: "{") {
                            if let command: SwiftCommandNode = parseCommand() {
                                if let _: Token = next(query: "}") {
                                    return SwiftForAdvancedCommandNode(declares: declares, condition: condition, nexts: nexts, command: command)
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func parseComparator() -> SwiftCompareNode? {
        if let _: Token = next(query: "...") {
            return SwiftRangeCompareNode()
        } else if let _: Token = next(query: "..<") {
            return SwiftRangeLowerCompareNode()
        } else if let _: Token = next(query: "..>") {
            return SwiftRangeGreaterCompareNode()
        } else {
            return nil
        }
    }

    func parseDeclares() -> SwiftDeclaresCommandNode? {
        var declares: [SwiftDeclareCommandNode] = []
        if let declare: SwiftDeclareCommandNode = parseDeclare() {
            declares.append(declare)
            while let _: Token = next(query: ",") {
                if let declare: SwiftDeclareCommandNode = parseDeclare() {
                    declares.append(declare)
                } else {
                    return nil
                }
            }
            return SwiftDeclaresCommandNode(declares: declares)
        }
        return nil
    }

    func parseDeclare() -> SwiftDeclareCommandNode? {
        var type: SwiftTypeNode? = nil
        var value: SwiftValueNode? = nil
        if let _: Token = next(query: "let") {
            if let id: Token = canIdentifier() {
                if let _: Token = next(query: ":") {
                    if let _type: SwiftTypeNode = parseType() {
                        type = _type
                    } else  {
                        return nil
                    }
                }
                if let _: Token = next(query: "=") {
                    if let _value: SwiftValueNode = parseExpr() {
                        value = _value
                    } else {
                        return nil
                    }
                }
                return SwiftDeclareCommandNode(idToken: id, type: type, value: value)
            }
        }
        return nil
    }
    
    func parseExprs() -> SwiftExpressionsCommandNode? {
        if let value: SwiftValueNode = parseExpr() {
            var values: [SwiftValueNode] = [value]
            while let _: Token = next(query: ",") {
                if let value: SwiftValueNode = parseExpr() {
                    values.append(value)
                } else {
                    return nil
                }
            }
            return SwiftExpressionsCommandNode(values: values)
        }
        return nil
    }
    
    func parseType() -> SwiftTypeNode? {
        var type: SwiftTypeNode!
        if has(query: "Int") {
            type = SwiftIntTypeNode()
        } else if has(query: "Double") {
            type = SwiftDoubleTypeNode()
        } else if let token: Token = canIdentifier() {
            type = SwiftIdentifierTypeNode(idToken: token)
        } else {
            return nil
        }
        while true {
            if has(query: "?") {
                type = SwiftOptionalTypeNode(type: type)
            } else if has(query: "!") {
                type = SwiftRequireTypeNode(type: type)
            } else {
                break
            }
        }
        return type
    }
    
    func parseExpr() -> SwiftValueNode? {
        return parseCompare()
    }
    
    func parseCompare() -> SwiftValueNode? {
        if var left: SwiftValueNode = parseSumSub() {
            while true {
                if let token: Token = next(query: "==") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftEqualValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: "!=") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftNotEqualValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: ">=") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftGreaterEqualValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: "<=") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftLowerEqualValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: ">") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftGreaterValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: "<") {
                    if let right: SwiftValueNode = parseSumSub() {
                        left = SwiftLowerValueNode(token: token, left: left, right: right)
                    }
                } else {
                    return left
                }
            }
        }
        return nil
    }
    
    func parseSumSub() -> SwiftValueNode? {
        if var left: SwiftValueNode = parseMulDiv() {
            while true {
                if let token: Token = next(query: "+") {
                    if let right: SwiftValueNode = parseMulDiv() {
                        left = SwiftSumValueNode(token: token, left: left, right: right)
                    }
                } else if let token: Token = next(query: "-") {
                    if let right: SwiftValueNode = parseMulDiv() {
                        left = SwiftSubValueNode(token: token, left: left, right: right)
                    }
                } else {
                    return left
                }
            }
        }
        return nil
    }
    
    func parseMulDiv() -> SwiftValueNode? {
        if let left: SwiftValueNode = parseLiteral() {
            if let token: Token = next(query: "*") {
                if let right: SwiftValueNode = parseExpr() {
                    return SwiftMulValueNode(token: token, left: left, right: right)
                }
            } else if let token: Token = next(query: "/") {
                if let right: SwiftValueNode = parseExpr() {
                    return SwiftDivValueNode(token: token, left: left, right: right)
                }
            } else {
                return left
            }
        }
        return nil
    }
    
    func parseLiteral() -> SwiftValueNode? {
        if let _: Token = next(query: "(") {
            if let left: SwiftValueNode = parseExpr() {
                if let _: Token = next(query: ")") {
                    return left
                }
            }
        } else if let token: Token = canInteger() {
            return SwiftIntegerNode(token: token)
        } else if let token: Token = canNumber() {
            return SwiftNumberNode(token: token)
        } else if let token: Token = canString() {
            return SwiftStringNode(token: token)
        } else if let token: Token = next(query: "nil") {
            return SwiftNilNode(token: token)
        } else if let token: Token = canIdentifier() {
            return SwiftIdentifierNode(token: token)
        }
        return nil
    }
    
    func canInteger() -> Token? {
        if let token: Token = has(pattern: "[+-]?[0-9]+") {
            return token
        }
        return nil
    }
    
    func canNumber() -> Token? {
        if let token: Token = has(pattern: "[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?") {
            return token
        }
        return nil
    }
    
    func canString() -> Token? {
        if let token: Token = has(pattern: "\"[^\"]*\"") {
            return token
        }
        return nil
    }
    
    func canIdentifier() -> Token? {
        if let token: Token = has(pattern: "[_a-zA-Z][_a-zA-Z0-9_$]*") {
            return token
        }
        return nil
    }
    
}

class SwiftNode {
    
    func cleanDebug() {}
    
}

class SwiftStatementNode: SwiftNode {
    
}

class SwiftCompareNode: SwiftNode {
    
    func compare(_ left: Int, right: Int) -> Bool {
        return false
    }
    
}

class SwiftRangeCompareNode: SwiftCompareNode {
    
    override func compare(_ left: Int, right: Int) -> Bool {
        return left <= right
    }
    
}

class SwiftRangeLowerCompareNode: SwiftCompareNode {
    
    override func compare(_ left: Int, right: Int) -> Bool {
        return left < right
    }
    
}

class SwiftRangeGreaterCompareNode: SwiftCompareNode {
    
    override func compare(_ left: Int, right: Int) -> Bool {
        return left > right
    }
    
}

class SwiftCommandNode: SwiftNode {
    
    func execute() {
    }
    
}

class SwiftExpressionCommandNode: SwiftCommandNode {
    
    let value: SwiftValueNode
    
    init(value: SwiftValueNode) {
        self.value = value
    }
    
    override func execute() {
        value.getValue()
    }
    
    override func cleanDebug() {
        value.cleanDebug()
    }
    
}

class SwiftExpressionsCommandNode: SwiftCommandNode {
    
    let values: [SwiftValueNode]?
    
    init(values: [SwiftValueNode]?) {
        self.values = values
    }
    
    override func execute() {
        for value: SwiftValueNode in values ?? [] {
            value.getValue()
        }
    }
    
    override func cleanDebug() {
        for value: SwiftValueNode in values ?? [] {
            value.cleanDebug()
        }
    }
    
}

class SwiftDeclareCommandNode: SwiftCommandNode {
    
    var idToken: Token?
    
    let name: String
    
    let type: SwiftTypeNode?
    
    let value: SwiftValueNode?
    
    init(idToken: Token, type: SwiftTypeNode?, value: SwiftValueNode?) {
        self.idToken = idToken
        self.name = idToken.word
        self.type = type
        self.value = value
    }
    
    override func execute() {
    }
    
    override func cleanDebug() {
        idToken = nil
        type?.cleanDebug()
        value?.cleanDebug()
    }
    
}

class SwiftDeclaresCommandNode: SwiftCommandNode {
    
    let declares: [SwiftDeclareCommandNode]
    
    init(declares: [SwiftDeclareCommandNode]) {
        self.declares = declares
    }
    
    override func execute() {
        for declare: SwiftDeclareCommandNode in declares {
            declare.execute()
        }
    }
    
    override func cleanDebug() {
        for declare: SwiftDeclareCommandNode in declares {
            declare.cleanDebug()
        }
    }
    
}

class SwiftIfCommandNode: SwiftCommandNode {
    
    let value: SwiftValueNode
    
    let command: SwiftCommandNode
    
    init(value: SwiftValueNode, command: SwiftCommandNode) {
        self.value = value
        self.command = command
    }
    
    override func execute() {
        if (value.getValue() as! Bool) {
            command.execute()
        }
    }
    
    override func cleanDebug() {
        value.cleanDebug()
        command.cleanDebug()
    }
    
}

class SwiftRepeatCommandNode: SwiftCommandNode {
    
    let value: SwiftValueNode
    
    let command: SwiftCommandNode
    
    init(value: SwiftValueNode, command: SwiftCommandNode) {
        self.value = value
        self.command = command
    }
    
    override func execute() {
        repeat {
            command.execute()
        } while value.getValue() as! Bool
    }
    
    override func cleanDebug() {
        value.cleanDebug()
        command.cleanDebug()
    }
    
}

class SwiftWhileCommandNode: SwiftCommandNode {
    
    let value: SwiftValueNode
    
    let command: SwiftCommandNode
    
    init(value: SwiftValueNode, command: SwiftCommandNode) {
        self.value = value
        self.command = command
    }
    
    override func execute() {
        while value.getValue() as! Bool {
            command.execute()
        }
    }
    
    override func cleanDebug() {
        value.cleanDebug()
        command.cleanDebug()
    }
    
}

class SwiftForCommandNode: SwiftCommandNode {
    
}

class SwiftForAdvancedCommandNode: SwiftForCommandNode {
    
    let declares: SwiftDeclaresCommandNode?
    
    let condition: SwiftValueNode?
    
    let nexts: SwiftExpressionsCommandNode?
    
    let command: SwiftCommandNode
    
    init(declares: SwiftDeclaresCommandNode?, condition: SwiftValueNode?, nexts: SwiftExpressionsCommandNode?, command: SwiftCommandNode) {
        self.declares = declares
        self.condition = condition
        self.nexts = nexts
        self.command = command
    }
    
    override func execute() {
        declares?.execute()
        while condition?.getValue() as! Bool {
            command.execute()
            nexts?.execute()
        }
    }
    
    override func cleanDebug() {
        declares?.cleanDebug()
        condition?.cleanDebug()
        nexts?.cleanDebug()
        command.cleanDebug()
    }
    
}

class SwiftForEachCommandNode: SwiftForCommandNode {
    
    let token: Token
    
    let type: SwiftTypeNode?
    
    let begin: SwiftValueNode
    
    let compare: SwiftCompareNode
    
    let end: SwiftValueNode
    
    let command: SwiftCommandNode
    
    init(token: Token, type: SwiftTypeNode?, begin: SwiftValueNode, compare: SwiftCompareNode, end: SwiftValueNode, command: SwiftCommandNode) {
        self.token = token
        self.type = type
        self.begin = begin
        self.compare = compare
        self.end = end
        self.command = command
    }
    
    override func execute() {
    }
    
    override func cleanDebug() {
    }
    
}

class SwiftTypeNode: SwiftNode {
    
}

class SwiftIntTypeNode: SwiftTypeNode {
    
}

class SwiftDoubleTypeNode: SwiftTypeNode {
    
}

class SwiftIdentifierTypeNode: SwiftTypeNode {
    
    var idToken: Token?
    
    let name: String
    
    init(idToken: Token) {
        self.idToken = idToken
        self.name = idToken.word
    }
    
    override func cleanDebug() {
        idToken = nil
    }
    
}

class SwiftOptionalTypeNode: SwiftTypeNode {
    
    let type: SwiftTypeNode
    
    init(type: SwiftTypeNode) {
        self.type = type
    }
    
}

class SwiftRequireTypeNode: SwiftTypeNode {
    
    let type: SwiftTypeNode
    
    init(type: SwiftTypeNode) {
        self.type = type
    }
    
}


class SwiftValueNode: SwiftNode {
    
    func getValue() -> NSObject? {
        return nil
    }
    
}

class SwiftSumValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return Int(lvalueInt + rvalueInt)
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) + rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble + rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble + Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString + rvalueString
            } else {
                return lvalueString + (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftSubValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt - rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) - rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble - rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble - Double(rvalueInt)
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftMulValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt * rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) * rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble * rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble * Double(rvalueInt)
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftDivValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt / rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) / rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble / rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble / Double(rvalueInt)
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftEqualValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt == rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) == rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble == rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble == Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString == rvalueString
            } else {
                return lvalueString == (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftNotEqualValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt != rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) != rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble != rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble != Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString != rvalueString
            } else {
                return lvalueString != (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftGreaterValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt > rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) > rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble > rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble > Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString > rvalueString
            } else {
                return lvalueString > (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftGreaterEqualValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt >= rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) >= rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble >= rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble >= Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString >= rvalueString
            } else {
                return lvalueString >= (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftLowerValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt < rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) < rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble < rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble < Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString < rvalueString
            } else {
                return lvalueString < (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftLowerEqualValueNode: SwiftValueNode {
    
    var token: Token?
    
    let left: SwiftValueNode
    
    let right: SwiftValueNode
    
    init(token: Token, left: SwiftValueNode, right: SwiftValueNode) {
        self.token = token
        self.left = left
        self.right = right
    }
    
    override func getValue() -> NSObject? {
        let lvalue: NSObject? = left.getValue()
        let rvalue: NSObject? = right.getValue()
        if let lvalueInt: Int = lvalue as? Int {
            if let rvalueInt: Int = rvalue as? Int {
                return lvalueInt <= rvalueInt
            } else if let rvalueDouble: Double = rvalue as? Double {
                return Double(lvalueInt) <= rvalueDouble
            }
        } else if let lvalueDouble: Double = lvalue as? Double {
            if let rvalueDouble: Double = rvalue as? Double {
                return lvalueDouble <= rvalueDouble
            } else if let rvalueInt: Int = rvalue as? Int {
                return lvalueDouble <= Double(rvalueInt)
            }
        } else if let lvalueString: String = lvalue as? String {
            if let rvalueString: String = rvalue as? String {
                return lvalueString <= rvalueString
            } else {
                return lvalueString <= (rvalue?.description ?? "")
            }
        }
        return nil
    }
    
    override func cleanDebug() {
        token = nil
        left.cleanDebug()
        right.cleanDebug()
    }
    
}

class SwiftNilNode: SwiftValueNode {
    
    var token: Token?
    
    init(token: Token) {
        self.token = token
    }
    
    override func getValue() -> NSObject? {
        return nil
    }
    
    override func cleanDebug() {
        token = nil
    }
    
}

class SwiftIntegerNode: SwiftValueNode {
    
    var token: Token?
    
    let value: Int
    
    init(token: Token) {
        self.token = token
        self.value = Int(token.word)!
    }
    
    override func getValue() -> NSObject? {
        return value as NSObject?
    }
    
    override func cleanDebug() {
        token = nil
    }
    
}

class SwiftNumberNode: SwiftValueNode {
    
    var token: Token?
    
    let value: Double
    
    init(token: Token) {
        self.token = token
        self.value = Double(token.word)!
    }
    
    override func getValue() -> NSObject? {
        return value as NSObject?
    }
    
    override func cleanDebug() {
        token = nil
    }
    
}

class SwiftStringNode: SwiftValueNode {
    
    var token: Token?
    
    let value: String
    
    init(token: Token) {
        self.token = token
        self.value = token.word.substring(with: (token.word.characters.index(after: token.word.startIndex) ..< token.word.characters.index(before: token.word.endIndex)))
    }
    
    override func getValue() -> NSObject? {
        return value as NSObject?
    }
    
    override func cleanDebug() {
        token = nil
    }
    
}

class SwiftIdentifierNode: SwiftValueNode {
    
    var token: Token?
    
    let value: String
    
    init(token: Token) {
        self.token = token
        self.value = token.word
    }
    
    override func getValue() -> NSObject? {
        return nil
    }
    
    override func cleanDebug() {
        token = nil
    }
    
}
