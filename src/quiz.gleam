import gleam/int
import gleam/list
import lustre
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import quiz/domain.{type Answer, type Question, type Quiz}
import quizzes/catalog

pub type Model {
  ChoosingQuiz
  Answering(
    quiz: Quiz,
    current: Question,
    remaining: List(Question),
    score: Int,
    answered_count: Int,
  )
  Reviewing(
    quiz: Quiz,
    current: Question,
    remaining: List(Question),
    selected: Answer,
    score: Int,
    answered_count: Int,
  )
  Finished(quiz: Quiz, score: Int, total: Int)
}

pub type Msg {
  UserStartedQuiz(Quiz)
  UserSelectedAnswer(Answer)
  UserClickedNextQuestion
  UserClickedRestartQuiz
  UserClickedChooseQuiz
}

pub fn initial_model() -> Model {
  ChoosingQuiz
}

fn start_quiz(quiz: Quiz) -> Model {
  case domain.shuffled_questions(quiz) {
    [first, ..rest] ->
      Answering(
        quiz: quiz,
        current: first,
        remaining: rest,
        score: 0,
        answered_count: 0,
      )

    [] -> Finished(quiz: quiz, score: 0, total: 0)
  }
}

pub fn update(model: Model, msg: Msg) -> Model {
  case model, msg {
    ChoosingQuiz, UserStartedQuiz(quiz) -> start_quiz(quiz)

    Answering(quiz, current, remaining, score, answered_count),
      UserSelectedAnswer(answer)
    -> {
      let new_score = case answer.is_correct {
        True -> score + 1
        False -> score
      }

      Reviewing(
        quiz: quiz,
        current: current,
        remaining: remaining,
        selected: answer,
        score: new_score,
        answered_count: answered_count + 1,
      )
    }

    Reviewing(quiz, _, [next, ..rest], _, score, answered_count),
      UserClickedNextQuestion
    ->
      Answering(
        quiz: quiz,
        current: next,
        remaining: rest,
        score: score,
        answered_count: answered_count,
      )

    Reviewing(quiz, _, [], _, score, answered_count), UserClickedNextQuestion ->
      Finished(quiz: quiz, score: score, total: answered_count)

    Finished(quiz, _, _), UserClickedRestartQuiz -> start_quiz(quiz)

    Finished(_, _, _), UserClickedChooseQuiz -> ChoosingQuiz

    _, _ -> model
  }
}

fn init(_arguments: Nil) -> Model {
  initial_model()
}

pub fn view(model: Model) -> Element(Msg) {
  html.main(
    [
      attribute.class(
        "flex min-h-screen items-center justify-center bg-slate-950 px-4 py-12 text-slate-100",
      ),
    ],
    [
      html.div([attribute.class("w-full max-w-3xl")], [
        html.h1(
          [
            attribute.class(
              "mb-6 text-center text-sm font-bold tracking-[0.3em] text-fuchsia-400 uppercase",
            ),
          ],
          [html.text(view_title(model))],
        ),
        case model {
          ChoosingQuiz -> view_quiz_chooser(catalog.all())

          Answering(_, current, remaining, _, answered_count) ->
            view_answering(current, remaining, answered_count)

          Reviewing(_, current, remaining, selected, _, answered_count) ->
            view_reviewing(current, remaining, selected, answered_count)

          Finished(quiz, score, total) -> view_finished(quiz, score, total)
        },
      ]),
    ],
  )
}

fn view_title(model: Model) -> String {
  case model {
    ChoosingQuiz -> "Quiz Library"
    Answering(quiz, _, _, _, _) -> quiz.title <> " Quiz"
    Reviewing(quiz, _, _, _, _, _) -> quiz.title <> " Quiz"
    Finished(quiz, _, _) -> quiz.title <> " Quiz"
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

fn view_answering(
  question: Question,
  remaining: List(Question),
  answered_count: Int,
) -> Element(Msg) {
  let question_number = answered_count + 1
  let total = question_number + list.length(remaining)

  html.section(card_attributes(), [
    view_progress(question_number, total),
    html.h2(
      [
        attribute.class(
          "mt-5 text-2xl leading-tight font-semibold text-white sm:text-3xl",
        ),
      ],
      [html.text(question.prompt)],
    ),
    html.div(
      [attribute.class("mt-8 grid gap-3")],
      list.map(question.answers, fn(answer) {
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
  question: Question,
  remaining: List(Question),
  selected: Answer,
  answered_count: Int,
) -> Element(Msg) {
  let total = answered_count + list.length(remaining)
  let feedback = case selected.is_correct {
    True -> "Correct!"
    False -> "Not quite."
  }
  let next_label = case remaining {
    [] -> "See results"
    _ -> "Next question"
  }

  let feedback_class = case selected.is_correct {
    True ->
      "mt-7 rounded-2xl border border-emerald-400/30 bg-emerald-400/10 p-5"
    False -> "mt-7 rounded-2xl border border-rose-400/30 bg-rose-400/10 p-5"
  }
  let feedback_heading_class = case selected.is_correct {
    True -> "text-lg font-semibold text-emerald-300"
    False -> "text-lg font-semibold text-rose-300"
  }

  html.section(card_attributes(), [
    view_progress(answered_count, total),
    html.h2(
      [
        attribute.class(
          "mt-5 text-2xl leading-tight font-semibold text-white sm:text-3xl",
        ),
      ],
      [html.text(question.prompt)],
    ),
    html.div(
      [attribute.class("mt-8 grid gap-3")],
      list.map(question.answers, view_reviewed_answer(_, selected)),
    ),
    html.div([attribute.class(feedback_class)], [
      html.h3([attribute.class(feedback_heading_class)], [html.text(feedback)]),
      html.p([attribute.class("mt-2 leading-relaxed text-slate-300")], [
        html.text(question.explanation),
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

fn view_reviewed_answer(answer: Answer, selected: Answer) -> Element(Msg) {
  let #(label, class) = case answer.is_correct, answer == selected {
    True, _ -> #(
      "✓ " <> answer.text,
      "rounded-2xl border border-emerald-400/40 bg-emerald-400/10 px-5 py-4 leading-snug text-emerald-200",
    )
    False, True -> #(
      "✗ " <> answer.text,
      "rounded-2xl border border-rose-400/40 bg-rose-400/10 px-5 py-4 leading-snug text-rose-200",
    )
    False, False -> #(
      answer.text,
      "rounded-2xl border border-slate-800 bg-slate-800/30 px-5 py-4 leading-snug text-slate-500",
    )
  }

  html.p([attribute.class(class)], [html.text(label)])
}

fn view_progress(current: Int, total: Int) -> Element(Msg) {
  html.p(
    [
      attribute.class(
        "text-sm font-medium tracking-wide text-slate-400 tabular-nums",
      ),
    ],
    [
      html.text(
        "Question " <> int.to_string(current) <> " of " <> int.to_string(total),
      ),
    ],
  )
}

fn view_finished(quiz: Quiz, score: Int, total: Int) -> Element(Msg) {
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
      html.text(int.to_string(score) <> " / " <> int.to_string(total)),
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

pub fn main() -> Nil {
  let app = lustre.simple(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)

  Nil
}
