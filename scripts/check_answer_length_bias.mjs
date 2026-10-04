import { readFileSync } from "node:fs";

const maximumLongestRate = 0.35;

function decodeString(value) {
  return JSON.parse(`"${value}"`);
}

function gleamQuestions() {
  const source = readFileSync("src/quizzes/gleam.gleam", "utf8");
  const answerPattern =
    /Answer\(\s*text: "((?:\\.|[^"\\])*)",\s*is_correct: (True|False)/gs;
  const answers = [...source.matchAll(answerPattern)].map((match) => ({
    text: decodeString(match[1]),
    correct: match[2] === "True",
  }));

  return Array.from({ length: answers.length / 4 }, (_, index) =>
    answers.slice(index * 4, index * 4 + 4),
  );
}

function functionalProgrammingQuestions() {
  const source = readFileSync(
    "src/quizzes/functional_programming.gleam",
    "utf8",
  );

  return source
    .split("domain.question(")
    .slice(1)
    .map((block) => {
      const correct = block.match(/correct: "((?:\\.|[^"\\])*)"/s)?.[1];
      const incorrectSource = block
        .split("incorrect: [", 2)[1]
        .split("],", 1)[0];
      const incorrect = [...incorrectSource.matchAll(/"((?:\\.|[^"\\])*)"/gs)];

      return [
        { text: decodeString(correct), correct: true },
        ...incorrect.map((match) => ({
          text: decodeString(match[1]),
          correct: false,
        })),
      ];
    });
}

function inspect(name, questions) {
  const invalid = questions.filter(
    (answers) =>
      answers.length !== 4 ||
      answers.filter((answer) => answer.correct).length !== 1,
  );
  const longest = questions.filter((answers) => {
    const correct = answers.find((answer) => answer.correct).text.length;
    const distractors = answers
      .filter((answer) => !answer.correct)
      .map((answer) => answer.text.length);

    return correct > Math.max(...distractors);
  }).length;
  const rate = longest / questions.length;

  console.log(
    `${name}: ${longest}/${questions.length} correct answers are strictly longest (${Math.round(rate * 100)}%)`,
  );

  if (invalid.length > 0) {
    console.error(`${name}: ${invalid.length} questions do not have four choices and one correct answer`);
  }

  return invalid.length === 0 && rate <= maximumLongestRate;
}

const checks = [
  inspect("Gleam", gleamQuestions()),
  inspect("Functional Programming", functionalProgrammingQuestions()),
];

if (checks.includes(false)) {
  console.error(
    `Answer-length quality check failed; each quiz must stay at or below ${maximumLongestRate * 100}%.`,
  );
  process.exitCode = 1;
}
