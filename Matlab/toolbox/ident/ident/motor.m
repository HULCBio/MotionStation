function [A,B,C,D,K,X0] = motor(par,ts,aux)
%MOTOR  Help file for IDDEMO, describing IDGREY models
%
%   [A,B,C,D,K,X0] = MOTOR(Tau,Ts,G)
%   returns the State Space matrices of the DC-motor with
%   time-constant Tau
%   (Tau = par) and known static gain G. The sampling interval is
%   Ts. 
%   The conversion to a sampled model is inhibited if Ts is entered
%   as zero. This means that the IDGREY property can CDMFILE cad be 
%   set to 'CD', which allows for easier transformations back and
%   forth between discrete and continuous time representations.
%   
%   See also IDGREY and IDDEMO # 6.

%   L. Ljung
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2001/04/06 14:22:27 $

t = par(1);
G=aux(1);

A=[0 1;0 -1/t];
B=[0;G/t];
C=eye(2);
D=[0;0];
K=zeros(2,2);
X0=[0;0];
if ts>0 % Sample the model with sampling interval ts
s = expm([[A B]*ts; zeros(1,3)]);
A = s(1:2,1:2);
B = s(1:2,3);
end
