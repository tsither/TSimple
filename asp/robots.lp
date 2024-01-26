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


% --------------- Represent the movements of the robots --------------- %

% #show robot/3.
% #show move/3.
% #show at/3.
#show last_operation/3.
% #show assign/3.
% #show job_complete/2.
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
{at(R,N2,T2)} :- robot(R,_,N), edge(N1,N2), T2=T1+1, at(R,N1,T1), T2 <=n.  

{at(R,N1,T2)} :- robot(R,_,N), T2=T1+1, at(R,N1,T1), T2 <=n.                               


% {at(R,N2,T2)} :- robot(R,_,N), edge(N1,N2), T2=1..n.                                    %generate at nodes for all possible time stamps


% % ROBOT cant be in two places at the same time
:- robot(R,_,_), at(R,N1,T1), at(R,N2,T2), T1=T2, N1!=N2.



% % % % make robots move in time correctly:
% % %:- at(R,N1,T1), at(R,N2,T2), move(R,N1,N2), |T2-T1| != 1.

% % this rule is fucked
% % :- at(R,N1,T1), at(R,N2,T2), edge(N1,N2), |T2-T1| != 1.


% % %problem: robots are jumping around graph ... 

% % % :- at(R,N1,T1), at(R,N2,T2), |T2-T1| = 1, not move(R,N1,N2).                  %move(R,N1,N2).%N2>N1, not edge(N1,N2), not move(R,N1,N2).
% :- at(R,N1,T1), at(R,N2,T2), |T2-T1| = 1, not edge(N1,N2).                  %move(R,N1,N2).%N2>N1, not edge(N1,N2), not move(R,N1,N2).





% % %two robots cant be in the same place at the same time
:- at(R1,N1,T1), at(R2,N2,T2), R1!=R2, N1=N2, T1=T2.


% % % % ensure there are the correct number of at atoms (must be an 'at' atom for every robot for every timestep)
:-  robot(R,_,_), not at(R,_,1..n).



% % ---------------------- Assign a robot to a job ---------------------- %

job_count(X) :- X = #count{J,C,D : job(J,C,D)}.

% % %generate assignment atoms
{assign(R,J,P)} :- robot(R,C,_), job(J,C1,D), C=C1, job_count(X), P=1..X. %need to adjust P for later

% % % robot needs to go to the node that the operation it's assigned to is on
:- assign(R,J,P), job(J,C,D), robot(R,_,_), operation(J,O,N), not at(R,N,_).


% % %every job needs an assignment
:-  job(J,C,D), not assign(_,J,_).


% %you must assign jobs with greater durations to later positions in the sequence
:-  job(J1,C1,D1), job(J2,C2,D2), assign(R,J1,P1), assign(R,J2,P2), D1>D2, P1<P2.

% %you can't assign two jobs to the same position in the sequence
:-  job(J1,C1,D1), job(J2,C2,D2), assign(R,J1,P1), assign(R,J2,P2), J1!=J2, P1=P2.







% % ---------------------- Job Completion ---------------------- %

% Problem: robots aren't going to the nodes when they need to

last_operation(J,O,N) :- #max{O, J : operation(J,O,N)}.


% {job_complete(J,T1)} :- J=j1, job(j1,_,D), assign(R,j1,1), T1 = #max{N,T: at(R,N,T)}, operation(j1,O,N).
% :- job_complete(J,T1), job_complete(J,T2), T2>T1, not job_complete(J,T1).


% there needs to be at least 1 'at' atom on every node of an operation, where the T is less than the duration
% :- job(J1,C1,D1), operation(J1,O1,N), assign(R,J1,P1), at(R,N,T), T<=D1, not #count{R,N,T: at(R,N,T)} >= 1.



% % There needs to be be an 'at' atom at every node of a job's operation such that the T is less than or equal to the deadline of the job
%doesnt work
% :- job(J1,_,D), operation(J1,O,N), job(J2,_,D), operation(J2,O,N), assign(R,J1,P1), assign(R,J2,P2), at(R,N,T1), at(R,N,T2), T2>T1, not T2<=D.


% Need to 

% :-  job(J1,C1,D1), operation(J1,O1,N1), operation(J1,O2,N2), O2>O1, at(R,N2,T2), job(J2,C2,D2), operation(J2,O,N2), assign(R,J1,P1), assign(R,J2,P2), J1!=J2, P1<P2, at(R,N2,T), not T>T2.



% :- not at(r1,1,0).
% % :- not assign(r1,j1,1). 
% % :- not assign(r1,j2,2). 
% :- not at(r1,3,2). 
% :- not at(r1,4,3). 
% :- not at(r1,4,4). 
% :- not at(r1,3,5). 
% :- not at(r1,1,7). 
% :- not at(r1,3,9).
% :- not at(r1,4,10). 
% :-not at(r1,2,1). 
% :-not at(r1,2,6).
% :- not at(r1,2,8).
% #show edge/2.

% % ---------------------- -------------- ---------------------- %

% get last operation

% last_operation(J1,O3,N3) :- job(J1,_,_), operation(J1,O2,N2), operation(J1,O3,N3), O3 > O2.

% :- last_operation(J1,O1,_), last_operation(J1,O2,_), O1<O2.
% :- #count{J1,O,N : last_operation(J1,O,N)} != X, job_count(X).










% :- at(R,N1,T1), at(R,N2,T2), N2-N1=1, N2>N1, T2>T1, T2-T1!=1.                           %for two at atoms between adjacent nodes, the timestamps must be adjacent
% :- at(R,N1,T1), at(R,N2,T2), T2-T1=1, N2-N1!=1, N2>N1, T2>T1.                           %for two at atoms between adjacent timestamps, the nodes must be adjacent


% :- X = #count{R,N,T: at(R,N,T)}, Y = #count{R,N1,N2: move(R,N1,N2)}, X!=Y+1.            % there must be 1 more at atom than there are move atoms 















% :-  job(J,C,D), operation(J,O,N), assign(R,J,P), at(R,N,T), not T<=D.








% ----------------------- Define NODE structure ----------------------- %


% max(N) :- N = #max{Y : edge(_,Y)}.
% max_X(I) :-  I = #max{X : edge((_,_), (X,Y))}.
% max_Y(I) :-  I = #max{Y : edge((_,_), (X,Y))}.

% node(1..N) :- max_X(X), max_Y(Y), N = X*Y.
% node(1..N) :- max(N).
