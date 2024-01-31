% Your program
at_op(1, 1, 1, 1).
at_op(1, 2, 2, 2).
at_op(3, 3, 3, 3).
at_op(4, 4, 4, 4).
at_op(5, 5, 5, 5).

% Count constraint
:- #count{R, J, N, T: at_op(R, J, N, T)} != 5.

% Other rules or constraints (if any)
