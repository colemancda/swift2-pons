//
//  pointeger.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public typealias POSwiftInteger = IntegerType

///
/// Protocol-oriented integer, signed or unsigned.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each integer type.
///
public protocol POInteger : POComparableNumber,
    RandomAccessIndexType, IntegerLiteralConvertible, _BuiltinIntegerLiteralConvertible
{
    // from IntegerArithmeticType
    static func addWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func subtractWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func multiplyWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func divideWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    static func remainderWithOverflow(lhs: Self, _ rhs: Self) -> (Self, overflow: Bool)
    func %(lhs: Self, rhs: Self) -> Self
    // from BitwiseOperationsType
    func &(lhs: Self, rhs: Self) -> Self
    func |(lhs: Self, rhs: Self) -> Self
    func ^(lhs: Self, rhs: Self) -> Self
    prefix func ~(x: Self) -> Self
    // strangely they did not exist
    func <<(_:Self,_:Self)->Self
    func >>(_:Self,_:Self)->Self
    // init?(_:String, radix:Int)
    func toDouble()->Double
    static var precision:Int { get }
    // the most significant bit
    var msbAt:Int { get }
    //
    var asUInt64:UInt64? { get }
    var asUInt32:UInt32? { get }
    var asUInt16:UInt16? { get }
    var asUInt8:UInt8?   { get }
    var asUInt:UInt?     { get }
    var asInt64:Int64?   { get }
    var asInt32:Int32?   { get }
    var asInt16:Int16?   { get }
    var asInt8:Int8?     { get }
    var asInt:Int?       { get }
}
// give away &op
public func &+<I:POInteger>(lhs:I, rhs:I)->I {
    return I.addWithOverflow(lhs, rhs).0
}
public func &-<I:POInteger>(lhs:I, rhs:I)->I {
    return I.subtractWithOverflow(lhs, rhs).0
}
public func &*<I:POInteger>(lhs:I, rhs:I)->I {
    return I.multiplyWithOverflow(lhs, rhs).0
}
// give away op=
public func %=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs % rhs
}
public func &=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs & rhs
}
public func |=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs | rhs
}
public func ^=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs ^ rhs
}
public func <<=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs << rhs
}
public func >>=<I:POInteger>(inout lhs:I, rhs:I) {
    lhs = lhs >> rhs
}
public extension POInteger {
    /// IntegerLiteralConvertible by Default
    public init(integerLiteral:Int) {
        self.init(integerLiteral)
    }
    /// _BuiltinIntegerLiteralConvertible by Default
    public init(_builtinIntegerLiteral:_MaxBuiltinIntegerType) {
        self.init(Int(_builtinIntegerLiteral: _builtinIntegerLiteral))
    }
    // from BitwiseOperationsType
    public static var allZeros: Self { return 0 }
    // RandomAccessIndexType by default
    public func successor() -> Self {
        return self + 1
    }
    public func predecessor() -> Self {
        return self - 1
    }
    public func advancedBy(n: Int) -> Self {
        return self + Self(n)
    }
    //
    public init(_ v:UInt64) { self.init(v.asInt!) }
    public init(_ v:UInt32) { self.init(v.asInt!) }
    public init(_ v:UInt16) { self.init(v.asInt!) }
    public init(_ v:UInt8)  { self.init(v.asInt!) }
    public init(_ v:Int64)  { self.init(v.asInt!) }
    public init(_ v:Int32)  { self.init(v.asInt!) }
    public init(_ v:Int16)  { self.init(v.asInt!) }
    public init(_ v:Int8)   { self.init(v.asInt!) }
    public init(_ d:Double) { self.init(Int(d)) }
    public var asDouble:Double?  { return self.toDouble() }
    public var asFloat:Float?    { return Float(self.toDouble()) }
    //
    /// default implementation.  you should override it
    public static func divmod(lhs:Self, _ rhs:Self)->(Self, Self) {
        return (lhs / rhs, lhs % rhs)
    }
    ///
    /// Generalized power func
    ///
    /// the end result is the same as `(1..<n).reduce(lhs, combine:op)`
    /// but it is faster by [exponentiation by squaring].
    ///
    ///     power(2, 3){ $0 + $1 }          // 2 + 2 + 2 == 6
    ///     power("Swift", 3){ $0 + $1 }    // "SwiftSwiftSwift"
    ///
    /// In exchange for efficiency, `op` must be commutable.
    /// That is, `op(x, y) == op(y, x)` is true for all `(x, y)`
    ///
    /// [exponentiation by squaring]: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    ///
    public static func power<L>(lhs:L, _ rhs:Self, op:(L,L)->L)->L {
        if rhs < Self(1) {
            fatalError("negative exponent unsupported")
        }
        var r = lhs
        var t = lhs, n = rhs - Self(1)
        while n > Self(0) {
            if n & Self(1) == Self(1) {
                r = op(r, t)
            }
            n >>= Self(1)
            t = op(t, t)
        }
        return r
    }
}

