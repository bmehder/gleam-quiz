//// Browser quiz application and Lustre UI for selecting and taking quizzes.

import gleam/dynamic/decode
import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/effect.{type Effect}
import lustre/element.{type Element}
import lustre/element/html
import lustre/element/svg
import lustre/event
import quiz/domain.{type Answer, type Question, type Quiz, Correct, Incorrect}
import quizzes/catalog
import support/dialog

// MODEL AND MESSAGES ----------------------------------------------------------

pub type QuizAttempt {
  QuizAttempt(
    quiz: Quiz,
    current_question: Question,
    remaining_questions: List(Question),
    score: Int,
  )
}

pub type Model {
  ChoosingQuiz
  Answering(attempt: QuizAttempt)
  Reviewing(attempt: QuizAttempt, selected_answer: Answer)
  ConfirmingQuizExit(model: Model)
  Finished(quiz: Quiz, score: Int)
}

pub type Msg {
  UserStartedQuiz(Quiz)
  UserSelectedAnswer(Answer)
  UserClickedNextQuestion
  UserClickedRestartQuiz
  UserClickedChooseQuiz
  UserConfirmedQuizExit
  UserCancelledQuizExit
  UserPressedQuizExitKey(String)
}

// LUSTRE LIFECYCLE ------------------------------------------------------------

pub fn initial_model() -> Model {
  ChoosingQuiz
}

fn start_quiz(quiz: Quiz) -> Model {
  case domain.shuffled_questions(quiz) {
    [first, ..rest] -> Answering(attempt: QuizAttempt(quiz, first, rest, 0))

    [] -> Finished(quiz: quiz, score: 0)
  }
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let next_model = update_model(model, msg)
  let effect = case model, msg {
    Answering(_), UserClickedChooseQuiz -> dialog.show_quiz_exit()

    Reviewing(_, _), UserClickedChooseQuiz -> dialog.show_quiz_exit()

    _, _ -> effect.none()
  }

  #(next_model, effect)
}

fn update_model(model: Model, msg: Msg) -> Model {
  case model, msg {
    ChoosingQuiz, UserStartedQuiz(quiz) -> start_quiz(quiz)

    Answering(attempt), UserSelectedAnswer(answer) -> {
      let new_score = case answer.correctness {
        Correct -> attempt.score + 1
        Incorrect -> attempt.score
      }

      Reviewing(
        attempt: QuizAttempt(..attempt, score: new_score),
        selected_answer: answer,
      )
    }

    Reviewing(QuizAttempt(quiz, _, [next, ..rest], score), _),
      UserClickedNextQuestion
    ->
      Answering(attempt: QuizAttempt(
        quiz: quiz,
        current_question: next,
        remaining_questions: rest,
        score: score,
      ))

    Reviewing(QuizAttempt(quiz, _, [], score), _), UserClickedNextQuestion ->
      Finished(quiz: quiz, score: score)

    Finished(quiz, _), UserClickedRestartQuiz -> start_quiz(quiz)

    Answering(_), UserClickedChooseQuiz -> ConfirmingQuizExit(model: model)

    Reviewing(_, _), UserClickedChooseQuiz -> ConfirmingQuizExit(model: model)

    Finished(_, _), UserClickedChooseQuiz -> ChoosingQuiz

    ConfirmingQuizExit(_), UserConfirmedQuizExit -> ChoosingQuiz

    ConfirmingQuizExit(model), UserCancelledQuizExit -> model

    ConfirmingQuizExit(model), UserPressedQuizExitKey("Escape") -> model

    _, _ -> model
  }
}

fn init(_arguments: Nil) -> #(Model, Effect(Msg)) {
  #(initial_model(), effect.none())
}

// VIEWS -----------------------------------------------------------------------

pub fn view(model: Model) -> Element(Msg) {
  html.main(
    [
      attribute.class(
        "flex min-h-screen items-center justify-center bg-slate-950 px-4 py-12 text-slate-100",
      ),
    ],
    [
      html.div([attribute.class("w-full max-w-3xl")], [
        view_header(model),
        view_content(model),
      ]),
      ..view_confirmation(model)
    ],
  )
}

// VIEW HELPERS ----------------------------------------------------------------

