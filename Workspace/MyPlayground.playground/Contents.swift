
import UIKit

var a: Int = 5
var b: NSNumber = NSNumber.init(integerLiteral: a)


let code: String = "\"abc\""
//let code: String = "_a_b a b= (5+3).2.av<>=%$\ta\nb;12.3../*abc*///a\n//b\na/"
//let code: String = "a/*b\n*/\na"

var words: [(Int, Int, Int, String)] = [(Int, Int, Int, String)]()
let symbolType = 1, wordType = 2, numberType = 3, lineCommentType = 4, blockCommentType = 5
var line = 1, column = 1
var i: String.Index = code.startIndex

while i != code.endIndex {
    var c: Character = code[i]
    
    while c <= " " {
        if c == "\n" {
            line = line + 1
            column = 0
        }
        i = code.index(after: i)
        guard i != code.endIndex else {break}
        c = code[i]
        column = column + 1
    }
    guard i != code.endIndex else {break}
    
    if (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || c == "_" {
        let j = i, col = column
        i = code.index(after: i)
        if i != code.endIndex {
            c = code[i]
            column = column + 1
            while (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c >= "0" && c <= "1") || c == "_" {
                i = code.index(after: i)
                guard i != code.endIndex else {break}
                c = code[i]
                column = column + 1
            }
        }
        words.append((line, col, wordType, code.substring(with: j ..< i)))
    } else if c >= "0" && c <= "9" {
        let j = i, col = column
        i = code.index(after: i)
        if i != code.endIndex {
            c = code[i]
            column = column + 1
            var dot = false
            while (c >= "0" && c <= "9") || (!dot && c == ".") {
                dot = dot || c == "."
                i = code.index(after: i)
                guard i != code.endIndex else {break}
                c = code[i]
                column = column + 1
            }
        }
        words.append((line, col, numberType, code.substring(with: j ..< i)))
    } else if c == "\"" {
        let j = i, col = column
        i = code.index(after: i)
        if i != code.endIndex {
            c = code[i]
            column = column + 1
            while c != "\"" {
                i = code.index(after: i)
                guard i != code.endIndex else {break}
                c = code[i]
                column = column + 1
            }
        }
        if i != code.endIndex {
            i = code.index(after: i)
            column = column + 1
        }
        words.append((line, col, numberType, code.substring(with: j ..< i)))
    } else if c == "/" && code.index(after: i) != code.endIndex && code[code.index(after: i)] == "/" {
        let j = code.index(i, offsetBy: 2), col = column
        i = j
        if i != code.endIndex {
            c = code[i]
            column = column + 2
            while c != "\n" {
                i = code.index(after: i)
                guard i != code.endIndex else {break}
                c = code[i]
                column = column + 1
            }
        }
        words.append((line, col, lineCommentType, code.substring(with: j ..< i)))
        if i != code.endIndex {
            i = code.index(after: i)
            column = column + 1
        }
        if c == "\n" {
            line = line + 1
            column = 1
        }
    } else if c == "/" && code.index(after: i) != code.endIndex && code[code.index(after: i)] == "*" {
        let j = code.index(i, offsetBy: 2), lin = line, col = column
        i = j
        if i != code.endIndex {
            c = code[i]
            column = column + 2
            while c != "*" && code.index(after: i) != code.endIndex && code[code.index(after: i)] != "/" {
                if c == "\n" {
                    line = line + 1
                    column = 0
                }
                i = code.index(after: i)
                guard i != code.endIndex else {break}
                c = code[i]
                column = column + 1
            }
        }
        words.append((lin, col, blockCommentType, code.substring(with: j ..< i)))
        if i != code.endIndex {
            i = code.index(after: i)
            column = column + 1
            if i != code.endIndex {
                i = code.index(after: i)
                column = column + 1
            }
        }
    } else {
        let j = i, col = column
        i = code.index(after: i)
        column = column + 1
        words.append((line, col, symbolType, code.substring(with: j ..< i)))
    }
}

for word in words {
    print(word)
}