public typealias POSwiftUInt = UnsignedIntegerType

///
/// Protocol-oriented unsigned integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each unsigned integer type.
///
public protocol POUInt: POInteger, StringLiteralConvertible, CustomDebugStringConvertible {
    init (_:UInt)
    init (_:UIntMax)
    func toUIntMax()->UIntMax
    typealias IntType:POSignedNumber    // its correspoinding singed type
    //init(_:IntType)         // must be capable of initializing from it
    var asSigned:IntType? { get }
}
public extension POUInt {
    public init(_ v:UInt64) { self.init(v.toUIntMax()) }
    public init(_ v:UInt32) { self.init(v.toUIntMax()) }
    public init(_ v:UInt16) { self.init(v.toUIntMax()) }
    public init(_ v:UInt8)  { self.init(v.toUIntMax()) }
    /// number of significant bits ==  sizeof(Self) * 8
    public static var precision:Int {
        return sizeof(Self) * 8
    }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int { return self.toUIntMax().msbAt }
    // POInteger conformance
    public var asUInt64:UInt64? { return UInt64(self.toUIntMax()) }
    public var asUInt32:UInt32? { return UInt32(self.toUIntMax()) }
    public var asUInt16:UInt16? { return UInt16(self.toUIntMax()) }
    public var asUInt8:UInt8?   { return UInt8(self.toUIntMax()) }
    public var asUInt:UInt?     { return UInt(self.toUIntMax()) }
    public var asInt64:Int64? {
        let ux = self.toUIntMax()
        return UInt64(Int64.max) < ux ? nil : Int64(ux)
    }
    public var asInt32:Int32? {
        let ux = self.toUIntMax()
        return UInt64(Int32.max) < ux ? nil : Int32(ux)
    }
    public var asInt16:Int16? {
        let ux = self.toUIntMax()
        return UInt64(Int16.max) < ux ? nil : Int16(ux)
    }
    public var asInt8:Int8? {
        let ux = self.toUIntMax()
        return UInt64(Int8.max) < ux ? nil : Int8(ux)
   }
    public var asInt:Int? {
        let ux = self.toUIntMax()
        return UInt64(Int.max) < ux ? nil : Int(ux)
    }
    public func toDouble()->Double { return Double(self.toUIntMax()) }
    ///
    /// `self.toString()` uses this to extract digits
    ///
    public static func divmod8(lhs:Self, _ rhs:Int8)->(Self, Int) {
        let denom = Self(rhs.asInt!)
        return (lhs / denom, (lhs % denom).asInt!)
    }
    /// returns quotient and remainder all at once.
    ///
    /// we give you the default you should override this for efficiency
    public static func divmod8(lhs:Self, _ rhs:Self)->(Self, Self) {
        return (lhs / rhs, lhs % rhs)
    }
    ///
    /// Stringifies `self` with base `radix` which defaults to `10`
    ///
    public func toString(base:Int = 10)-> String {
        guard 2 <= base && base <= 36 else {
            fatalError("base out of range. \(base) is not within 2...36")
        }
        var v = self
        var digits = [Int]()
        repeat {
            var r:Int
            (v, r) = Self.divmod8(v, Int8(base))
            digits.append(r)
        } while v != 0
        return digits.reverse().map{"\(POUtil.int2char[$0])"}.joinWithSeparator("")
    }
    
