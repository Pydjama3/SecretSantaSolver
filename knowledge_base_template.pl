% --- KNOWLEDGE BASE TEMPLATE ---

% FAMILY TREE
family(member_1_of_a, a).
family(member_2_of_a, a).
family(member_3_of_a, a).

family(member_1_of_b, b).
family(member_2_of_b, b).

% ...

family(member_n_of_z, z).


% LAST YEAR DISTRIBUTION
has_given(member_1_of_a, member_1_of_b).
has_given(member_2_of_a, member_2_of_a). % has_give(x, x) <=> no constraint
% ...
