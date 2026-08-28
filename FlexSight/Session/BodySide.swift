//
//  BodySide.swift
//  FlexSight
//

enum BodySide: Sendable {
    case left
    case right

    var hip: BodyJoint { self == .left ? .leftHip : .rightHip }
    var knee: BodyJoint { self == .left ? .leftKnee : .rightKnee }
    var ankle: BodyJoint { self == .left ? .leftAnkle : .rightAnkle }

    var legJoints: [BodyJoint] { [hip, knee, ankle] }
}
