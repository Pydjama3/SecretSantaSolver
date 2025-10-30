:- consult([constraints]).


% --- SOLVER ---

% Method to get a list of all people participating.
all_people(People) :-
    findall(P, family(P, _), People).

% Main solver: secret_santa(Pairings) returns the first solution 
% that follows the constraints
secret_santa(Pairings) :-
    all_people(Givers),
    all_people(Receivers),

    assign_gifts(Givers, Receivers, Pairings).

% Main solver: secret_santa(Pairings) returns a (random) solution 
% that follows the constraints
secret_santa_randomized(Pairings) :-
    all_people(People),

    % "Randomize" solutions
    random_permutation(People, Givers),
    random_permutation(People, Receivers),

    assign_gifts(Givers, Receivers, Pairings).

% Main solver with info on seed: returns a (random) solution 
% that follows the constraints and the seed that was used
secret_santa_with_seed(Pairings, SeedState) :-
    random_property(state(SeedState)),

    all_people(People),

    % "Randomize" solutions
    random_permutation(People, Givers),
    random_permutation(People, Receivers),

    assign_gifts(Givers, Receivers, Pairings).


% assign_gifts(Givers, Receivers, Pairings)

% Base case: break condition
assign_gifts([], [], []).

% Recursive step
assign_gifts([Giver | NextGivers], Receivers, [pair(Giver, Receiver) | NextPairings]) :-
    
    % Pick a receiver from the list of existing remaining Receivers
    select(Receiver, Receivers, RemainingReceivers),
    
    % 2. Check if this pair follows the constraints (is a valid pair)
    valid_pair(Giver, Receiver),
    
    % 3. If valid, recursively step through and do the same on the NextGivers
    assign_gifts(NextGivers, RemainingReceivers, NextPairings).