fn view_header(model: Model) -> Element(Msg) {
  html.header(
    [attribute.class("relative mb-6 flex items-center justify-center")],
    [
      html.h1(
        [
          attribute.class(
            "text-center text-sm font-bold tracking-[0.3em] text-fuchsia-400 uppercase",
          ),
        ],
        [html.text(view_title(model))],
      ),
      html.a(
        [
          attribute.href("https://github.com/bmehder/gleam-quiz"),
          attribute.target("_blank"),
          attribute.rel("noopener noreferrer"),
          attribute.aria_label("View the source code on GitHub"),
          attribute.class(
            "absolute right-0 rounded-lg p-2 text-slate-400 transition hover:bg-slate-800 hover:text-white focus:ring-2 focus:ring-fuchsia-400 focus:outline-none",
          ),
        ],
        [view_github_icon()],
      ),
    ],
  )
}

fn view_github_icon() -> Element(Msg) {
  svg.svg(
    [
      attribute.attribute("viewBox", "0 0 24 24"),
      attribute.attribute("fill", "currentColor"),
      attribute.aria_hidden(True),
      attribute.class("size-6"),
    ],
    [
      svg.path([
        attribute.attribute(
          "d",
          "M12 0C5.37 0 0 5.37 0 12c0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C6.096 18.32 5.438 18 5.438 18c-1.087-.744.083-.729.083-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.418-1.305.762-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23A11.5 11.5 0 0 1 12 6.5c1.02.005 2.045.138 3.005.404 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 21.795 24 17.3 24 12c0-6.63-5.37-12-12-12Z",
        ),
      ]),
    ],
  )
}

fn view_content(model: Model) -> Element(Msg) {
  case model {
    ChoosingQuiz -> view_quiz_chooser(catalog.all())

    Answering(attempt) -> view_answering(attempt)

    Reviewing(attempt, selected_answer) ->
      view_reviewing(attempt, selected_answer)

    ConfirmingQuizExit(model) -> view_content(model)

    Finished(quiz, score) -> view_finished(quiz, score)
  }
}

fn view_title(model: Model) -> String {
  case model {
    ChoosingQuiz -> "Quiz Library"
    Answering(attempt) -> attempt.quiz.title <> " Quiz"
    Reviewing(attempt, _) -> attempt.quiz.title <> " Quiz"
    ConfirmingQuizExit(model) -> view_title(model)
    Finished(quiz, _) -> quiz.title <> " Quiz"
  }
}

fn view_confirmation(model: Model) -> List(Element(Msg)) {
  case model {
    ConfirmingQuizExit(_) -> [
      html.dialog(
        [
          attribute.id("quiz-exit-dialog"),
          attribute.autofocus(True),
          attribute.tabindex(-1),
          attribute.aria_labelledby("quiz-exit-title"),
          attribute.class(
            "m-auto w-[calc(100%-2rem)] max-w-md rounded-3xl border border-slate-700 bg-slate-900 p-6 text-slate-100 shadow-2xl shadow-black/50 backdrop:bg-slate-950/80 backdrop:backdrop-blur-sm sm:p-8",
          ),
          event.on("cancel", decode.success(UserCancelledQuizExit)),
          event.on_keydown(UserPressedQuizExitKey),
        ],
        [
          html.h2(
            [
              attribute.id("quiz-exit-title"),
              attribute.class("text-2xl font-semibold text-white"),
            ],
            [html.text("Leave this quiz?")],
          ),
          html.p([attribute.class("mt-3 leading-relaxed text-slate-400")], [
            html.text("Your progress in this attempt will be lost."),
          ]),
          html.div([attribute.class("mt-7 flex flex-wrap justify-end gap-3")], [
            html.button(
              [
                attribute.class(
                  "rounded-xl border border-slate-700 bg-slate-800 px-5 py-3 font-semibold text-slate-200 transition hover:border-fuchsia-400 hover:text-white focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
                ),
                event.on_click(UserCancelledQuizExit),
              ],
              [html.text("Keep going")],
            ),
            html.button(
              [
                attribute.class(
                  "rounded-xl bg-rose-500 px-5 py-3 font-semibold text-white transition hover:bg-rose-400 focus:ring-2 focus:ring-rose-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
                ),
                event.on_click(UserConfirmedQuizExit),
              ],
              [html.text("Leave quiz")],
            ),
          ]),
        ],
      ),
    ]

    _ -> []
  }
}

