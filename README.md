# SecretSantaSolver

A small SWI-Prolog project to compute Secret Santa pairings based on a knowledge base and a set of constraints.

## Overview

The solver reads a knowledge base describing participants (their families) and last year's distribution, checks pairings against constraints (for example: don't give to the same family or the same person as last year), and prints gift assignments.

This repository provides:

- A template knowledge base: `knowledge_base_template.pl` (use as a starter).
- Constraint definitions: `constraints.pl` (rules that decide whether a pairing is valid).
- A solver: `solver.pl` (the pairing algorithm and utilities).
- A small runner script: `runner.pl` (convenience script to invoke the solver with a chosen KB).

## Todo:
- [ ] Fully use randomisation: outputing seed and being able to pass a seed as an argument.
- [ ] ...

## Requirements

- SWI-Prolog (swipl) available on your PATH. The runner uses the shebang `#!/usr/bin/env swipl`.

Tested with SWI-Prolog on Linux. Other platforms where `swipl` is in PATH should work similarly.

## Files and responsibilities
- `knowledge_base_template.pl` — A template to create your own knowledge base.
- `constraints.pl` — Predicate `valid_pair(Giver, Receiver)` encodes the constraints. It intentionally does not consult the KB; the `runner.pl` ensures the KB is loaded first.
- `solver.pl` — Provides the solving predicates:
  - `all_people/1` — returns all participants found in `family/2`.
  - `secret_santa/1` — deterministic solver (first found solution).
  - `secret_santa_randomized/1` and `secret_santa_with_seed/2` — randomized variants.
  - `assign_gifts/3` — internal assignment logic.

- `runner.pl` — Executable script to run the solver from the command line. It requires a knowledge base filename argument (see usage). The runner consults the chosen KB, `constraints.pl`, and `solver.pl`, then runs the solver and prints pairings.

## Usage

Make `runner.pl` executable (once):

```bash
chmod +x runner.pl
```

Run the solver using a knowledge base file (required argument):

```bash
# Use your own KB (with or without .pl extension) by following the template
./runner.pl my_custom_kb.pl
# or
./runner.pl my_custom_kb
```

Notes:
- The runner supports passing a filename with or without the `.pl` extension.
- When run via the shebang, argument parsing falls back to OS argv so `./runner.pl my_kb.pl` works as expected.

## Examples

- Good KB (produces pairings):

```bash
./runner.pl good_kb.pl
# Output:
# Using knowledge base: good_kb.pl
# 
# Attributions:
# > Gift from A to B
# > Gift from E to D
# ...
```

- Incomplete/unsolvable KB:

```bash
./runner.pl unsolvable_kb.pl
# Output:
# Using knowledge base: unsolvable_kb.pl
# Error: no solution found using knowledge base unsolvable_kb.pl
```

- No argument:

```bash
./runner.pl
# Output:
# Error: no knowledge base argument provided.
# Usage: ./runner.pl <knowledge_base.pl>
```

## Exit codes

The runner uses these exit codes to signal errors:
- `0` — success (pairings printed to stdout).
- `1` — usage error (no knowledge-base argument provided).
- `2` — consult error (knowledge base / constraints / solver failed to load).
- `3` — solver failure (no valid solution for the provided KB).

## How it works (brief)

1. `runner.pl` consults the requested knowledge base file.
2. It consults `constraints.pl` and `solver.pl`.
3. It calls `secret_santa/1` to compute a mapping of `pair(Giver, Receiver)` for all participants.
4. If a solution is found it prints each pairing, otherwise it reports an error.

The solver uses `findall/3` to gather participants, then `assign_gifts/3` with `select/3` to build a matching while checking `valid_pair/2` for each selected pair.

## Extending / customizing

- To change constraints, edit `constraints.pl`.
- To change solver behavior (for example to prefer certain receivers), modify `solver.pl` (or add new solver predicates such as heuristic-based assignment).
- To use your own dataset, copy `knowledge_base_template.pl` to `my_kb.pl` and update `family/2` and `has_given/2` facts.

Important: `constraints.pl` intentionally does not consult any KB. The runner is responsible for consulting the chosen KB before loading constraints and solver.

## Recommendations and follow-ups

- Avoid double-consult: `solver.pl` currently contains `:- consult([constraints]).` for standalone usage — if you always run via the runner which already consults `constraints`, that causes a double consult. You can remove or guard that top-level consult in `solver.pl` if desired.
- Add `--help` to the runner to print usage and optional flags (seed/random) — I can add that if you'd like.
- Add validation to the runner to check for a minimum viable KB (e.g., at least two `family/2` participants) and give clearer diagnostics before attempting the solver.

## Troubleshooting

- "Error: no solution found" — means your KB doesn't permit a complete assignment that satisfies the constraints. Check `family/2` membership across groups and `has_given/2` entries. Using the template may produce this error if many placeholders are present.
- "Error: failed to consult ..." — indicates Prolog failed to load a file (syntax error or file not found). Check for typos and ensure the file exists.

## License & contribution

This repository is minimal and intended as a small utility. Feel free to adapt and submit improvements (pull requests) for features like better CLI handling, additional constraints, or more robust validation.
