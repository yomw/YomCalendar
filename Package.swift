// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "YomCalendar",
    products: [
        .library(
            name: "YomCalendar",
            targets: ["YomCalendar"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "YomCalendar",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "YomCalendarTests",
            dependencies: ["YomCalendar"],
            path: "Tests"
        ),
    ]
)
