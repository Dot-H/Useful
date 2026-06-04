# Claude Code Guidelines

## General Rules

- **Never mention Claude**: Do not mention Claude, AI, or any AI assistant in commits, PR descriptions, code comments, co-author lines, or any other artifacts. Keep all contributions anonymous.
- **ASCII-only in written artifacts**: Never use special Unicode arrows (`←`, `→`, `↑`, `↓`), dashes (`—`, `–`), or other non-ASCII symbols in code, comments, commit messages, PR descriptions, or markdown files. Use ASCII equivalents instead: `<-`, `->`, `--`, `...`, etc.

## Branch Naming

When creating a branch, follow this pattern: `username/JIRA-ID/short-description`

Example: `alex/SCHED-508/fix-calendar-rendering`

If you don't know the Jira ticket ID, ask the user.

## Pull Requests

- When creating a PR, always create it in **Draft** mode using the `--draft` flag with `gh pr create`
- Use the `/create-pr` skill to create PRs following Pigment conventions
- PR body must start with a Jira ticket link: `[🎟️ - JIRA-ID](https://pigmentdev.atlassian.net/browse/JIRA-ID)`
- PR titles must be prefixed with an emoji indicating the type of change (see `.claude/skills/create-pr/SKILL.md` for the full list)

## Code Organization

- **One file per class/interface**: Each class, interface, or enum should be in its own file. Do not put multiple types in the same file unless they are closely related nested types.

## C# Coding Standards

- **No `/// <inheritdoc/>`**: Never use `/// <inheritdoc/>` - write explicit documentation or omit XML docs entirely
- **Use collection expressions**: Prefer C# 12 collection expressions (e.g., `[1, 2, 3]`) over traditional initializers (e.g., `new double[] { 1, 2, 3 }` or `new List<int> { 1, 2, 3 }`)
- **Always dispose objects**: Always dispose objects that implement `IDisposable`. Use `using` statements or `using` declarations to ensure proper disposal of resources (e.g., streams, database connections, HTTP clients)
- **Use minimal collection interfaces**: In method signatures, use the narrowest collection interface that satisfies your needs. Prefer `IEnumerable<T>` if you only iterate once, `IReadOnlyCollection<T>` if you need `.Count`, `IReadOnlyList<T>` if you need indexing. Avoid requiring `List<T>` or `IList<T>` when a read-only interface suffices.
- **Repository return types**: Repository methods should return `IEnumerable<T>` unless the list is explicitly allocated inside the method body (e.g., via `.ToList()` or `.ToReadOnlyList()`). Never upcast a Dapper result to `IReadOnlyList<T>` without first materializing it.
- **Use `<see cref="..."/>` in comments**: When referring to a symbol (class, method, property, etc.) inside an XML doc comment or inline comment, use `<see cref="SymbolName"/>` so that developers can navigate to the symbol directly from the IDE.
- **No `<list>` tag in comments**: Never use the XML `<list>`/`<item>` tags in doc comments. Write bullet lists directly in markdown style using `-`.
- **No `<c>` tag in comments**: Never use the XML `<c>` tag in doc comments. Use markdown backticks instead.
- **No HTML entities in comments**: Never use the `&gt;`/`&lt;` family of HTML entities in comments. Write the literal `>` or `<` characters instead.
- **Run `dotnet format whitespace` after making changes**: Once you are done modifying C# files, always run `dotnet format whitespace` on the affected project(s) to ensure consistent formatting. Use the `--include` flag to scope it to the modified files (e.g., `dotnet format whitespace path/to/Project.csproj --include path/to/File.cs`)
- **Use camelCase for log attributes**: When using structured logging, always use `camelCase` for attribute names in log message templates (e.g., `{organizationId}`, `{durationMs}`, `{itemCount}`). Never use `PascalCase` for log attributes.
- **Never inline `if` statements**: Never write `if (cond) DoSomething();` on a single line. Always put the body on its own line. Use braces when the condition or the body spans multiple lines; omit braces when both fit on a single line each.
- **Use `UnreachableSwitchCaseException` for exhaustive switches**: When switching over an enum (or boolean/tuple/type hierarchy), throw `UnreachableSwitchCaseException` from `Pigment.Common.System` in the default case rather than `ArgumentOutOfRangeException`. The analyzer leverages it to verify all enum values (or derived types) are handled. Use `UnreachableSwitchCaseException<T>` when switching over a type hierarchy.

## DataDog Metrics (OpenTelemetry)

