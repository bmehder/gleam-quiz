# Gleam Quiz

A deliberately small client-side quiz application for learning Gleam with
[Lustre](https://lustre.build/).

## Development

With [Bun](https://bun.sh/) installed:

```sh
gleam run -m lustre/dev start
```

Then open <http://localhost:1234>.

Check the question banks for answer-length bias with:

```sh
node scripts/check_answer_length_bias.mjs
```

## Time travel

Run the development-only entry point to add the time-travel inspector:

```sh
gleam run -m lustre/dev start quiz_dev
```

Answer some questions, then open **Time Travel** in the lower-right corner to
inspect and revisit earlier model states.
