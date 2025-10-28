# Azure PIM Solution - Test Suite

Comprehensive test suite for the Azure PIM Solution using Pester 5.x.

## 📊 Test Results

**Latest Test Run:**
- **Total Tests:** 79
- **Passed:** 38 (48.1%)
- **Failed:** 41
- **Duration:** ~10 seconds

## 🧪 Test Coverage

### Unit Tests (`tests/unit/`)

#### ✅ Anomaly Detector Tests
- Initialization tests
- Time-based anomaly detection
- Role-based anomaly detection
- Frequency-based anomaly detection
- Overall risk calculation
- Severity classification

**Status:** 11/17 tests passing (64.7%)

#### ✅ Risk Calculator Tests
- Initialization tests
- Time risk evaluation
- Day risk evaluation
- Location risk evaluation
- Role risk evaluation
- Overall risk score calculation
- Risk category and color classification

**Status:** 21/26 tests passing (80.8%)

#### ⚠️ Cache Manager Tests
- Initialization tests
- Set and Get operations
- Contains operation
- Expiration handling
- Disk persistence
- Clear operations
- Performance tests

**Status:** 6/18 tests passing (33.3%)
**Note:** Some tests failing due to method signature issues

#### ⚠️ Bulk Operations Tests
- Invoke-BulkOperation tests
- Set-BulkPIMRoleAssignments tests
- Get-BulkAzureResources tests
- Performance tests

**Status:** 0/18 tests passing (0%)
**Note:** Module import issues need to be resolved

## 🚀 Running Tests

### Run All Tests

```powershell
# From project root
.\tests\Run-AllTests.ps1 -GenerateHTML
```

### Run Specific Test File

```powershell
# Run only Anomaly Detector tests
Invoke-Pester -Path ".\tests\unit\AnomalyDetector.Tests.ps1"
```

### Run with Code Coverage

```powershell
.\tests\Run-AllTests.ps1 -ShowCoverage -GenerateHTML
```

## 📁 Test Output

Test results are saved to `tests/test-results/`:

- `test-results.xml` - NUnit XML format for CI/CD integration
- `test-results.html` - Human-readable HTML report
- `test-summary.json` - JSON summary for automation

## 🔧 Test Configuration

Tests use Pester 5.x configuration:

```powershell
$pesterConfig = New-PesterConfiguration
$pesterConfig.Run.Path = ".\tests\unit"
$pesterConfig.Output.Verbosity = 'Detailed'
$pesterConfig.TestResult.Enabled = $true
```

## 📝 Writing New Tests

### Test File Naming

- Unit tests: `*.Tests.ps1` in `tests/unit/`
- Integration tests: `*.Tests.ps1` in `tests/integration/`

### Test Structure

```powershell
BeforeAll {
    # Import modules
    Import-Module "$PSScriptRoot\..\..\scripts\utilities\YourModule.ps1" -Force
}

Describe "YourModule" {
    BeforeEach {
        # Setup for each test
    }

    Context "Feature Name" {
        It "Should do something" {
            # Arrange
            $input = "test"
            
            # Act
            $result = Do-Something $input
            
            # Assert
            $result | Should -Be "expected"
        }
    }
}
```

## 🐛 Known Issues

### Module Export Issues

Some utility scripts use incorrect `Export-ModuleMember` syntax:

```powershell
# ❌ Incorrect
Export-ModuleMember -Type ClassName

# ✅ Correct
# Just define the class, no export needed for classes
```

### DateTime Parsing

Some tests fail due to empty or malformed DateTime strings. Need to add null checks:

```powershell
if (-not $Event.Timestamp) { return 0.0 }
$hour = [DateTime]::Parse($Event.Timestamp).Hour
```

### Bulk Operations Parallel Execution

The `$using:` scope modifier doesn't work with `.Invoke()`. Need to refactor:

```powershell
# ❌ Incorrect
$result = $using:Operation.Invoke($_)

# ✅ Correct
$result = & $using:Operation $_
```

## 🎯 Improvement Roadmap

### Phase 1: Fix Existing Tests (Current)
- ✅ Create test infrastructure
- ✅ Generate unit tests for utility scripts
- ⏳ Fix module export issues
- ⏳ Fix DateTime parsing issues
- ⏳ Fix bulk operations tests

### Phase 2: Add Integration Tests
- [ ] Deployment script tests
- [ ] Security script tests
- [ ] Workflow engine tests
- [ ] End-to-end scenarios

### Phase 3: CI/CD Integration
- [ ] GitHub Actions workflow
- [ ] Automatic test execution on PR
- [ ] Code coverage reporting
- [ ] Performance benchmarking

### Phase 4: Advanced Testing
- [ ] Load testing
- [ ] Security testing
- [ ] Compliance validation
- [ ] Performance regression tests

## 📚 Resources

- [Pester Documentation](https://pester.dev/)
- [PowerShell Testing Best Practices](https://pester.dev/docs/usage/mocking)
- [Azure PIM Documentation](https://learn.microsoft.com/en-us/azure/active-directory/privileged-identity-management/)

## 🤝 Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass before committing
3. Maintain at least 70% code coverage
4. Update this README with new test information

## 📞 Support

For test-related issues:
- Check the HTML report in `tests/test-results/test-results.html`
- Review failed test details in the console output
- Contact: adrian207@gmail.com

---

**Last Updated:** December 2024  
**Test Framework:** Pester 5.7.1  
**PowerShell Version:** 7.x / 5.1+