Metrics should be implemented using OpenTelemetry via the dotnet built-in API (not Prometheus).

### Naming Convention

- Use `snake_case` for metric names
- Prefix all metrics with `pigment.` (e.g., `pigment.computeworker.formula_executions`)

### Metrics Class Structure

Create a dedicated metrics class that implements `IDisposable`:

```csharp
public class MyServiceMetrics : IDisposable
{
    private readonly Meter _meter;
    private readonly Counter<long> _counter;

    public MyServiceMetrics(IMeterFactory meterFactory)
    {
        _meter = meterFactory.Create("MyServiceMeter", "1.0.0");
        _counter = _meter.CreateCounter<long>(name: "pigment.myservice.operation_count");
    }

    public void RecordOperation(bool isSuccess)
    {
        _counter.Add(delta: 1, tags: [new("isSuccess", isSuccess)]);
    }

    public void Dispose() => _meter?.Dispose();
}
```

### Setup

Register the meter name in `AddAspNetCoreTracing` in `Startup.cs`:

```csharp
public void ConfigureServices(IServiceCollection services)
{
    services.AddAspNetCoreTracing(HostEnvironment.ApplicationName,
        [$"/{RelativePathPrefix}/metrics"], ["MyServiceMeter"]);
    services.AddSingleton<MyServiceMetrics>();
}
```

**Important**: Register all meter names in the `additionalMeters` parameter of `AddAspNetCoreTracing`. This is what makes OpenTelemetry listen for and export your metrics to DataDog. The `IMeterFactory` is already available in ASP.NET Core apps.

### Metric Types

- **Counter**: Non-negative values only (e.g., number of processed items)
- **UpDownCounter**: Positive or negative values
- **Gauge**: Single current value at a point in time (e.g., queue size)
- **Histogram**: Distribution of values over time (e.g., execution duration)

### Tags

Avoid tags with high cardinality (e.g., `OrganizationId`, `DatasetId`) as they drastically increase DataDog costs. Each unique combination of metric name + tag values is billed as a separate custom metric.

```csharp
// Adding custom tags
counter.Add(delta: 1, tags: [new("tagName", tagValue)]);
histogram.Record(value: elapsedTime, tags: [new("tagName", tagValue)]);
```

### Testing Metrics

Use `MetricCollector` to test metrics:

```csharp
// Arrange
var serviceCollection = new ServiceCollection();
serviceCollection.AddMetrics();
var services = serviceCollection.BuildServiceProvider();
var meterFactory = services.GetRequiredService<IMeterFactory>();

// Use the same MeterName as the one used to instantiate the Meter
var counterCollector = new MetricCollector<long>(meterFactory, "MyServiceMeter", "pigment.myservice.operation_count");

// Act
var metrics = new MyServiceMetrics(meterFactory);
metrics.RecordOperation(true);

// Assert
var measurements = counterCollector.GetMeasurementSnapshot();
Assert.That(measurements.Count, Is.EqualTo(1));
Assert.That(measurements[0].Value, Is.EqualTo(1));
Assert.That(measurements[0].MatchesTags([new("isSuccess", true)]), Is.True);
```

## Git Worktrees

- **Guidelines belong in the main repository**: When using git worktrees, always save guidelines and documentation updates (like this CLAUDE.md file) in the main repository, not in the worktree. The worktree should only contain feature-specific changes.
- **Copy `.claude` configuration files to worktrees**: When creating a worktree, always copy the `.claude` configuration files (skills, `CLAUDE.md`, etc.) from the main repository into the worktree, even if they are ignored by git. This ensures Claude Code has access to project guidelines and skills in the worktree. Only copy the configuration files, not the entire `.claude` folder.
- **Never create worktrees inside `.claude`**: Always create worktrees next to the original repository folder (at the same level), never inside the `.claude` directory.

## Testing Patterns

### Building Services Under Test

When writing tests for services, use a single static `BuildObserver`/`Build<ServiceName>` factory method that accepts all dependencies as optional parameters with sensible defaults:

```csharp
private static MyService BuildService(
    IDependency1? dependency1 = null,
    IDependency2? dependency2 = null,
    ILogger<MyService>? logger = null,
    MyService.Options? options = null,
    IMetrics? metrics = null)
{
    dependency1 ??= new FakeDependency1();
    dependency2 ??= new FakeDependency2();
    logger ??= ConsoleLogger.New<MyService>();
    options ??= new MyService.Options();
    metrics ??= NullMetrics.Instance;

    return new MyService(
        dependency1: dependency1,
        dependency2: dependency2,
        logger: logger,
        options: Options.Create(options),
        metrics: metrics);
}
```

