import XCTest
@testable import FounDarwinTestSuite
@testable import DirectoryTestSuite
@testable import FileTestSuite
@testable import PackageBuildTestSuite

XCTMain([
	 testCase(FounDarwinTests.allTests),
	 testCase(DirectoryTests.allTests),
	 testCase(FileTests.allTests),
	 testCase(PackageBuildTests),
])
