import InlineSnapshotTesting
import SwiftBasicFormat
import SwiftParser
import SwiftSyntax
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

public func assertMacroSnapshot(
  _ macros: [String: Macro.Type],
  of source: () throws -> String,
  expandsTo expected: (() -> String)? = nil,
  file: StaticString = #filePath,
  function: StaticString = #function,
  line: UInt = #line,
  column: UInt = #column
) {
  assertInlineSnapshot(
    of: try source(),
    as: .macroExpansion(macros),
    matches: expected,
    file: file,
    function: function,
    line: line,
    column: column
  )
}

extension Snapshotting where Value == String, Format == String {
  public static func macroExpansion(
    _ macros: [String: Macro.Type],
    testModuleName: String = "TestModule",
    testFileName: String = "Test.swift",
    indentationWidth: Trivia = .spaces(2)
  ) -> Self {
    Snapshotting<String, String>.lines.pullback { input in
      let origSourceFile = Parser.parse(source: input)
      let context =  SwiftSyntaxMacroExpansion.BasicMacroExpansionContext(
        sourceFiles: [
          origSourceFile: .init(moduleName: testModuleName, fullFilePath: testFileName)
        ]
      )
      let expandedSourceFile = origSourceFile.expand(
        macros: macros,
        in: context
      )
      .formatted(using: BasicFormat(indentationWidth: indentationWidth))
      return expandedSourceFile.description.trimmingTrailingWhitespace()
    }
  }
}