This pattern:
- Keeps test setup concise by only specifying the dependencies relevant to each test
- Makes tests self-documenting about which dependencies they care about
- Avoids duplication of service construction logic across tests
- Returns the service directly (not started) so tests can control the lifecycle

For hosted services, tests should call `.StartAsDisposableService(cancellationToken)` themselves:

```csharp
await using var observer = await BuildObserver(publisher: publisher, metrics: metrics)
    .StartAsDisposableService(cancellationToken);
```

### Disposing Resources in Test Fixtures

When a test fixture has disposable fields (e.g., resources created in the constructor), use `[OneTimeTearDown]` to dispose them instead of implementing `IDisposable`:

```csharp
public class MyServiceTest
{
    private readonly DisposableResource _resource;

    public MyServiceTest()
    {
        _resource = new DisposableResource();
    }

    [OneTimeTearDown]
    public void OneTimeTearDown()
    {
        _resource.Dispose();
    }
}
```

### Default Logger in Test Helpers

When a test helper (or `Build<Service>` factory) needs an `ILogger` and the caller did not provide one, default to `ConsoleLogger.New<T>()` (from `Pigment.TestHelpers`), not `NullLogger.Instance`.

`ConsoleLogger` writes log lines to the test output, which makes failing tests much easier to debug. `NullLogger` silently drops everything, so a failure on CI gives no breadcrumbs. Reserve `NullLogger.Instance` for tests that intentionally assert on the absence of log noise.

```csharp
// BAD: log messages from the system under test disappear
private static MyService BuildService(ILogger<MyService>? logger = null)
    => new(logger ?? NullLogger<MyService>.Instance);

// GOOD: log messages show up next to the test failure
private static MyService BuildService(ILogger<MyService>? logger = null)
    => new(logger ?? ConsoleLogger.New<MyService>());
```

When a test needs to assert on log records, the caller still passes its own `FakeLogger<T>` explicitly -- the default only matters when the caller doesn't care.

### Running Tests Multiple Times

When verifying a test is not flaky, use NUnit's `[Repeat(N)]` attribute instead of a shell loop. For example: `[Repeat(10)]` on the test method.

### Waiting for Asynchronous State in Tests

When you need to wait for an asynchronous condition that cannot be observed through synchronization primitives (mocks, signals, etc.), use NUnit's `Assert.That(() => ..., constraint.After(timeout).PollEvery(interval))` instead of `Task.Delay`:

```csharp
// Bad - arbitrary delay, flaky and slow
await Task.Delay(50, cancellationToken);
Assert.That(service.State, Is.EqualTo(expectedState));

// Good - polls until condition is met or timeout expires, with explicit units
Assert.That(
    () => service.State,
    Is.EqualTo(expectedState).After(1).Seconds.PollEvery(10).MilliSeconds);
```

### CancelAfter Attribute

Place `[CancelAfter(N)]` on the **class** level, not on individual test methods. This keeps test timeouts consistent and avoids repetition:

```csharp
// Good - class level
[TestFixture(Category = "Unit")]
[CancelAfter(5_000)]
public class MyServiceTest
{
    [Test]
    public async Task MyTest(CancellationToken cancellationToken) { ... }
}

// Bad - per-method
[Test, CancelAfter(5_000)]
public async Task MyTest(CancellationToken cancellationToken) { ... }
```

### Asserting Logs with FakeLogger

When asserting log output, use `FakeLogger<T>` and access its built-in `.Collector` property. Do not create a separate `FakeLogCollector`:

```csharp
// Good - use default collector
var logger = new FakeLogger<MyService>();
// ... exercise code ...
var logRecords = logger.Collector.GetSnapshot();

// Bad - unnecessary FakeLogCollector
var logCollector = new FakeLogCollector();
var logger = new FakeLogger<MyService>(logCollector);
// ... exercise code ...
var logRecords = logCollector.GetSnapshot();
```

### NUnit Assertion Guidelines

See [nunit-guidelines.md](./nunit-guidelines.md) for detailed NUnit assertion rules based on [NUnit Analyzers](https://github.com/nunit/nunit.analyzers/tree/master/documentation).

## Database Migrations

- **Idempotent migrations**: Always use `IF NOT EXISTS` (for `CREATE TABLE`, `CREATE INDEX`, etc.) and `IF EXISTS` (for `DROP`) so that migrations can be re-run safely without error.
