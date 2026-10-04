import quiz/domain.{type Quiz, Quiz}

pub fn quiz() -> Quiz {
  Quiz(
    id: "functional-programming",
    title: "Functional Programming",
    description: "42 practical questions about functions, data, effects, and program design.",
    questions: questions(),
  )
}

fn questions() {
  [
    domain.question(
      prompt: "What makes a function pure?",
      correct: "Its result depends only on its inputs and it has no observable side effects",
      incorrect: [
        "It contains no local variables",
        "It accepts exactly one argument",
        "It is shorter than ten lines",
      ],
      explanation: "A pure function is deterministic for the same inputs and does not change observable state outside itself.",
    ),
    domain.question(
      prompt: "What does referential transparency allow you to do?",
      correct: "Replace an expression with its value without changing program behaviour",
      incorrect: [
        "Replace every function with a global variable",
        "Skip type checking for an expression",
        "Mutate a value through any reference",
      ],
      explanation: "Referentially transparent expressions have no hidden context or effects that would make substitution change behaviour.",
    ),
    domain.question(
      prompt: "What is the practical meaning of immutable data?",
      correct: "Existing values are not changed; updated versions are new values",
      incorrect: [
        "Values can never be stored",
        "Every value must be a constant literal",
        "Memory can never be reused internally",
      ],
      explanation: "Immutability is a semantic guarantee. Implementations may safely share or reuse storage without exposing mutation.",
    ),
    domain.question(
      prompt: "What does it mean for functions to be first-class values?",
      correct: "They can be stored, passed as arguments, and returned like other values",
      incorrect: [
        "They always execute before data is created",
        "They must be declared at the top of a file",
        "They cannot capture surrounding values",
      ],
      explanation: "Treating functions as values enables callbacks, composition, reusable transformations, and higher-order APIs.",
    ),
    domain.question(
      prompt: "What is a higher-order function?",
      correct: "A function that accepts or returns another function",
      incorrect: [
        "A function with more than five parameters",
        "A function that runs with elevated permissions",
        "A recursive function with no base case",
      ],
      explanation: "Map, filter, and fold are common higher-order functions because their behaviour is configured with another function.",
    ),
    domain.question(
      prompt: "What operation does map express?",
      correct: "Transform every element while preserving the collection's shape",
      incorrect: [
        "Keep only elements matching a predicate",
        "Combine all elements into one value",
        "Reorder elements randomly",
      ],
      explanation: "Map applies one transformation independently to each element and returns the corresponding transformed collection.",
    ),
    domain.question(
      prompt: "What operation does filter express?",
      correct: "Keep the elements for which a predicate succeeds",
      incorrect: [
        "Transform every element into a new type",
        "Combine all elements into an accumulator",
        "Return only the final element",
      ],
      explanation: "Filter preserves original elements that satisfy a condition and discards the others.",
    ),
    domain.question(
      prompt: "What operation does fold express?",
      correct: "Process a collection into an accumulated result",
      incorrect: [
        "Duplicate every element",
        "Make a collection mutable",
        "Run a predicate without producing a value",
      ],
      explanation: "A fold repeatedly combines the current accumulator with the next element to produce a final result.",
    ),
    domain.question(
      prompt: "Why does a fold usually take an initial accumulator?",
      correct: "It defines the starting result and handles an empty collection",
      incorrect: [
        "It forces the collection to be sorted",
        "It enables mutation of the first element",
        "It determines the collection's element type at runtime",
      ],
      explanation: "The initial value gives the fold a well-defined result even when there are no elements to process.",
    ),
    domain.question(
      prompt: "What is the essential role of a recursive function's base case?",
      correct: "It provides a result without making another recursive call",
      incorrect: [
        "It mutates the recursion counter",
        "It catches every possible exception",
        "It runs only after the program exits",
      ],
      explanation: "A reachable base case stops the recursion; other branches must make progress toward it.",
    ),
    domain.question(
      prompt: "When is recursion tail-recursive?",
      correct: "When the recursive call is the function's final operation",
      incorrect: [
        "When it processes a linked list",
        "When it calls itself more than once",
        "When its result is a Boolean",
      ],
      explanation: "With no remaining work after the call, a runtime can often reuse the current stack frame.",
    ),
    domain.question(
      prompt: "What does pattern matching combine particularly well?",
      correct: "Checking data's shape and binding the parts you need",
      incorrect: [
        "Mutating data and suppressing errors",
        "Downloading data and caching files",
        "Sorting data and changing its type",
      ],
      explanation: "Patterns describe expected structure while introducing names for the values contained within that structure.",
    ),
    domain.question(
      prompt: "Why are algebraic data types useful in everyday application code?",
      correct: "They model a closed set of meaningful data shapes",
      incorrect: [
        "They automatically persist data to a database",
        "They eliminate the need for functions",
        "They make all values interchangeable",
      ],
      explanation: "Product and variant types let a program represent domain states explicitly and process them with pattern matching.",
    ),
    domain.question(
      prompt: "What problem does an Option type solve?",
      correct: "Representing that a value may be present or absent",
      incorrect: [
        "Representing several detailed failure reasons",
        "Running an operation asynchronously",
        "Storing values in insertion order",
      ],
      explanation: "Option replaces implicit nullability with explicit Some and None cases that callers must consider.",
    ),
    domain.question(
      prompt: "When is Result usually preferable to Option?",
      correct: "When callers benefit from information about why an operation failed",
      incorrect: [
        "When failure is impossible",
        "When a function returns no value",
        "When values need to be mutable",
      ],
      explanation: "Result carries an error value, making it suitable when distinct failure details affect handling or feedback.",
    ),
    domain.question(
      prompt: "What is function composition?",
      correct: "Building a function by connecting the output of one function to another",
      incorrect: [
        "Putting every function in one source file",
        "Running unrelated functions simultaneously",
        "Changing a function's arguments after it returns",
      ],
      explanation: "Composition creates larger transformations from smaller functions with compatible inputs and outputs.",
    ),
    domain.question(
      prompt: "What is the main readability benefit of a pipeline?",
      correct: "It presents a sequence of transformations in data-flow order",
      incorrect: [
        "It makes every operation lazy",
        "It automatically handles every error",
        "It changes immutable data into mutable data",
      ],
      explanation: "Pipelines let readers follow a value through successive steps without deeply nested function calls.",
    ),
    domain.question(
      prompt: "What is a closure?",
      correct: "A function together with values captured from its surrounding scope",
      incorrect: [
        "A function that immediately terminates the process",
        "A data structure that cannot be inspected",
        "The final expression in a module",
      ],
      explanation: "A closure can continue to use captured values even after the scope that created it has finished.",
    ),
    domain.question(
      prompt: "What does partial application produce?",
      correct: "A new function with some arguments already supplied",
      incorrect: [
        "A partially computed value that cannot finish",
        "A function with no type",
        "A mutable copy of the original function",
      ],
      explanation: "Supplying fewer than all conceptual inputs can specialise a general function into a more specific one.",
    ),
    domain.question(
      prompt: "What is currying?",
      correct: "Representing a multi-argument function as nested one-argument functions",
      incorrect: [
        "Caching every function result",
        "Converting a function into a string",
        "Calling a function with named arguments",
      ],
      explanation: "Currying and partial application are related but distinct: currying is a function representation; partial application supplies some inputs.",
    ),
    domain.question(
      prompt: "What distinguishes lazy evaluation from eager evaluation?",
      correct: "Lazy evaluation delays work until its result is needed",
      incorrect: [
        "Lazy evaluation always runs work concurrently",
        "Eager evaluation cannot evaluate functions",
        "Eager evaluation skips unused arguments after computing them",
      ],
      explanation: "Eager evaluation computes expressions as encountered, while lazy evaluation represents deferred computation until demanded.",
    ),
    domain.question(
      prompt: "What is a persistent data structure?",
      correct: "An immutable structure whose older versions remain available after updates",
      incorrect: [
        "A structure permanently stored on disk",
        "A mutable structure shared by every thread",
        "A collection that can never be garbage-collected",
      ],
      explanation: "Persistent structures commonly share unchanged internal parts, making new versions practical without modifying old ones.",
    ),
    domain.question(
      prompt: "How does immutability help concurrent programs?",
      correct: "Shared immutable values cannot suffer data races from writes",
      incorrect: [
        "It guarantees that all operations run in parallel",
        "It prevents processes from sending messages",
        "It removes every possible concurrency bug",
      ],
      explanation: "Immutability removes a major class of coordination problems, though ordering, deadlocks, and other issues can still remain.",
    ),
    domain.question(
      prompt: "How do functional programs typically handle unavoidable side effects?",
      correct: "Keep them at explicit boundaries around a mostly pure core",
      incorrect: [
        "Pretend that input and output are pure",
        "Ban all interaction with the outside world",
        "Place effects randomly throughout domain logic",
      ],
      explanation: "A functional core with an imperative shell makes effectful integration visible while keeping most logic deterministic.",
    ),
    domain.question(
      prompt: "Why is hidden global state difficult to reason about?",
      correct: "A function's behaviour can depend on changes not visible in its inputs",
      incorrect: [
        "Global values cannot have types",
        "It forces every function to be recursive",
        "It makes source files immutable",
      ],
      explanation: "Hidden dependencies weaken local reasoning because understanding a call requires knowing unrelated execution history.",
    ),
    domain.question(
      prompt: "Why are pure functions usually straightforward to unit test?",
      correct: "Tests can supply inputs and compare outputs without arranging external state",
      incorrect: [
        "Pure functions never contain bugs",
        "They do not need test inputs",
        "Their results are always Boolean",
      ],
      explanation: "Determinism and lack of effects reduce setup, cleanup, mocking, and timing concerns.",
    ),
    domain.question(
      prompt: "What is property-based testing well suited to checking?",
      correct: "General invariants across many generated inputs",
      incorrect: [
        "Only one manually chosen example",
        "The colour of rendered buttons",
        "Whether a function has comments",
      ],
      explanation: "Properties describe behaviour that should hold broadly, while generators explore many cases that example tests might miss.",
    ),
    domain.question(
      prompt: "How can dependency injection remain functional?",
      correct: "Pass required operations into a function as values",
      incorrect: [
        "Read every dependency from a global registry",
        "Construct network clients inside pure calculations",
        "Disable the function's type signature",
      ],
      explanation: "Passing functions or capability records makes dependencies explicit and allows tests to provide deterministic alternatives.",
    ),
    domain.question(
      prompt: "What is a state transition function?",
      correct: "A function that derives a new state from an old state and an event",
      incorrect: [
        "A procedure that mutates every reachable object",
        "A function that can only return the old state",
        "A database table containing application logs",
      ],
      explanation: "Explicit state transitions make changes inspectable, testable, and replayable without requiring hidden mutation.",
    ),
    domain.question(
      prompt: "Why is modelling an event separately from state useful?",
      correct: "It records what happened independently of the resulting state",
      incorrect: [
        "It guarantees the event came from a browser",
        "It makes state untyped",
        "It allows events to mutate earlier states",
      ],
      explanation: "Events can be logged, replayed, tested, and interpreted by a transition function to produce new states.",
    ),
    domain.question(
      prompt: "What does expression-oriented programming encourage?",
      correct: "Constructs that evaluate to values and can be composed",
      incorrect: [
        "Statements that always mutate global state",
        "Functions that cannot return data",
        "Branches with unrelated result types",
      ],
      explanation: "When conditionals, matches, and blocks yield values, they fit naturally into larger computations.",
    ),
    domain.question(
      prompt: "What does declarative code emphasise?",
      correct: "What result is wanted more than step-by-step machine instructions",
      incorrect: [
        "Avoiding all function calls",
        "Writing only comments and type signatures",
        "Changing variables as often as possible",
      ],
      explanation: "Operations such as map and filter state the transformation directly while abstracting traversal mechanics.",
    ),
    domain.question(
      prompt: "What is a total function?",
      correct: "A function defined for every value in its declared input domain",
      incorrect: [
        "A function that only adds numbers",
        "A function that returns several values",
        "A function with access to all global state",
      ],
      explanation: "Total functions return a valid result for every permitted input rather than crashing or becoming undefined for some cases.",
    ),
    domain.question(
      prompt: "How can a type help turn a partial operation into a total one?",
      correct: "Represent failure explicitly with a type such as Option or Result",
      incorrect: [
        "Hide invalid inputs from the documentation",
        "Return an arbitrary value for every failure",
        "Use mutation to retry forever",
      ],
      explanation: "An explicit failure case makes every input produce a value covered by the function's return type.",
    ),
    domain.question(
      prompt: "Why is exhaustive pattern matching valuable?",
      correct: "It ensures every represented case is handled",
      incorrect: [
        "It makes every case execute",
        "It automatically chooses the fastest branch",
        "It permits branches to return unrelated types",
      ],
      explanation: "Exhaustiveness checking turns omitted cases into compiler feedback rather than surprising runtime behaviour.",
    ),
    domain.question(
      prompt: "What does 'make illegal states unrepresentable' mean?",
      correct: "Design types so invalid combinations cannot be constructed normally",
      incorrect: [
        "Remove validation from every system boundary",
        "Store invalid values in hidden global variables",
        "Treat every field as an optional string",
      ],
      explanation: "Precise domain types shift invariants from comments and repeated checks into construction rules enforced by the compiler.",
    ),
    domain.question(
      prompt: "What is a combinator in practical functional code?",
      correct: "A function that builds or combines behaviour from other functions or values",
      incorrect: [
        "A compiler that merges source files",
        "A loop that mutates its collection",
        "A global registry of callbacks",
      ],
      explanation: "Small combinators provide reusable ways to sequence, transform, choose, or combine computations.",
    ),
    domain.question(
      prompt: "When is memoisation safest?",
      correct: "When the memoised function is pure",
      incorrect: [
        "When the function writes to a database",
        "When results intentionally change on every call",
        "When cache keys omit function inputs",
      ],
      explanation: "A pure function always maps the same input to the same output, so reusing a cached result preserves behaviour.",
    ),
    domain.question(
      prompt: "What is a common advantage of parsing data into domain types early?",
      correct: "Later code can operate on validated structure instead of repeatedly checking raw input",
      incorrect: [
        "The original input becomes mutable",
        "Every parse is guaranteed to succeed",
        "Domain types no longer need constructors",
      ],
      explanation: "Parsing at the boundary concentrates validation and gives the pure core stronger, more useful guarantees.",
    ),
    domain.question(
      prompt: "What is the difference between fail-fast and accumulating validation?",
      correct: "Fail-fast stops at one error; accumulating validation collects independent errors",
      incorrect: [
        "Fail-fast is pure while accumulation is always impure",
        "Accumulation ignores every error",
        "They differ only in function naming",
      ],
      explanation: "The right approach depends on whether later checks are meaningful and whether users benefit from seeing several problems together.",
    ),
    domain.question(
      prompt: "Why use a structured error type instead of arbitrary strings?",
      correct: "Programs can handle known failure cases safely and consistently",
      incorrect: [
        "Structured errors can never be displayed",
        "Strings cannot be returned from functions",
        "It makes failures impossible",
      ],
      explanation: "Typed variants support exhaustive handling, while presentation code can still convert them into human-readable messages.",
    ),
    domain.question(
      prompt: "Does functional programming require eliminating all mutation internally?",
      correct: "No; controlled local mutation can be an implementation detail behind a pure interface",
      incorrect: [
        "Yes; any mutation makes a program non-functional",
        "No; hidden global mutation is always harmless",
        "Yes; computers running functional code cannot change memory",
      ],
      explanation: "The observable semantics and boundaries matter most. Implementations can use local mutation safely when it does not leak or alter expected behaviour.",
    ),
  ]
}
