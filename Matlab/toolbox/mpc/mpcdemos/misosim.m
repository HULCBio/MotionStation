%MISOSIM MPC control of a MISO system, closed-loop simulation using SIM
%
% The system has 3 inputs (1 manipulated var, 1 measured disturbance, 1 unmeasured dist.)
% and 1 output.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:55 $   

% Open-loop system parameters 

% True plant & true initial state
sys=ss(tf({1,1,1},{[1 .5 1],[1 1],[.7 .5 1]}));
A=sys.a;
B=sys.b;
C=sys.c;
D=sys.d;
x0=[0 0 0 0 0]';


% MPC object setup

Ts=.2;             % sampling time
model=c2d(sys,Ts); % prediction model

% Define type of input signals
model.InputGroup=struct('Manipulated',1,'Measured',2,'Unmeasured',3);

Model=[]; % reset structure Model
Model.Plant=model;
Model.Disturbance=tf(sqrt(1000),[1 0]); % Integrator driven by white noise with variance=1000
 
p=[];       % prediction horizon (take default one)
m=3;        % control horizon

% Assume default value for weights
MPCobj=mpc(Model,Ts,p,m);

% Define constraints on manipulated variable
MPCobj.MV=struct('Min',0,'Max',1);

% Now simulate closed-loop MPC system using SIM

Tstop=30;           % simulation time

Tf=round(Tstop/Ts); % number of simulation steps
r=ones(Tf,1);       % reference trajectory
v=[zeros(Tf/3,1);ones(2*Tf/3,1)];         % measured disturbance trajectory

SimOptions=mpcsimopt(MPCobj);
SimOptions.Unmeas=[zeros(2*Tf/3,1);-0.5*ones(Tf/3,1)];    % unmeasured disturbance trjaectory
SimOptions.OutputNoise=.001*(rand(Tf,1)-.5);  % output measurement noise
SimOptions.InputNoise=.05*(rand(Tf,1)-.5);   % noise on manipulated variables

%SimOptions.Constr='off'; % Remove all MPC constraints
SimOptions.Constr='on'; % Default: keep MPC constraints

SimOptions.PlantInitialState=[0 0 0 0 0]'; % Initial state of controlled plant
SimOptions.ControllerInitialState=mpcstate(MPCobj,zeros(5,1)); % Initial states of plant model used for prediction

%SimOptions.StatusBar='off';

% Perform actual simulation
[y,t,u,xp,xmpc]=sim(MPCobj,[],r,v,SimOptions);

% Plot results
subplot(211)
plot(0:Tf-1,y,0:Tf-1,r)
title('Output');
grid
subplot(212)
plot(0:Tf-1,u)
title('Input');
grid
