%MOTOR_MODEL Data for DC-motor with elastic shaft
%
%   Reference: 
%
%   A. Bemporad, "Reference Governors: On-Line Set-Point Optimization Techniques for 
%   Constraint Fulfillment", Ph.D. dissertation, DSI, University of Florence, Italy, 1997. 

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2004/04/19 01:16:10 $   

%Parameters (MKS)
%------------------------------------------------------------------------------------------
Lshaft=1.0;      %Shaft length
dshaft=0.02;     %Shaft diameter
shaftrho=7850;   %Shaft specific weight (Carbon steel)
G=81500*1e6;     %Modulus of rigidity

tauam=50*1e6;    %Shear strength

Mmotor=100;      %Rotor mass
Rmotor=.1;       %Rotor radius
Jmotor=.5*Mmotor*Rmotor^2; %Rotor axial moment of inertia                      
Bmotor=0.1;      %Rotor viscous friction coefficient (A CASO)
R=20;            %Resistance of armature
Kt=10;           %Motor constant

gear=20;         %Gear ratio


Jload=50*Jmotor; %Load NOMINAL moment of inertia
%Jload=input('Jload: how many times Jmotor?' )*Jmotor; %Load NOMINAL moment of inertia
Bload=25;        %Load NOMINAL viscous friction coefficient

Ip=pi/32*dshaft^4;               %Polar momentum of shaft (circular) section
Kth=G*Ip/Lshaft;                 %Torsional rigidity (Torque/angle)
Vshaft=pi*(dshaft^2)/4*Lshaft;   %Shaft volume
Mshaft=shaftrho*Vshaft;          %Shaft mass
Jshaft=Mshaft*.5*(dshaft^2/4);   %Shaft moment of inertia (???)

JM=Jmotor; 
JL=Jload+Jshaft;

Ts=.1;     %Sampling time

%Input/State/Output continuous time form
%------------------------------------------------------------------------------------------
AA=[0             1             0                 0;
    -Kth/JL       -Bload/JL     Kth/(gear*JL)     0;
    0             0             0                 1;
    Kth/(JM*gear) 0             -Kth/(JM*gear^2)  -(Bmotor+Kt^2/R)/JM];
                
BB=[0;0;0;Kt/(R*JM)];

[AAd,BBd]=c2d(AA,BB,Ts);

Hyd=[1 0 0 0];
Hvd=[Kth 0 -Kth/gear 0];

Dyd=0;
Dvd=0;

Vmax=tauam*pi*dshaft^3/16; %Maximum admissible torque
Vmin=-Vmax;

% Prepare parameters 

%Tstop=40*Ts;   %Simulation time
Tstop=200*Ts;

sys=ss(AA,BB,[Hyd;Hvd],[Dyd;Dvd]);
x0=zeros(4,1);
 
umin=-220;
umax=220;
dumin=-Inf;
dumax=Inf;
ymin=[-Inf Vmin];
ymax=[Inf Vmax];

uweight=0;
duweight=.05;
yweight=10*[1 0];

% prediction model, LTI form
%model=c2d(sys,Ts);

%% prediction model, STEP form
%[A,B,C,D]=ssdata(sys);
%stepsys=ss2step(A,B,C,D,10,0,Ts,[0;1]);
