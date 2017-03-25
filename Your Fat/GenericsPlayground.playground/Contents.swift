//: Playground - noun: a place where people can play
import Foundation

var date1 = Date(timeIntervalSince1970: 1484657100) // 01/17/2017 @ 12:45pm (UTC)
var date2 = Date(timeIntervalSince1970: 1484657040) // 01/17/2017 @ 12:44pm (UTC)

let date1a = date1 - 60
let date1b = date1 + 60

let comparison = date2 <= date1b && date2 >= date1a