fn view_quiz_chooser(quizzes: List(Quiz)) -> Element(Msg) {
  html.section(card_attributes(), [
    html.h2([attribute.class("text-3xl font-semibold text-white")], [
      html.text("Choose a quiz"),
    ]),
    html.p([attribute.class("mt-3 leading-relaxed text-slate-400")], [
      html.text(
        "Pick a subject. Questions and answers are shuffled every time.",
      ),
    ]),
    html.div(
      [attribute.class("mt-8 grid gap-4 sm:grid-cols-2")],
      list.map(quizzes, view_quiz_card),
    ),
  ])
}

fn view_quiz_card(quiz: Quiz) -> Element(Msg) {
  html.article(
    [
      attribute.class(
        "flex flex-col rounded-2xl border border-slate-700 bg-slate-800/60 p-5",
      ),
    ],
    [
      html.p([attribute.class("text-sm font-medium text-fuchsia-300")], [
        html.text(int.to_string(list.length(quiz.questions)) <> " questions"),
      ]),
      html.h3([attribute.class("mt-2 text-xl font-semibold text-white")], [
        html.text(quiz.title),
      ]),
      html.p([attribute.class("mt-3 grow leading-relaxed text-slate-400")], [
        html.text(quiz.description),
      ]),
      html.button(
        [
          attribute.class(
            "mt-6 rounded-xl bg-fuchsia-500 px-5 py-3 font-semibold text-white transition hover:bg-fuchsia-400 focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
          ),
          event.on_click(UserStartedQuiz(quiz)),
        ],
        [html.text("Start quiz")],
      ),
    ],
  )
}

fn card_attributes() {
  [
    attribute.class(
      "rounded-3xl border border-slate-800 bg-slate-900/80 p-6 shadow-2xl shadow-black/30 backdrop-blur sm:p-9",
    ),
  ]
}

fn current_question_number(attempt: QuizAttempt) -> Int {
  list.length(attempt.quiz.questions) - list.length(attempt.remaining_questions)
}

fn view_answering(attempt: QuizAttempt) -> Element(Msg) {
  let question_number = current_question_number(attempt)
  let total_question_count = list.length(attempt.quiz.questions)

  html.section(card_attributes(), [
    view_progress(question_number, total_question_count),
    html.h2(
      [
        attribute.class(
          "mt-5 text-2xl leading-tight font-semibold text-white sm:text-3xl",
        ),
      ],
      [html.text(attempt.current_question.prompt)],
    ),
    html.div(
      [attribute.class("mt-8 grid gap-3")],
      list.map(attempt.current_question.answers, fn(answer) {
        html.button(
          [
            attribute.class(
              "rounded-2xl border border-slate-700 bg-slate-800/70 px-5 py-4 text-left leading-snug text-slate-200 transition hover:border-fuchsia-400 hover:bg-slate-800 hover:text-white focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
            ),
            event.on_click(UserSelectedAnswer(answer)),
          ],
          [html.text(answer.text)],
        )
      }),
    ),
  ])
}

fn view_reviewing(
  attempt: QuizAttempt,
  selected_answer: Answer,
) -> Element(Msg) {
  let question_number = current_question_number(attempt)
  let total_question_count = list.length(attempt.quiz.questions)
  let feedback = case selected_answer.correctness {
    Correct -> "Correct!"
    Incorrect -> "Not quite."
  }
  let next_label = case attempt.remaining_questions {
    [] -> "See results"
    _ -> "Next question"
  }

  let feedback_class = case selected_answer.correctness {
    Correct ->
      "mt-7 rounded-2xl border border-emerald-400/30 bg-emerald-400/10 p-5"
    Incorrect -> "mt-7 rounded-2xl border border-rose-400/30 bg-rose-400/10 p-5"
  }
  let feedback_heading_class = case selected_answer.correctness {
    Correct -> "text-lg font-semibold text-emerald-300"
    Incorrect -> "text-lg font-semibold text-rose-300"
  }

  html.section(card_attributes(), [
    view_progress(question_number, total_question_count),
    html.h2(
      [
        attribute.class(
          "mt-5 text-2xl leading-tight font-semibold text-white sm:text-3xl",
        ),
      ],
      [html.text(attempt.current_question.prompt)],
    ),
    html.div(
      [attribute.class("mt-8 grid gap-3")],
      list.map(attempt.current_question.answers, view_reviewed_answer(
        _,
        selected_answer,
      )),
    ),
    html.div([attribute.class(feedback_class)], [
      html.h3([attribute.class(feedback_heading_class)], [html.text(feedback)]),
      html.p([attribute.class("mt-2 leading-relaxed text-slate-300")], [
        html.text(attempt.current_question.explanation),
      ]),
    ]),
    html.div([attribute.class("mt-7 flex justify-end")], [
      html.button(
        [
          attribute.class(
            "rounded-xl bg-fuchsia-500 px-5 py-3 font-semibold text-white transition hover:bg-fuchsia-400 focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
          ),
          event.on_click(UserClickedNextQuestion),
        ],
        [html.text(next_label)],
      ),
    ]),
  ])
}

