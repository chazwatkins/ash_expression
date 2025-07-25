# Agent Guidance for AshExpression

## Project Overview

**AshExpression** is a standalone expression system for the Ash Framework that decouples expression handling from `Ash.Query`. This allows expressions to be defined, processed, and evaluated independently while maintaining compatibility with existing Ash DSLs.

### Repository Description
> Standalone expression system for Ash Framework - Build, analyze, and evaluate expressions without Query dependencies

## Key Architecture Principles

### 1. Source→Sink Data Flow
- **Source**: Raw Elixir AST from `expr(...)` macros
- **Intermediate Representation (IR)**: Structured `Ref` and `Call` types  
- **Sink**: Target systems (SQL, evaluation, etc.)

### 2. Transformer Pipeline Architecture
Expressions flow through focused transformers with single responsibilities:
1. **BuildExpressions**: AST → structured `Ref`/`Call` types
2. **ClassifyExpressions**: Determine compile-time vs runtime + pre-compute static results
3. **Future transformers**: Validation, optimization, etc.

### 3. No Breaking Changes
- All existing public APIs must continue working
- Use delegation patterns for backward compatibility
- Support incremental migration from `Ash.Expr` to `AshExpression`

## Code Quality Standards

### Error Handling
- **Use Splode package** for all custom exceptions
- **Each exception type gets its own module** (not nested in umbrella modules)
- **No rescue blocks on functions** - let exceptions bubble up naturally
- Follow Ash's error patterns from `/ash/lib/ash/error/`

### Function Naming
- **Avoid `do_*` prefix** - use descriptive names like `build`, `classify`, `evaluate`
- Use clear, intention-revealing names over generic prefixes

### Testing
- **Test descriptions should be descriptive** - avoid unnecessary comments in tests
- **Use `is_struct(value, Module)` for struct type assertions** instead of `.__struct__`
- **Separate test files for each module** - don't put everything in one test file
- Use TDD approach - write tests first, then implement

### File Organization
- **Clean up temporary/debug files** - don't leave unused files around
- Each transformer gets its own file and test file
- Use descriptive module names that reflect single responsibilities

### Dependencies
- **Never assume libraries are available** - check if the codebase uses them first
- Look at `package.json`, `mix.exs`, etc. to verify dependencies
- Follow existing patterns in the codebase

## Development Workflow

### 1. Task Management
- **Use TodoWrite tool frequently** to track progress and give user visibility
- Mark todos as completed immediately when finished (don't batch)
- Only have ONE task in_progress at any time
- Create specific, actionable todo items

### 2. Git Workflow
- **Always ask permission before committing** - never commit without explicit approval
- **Use conventional commit messages** that are descriptive
- **Never push without explicit permission** from the user
- Use `git add .` then commit with detailed message using heredoc format

### 3. Planning vs Implementation
- **Use ExitPlanMode tool** when tasks require planning implementation steps
- **Don't use ExitPlanMode** for research/exploration tasks
- Focus on implementation after planning is approved

## Current Implementation Status

### Completed Components

#### Core Data Structures
- `AshExpression.Ref` - Field references (attribute, relationship_path)
- `AshExpression.Call` - Function calls and operators (name, args, operator?)
- `AshExpression.Dsl.Expr` - Expression entity with clear fields:
  - `:source_ast` - Original quoted AST
  - `:parsed_ir` - Structured Ref/Call intermediate representation
  - `:type` - `:compile_time` or `:runtime` classification
  - `:result` - Pre-computed result for compile-time expressions

#### DSL System
- Spark DSL extension with top-level `expr(...)` macro
- Automatic AST capture using `:quoted` type
- Clean module syntax: `use AshExpression` then `expr(field == value)`

#### Transformer Pipeline
1. **BuildExpressions** - Converts AST to structured types
   - Supports operators: `==`, `!=`, `>`, `<`, `>=`, `<=`
   - Supports boolean operators: `and`, `or`, `not`, `in`
   - Supports arithmetic: `+`, `-`, `*`, `/`
   - Proper error handling with `UnsupportedExpression`

2. **ClassifyExpressions** - Determines evaluation strategy
   - `:compile_time` for expressions with only static values
   - `:runtime` for expressions containing field references
   - Pre-computes results for compile-time expressions
   - Proper transformer dependency ordering with `after?/1`

### Expression Classification Logic

**Compile-time expressions** (no field references):
```elixir
expr(true == false)           # → type: :compile_time, result: false
expr(2 + 2 == 4)             # → type: :compile_time, result: true
expr(not false)              # → type: :compile_time, result: true
```

**Runtime expressions** (contains field references):
```elixir
expr(status == :active)      # → type: :runtime, result: nil
expr(age > 18)               # → type: :runtime, result: nil
expr(active? and true)       # → type: :runtime (mixed, but has field ref)
```

### Next Steps (Pending)
- Step 5: Create Expression Module Template
- Step 6: Create Expression Access Functions  
- Step 7: Create Usage Interface
- Step 8: End-to-End Integration Test

## Integration Strategy

### Incremental Migration Plan
The goal is to gradually replace `Ash.Expr` functionality using feature-based delegation:

1. **Capability Detection** - `AshExpression.supports?(ast)` determines if new system can handle expression
2. **Smart Router** - `Ash.Expr.expr/1` routes to appropriate implementation
3. **Feature Flags** - Allow enabling/disabling features during rollout
4. **Zero Breaking Changes** - Existing code continues working unchanged

This allows shipping `AshExpression` early and expanding capabilities incrementally.

## Communication Style

### For Claude Agents
- **Be concise and direct** - fewer than 4 lines unless user asks for detail
- **Minimize output tokens** while maintaining quality
- **No unnecessary preamble/postamble** unless requested
- **Answer directly** without "The answer is..." or "Based on..."
- **Use TodoWrite proactively** for complex multi-step tasks
- **Focus on the specific task** - avoid tangential information

### Code Comments
- **NEVER add comments unless explicitly asked**
- Code should be self-documenting through clear naming
- Use descriptive variable and function names instead of comments

## File Structure Reference

```
ash_expression/
├── lib/ash_expression/
│   ├── call.ex                    # Call struct for operators/functions
│   ├── ref.ex                     # Ref struct for field references  
│   ├── dsl.ex                     # Spark DSL extension + Expr entity
│   ├── info.ex                    # Introspection functions
│   ├── error/
│   │   ├── unsupported_expression.ex
│   │   └── invalid_expression.ex
│   └── transformers/
│       ├── build_expressions.ex   # AST → Ref/Call transformation
│       └── classify_expressions.ex # Compile-time vs runtime classification
├── test/
│   ├── ash_expression_test.exs    # Top-level integration tests
│   ├── ash_expression/
│   │   ├── call_test.exs
│   │   ├── ref_test.exs  
│   │   ├── dsl/
│   │   │   └── expr_test.exs
│   │   └── transformers/
│   │       ├── build_expressions_test.exs
│   │       └── classify_expressions_test.exs
├── notes/                         # Design documentation
└── mix.exs                       # Dependencies: splode, spark, sourceror, igniter
```

Remember: This is a **proof of concept** demonstrating clean architectural separation. The focus is on showing how expressions can be processed independently of `Ash.Query` while maintaining compatibility and extensibility.