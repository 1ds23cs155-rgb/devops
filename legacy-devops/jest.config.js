module.exports = {
  testEnvironment: 'node',
  collectCoverageFrom: [
    'app/**/*.js',
    '!app/node_modules/**',
    '!app/server.js'
  ],
  coveragePathIgnorePatterns: ['/node_modules/'],
  testPathIgnorePatterns: ['/node_modules/'],
  coverageThreshold: {
    global: {
      branches: 70,
      functions: 70,
      lines: 70,
      statements: 70
    }
  },
  testMatch: ['**/tests/**/*.test.js'],
  verbose: true,
  bail: false,
  testTimeout: 10000
};
