func fib(_ x: Double) -> Double {
    if x < 3 {
        return 1
    } else {
        return fib(x - 1) + fib(x - 2)
    }
}
