pub type Answer {
  Answer(text: String, is_correct: Bool)
}

pub type Question {
  Question(prompt: String, answers: List(Answer), explanation: String)
}

pub fn all() -> List(Question) {
  [
    Question(
      prompt: "What does Gleam's Result type represent?",
      answers: [
        Answer(
          text: "A value that can be successful or contain an error",
          is_correct: True,
        ),
        Answer(
          text: "A value that may or may not be present",
          is_correct: False,
        ),
        Answer(text: "A collection with exactly two items", is_correct: False),
        Answer(text: "A delayed side effect", is_correct: False),
      ],
      explanation: "Result(value, error) represents either Ok(value) or Error(error).",
    ),
    Question(
      prompt: "What must a case expression do in Gleam?",
      answers: [
        Answer(text: "Match every possible value", is_correct: True),
        Answer(text: "Return a Boolean", is_correct: False),
        Answer(text: "Contain an else branch", is_correct: False),
        Answer(text: "Perform a side effect", is_correct: False),
      ],
      explanation: "Gleam checks that case expressions exhaustively cover every possible value.",
    ),
    Question(
      prompt: "What does the pipeline operator pass to the next function?",
      answers: [
        Answer(text: "The value on its left", is_correct: True),
        Answer(text: "The function's return type", is_correct: False),
        Answer(text: "The current module", is_correct: False),
        Answer(text: "A list of all previous values", is_correct: False),
      ],
      explanation: "The |> operator passes the value on its left as an argument to the function on its right.",
    ),
  ]
}
