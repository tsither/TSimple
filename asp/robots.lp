% --------------- COMMANDS ---------------% 
% Visualizing solutions from JSON:
% cat asp/solutions-for-clingraph/corridor-01.json | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{model_number}
%
% Visualizing personal solution:
%  clingo asp/robots.lp asp/viz_show.lp asp/instances/corridor-01.lp -q1,1,2 --outf=2 --opt-mode=optN 0 | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{model_number}
%
% clingo asp/robots.lp asp/instances/corridor-01.lp 0
% 
% python asp/test.py -e asp/robots.lp -i asp/instances -s asp/solutions -t 180 -opt


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


% max(N) :- N = #max{Y : edge(_,Y)}.
% max_X(I) :-  I = #max{X : edge((_,_), (X,Y))}.
% max_Y(I) :-  I = #max{Y : edge((_,_), (X,Y))}.

% node(1..N) :- max_X(X), max_Y(Y), N = X*Y.
% node(1..N) :- max(N).


% --------------- Represent the movements of the robots --------------- %

% #show robot/3.
% #show move/3.
#show at/3.
% #show assign/3.
% #show edge/2.
% :- not at(r2,6,3).
% :- not at(r2,3,4).


% {move(R, N1, N2)} :- robot(R,C,N), edge(N1,N2).                                         %generate movement atoms for the robots
% {move(R, N2, N1)} :- robot(R,C,N), edge(N1,N2).                                        

edge(N2,N1) :- edge(N1,N2).



% GENERATE 'at' atoms 

%must be 'at' atom on the node the robots starts on
at(R,N,T) :- robot(R,_,N), T=0.                                                         %create at atom for the start nodes of the robots

% {at(R,N2,T)} :- robot(R,_,N), move(R,N1,N2), T=1..n.                                    %generate at nodes for all possible time stamps

%recursive at atom generation
% {at(R,N2,T2)} :- robot(R,_,N), edge(N1,N2), T2=T1+1, at(R,N1,T1), T2 <=n.                               %generate at nodes for all possible time stamps



{at(R,N2,T2)} :- robot(R,_,N), edge(N1,N2), T2=1..n.                                    %generate at nodes for all possible time stamps


% % ROBOT cant be in two places at the same time
:- robot(R,_,_), at(R,N1,T1), at(R,N2,T2), T1=T2, N1!=N2.



% % % make robots move in time correctly:
% %:- at(R,N1,T1), at(R,N2,T2), move(R,N1,N2), |T2-T1| != 1.

% this rule is fucked
% :- at(R,N1,T1), at(R,N2,T2), edge(N1,N2), |T2-T1| != 1.


% %problem: robots are jumping around graph ... 

% % :- at(R,N1,T1), at(R,N2,T2), |T2-T1| = 1, not move(R,N1,N2).                  %move(R,N1,N2).%N2>N1, not edge(N1,N2), not move(R,N1,N2).
% :- at(R,N1,T1), at(R,N2,T2), |T2-T1| = 1, not edge(N1,N2).                  %move(R,N1,N2).%N2>N1, not edge(N1,N2), not move(R,N1,N2).



% %two robots cant be in the same place at the same time
:- at(R1,N1,T1), at(R2,N2,T2), R1!=R2, N1=N2, T1=T2.


% % % ensure there are the correct number of at atoms (must be an 'at' atom for every robot for every timestep)
:-  robot(R,_,_), not at(R,_,1..n).





% % ---------------------- Assign a robot to a job ---------------------- %

% %generate assignment atoms
{assign(R,J,P)} :- robot(R,C,_), job(J,C1,D), C=C1, P=1.

% % robot needs to go to the node that the operation it's assigned to is on
:- assign(R,J,P), job(J,C,D), robot(R,_,_), operation(J,O,N), not at(R,N,_).


% %every job needs an assignment
:-  job(J,C,D), not assign(_,J,_).







% % ---------------------- Job Completion ---------------------- %


% % There needs to be be an 'at' atom at every node of a job's operation such that the T is less than or equal to the deadline of the job
:-  job(J,C,D), operation(J,O,N), robot(R,_,_), assign(R,J,P), at(R,N,T), not T<=D.



% % ---------------------- -------------- ---------------------- %








% :- at(R,N1,T1), at(R,N2,T2), N2-N1=1, N2>N1, T2>T1, T2-T1!=1.                           %for two at atoms between adjacent nodes, the timestamps must be adjacent
% :- at(R,N1,T1), at(R,N2,T2), T2-T1=1, N2-N1!=1, N2>N1, T2>T1.                           %for two at atoms between adjacent timestamps, the nodes must be adjacent


% :- X = #count{R,N,T: at(R,N,T)}, Y = #count{R,N1,N2: move(R,N1,N2)}, X!=Y+1.            % there must be 1 more at atom than there are move atoms 




























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