fn view_reviewed_answer(
  answer: Answer,
  selected_answer: Answer,
) -> Element(Msg) {
  let #(label, class) = case answer.correctness, answer == selected_answer {
    Correct, _ -> #(
      "✓ " <> answer.text,
      "rounded-2xl border border-emerald-400/40 bg-emerald-400/10 px-5 py-4 leading-snug text-emerald-200",
    )
    Incorrect, True -> #(
      "✗ " <> answer.text,
      "rounded-2xl border border-rose-400/40 bg-rose-400/10 px-5 py-4 leading-snug text-rose-200",
    )
    Incorrect, False -> #(
      answer.text,
      "rounded-2xl border border-slate-800 bg-slate-800/30 px-5 py-4 leading-snug text-slate-500",
    )
  }

  html.p([attribute.class(class)], [html.text(label)])
}

fn view_progress(
  current_question_number: Int,
  total_question_count: Int,
) -> Element(Msg) {
  html.div([attribute.class("flex items-center justify-between gap-4")], [
    html.button(
      [
        attribute.class(
          "text-sm font-medium text-slate-400 transition hover:text-fuchsia-300 focus:outline-none focus-visible:text-fuchsia-300",
        ),
        event.on_click(UserClickedChooseQuiz),
      ],
      [html.text("← All quizzes")],
    ),
    html.p(
      [
        attribute.class(
          "text-sm font-medium tracking-wide text-slate-400 tabular-nums",
        ),
      ],
      [
        html.text(
          "Question "
          <> int.to_string(current_question_number)
          <> " of "
          <> int.to_string(total_question_count),
        ),
      ],
    ),
  ])
}

fn view_finished(quiz: Quiz, score: Int) -> Element(Msg) {
  html.section(card_attributes(), [
    html.div(
      [
        attribute.class(
          "mx-auto mb-6 flex size-16 items-center justify-center rounded-full bg-fuchsia-400/10 text-3xl text-fuchsia-300",
        ),
      ],
      [html.text("✓")],
    ),
    html.h2([attribute.class("text-center text-3xl font-semibold text-white")], [
      html.text("Quiz complete"),
    ]),
    html.p([attribute.class("mt-4 text-center text-5xl font-bold text-white")], [
      html.text(
        int.to_string(score)
        <> " / "
        <> int.to_string(list.length(quiz.questions)),
      ),
    ]),
    html.p([attribute.class("mt-3 text-center text-slate-400")], [
      html.text("You’ve reached the end of the " <> quiz.title <> " quiz."),
    ]),
    html.div([attribute.class("mt-8 flex flex-wrap justify-center gap-3")], [
      html.button(
        [
          attribute.class(
            "rounded-xl border border-slate-700 bg-slate-800 px-5 py-3 font-semibold text-slate-200 transition hover:border-fuchsia-400 hover:text-white focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
          ),
          event.on_click(UserClickedChooseQuiz),
        ],
        [html.text("Choose another quiz")],
      ),
      html.button(
        [
          attribute.class(
            "rounded-xl bg-fuchsia-500 px-5 py-3 font-semibold text-white transition hover:bg-fuchsia-400 focus:ring-2 focus:ring-fuchsia-400 focus:ring-offset-2 focus:ring-offset-slate-900 focus:outline-none",
          ),
          event.on_click(UserClickedRestartQuiz),
        ],
        [html.text("Restart quiz")],
      ),
    ]),
  ])
}

// ENTRY POINT -----------------------------------------------------------------

pub fn main() -> Nil {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
