import UIKit

var a = 1234 // 變數宣告
let b = 5678 // 常數宣告

a = a + 1
//b = b + 1 // 這樣是單行註解
/* 這樣是跨行宣告
print(a)
print(b)
*/

var text: Int?
text = 1
var test: String?
test = "Optional"
print(test)
print(test ?? "Test") // 透過「?? 預設值」來避免 Optional
print(test!) // 用 ! 來強制解析 Optional
