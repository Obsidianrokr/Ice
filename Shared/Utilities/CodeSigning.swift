//
//  CodeSigning.swift
//  Shared
//

import Foundation
import Security

extension Bundle {
    /// The code signing team identifier for the bundle's executable, if any.
    var codeSigningTeamIdentifier: String? {
        let url = executableURL ?? bundleURL
        var staticCode: SecStaticCode?
        guard SecStaticCodeCreateWithPath(url as CFURL, [], &staticCode) == errSecSuccess,
              let staticCode
        else {
            return nil
        }

        var signingInformation: CFDictionary?
        guard SecCodeCopySigningInformation(
            staticCode,
            SecCSFlags(rawValue: kSecCSSigningInformation),
            &signingInformation
        ) == errSecSuccess,
              let signingInformation
        else {
            return nil
        }

        return (signingInformation as NSDictionary)[kSecCodeInfoTeamIdentifier as String] as? String
    }

    /// A Boolean value that indicates whether the bundle has a development
    /// or distribution team identifier in its code signature.
    var hasCodeSigningTeamIdentifier: Bool {
        guard let teamIdentifier = codeSigningTeamIdentifier else {
            return false
        }
        return !teamIdentifier.isEmpty
    }
}
