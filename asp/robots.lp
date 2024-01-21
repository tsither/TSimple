% Making it a simple solution
% Please insert the names and email addresses of the group members:
% 
%

%
% Input:
%   #const n: the time steps range from 0 to n
%   edge(N1,N2): there is an (undirected) edge between nodes N1 and N2
%   robot(R,C,N): robot R is of class C and starts at node N
%   job(J,C,D): job J is of class C and its deadline is D 
%   operation(J,O,N): J's operation O takes place at node N (O >= 1)
%
% Output:
%   at(R,N,T): robot R is at node N at time step T
%   assign(R,J,P): assign to R the job J at position P (in the sequence of jobs assigned to R) (P >= 1)
%


time(0..n).

% Your encoding please...

% ----------------------- Define NODE structure ----------------------- %


max(N) :- N = #max{Y : edge(_,Y)}.
max_X(I) :-  I = #max{X : edge((_,_), (X,Y))}.
max_Y(I) :-  I = #max{Y : edge((_,_), (X,Y))}.

node(1..N) :- max_X(X), max_Y(Y), N = X*Y.
node(1..N) :- max(N).


% --------------- Represent the movements of the robots --------------- %


{move(R, N1, N2)} :- robot(R,C,N), edge(N1,N2).                                         %generate movement atoms for the robots

:- robot(R,C,N1), not #count{R,N1,N2: move(R,N1,N2)} >= 1.                              %robots must move from start node 



at(R,N,T) :- robot(R,_,N), T=0.                                                         %create at atom for the start nodes of the robots
{at(R,N2,T)} :- robot(R,_,N), move(R,N1,N2), T=1..n.                                    %generate at nodes for all possible time stamps


:- at(R,N1,T1), at(R,N2,T2), N2-N1=1, N2>N1, T2>T1, T2-T1!=1.                           %for two at atoms between adjacent nodes, the timestamps must be adjacent
:- at(R,N1,T1), at(R,N2,T2), T2-T1=1, N2-N1!=1, N2>N1, T2>T1.                           %for two at atoms between adjacent timestamps, the nodes must be adjacent


:- X = #count{R,N,T: at(R,N,T)}, Y = #count{R,N1,N2: move(R,N1,N2)}, X!=Y+1.            % there must be 1 more at atom than there are move atoms 



% #show robot/3.
% #show move/3.
#show at/3.






% ---------------------- Assign a robot to a job ---------------------- %

{assign(R,J,P)} :- robot(R,C,_), job(J,C1,D), C=C1, P=1.

:- assign(R,J,P), job(J,C,D), operation(J,O,N2), not #count{R,N1,N2: move(R,N1,N2)} >= 1.

:- not assign(_,_,_).

#show assign/3.













































% % --------------- Represent the movements of the robots --------------- %

% %robots can move from their start nodes
% {move(R,N1,N2)} :- robot(R,_,N1), edge(N1,N2).
% %they can move from node to node
% {move(R,N2,N3)} :- move(R,N1,N2), edge(N2,N3).
% %robots can go 'backwards'
% {move(R,N3,N2)} :- move(R,N1,N2), edge(N2,N3).


% #show move/3.

% :- not at(_,_,_).
% at(R,N,T) :- robot(R,_,N), T=0.
% {at(R,N2,T)} :- move(R,N1,N2), T=1..n.


% %there must be 1 more assign atoms than move atom, because the robot needs to start somewhere without a movement
% :- robot(R,_,_), X = #count{R,N,T : at(R,N,T)}, Y = #count{R,N1,N2 : move(R,N1,N2)}, X!=Y+1.

% %the number of moves cannot be greater than the time limit
% :- robot(R,_,_), #count{R,N1,N2 : move(R,N1,N2)} > n.


% %a robot cant be in two places at once
% % :- robot(R,_,_), at(R,N,T), at(R,N,T1), R=R, N!=N, T=T1.

% :- robot(R, _, _), at(R, N1, T1), at(R, N2, T2), N1!=N2, T1=T2.


% #show move_count/1.


% ---------------------- Assign a robot to a job ---------------------- %






% ------- Check if the movements/assignments solve the problem -------  %








%
%#show at/3.
%
% #show assign/3.
