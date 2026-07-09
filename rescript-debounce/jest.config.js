module.exports = {
    testEnvironment: "node",
    testRegex: "tests/.*\\.res\\.js$",
    testPathIgnorePatterns: ["/node_modules/", "/lib/"],
    transformIgnorePatterns: ["node_modules/(?!(@rescript/runtime|@glennsl/rescript-jest)/)"],
};
