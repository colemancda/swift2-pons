//
//  pofloat.swift
//  pons
//
//  Created by Dan Kogai on 2/4/16.
//  Copyright © 2016 Dan Kogai. All rights reserved.
//

public typealias POSwiftReal = FloatingPointType

public protocol POReal : POSignedNumber {
    init(_:Double)
    func toDouble()->Double
    var isInfinite:Bool  { get }
    var isNaN:Bool       { get }
    var isSignMinus:Bool { get }
    var isZero:Bool      { get }
    static var NaN:Self      { get }
    static var infinity:Self { get }
    var precision:Int { get }
}
public extension POReal {
    public var isFinite:Bool { return !isInfinite }
}
#if os(Linux)
    import Glibc
#else
    import Darwin
#endif
public protocol POFloat : POReal {
    // static var EPSILON:Self { get }
}
// public protocol POElementaryFunctional : POReal {}
extension POReal {
    #if os(Linux)
    public static func sqrt(x:Self)->Self   { return Self(Glibc.sqrt(x.toDouble())) }
    public static func hypot(x:Self, _ y:Self)->Self { return Self(Glibc.hypot(x.toDouble(), y.toDouble())) }
    public static func log(x:Self)->Self    { return Self(Glibc.log(x.toDouble())) }
    public static func exp(x:Self)->Self    { return Self(Glibc.exp(x.toDouble())) }
    public static func pow(x:Self, _ y:Self)->Self  { return Self(Glibc.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self)->Self    { return Self(Glibc.cos(x.toDouble())) }
    public static func sin(x:Self)->Self    { return Self(Glibc.sin(x.toDouble())) }
    public static func tan(x:Self)->Self    { return Self(Glibc.tan(x.toDouble())) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Glibc.atan2(y.toDouble(), x.toDouble())) }
    public static func acos(x:Self)->Self   { return Self(Glibc.acos(x.toDouble())) }
    public static func asin(x:Self)->Self   { return Self(Glibc.asin(x.toDouble())) }
    public static func atan(x:Self)->Self   { return Self(Glibc.atan(x.toDouble())) }
    public static func cosh(x:Self)->Self   { return Self(Glibc.cosh(x.toDouble())) }
    public static func sinh(x:Self)->Self   { return Self(Glibc.sinh(x.toDouble())) }
    public static func tanh(x:Self)->Self   { return Self(Glibc.tanh(x.toDouble())) }
    public static func acosh(x:Self)->Self  { return Self(Glibc.acosh(x.toDouble())) }
    public static func asinh(x:Self)->Self  { return Self(Glibc.asinh(x.toDouble())) }
    public static func atanh(x:Self)->Self  { return Self(Glibc.atanh(x.toDouble())) }
    #else
    // public static func sqrt(x:Self)->Self   { return Self(Darwin.sqrt(x.toDouble())) }
    /// - returns: square root of `x` to precision `precision`
    public static func sqrt(x:Self, precision:Int=0)->Self {
        if x < 0  { return Self.NaN }
        if x == 0 { return 0 }
        if x == 1 { return 1 }
        let px = max(precision, x.precision)
        var r0 = Self(Darwin.sqrt(x.toDouble()))
        var p  = 1.0.precision
        var r = r0
        while p < px {
            // print("p=\(p), px=\(px), r=\(r)")
            r = (x/r0 + r0) / 2
            if r0 == r { break }
            r0 = r
            p *= 2 // precision is now doubled!
        }
        return r
    }
    public static func hypot(x:Self, _ y:Self)->Self { return Self(Darwin.hypot(x.toDouble(), y.toDouble())) }
    public static func log(x:Self)->Self    { return Self(Darwin.log(x.toDouble())) }
    // public static func exp(x:Self)->Self    { return Self(Darwin.exp(x.toDouble())) }
    public static func exp(x:Self, precision:Int=0)->Self {
        if x == 0 { return 1 }
        // if x == 1 { return x }
        let px = max(precision, x.precision)
        // var r0 = Self(Darwin.exp(x.toDouble()))
        let ax = x < 0 ? -x : x
        var r:Self = 1
        var d:Self = 1  // 1 / (i!)
        for i in 1...precision {
            // print("p=\(p), px=\(px), r=\(r)")
            // if px < d.msbAt + 1 { break }
            d /= Self(i)
            r += ax * d
            if px < d.precision { break }
        }
        return x < 0 ? -r : r
    }
    public static func pow(x:Self, _ y:Self)->Self  { return Self(Darwin.pow(x.toDouble(), y.toDouble())) }
    public static func cos(x:Self)->Self    { return Self(Darwin.cos(x.toDouble())) }
    public static func sin(x:Self)->Self    { return Self(Darwin.sin(x.toDouble())) }
    public static func tan(x:Self)->Self    { return Self(Darwin.tan(x.toDouble())) }
    public static func atan2(y:Self, _ x:Self)->Self { return Self(Darwin.atan2(y.toDouble(), x.toDouble())) }
    public static func acos(x:Self)->Self   { return Self(Darwin.acos(x.toDouble())) }
    public static func asin(x:Self)->Self   { return Self(Darwin.asin(x.toDouble())) }
    public static func atan(x:Self)->Self   { return Self(Darwin.atan(x.toDouble())) }
    public static func cosh(x:Self)->Self   { return Self(Darwin.cosh(x.toDouble())) }
    public static func sinh(x:Self)->Self   { return Self(Darwin.sinh(x.toDouble())) }
    public static func tanh(x:Self)->Self   { return Self(Darwin.tanh(x.toDouble())) }
    public static func acosh(x:Self)->Self  { return Self(Darwin.acosh(x.toDouble())) }
    public static func asinh(x:Self)->Self  { return Self(Darwin.asinh(x.toDouble())) }
    public static func atanh(x:Self)->Self  { return Self(Darwin.atanh(x.toDouble())) }
    #endif
    public static var PI:Self       { return Self(M_PI) }
    public static var E:Self        { return Self(M_E) }
    public static var LN2:Self      { return Self(M_LN2) }
    public static var LN10:Self     { return Self(M_LN10) }
    public static var LOG2E:Self    { return Self(M_LOG2E) }
    public static var LOG10E:Self   { return Self(M_LOG10E) }
    public static var SQRT1_2:Self  { return Self(M_SQRT1_2) }
    public static var SQRT2:Self    { return Self(M_SQRT2) }
}
extension Double : POFloat {
    public func toDouble()->Double { return self }
    public func toIntMax()->IntMax { return IntMax(self) }
    /// number of significant bits == 52
    public static let precision = 52
    public var precision:Int { return Double.precision }
    #if os(Linux)
    public static func frexp(d:Double)->(Double, Int) {
        // return Glibc.frexp(d)
        var e:Int32 = 0
        let m = Glibc.frexp(d, &e)
        return (m, Int(e))
    }
    public static func ldexp(m:Double, _ e:Int)->Double {
        // return Glibc.ldexp(m, e)
        return Glibc.ldexp(m, Int32(e))
    }
    #else
    public static func frexp(d:Double)->(Double, Int)   { return Darwin.frexp(d) }
    public static func ldexp(m:Double, _ e:Int)->Double { return Darwin.ldexp(m, e) }
    public static func sqrt(x:Double, precision:Int=0)->Double { return Darwin.sqrt(x) }
    public static func exp(x:Double, precision:Int=0)->Double   { return Darwin.exp(x) }
    #endif
}
extension Float : POFloat {
    public func toDouble()->Double { return Double(self) }
    public func toIntMax()->IntMax { return IntMax(self) }
    /// number of significant bits == 23
    public static let precision = 23
    public var precision:Int { return Float.precision }
}

