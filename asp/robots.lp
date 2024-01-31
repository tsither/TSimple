
% Your encoding please...


% --------------- Represent the movements of the robots --------------- %
time(0..n).

edge(N2,N1) :- edge(N1,N2).



% GENERATE 'at' atoms 

%must be 'at' atom on the node the robots starts on
at(R,N,T) :- robot(R,_,N), T=0.                                                         %create at atom for the start nodes of the robots


%recursive at atom generation
%robot moves forward or back
{at(R,N2,T2)} :- robot(R,_,N), edge(N1,N2), T2=T1+1, at(R,N1,T1), T2 <=n.  

%robot stays on same node
{at(R,N1,T2)} :- robot(R,_,N), at(R,N1,T1), T2=T1+1, T2 <=n.                               


% % ROBOT cant be in two places at the same time
:- robot(R,_,_), at(R,N1,T1), at(R,N2,T2), T1=T2, N1!=N2.


% Robots can't swap place... (insert rule)
:- at(R1,N1,T1), at(R2,N2,T1), R1!=R2, edge(N1,N2), T2=T1+1, at(R1,N2,T2), at(R2,N1,T2).


% % %two robots cant be in the same place at the same time
:- at(R1,N1,T1), at(R2,N2,T2), R1!=R2, N1=N2, T1=T2.


% % % % ensure there are the correct number of at atoms (must be an 'at' atom for every robot for every timestep)
:-  robot(R,_,_), not at(R,_,1..n).

% --------------- ^Represent the movements of the robots^ --------------- %

% --------------- Optimal movement --------------- %

%make a 'move' atom representing every time a robot moves to a different node
move(R,T) :- at(R,N1,T1), at(R,N2,T2), edge(N1,N2), T1<T2, T2-T1=1, T=T2.


count_total_moves(COUNT) :- COUNT = #count{R,T : move(R,T)}.


#minimize{C : count_total_moves(C)}.


% #show count_total_moves/1.


% --------------- ^ Optimal movement ^ --------------- %

% % ---------------------- Assign a robot to a job ---------------------- %

job_count(X) :- X = #count{J,C,D : job(J,C,D)}.

% %generate assignment atoms
{assign(R,J,P)} :- robot(R,C,_), job(J,C1,D), C=C1, job_count(X), P=1..X. %need to adjust P for later


%count how many jobs a robot is assigned to
assign_count_job(R, COUNT) :- 
    robot(R,_,_),
    COUNT = #count { J : assign(R, J, _) }.


% the number of jobs a robot is assigned to cant be larger than the length of the sequence 
:- assign(R,J,P), assign_count_job(R,COUNT), P>COUNT.


%number of assigns must match the number of jobs
:- #count{R,J,P : assign(R,J,P)} = ASSIGN_N, job_count(JOB_N), ASSIGN_N!=JOB_N.

% % % robot needs to go to the node that the operation it's assigned to is on
:- assign(R,J,P), job(J,C,D), robot(R,_,_), operation(J,O,N), not at(R,N,_).


% % %every job needs an assignment
:-  job(J,C,D), not assign(_,J,_).



% %you can't assign two jobs to the same position in the sequence
:-  job(J1,C1,D1), job(J2,C2,D2), assign(R,J1,P1), assign(R,J2,P2), J1!=J2, P1=P2.

% % ---------------------- ^ Assign a robot to a job ^ ---------------------- %


% % ---------------------- Job Completion ---------------------- %


{op_complete(J,O,T)} :- job(J,_,D), 
    operation(J,O,N), 
    assign(R,J,_), 
    at(R,N,T).




%every operation must have an op_complete
:- operation(J,O,N), not op_complete(J,O,_).

%an op_complete cant be completed later than the duration of the job
:- op_complete(J,O,T), job(J,_,D), T>D.


%jobs must be done in order
:- assign(R,J1,P1), assign(R,J2,P2), P2>P1, 
    op_complete(J1,_,T1), op_complete(J2,_,T2), 
    T1>T2.

%operations must be done in order
:- op_complete(J,O1,T1), op_complete(J,O2,T2), O2>O1, T1>T2.

%operations from two different jobs can't be completed at the same time
:- op_complete(J1,O1,T1), op_complete(J2,O2,T2), 
    job(J1,_,_), job(J2,_,_),
    assign(R,J1,P1), assign(R,J2,P2), P2>P1,
    T1>=T2. 


%number of op_completes must equal the number of operations
:- #count{J,O,T: op_complete(J,O,T)}=OP_COMP, #count{J,O,N: operation(J,O,N)}=OP, OP!=OP_COMP.

% #show at/3.

op_T_sum(C) :- C = #sum{T: op_complete(J,O,T)}.

% #show op_T_sum/1.


#minimize{T: op_complete(J,O,T)}.



% #show op_complete/3.
% #show move/2.
#show at/3.
#show assign/3.


% :- not at(r1,11,0).
% :- not at(r2,12,0).
% :- not assign(r1,j11,1).
% :- not assign(r2,j21,1).
% :- not assign(r1,j12,2).
% :- not assign(r2,j22,2).
% :- not at(r1,1,1).
% :- not at(r1,1,2).
% :- not at(r1,1,3).
% :- not at(r2,1,4).
% :- not at(r1,2,4).
% :- not at(r2,1,5).
% :- not at(r1,2,5).
% :- not at(r2,1,6).
% :- not at(r1,2,6).
% :- not at(r2,2,7).
% :- not at(r2,2,8).
% :- not at(r1,3,7).
% :- not at(r1,3,8).
% :- not at(r2,12,1).
% :- not at(r2,12,2).
% :- not at(r2,12,3).
