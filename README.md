# Quiz Library

A client-side quiz application built with [Gleam](https://gleam.run/) and
[Lustre](https://lustre.build/). It currently includes a 100-question Gleam
quiz and a 42-question practical Functional Programming quiz.

[Take the quizzes](https://gleam-quiz.vercel.app) ·
[View the source](https://github.com/bmehder/gleam-quiz)

## Features

- A catalogue for selecting between independent quizzes
- Random question order on every attempt
- Random answer order while keeping quiz authoring predictable
- Immediate answer review with an explanation
- Progress tracking, final scores, and quiz restarts
- Native browser confirmation before abandoning an attempt
- A dark, responsive Tailwind CSS interface
- Development-only time-travel debugging

## How it is organised

The quiz engine and quiz content are deliberately separate:

```text
src/
├── quiz.gleam                         # Lustre application and interface
├── quiz/
│   └── domain.gleam                  # Quiz, Question, and Answer types
├── quizzes/
│   ├── catalog.gleam                 # Available quizzes
│   ├── gleam.gleam                   # 100 Gleam questions
│   └── functional_programming.gleam  # 42 FP questions
└── support/
    ├── dialog.gleam                  # Managed native-dialog effect
    └── dialog_ffi.mjs                # Small browser API boundary
dev/
├── check_answer_length_bias.gleam    # Quiz-content quality check
└── quiz_dev.gleam                    # Time-travel development entry point
test/
└── quiz_test.gleam                   # Domain and state-transition tests
```

`quiz.gleam` owns the Model–View–Update lifecycle. The model keeps the current
screen separate from its dialog, so opening the exit confirmation does not
replace or recursively wrap the quiz screen. Its `QuizAttempt` type holds the
state shared by the `Answering` and `Reviewing` screens, while the screen's
variants ensure that only the reviewing phase can contain a selected answer.
Question numbers and totals are derived from the quiz and its remaining
questions instead of being stored as additional, potentially inconsistent
state.
The domain module contains reusable quiz types and preparation functions, while
each module under `src/quizzes/` contains only quiz metadata and questions.

## Question authoring

Quiz authors supply the correct answer first. Before an attempt begins, the app
shuffles both the question list and each question's answers, so the source order
never reveals the answer to the player.

The `quiz/domain.question` helper provides a compact format for new question
banks:

```gleam
domain.question(
  prompt: "What makes a function pure?",
  correct: "It is deterministic and has no observable side effects",
  incorrect: [
    "It contains no local variables",
    "It accepts exactly one argument",
    "It is shorter than ten lines",
  ],
  explanation: "A pure function depends only on its inputs and does not change observable external state.",
)
```

Add new quizzes to `src/quizzes/` and register them in
`src/quizzes/catalog.gleam`.

## Development

Install [Gleam](https://gleam.run/getting-started/installing/) and
[Bun](https://bun.sh/), then start Lustre's development server:

```sh
gleam run -m lustre/dev start
```

Open <http://localhost:1234>. The server watches the source and reloads the
browser after changes.

### Checks

Compile the project:

```sh
gleam check
```

Run the automated tests:

```sh
gleam test
```

Check formatting:

```sh
gleam format --check src dev
```

Check both question banks for structural errors and answer-length bias:

```sh
gleam run -m check_answer_length_bias
```

The content check verifies that every question has four choices, exactly one
correct answer, and that correct answers are not disproportionately the longest
choice. It imports the catalogue and checks the same Gleam domain values used by
the application rather than parsing the question source files.

### Time travel

Run the development entry point to add the
[timetravel](https://hex.pm/packages/timetravel) inspector:

```sh
gleam run -m lustre/dev start quiz_dev
```

Answer some questions, then open **Time Travel** in the lower-right corner to
inspect messages, revisit earlier models, and return to the present state.

## Production build

Create the static site in `dist/`:

```sh
gleam run -m lustre/dev build
```

The output contains the bundled JavaScript, compiled Tailwind stylesheet,
generated HTML, and static assets. Production is hosted on Vercel and deployed
manually from this build, so a GitHub push does not automatically publish the
site.
