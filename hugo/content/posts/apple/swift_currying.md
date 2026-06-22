---
title: "柯里化：函数式编程的利器与Swift中的演进"
date: 2026-06-22
categories: ["技术"]
tags: ["Swift"]
---

柯里化（Currying）是函数式编程中的核心概念，由数学家 Haskell Curry 命名。它将一个接收多个参数的函数，转换为一系列每次只接收一个参数的函数链。

## 什么是柯里化

最直观的理解：

```swift
// 普通函数：一次接收两个参数
func add(_ a: Int, _ b: Int) -> Int {
    return a + b
}

// 柯里化函数：每次只接收一个参数
func curriedAdd(_ a: Int) -> (Int) -> Int {
    return { b in a + b }
}

let addFive = curriedAdd(5)
addFive(3)  // 8
addFive(10) // 15
```

柯里化的本质是**参数的延迟绑定**——先固定部分参数，得到一个新函数，稍后再传入剩余参数。

## Swift 中的演进

### Swift 2.x 时代：原生支持

早期 Swift 提供了原生的柯里化函数语法：

```swift
// Swift 2.x 的原生柯里化语法（已废弃）
func multiply(a: Int)(b: Int) -> Int {
    return a * b
}

let double = multiply(2)
double(b: 5) // 10
```

### Swift 3.0：移除原生语法

Swift 3.0 在 [SE-0002](https://github.com/apple/swift-evolution/blob/main/proposals/0002-remove-currying.md) 中移除了这个语法。官方理由是：

- 语法特殊，增加语言复杂度
- 闭包可以完全替代，无需专门语法
- 与整体语言设计风格不一致

从此，柯里化完全通过**返回闭包的普通函数**来实现。

### 现代 Swift 的写法

```swift
// 手动柯里化
func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

let curriedMultiply = curry(*)
let triple = curriedMultiply(3)
triple(4)  // 12
triple(10) // 30
```

## 实际应用场景

### 1. 部分应用（Partial Application）

预先绑定部分参数，生成专用函数：

```swift
func validate(minLength: Int, maxLength: Int, input: String) -> Bool {
    return input.count >= minLength && input.count <= maxLength
}

// 固定长度规则，生成专用校验器
let validateUsername = curry(validate)(3)(20)
let validatePassword = curry(validate)(8)(128)

validateUsername("swift")   // true
validatePassword("123")     // false
```

### 2. 配合高阶函数

柯里化与 `map`、`filter` 结合，代码更具表达力：

```swift
func hasPrefix(_ prefix: String) -> (String) -> Bool {
    return { $0.hasPrefix(prefix) }
}

let files = ["main.swift", "view.swift", "README.md", "model.swift"]
let swiftFiles = files.filter(hasPrefix("main"))
// ["main.swift"]
```

### 3. 依赖注入风格

```swift
// 将依赖作为第一个参数，业务参数靠后
func fetchUser(apiClient: APIClient) -> (UserID) -> User? {
    return { userId in
        apiClient.get("/users/\(userId)")
    }
}

let productionFetch = fetchUser(apiClient: productionClient)
let mockFetch = fetchUser(apiClient: mockClient)
```

### 4. 实例方法的隐式柯里化

Swift 中有一个鲜为人知的特性：通过类型访问实例方法，会得到一个柯里化函数：

```swift
struct Greeter {
    let greeting: String

    func greet(_ name: String) -> String {
        return "\(greeting), \(name)!"
    }
}

// 通过类型名访问实例方法，返回 (Greeter) -> (String) -> String
let unboundGreet = Greeter.greet

let hello = Greeter(greeting: "Hello")
let greetWithHello = unboundGreet(hello)
greetWithHello("Swift") // "Hello, Swift!"
```

## 柯里化 vs 闭包捕获

两者都能实现"记住"某个值的效果，区别在于意图：

| | 柯里化 | 闭包捕获 |
|---|---|---|
| 意图 | 函数变换，参数分步传入 | 持有外部状态 |
| 组合性 | 易于组合和管道化 | 相对独立 |
| 适用场景 | 函数式风格、高阶函数 | 通用场景 |

```swift
// 闭包捕获
var count = 0
let increment = { count += 1 }

// 柯里化更倾向无状态、纯函数
let add = curry(+)
let addTen = add(10) // 纯函数，无副作用
```

## 小结

柯里化在 Swift 中经历了从语言层面内建到回归"普通闭包"的过程。这个演变本身也说明了 Swift 的设计哲学：**优先保持语言简洁，用已有机制表达能力，而非为每个概念引入专属语法**。

实践中，柯里化在以下场景最有价值：
- 需要**复用部分参数**的场景（部分应用）
- 配合 `map` / `filter` 等高阶函数让代码更简洁
- 函数式风格的**管道组合**

不必强求到处使用，在合适的场景选用，代码自然更具表达力。
