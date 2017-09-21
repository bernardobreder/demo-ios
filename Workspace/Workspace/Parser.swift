//
//  Parser.swift
//  Workspace
//
//  Created by Bernardo Breder on 14/02/16.
//  Copyright © 2016 breder. All rights reserved.
//

import Foundation

struct Token {
    
    let type: Int
    
    let word: String
    
    let line: Int
    
    let column: Int
    
}

class Lexer: NSObject {
    
    let code: String
    
    var pos: String.Index
    
    var line:Int

    var column:Int
    
    init(code: String) {
        self.code = code
        self.pos = code.startIndex
        self.line = 1
        self.column = 1
    }
    
    func execute() -> [Token]? {
        return []
    }
    
    func whiteSpace() {
        if pos >= code.endIndex {
            return
        }
        var c: Character = code[pos]
        while (pos < code.endIndex && c <= " ") {
            if c == "\n" {
                line = line + 1
                column = 1
            } else {
                column = column + 1
            }
            pos = code.index(after: pos)
            c = code[pos]
        }
    }
    
    func has(prefix query: String) -> Range<String.Index>? {
        if code.index(pos, offsetBy: query.characters.count - 1, limitedBy: code.endIndex) == nil {
            return nil
        }
        switch query.characters.count {
        case 1:
            if code[pos] == query[query.startIndex] {
                pos = code.index(after: pos)
                return code.index(before: pos) ..< pos
            }
        case 2:
            if code[pos] == query[query.startIndex] && code[code.index(after: pos)] == query[query.index(after: query.startIndex)] {
                pos = code.index(pos, offsetBy: 2)
                return code.index(pos, offsetBy: -2) ..< pos
            }
        case 3:
            if code[pos] == query[query.startIndex] && code[code.index(after: pos)] == query[query.index(after: query.startIndex)] && code[code.index(pos, offsetBy: 2)] == query[query.index(pos, offsetBy: 2)] {
                pos = code.index(pos, offsetBy: 3)
                return code.index(pos, offsetBy: -3) ..< pos
            }
        default:
            let word: String = code.substring(with: pos ..< code.index(pos, offsetBy: query.characters.count))
            if word.hasPrefix(query) {
                let start: String.Index = pos
                pos = code.index(pos, offsetBy: query.characters.count)
                return start ..< pos
            }
        }
        return nil
    }
    
    func has(pattern pattern: String) -> Range<String.Index>? {
        if let range: Range<String.Index> = code.rangeOfString(pattern, options: [.RegularExpressionSearch, .AnchoredSearch], range: pos ..< code.endIndex, locale: nil) {
            for _ in 1 ... range.count {
                if code[pos] == "\n" {
                    line++
                    column = 1
                } else {
                    column++
                }
                pos = code.index(after: pos)
            }
            return range
        }
        return nil
    }
    
    func eof() -> Bool {
        return pos < code.endIndex
    }
    
}

class Parser: NSObject {
    
    let tokens: [Token]
    
    var pos: Int
    
    init(tokens: [Token]) {
        self.tokens = tokens
        self.pos = tokens.startIndex
    }
    
    func whiteSpace() {
        while (pos < code.endIndex && code[pos] <= " ") {
            pos = pos.successor()
        }
    }
    
    func has(query query: String) -> Bool {
        if pos >= code.endIndex {
            return false
        }
        return code.substringFromIndex(pos).hasPrefix(query)
    }
    
    func next(query query: String) -> Token? {
        if pos.advancedBy(query.characters.count - 1, limit: code.endIndex) >= code.endIndex {
            return nil
        }
        let word: String = code.substringWithRange(Range(start: pos, end: pos.advancedBy(query.characters.count)))
        if word.hasPrefix(query) {
            pos = pos.advancedBy(query.characters.count)
            self.whiteSpace()
            return Token(word: word)
        }
        return nil
    }
    
    func has(pattern pattern: String) -> Token? {
        if pos >= code.endIndex {
            return nil
        }
        if let range: Range<String.Index> = code.rangeOfString(pattern, options: [.RegularExpressionSearch, .AnchoredSearch], range: pos ..< code.endIndex, locale: nil) {
            pos = pos.advancedBy(range.count)
            self.whiteSpace()
            return Token(word: code.substringWithRange(range))
        }
        return nil
    }
    
}
