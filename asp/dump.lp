% ----------------------- Rough version ----------------------- % 

%to show javier?
(asp) [tgs:~/Project3/TSimple] mymac% clingo asp/robots.lp asp/instances/stop-01.lp 8 --opt-mode=optN


% --------------- COMMANDS ---------------% 
% Visualizing solutions from JSON:
% cat asp/solutions-for-clingraph/corridor-01.json | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{model_number}
%

cat asp/solutions-for-clingraph/stop-01.json | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{stop-01}
cat asp/solutions-for-clingraph/stop-02.json | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{stop-01}

% Visualizing personal solution:

clingo asp/robots.lp asp/viz_show.lp asp/instances/stop-01.lp -q1,1,2 --outf=2 --opt-mode=optN 0 | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{model_number}

%  clingo asp/robots.lp asp/viz_show.lp asp/instances/corridor-01.lp -q1,1,2 --outf=2 --opt-mode=optN 0 | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{model_number}
%
clingo asp/robots.lp asp/viz_show.lp asp/instances/stop-01.lp -q1,1,2 --outf=2 --opt-mode=optN 0 | clingraph --viz-encoding=asp/viz.lp  --out=animate --sort=asc-int  --engine=neato --prefix=viz_ --dir=img --name-format=model-{TS_STOP-01}

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


% time(0..n).

% % Your encoding please...

% time(0..n).

% % Generating backward and forward edges for bidirectional movement
% bidirectional_edge(N1,N2) :- edge(N2,N1).
% bidirectional_edge(N2,N1) :- edge(N2,N1).


% % Generating all possible movements /  positions that the robot can be at
% {robot_moves(R,N1,N2)} :- robot(R,_,N), bidirectional_edge(N1,N2).

% % Saying that the robot must start at the first node
% at(R,N,T) :- robot(R,_,N), T=0.

% % Generating all possible moves from the start node
% {at(R,N2,T)} :- robot(R,_,N), robot_moves(R,N1,N2), T=1..n. 


% % Restricting the robot from being in two places at the same time
% :- at(R,N,T), at(R1,N1,T1), R1=R, N!=N1, T=T1.

% % It can not be that the robot moves between two nodes and the nodes are not adjacent
% :- at(R,N,T) , at(R, N1, T1), |T1-T| = 1, not |N1-N|=1 .


% % --------------- Job stuff ---------------% 

% % Job assigning 
% {assign(R,J,P)} :- robot(R,C,N), job(J,C1,D), P=N, C1 = C . 

% % Eliminate all those sets where a robots time exceeds the job's duration
% :- robot(_,_,_), job(_,_,D), at(_,_,T), T>D .

% 


% :- at(R,N,T), at(R1,N1,T1) , robot(R,_,N), T=T1, N!=N1, R=R1. 
% #show robot_moves/3.
% #show robot_moves/3.
#show at/3.
% #show assign/3.


% ----------------------- Rough version ----------------------- % 




max_op(X) :- X = #max{O:operation(j1,O,N)}.

% #show max_op/1.
% #show j2_start_node/3.

j2_start_node(R,N,T) :- job(j1,_,_), max_op(O), operation(j1,O,N), at_J1(R,N,T).





% ----------------------- Define NODE structure ----------------------- %


% max(N) :- N = #max{Y : edge(_,Y)}.
% max_X(I) :-  I = #max{X : edge((_,_), (X,Y))}.
% max_Y(I) :-  I = #max{Y : edge((_,_), (X,Y))}.

% node(1..N) :- max_X(X), max_Y(Y), N = X*Y.
% node(1..N) :- max(N).
% ----------------------- Define NODE structure ----------------------- %




% % ---------------------- Job Completion ---------------------- %

% Problem: robots aren't going to the nodes when they need to

% last_operation(J,O,N) :- #max{O, J : operation(J,O,N)}.


% {job_complete(J,T1)} :- J=j1, job(j1,_,D), assign(R,j1,1), T1 = #max{N,T: at(R,N,T)}, operation(j1,O,N).
% :- job_complete(J,T1), job_complete(J,T2), T2>T1, not job_complete(J,T1).


% there needs to be at least 1 'at' atom on every node of an operation, where the T is less than the duration
% :- job(J1,C1,D1), operation(J1,O1,N), assign(R,J1,P1), at(R,N,T), T<=D1, not #count{R,N,T: at(R,N,T)} >= 1.



% % There needs to be be an 'at' atom at every node of a job's operation such that the T is less than or equal to the deadline of the job
%doesnt work
% :- job(J1,_,D), operation(J1,O,N), job(J2,_,D), operation(J2,O,N), assign(R,J1,P1), assign(R,J2,P2), at(R,N,T1), at(R,N,T2), T2>T1, not T2<=D.


% Need to 

% :-  job(J1,C1,D1), operation(J1,O1,N1), operation(J1,O2,N2), O2>O1, at(R,N2,T2), job(J2,C2,D2), operation(J2,O,N2), assign(R,J1,P1), assign(R,J2,P2), J1!=J2, P1<P2, at(R,N2,T), not T>T2.
% % ---------------------- Job Completion ---------------------- %







% section 1

% at_operation(R, 1, J, N_target, T_target) :- assign(R,J,1), 
%     job(J,_,D), 
%     at(R, N_target, T_target), at(R, N_operation, T_upper_bound), 
%     operation(J, 1, N_operation), 
%     T_target=0..T_upper_bound.


% % section 2
% at_operation(R, O_current, J, N_target, T_target) :- at_operation(R, O_prior, J, N_prior, T_prior),
%     at(R, N_target, T_target), at(R, N_Operation, T_upper_bound),
%     at(R,N_prior,T_prior),
%     operation(J, O_current, N_Operation),
%     operation(J, O_prior, N_prior),
%     O_prior<2,
%     T_prior!=T_upper_bound,
%     T_target=T_prior+1..T_upper_bound.



% job_times(J,T1,T2,T3) :- assign(R,J,_), 
%     job(J,_,D),
%     operation(J,O1,N1), at(R,N1,T1),
%     operation(J,O2,N2), at(R,N2,T2),
%     operation(J,O3,N3), at(R,N3,T3),
%     T1<=D, T2<=D, T3<=D.



% % #show job_times/4.

% job_complete(J,M) :- job(J,_,D), M = #max{T1,T2,T3:job_times(J,T1,T2,T3)}.

% #show job_complete/2.


% job_complete(J,T3) :- job(J,C,D), operation(J,O1,N1), operation(J,O2,N2), operation(J,O3,N3), O3>O2>O1, 3{at(R,N1,T1);at(R,N2,T2);at(R,N3,T3)}, at(R,N3,T3).


% This rule doesnt seem necessary
% :- assign_count_job(R1,C1), assign_count_job(R2,C2), 
%     job_count(TOTAL),
%     R1!=R2, C1+C2!= TOTAL.


% % you must assign jobs with greater durations to later positions in the sequence %%%%%% need to fix for later
% :-  job(J1,C1,D1), job(J2,C2,D2), assign(R,J1,P1), assign(R,J2,P2), D1>D2, P1<P2.