import XCTest
@testable import FounDarwinTestSuite

XCTMain([
	 testCase(FounDarwinTests.allTests),
	 testCase(DirectoryTests.allTests),
	 testCase(FileTests.allTests),
	 testCase(PackageBuildTests),
])
