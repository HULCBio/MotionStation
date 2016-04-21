%MISOSS MPC control of a MISO system and simulation using model linearized through method SS
%
% The system has 3 inputs (1 manipulated var, 1 measured disturbance, 1 unmeasured dist.)
% and 1 output.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:33:58 $   

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

% No constraints on manipulated variable and output are enforced

Model=[]; % reset structure Model
Model.Plant=model;
Model.Disturbance=tf(sqrt(1000),[1 0]); % Integrator driven by white noise with variance=1000
 
p=[];       % prediction horizon (take default one)
m=3;        % control horizon

% Assume default value for weights
MPCobj=mpc(Model,Ts,p,m);

% Get linearized state-space form of MPC controller (constraints inactive)
[LTIMPC,BLr,DLr,BLv,DLv]=ss(MPCobj);

% Get state-space matrices
[AL,BL,CL,DL]=ssdata(LTIMPC);

% Get state-space matrices of Plant model used by MPC
[A,B,C,D]=ssdata(model);


% Simulate linear MPC closed-loop system

disp('Simulating closed loop system');
Tstop=5;  %Simulation time
xL=[x0;0;0];
x=x0;
y=0;
r=1;
u=0;

YY=[];
XX=[];
RR=[];

xmpc=[];
for t=0:round(Tstop/Ts)-1,
    YY=[YY,y];
    XX=[XX,x];
    v=0;
    if t*Ts>=10,
        v=1;
    end
    d=0;
    if t*Ts>=20,
        d=-0.5;
    end
    uold=u;
    u=CL*xL+DL*y+DLr*r+DLv*v;
    
    % Compare input move with the one provided by MPC
    [uMPC,xmpc]=mpcmove(MPCobj,y,r,v,xmpc);
    %[uMPC,xmpc,Info]=mpcmove(MPCobj,y,r,v,xmpc);
    disp(sprintf('t=%5.2f, input move u=%7.4f (u=%7.4f is provided by MPCMOVE)',t*Ts,u,uMPC));
    
    x=A*x+B(:,1)*u+B(:,2)*v+B(:,3)*d;

    xL=AL*xL+BL*y+BLv*v+BLr*r;
    %disp('[x,xL]=');
    %[[x;0;u],xL]
    
    y=C*x+D(:,1)*u+D(:,2)*v+D(:,3)*d;
    %disp(sprintf('t=%f\%n',t*Ts));
end

% Plot results
plot(0:Ts:Tstop-Ts,YY)
grid