    // automagically CustomStringConvertible by defalut
    public var description:String {
        return self.toString()
    }
    // automagically CustomDebugStringConvertible
    public var debugDescription:String {
        return "0x" + self.toString(16)
    }
    public static func fromString(s: String, radix:Int = 10)->Self? {
        var (ss, b) = (s, radix)
        let si = s.startIndex
        if s[si] == "0" {
            let sis = si.successor()
            if s[sis] == "x" || s[sis] == "o" || s[sis] == "b" {
                ss = s[sis.successor()..<s.endIndex]
                b = s[sis] == "x" ? 16 : s[sis] == "o" ? 8 : 2
            }
        }
        var result = Self(0)
        for c in ss.lowercaseString.characters {
            if let d = POUtil.char2int[c] {
                result *= Self(b)
                result += Self(d)
            } else {
                if c != "_" { return nil }
            }
        }
        return result
    }
    /// init() with String. Handles `0x`, `0b`, and `0o`
    ///
    /// ought to be `init?` but that makes Swift 2.1 irate :-(
    public init(_ s:String, radix:Int = 10) {
        self.init(Self.fromString(s, radix:radix)!)
    }
    public var hashValue : Int {    // slow but steady
        return self.debugDescription.hashValue
    }
    /// StringLiteralConvertible by Default
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: "\(unicodeScalarLiteral)")
    }
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    ///
    /// * `lhs ** rhs`
    /// * `lhs ** rhs % mod` if `mod !=` (aka `modpow` or `powmod`)
    ///
    /// note only `rhs` must be an integer.
    ///
    public static func pow<L:POUInt>(lhs:L, _ rhs:Self)->L {
        return rhs < Self(1) ? L(1) : power(lhs, rhs, op:&*)

    }
    public static func pow(lhs:Self, _ rhs:Self, mod:Self=Self(1))->Self {
        return rhs < Self(1) ? Self(1)
            // : mod == L(1) ? power(lhs, rhs, op:&*) : power(lhs, rhs){ ($0 &* $1) % mod }
            : mod == Self(1) ? power(lhs, rhs, op:&*) : power(lhs, rhs){ powmod($0, $1, mod:mod) }
    }
    /// modular reciprocal of n
    public var modinv:Self {
        var m = Self(0)
        var t = Self(0)
        var r = Self(2) << Self(self.msbAt)
        var i = Self(1)
        // print("\(__FILE__):\(__LINE__): t=\(t),r=\(r),i=\(i)")
        while r > Self(1) {
            if t & Self(1) == Self(0) {
                t += self
                m += i
            }
            t >>= Self(1)
            r >>= Self(1)
            i <<= Self(1)
        }
        return m
    }
    /// montgomery reduction
    public static func redc(n:Self, _ m:Self)->Self {
        let bits = Self(m.msbAt + 1)
        let mask = (Self(1) << bits) - 1
        let minv = m.modinv
        // print("\(__FILE__):\(__LINE__): n=\(n),bits=\(bits), minv=\(minv)")
        let t = (n + ((n * minv) & mask) * m) >> bits
        return t >= m ? t - m : t
    }
    /// - returns: `(x * y) % m` witout overflow in exchange for speed
    public static func mulmod(x:Self, _ y:Self, _ m:Self)->Self {
        if (m == 0) { fatalError("modulo by zero") }
        if (m == 1) { return 1 }
        if (m == 2) { return x & 1 }  // just odd or even
        let xyo = Self.multiplyWithOverflow(x, y)
        if !xyo.1 { return xyo.0 % m }
        var a = x % m;
        if a == 0 { return 0 }
        var b = y % m;
        if b == 0 { return 0 }
        var r:Self = 0;
        while a > 0 {
            if a & 1 == 1 { r = (r + b) % m }
            a >>= 1
            b = (b << 1) % m
        }
        return r
    }
    ///
    /// Modular exponentiation. a.k.a `modpow`.
    ///
    /// - returns: `b ** x mod m`
    public static func powmod(b:Self, _ x:Self, mod m:Self)->Self {
        // return b < 1 ? 1 : power(b, x){ mulmod($0, $1, m) }
        let bits = Self(m.msbAt + 1)
        let mask = (Self(1) << bits) - 1
        let minv = m.modinv
        let r1 = (Self(1) << bits) % m
        let r2 = mulmod(r1, r1, m)  // to avoid overflow
        let innerRedc:Self->Self =  { n in
            // print("\(__FILE__):\(__LINE__): n=\(n),bits=\(bits), minv=\(minv)")
            let t = (n + ((n * minv) & mask) * m) >> bits
            return t >= m ? t - m : t
        }
        let innerMulMod:(Self,Self)->Self = { (a, b) in
            // return innerRedc(innerRedc(a * b) * r2)
            let ma = innerRedc(a * r2)
            let mb = innerRedc(b * r2)
            return innerRedc(innerRedc(ma * mb))
        }
        if b < Self(1) {
            fatalError("negative exponent unsupported")
        }
        var r = b
        var t = b, n = x - Self(1)
        while n > Self(0) {
            if n & Self(1) == Self(1) {
                r = innerMulMod(r, t)
            }
            n >>= Self(1)
            t = innerMulMod(t, t)
        }
        return r
    }
}
extension UInt64:   POUInt {
    public typealias IntType = Int64
    public var msbAt:Int {
        return self <= UInt64(UInt32.max)
            ? UInt32(self).msbAt
            : UInt32(self >> 32).msbAt + 32
    }
    public var asSigned:IntType? { return UInt64(Int64.max) < self ? nil : IntType(self) }
    public static func powmod(b:UInt64, _ x:UInt64, mod m:UInt64)->UInt64 {
        return BigUInt.powmod(b.asBigUInt!, x.asBigUInt!, mod:m.asBigUInt!).asUInt64!
    }
}
extension UInt32:   POUInt {
    public typealias IntType = Int32
    public var msbAt:Int {
        return Double.frexp(Double(self)).1 - 1
    }
    public var asSigned:IntType? { return UInt32(Int32.max) < self ? nil : IntType(self) }
    public static func powmod(b:UInt32, _ x:UInt32, mod m:UInt32)->UInt32 {
        return UInt64.powmod(b.asUInt64!, x.asUInt64!, mod:m.asUInt64!).asUInt32!
    }
}
extension UInt16:   POUInt {
    public typealias IntType = Int16
    public var asSigned:IntType? { return UInt16(Int16.max) < self ? nil : IntType(self) }
    public static func powmod(b:UInt16, _ x:UInt16, mod m:UInt16)->UInt16 {
        return UInt32.powmod(b.asUInt32!, x.asUInt32!, mod:m.asUInt32!).asUInt16!
    }
}
extension UInt8:    POUInt {
    public typealias IntType = Int8
    public var asSigned:IntType? { return UInt8(Int8.max) < self ? nil : IntType(self) }
    public static func powmod(b:UInt8, _ x:UInt8, mod m:UInt8)->UInt8 {
        return UInt16.powmod(b.asUInt16!, x.asUInt16!, mod:m.asUInt16!).asUInt8!
    }
}
extension UInt:     POUInt {
    public typealias IntType = Int
    public var asSigned:IntType? { return UInt(Int.max) < self ? nil : IntType(self) }
    public static func powmod(b:UInt, _ x:UInt, mod m:UInt)->UInt {
        return BigUInt.powmod(b.asBigUInt!, x.asBigUInt!, mod:m.asBigUInt!).asUInt!
    }
}

