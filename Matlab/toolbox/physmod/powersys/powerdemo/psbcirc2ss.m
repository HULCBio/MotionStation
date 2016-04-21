% PSBCIRC2SS.M script file
% This file illustrates the use of the CIRC2SS function.
%
% PSBCIRC2SS creates the parameters for the circuit used in the 
%            example section of the CIRC2SS documentation and 
%            calls the CIRC2SS function to produce the state-space model.
%
% The circuit parameters are contained in:
%       RLC : Branch matrix specifying the network topology and R L C values
%  SWITCHES : switch matrix 
%    SOURCE : source matrix 
%      YOUT : string matrix of output expressions
%    Y_TYPE : vector indicating output types
%      UNIT : units used to specify R L and C values ='OMU'
%
% See CIRC2SS documentation for details
%
% The variables o returned by the CIRC2SS function are:
% A,B,C,D :  State-space matrices of the linear circuit with all switches open
%            A (n_state,n_state) B(n_state,n_input)
%            C (n_output,n_state) B(n_output,n_input)
%  STATES :  String matrix (n,n_state) containing the names of state variables. 
%      X0 :  Column vector of initial values of state variables
%            considering the status (open or closed) of switches
%    X0SW :  Vector of initial values of switch currents
%    RLSW :  Matrix (nsw,2) containing the R and L values of series switch
%              impedances in Ohms and Henrys,
%   U,X,Y :  Matrices U(n_input,n_freq) X(n_state,n_freq) Y(n_output,n_freq)
%            containing the steady-state complex values of INPUTS, STATES
%              and OUTPUTS. 
%    FREQ :  Column vector containing the (nfreq) source frequencies 
%              ordered by increasing frequencies.
% ASW,BSW :  State-space matrices of the circuit including the closed switches
% CSW,DSW :  (one extra state per closed switch)
%    Hlin :  Complex transfer impedance matrices (n_output,n_input,n_freq)
%              of the linear system. for the n_freq frequencies contained in FREQ. 
%
% For this example, the dimensions of returned variables are:
%        n_state = 4 
%        n_input = 5 (2 sources +1 current source simulating transformer saturation
%                      + 2 switch voltage inputs)
%       n_output = 6 (3 measurements + 1 magnetizing branch voltage
%                      + 2 switch current outputs)
%
%         n_freq = 3  O Hz undetermined frequency of current sources
%                          modeling nonlinear elements,
%                     60 Hz voltage source
%                     180 Hz current source

%   Gilbert Sybille 98-May-23, 08-05-2000
%   Copyright 1997-2002 TransEnergie Technologies Inc., under sublicense
%   from Hydro-Quebec, and The MathWorks, Inc.
%   $Revision: 1.1.2.2 $  

unit='OMU'; % Units = Ohms, mH and uF

rlc=[
%Node1 Node2 type R     L   C(uF)/U(V)
1      2     0    0.1   1   0    %R1 L1
2      0     2    0.05  1.5 100  %transformer Winding #1
10     0     2    0.20  0   200  %transformer Winding #2
2.1    0     1    1000  0   0    %transformer magnetization branch
11     0     1    200   0   1    %R5 C5
11     12    0    0     0   1e-3 %C6
12     0     1    0     500 2    %L7 C7
];

source=[
%Node1 Node2 type U/I   phase  freq
10     11    1    0     0       0    %Sw1
11     12    1    0     0       0    %Sw2
2.1    0     1    0     0       0    %Saturation
1      0     0    100   0      60    %Voltage source
0      10    1    2     -30    180   %Current source
]; 

switches=[
%Node1 Node2 status R(ohms)  L(mH)   I#  U#  
10     11    1      0.01     0       1   1  %Sw1
11     12    0      0.1      0       2   2  %Sw2
];

%outputs
%
% Both switches have Lon=0, so their voltages must be the first outputs,
% immediatly followed by their currents (in the same order as the voltages).
% The voltage across all nonlinear models which don't have L=0 follow (in
% this case the saturable transformer's magnetizing inductor). The measure-
% ments which you request follow, in any order.
%
y_u1='U_n10_11' ; %U_Sw1= Voltage across Sw1
y_u2='U_n11_12' ; %U_Sw2= Voltage across Sw2
y_i3='I1'       ; %I1= Switch current Sw1    
y_i4='I2'       ; %I2= Switch current Sw2
y_u5='U_n2.1_0' ; %U_sat= Voltage across saturable reactor 
y_i6='I_b1';      %I1 measurement
y_u7='U_n11_0';   %V2 measurement
y_u8='U_n12_0';   %V3 measurement

yout=str2mat(y_u1,y_u2,y_i3,y_i4,y_u5,y_i6,y_u7,y_u8); % outputs
y_type=[0,0,1,1,0,1,0,0]; %output types; 0=voltage 1=current

% open file which will contain circ2ss output information
fid=fopen('psbcirc2ss.net','w');

[A,B,C,D,states,x0,x0sw,rlsw,u,x,y,freq,Asw,Bsw,Csw,Dsw,Hlin]=...
   circ2ss(rlc,switches,source,[],yout,y_type,unit,[],[],[],0,fid);
