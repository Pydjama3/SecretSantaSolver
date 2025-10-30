#!/usr/bin/env swipl

% Runner: requires a first argument with the knowledge-base file
% to load (for example: `./runner.pl other_knowledge_base.pl`). If no
% argument is provided the script will print usage and exit with error.

:- initialization(main).


show_pairs([]).
show_pairs([pair(From, To)|RemainingPairs]) :-
    format('> Gift from ~w to ~w.~n', [From, To]),
    show_pairs(RemainingPairs).


main :-
    % Prefer the Prolog-level argv; if empty (common with some shebang
    % invocations), fall back to os_argv and try to extract an argument
    % following this script's name. Finally fall back to the default.
    current_prolog_flag(argv, Argv),
    ( Argv = [KBArg|_] ->
        ( string(KBArg) -> atom_string(KBAtom0, KBArg) ; KBAtom0 = KBArg )
    ;
        current_prolog_flag(os_argv, OSArgv),
        % Try to find the script name in os_argv and take the next element as arg.
        ( ( member(ScriptElem, OSArgv), sub_atom(ScriptElem, _, _, 0, 'runner.pl'),
            append(_, [ScriptElem|Rest], OSArgv), Rest = [KBArgCandidate|_]
          ) ->
            ( string(KBArgCandidate) -> atom_string(KBAtom0, KBArgCandidate) ; KBAtom0 = KBArgCandidate )
        ;
            % No argument found: print usage and exit with error
            format(user_error, 'Error: no knowledge base argument provided.~nUsage: ./runner.pl <knowledge_base.pl>~n', []),
            halt(1)
        )
    ),

    % If the file doesn't exist as given, try adding a .pl suffix.
    ( exists_file(KBAtom0) ->
        KBFile = KBAtom0
    ; atom_concat(KBAtom0, '.pl', KBAtomPl),
      ( exists_file(KBAtomPl) -> KBFile = KBAtomPl
      ; format(user_error, 'Error: knowledge base file "~w" not found.~n', [KBAtom0]), halt(2)
      )
    ),

    % Consult the chosen knowledge base. Report and exit on errors.
    ( catch(consult(KBFile), E,
            ( format(user_error, 'Error: failed to consult ~w: ~w~n', [KBFile, E]), halt(2) ) ) ),

    % Report which KB we are using (helpful for clarity/debugging).
    format('Using knowledge base: ~w~n', [KBFile]),

    % Load constraints and solver (they expect the KB to be present).
    ( catch(consult(constraints), E2,
            ( format(user_error, 'Error: failed to consult constraints: ~w~n', [E2]), halt(2) ) ) ),
    ( catch(consult(solver), E3,
            ( format(user_error, 'Error: failed to consult solver: ~w~n', [E3]), halt(2) ) ) ),
    nl,

    % Seed for deterministic runs (kept for backward compatibility)
    set_random(seed(0)),

    % Compute and show pairs, or report failure if no solution found.
    ( secret_santa(Solutions) ->
        format("Attributions:~n", []),
        show_pairs(Solutions)
    ;
        format(user_error, 'Error: no solution found using knowledge base "~w"~n', [KBFile]),
        halt(3)
    ),

    halt.
    