public typealias POSwiftInt = SignedIntegerType

///
/// Protocol-oriented signed integer.  All built-ins already conform to this.
///
/// For the sake of protocol-oriented programming,
/// consider extend this protocol first before extending each signed integer types.
///
public protocol POInt: POInteger, POSignedNumber, StringLiteralConvertible, CustomDebugStringConvertible {
    init(_:IntMax)
    ///
    /// The unsigned version of `self`
    ///
    typealias UIntType:POUInt           // its corresponding unsinged type
    init(_:UIntType)                    // capable of initializing from it
    var asUnsigned:UIntType? { get }    // able to convert to unsigned
}
public extension POInt {
    /// number of significant bits ==  sizeof(Self) * 8 - 1
    public static var precision:Int {
        return sizeof(Self) * 8 - 1
    }
    /// Default isSignMinus
    public var isSignMinus:Bool { return self < 0 }
    /// Default toUIntMax
    public func toUIntMax()->UIntMax {
        return UIntMax(self.toIntMax())
    }
    // POInteger conformance
    public var asUInt64:UInt64? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt64(ix)
    }
    public var asUInt32:UInt32? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt32(ix)
    }
    public var asUInt16:UInt16? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt16(ix)
    }
    public var asUInt8:UInt8? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt8(ix)
    }
    public var asUInt:UInt? {
        let ix = self.toIntMax()
        return ix < 0 ? nil : UInt(ix)
    }
    public var asInt64:Int64? { return Int64(self.toUIntMax()) }
    public var asInt32:Int32? { return Int32(self.toUIntMax()) }
    public var asInt16:Int16? { return Int16(self.toUIntMax()) }
    public var asInt8:Int8?   { return Int8(self.toUIntMax()) }
    public var asInt:Int?     { return Int(self.toUIntMax()) }
    public func toDouble()->Double { return Double(self.toIntMax()) }
    ///
    /// Returns the index of the most significant bit of `self`
    /// or `-1` if `self == 0`
    public var msbAt:Int {
        return self < 0 ? sizeof(Self) * 8 - 1 : self.toUIntMax().msbAt
    }
    ///
    /// absolute value of `self`
    ///
    public var abs:Self { return Swift.abs(self) }
    ///
    /// Stringifies `self` with base `radix` which defaults to `10`
    ///
    public func toString(radix:Int = 10)-> String {
        return (self < 0 ? "-" : "") + self.abs.asUInt64!.toString(radix)
    }
    // automagically CustomStringConvertible by defalut
    public var description:String {
        return self.toString()
    }
    // automagically CustomDebugStringConvertible
    public var debugDescription:String {
        return (self < 0 ? "-" : "+") + self.abs.asUInt64.debugDescription
    }
    /// init() with String. Handles `0x`, `0b`, and `0o`
    ///
    /// ought to be `init?` but that makes Swift 2.1 irate :-(
    public init(_ s:String, radix:Int = 10) {
        let si = s.startIndex
        let u = s[si] == "-" || s[si] == "+"
            ? UIntType(s[si.successor()..<s.endIndex], radix:radix)
            : UIntType(s, radix:radix)
        self.init(s[si] == "-" ? -Self(u) : +Self(u))
    }
    ///
    /// StringLiteralConvertible by Default
    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
    public init(unicodeScalarLiteral: String) {
        self.init(stringLiteral: "\(unicodeScalarLiteral)")
    }
    public init(extendedGraphemeClusterLiteral: String) {
        self.init(stringLiteral: extendedGraphemeClusterLiteral)
    }
    /// - returns: 
    ///   `lhs ** rhs` or `lhs ** rhs % mod` if `mod != 1`  (aka `modpow` or `powmod`)
    ///
    /// note only `rhs` must be an integer.
    /// also note it unconditinally returns `1` if `rhs < 1`
    /// for negative exponent, make lhs noninteger
    ///
    ///     pow(2,   -2) // 1
    ///     pow(2.0, -2) // 0.25
    public static func pow<L:POInt>(lhs:L, _ rhs:Self)->L {
        return rhs < 1 ? 1 : power(lhs, rhs, op:&*)
    }
    /// - returns: `lhs ** rhs`
    public static func pow<L:POReal>(lhs:L, _ rhs:Self)->L {
        return L.pow(lhs, L(rhs.toDouble()))
    }
}
extension Int64:    POInt {
    public typealias UIntType = UInt64
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int32:    POInt {
    public typealias UIntType = UInt32
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int16:    POInt {
    public typealias UIntType = UInt16
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int8:     POInt {
    public typealias UIntType = UInt8
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
extension Int:      POInt {
    public typealias UIntType = UInt
    public var asUnsigned:UIntType? { return self < 0 ? nil : UIntType(self) }
}
