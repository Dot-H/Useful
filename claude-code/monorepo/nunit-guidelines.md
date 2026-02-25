# NUnit Testing Guidelines

Follow [NUnit Analyzers](https://github.com/nunit/nunit.analyzers/tree/master/documentation) rules when writing tests.

## Assertion Style

### Use Constraint Model (Assert.That) Instead of Classic Model

Prefer `Assert.That` with constraints over `ClassicAssert`:

```csharp
// Good
Assert.That(actual, Is.EqualTo(expected));
Assert.That(actual, Is.Not.EqualTo(expected));
Assert.That(expr, Is.True);
Assert.That(expr, Is.False);
Assert.That(expr, Is.Null);
Assert.That(expr, Is.Not.Null);
Assert.That(actual, Is.SameAs(expected));
Assert.That(collection, Is.Empty);
Assert.That(collection, Does.Contain(item));
Assert.That(actual, Is.GreaterThan(expected));
Assert.That(actual, Is.LessThanOrEqualTo(expected));
Assert.That(actual, Is.InstanceOf<T>());

// Bad - Classic model
ClassicAssert.AreEqual(expected, actual);
ClassicAssert.IsTrue(expr);
ClassicAssert.IsNull(expr);
```

### Actual Value Should Not Be Constant (NUnit2007)

The first argument to `Assert.That` is the actual value (produced by code), not a constant:

```csharp
// Good
Assert.That(result, Is.EqualTo(5));

// Bad - constant as actual value
Assert.That(5, Is.EqualTo(result));
```

### Use EqualConstraint Instead of == (NUnit2010)

Use `Is.EqualTo` for better failure messages:

```csharp
// Good
Assert.That(actual, Is.EqualTo(expected));

// Bad
Assert.That(actual == expected, Is.True);
```

### Use Specific Constraints for Better Messages

```csharp
// Good - specific constraints
Assert.That(str, Does.Contain("text"));
Assert.That(str, Does.StartWith("prefix"));
Assert.That(str, Does.EndWith("suffix"));
Assert.That(collection, Has.Some.EqualTo(item));

// Bad - boolean expressions
Assert.That(str.Contains("text"), Is.True);
```

## Exception Testing (NUnit2044)

Use delegates for exception assertions:

```csharp
// Good - delegate/lambda
Assert.That(() => MethodThatThrows(), Throws.TypeOf<InvalidOperationException>());
Assert.That(async () => await AsyncMethodThatThrows(), Throws.TypeOf<Exception>());

// Bad - evaluated before Assert
Assert.That(MethodThatThrows(), Throws.TypeOf<Exception>());  // Exception thrown before Assert sees it
```

## Structure Rules

### Async Test Methods Must Return Task (NUnit1012)

```csharp
// Good
[Test]
public async Task AsyncTest()
{
    var result = await SomeAsyncMethod();
    Assert.That(result, Is.True);
}

// Bad - async void
[Test]
public async void AsyncTest()  // Exceptions will be swallowed
{
    var result = await SomeAsyncMethod();
    Assert.That(result, Is.True);
}
```

### Use nameof for TestCaseSource (NUnit1002)

```csharp
// Good - compile-time safety
[TestCaseSource(nameof(TestCases))]
public void Test(int value) { }

private static IEnumerable<int> TestCases => [1, 2, 3];

// Bad - string literal
[TestCaseSource("TestCases")]  // Breaks silently if renamed
public void Test(int value) { }
```

### IDisposable Fields Must Be Disposed (NUnit1032)

For `LifeCycle.SingleInstance` (default):
- Dispose fields initialized in `SetUp` or test methods in `TearDown`
- Dispose fields initialized in `OneTimeSetUp`, constructors, or field initializers in `OneTimeTearDown`

```csharp
public class MyTest
{
    private DisposableResource _resource;

    [SetUp]
    public void SetUp()
    {
        _resource = new DisposableResource();
    }

    [TearDown]
    public void TearDown()
    {
        _resource.Dispose();
    }
}
```

### Test Methods Must Be Public (NUnit1026)

```csharp
// Good
[Test]
public void MyTest() { }

// Bad
[Test]
private void MyTest() { }
```

### TestCaseSource Must Be Static (NUnit1017)

```csharp
// Good
private static IEnumerable<TestCaseData> TestCases => [...];

// Bad
private IEnumerable<TestCaseData> TestCases => [...];
```

## Quick Reference

| Rule | Summary |
|------|---------|
| NUnit1002 | Use `nameof` for TestCaseSource |
| NUnit1012 | Async tests must return `Task` |
| NUnit1017 | TestCaseSource must be static |
| NUnit1026 | Test methods must be public |
| NUnit1032 | Dispose IDisposable in TearDown |
| NUnit2005-2006 | Use `Assert.That` over `ClassicAssert.AreEqual` |
| NUnit2007 | Actual value should not be constant |
| NUnit2010 | Use `Is.EqualTo` instead of `==` |
| NUnit2044 | Use delegates for exception testing |
