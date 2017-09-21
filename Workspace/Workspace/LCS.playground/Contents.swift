//: Playground - noun: a place where people can play

import UIKit

let source = "AAACCGTGAGTTATTCGTTCTAGAA"
let target = "CACCCCTAAGGTACCTTTGGTTC"
let lcs = "ACCTAGTACTTTG"

// http://www.columbia.edu/~cs2035/courses/csor4231.F11/lcs.pdf

source.characters.count
target.characters.count
lcs.characters.count


var i = 0, j = 0, k = 0
while i < source.characters.count && j < lcs.characters.count {
    let ii = source.index(source.startIndex, offsetBy: i)
    let jj = lcs.index(lcs.startIndex, offsetBy: j)
    if ii != source.endIndex && jj != lcs.endIndex && source[ii] == lcs[jj] {
        i = i + 1
        j = j + 1
    } else {
        print("Remove \(i)")
        i = i + 1
    }
}

i = 0
j = 0
k = 0

while i < target.characters.count && j < lcs.characters.count {
    let ii = target.index(source.startIndex, offsetBy: i)
    let jj = lcs.index(lcs.startIndex, offsetBy: j)
    if ii != target.endIndex && jj != lcs.endIndex && target[ii] == lcs[jj] {
        i = i + 1
        j = j + 1
    } else {
        print("Insert \(i)")
        i = i + 1
    }
}
