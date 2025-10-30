% --- CONSTRAINTS ---

% Note: Do not auto-consult the knowledge base here. The runner will
% load the desired knowledge base (default: `knowledge_base.pl`) and
% then load `constraints.pl` and `solver.pl`.

valid_pair(Giver, Receiver) :-
    family(Giver, F_Giver),
    family(Receiver, F_Receiver),
    has_given(Giver, LastYearReceiver),
    F_Giver \= F_Receiver, % Primary constraint.
    Receiver \= LastYearReceiver. % Secondary constraint.
