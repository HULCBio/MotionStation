function [Ad,Bd,Cd,Dd,sn,gic] = impconv(A,B,C,D,T,fid,fod,sn)
%impconv  impulse invariant conversion of continuous-time to discrete time state space 
%
%   SYSD = impconv(A,B,C,D,T,fid,fod,sn)
%   Called by c2d. Transforms the continuous time state space system described by A,B,C,D
%   with fractional delays fid, fid into a discrete time system Adiscrete,Bdiscrete,Cdiscrete,Ddiscrete
%   using the impulse invariant transform. The state vector of the discretized system is
%   [x_k
%    yp_k]
%   where x_k=x(k*T) and yp_k is equal to the sampled value of those outputs y which are
%   subject to ouptput delay.

%   James G. Owen
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 06:03:24 $

if T<=0 
    error('Requires a strictly positive sample time');
end
numStates = size(A,1);
numInputs = size(B,2);
numOutputs = size(C,1);

%fod,fid are normalized, convert them back
fracInputDelay = fid*T;
fracOutputDelay = fod*T;
fracIODelay = fod(:,ones(1,numInputs)) + fid(:,ones(1,numOutputs))'; % normalized

IzeroFracOutputDelay = find(fracOutputDelay==0);
IposFracOutputDelay = find(fracOutputDelay>0);
IposFracInputDelay = find(fracInputDelay>0);
fracOutputDelay = fracOutputDelay(IposFracOutputDelay);
fracInputDelay = fracInputDelay(IposFracInputDelay);
nxaug = length(fracOutputDelay); % Number of additional states = # positive output delays

% Discretized state matrices
Ad = expm(A*T);

Bd = B;
inDelays = unique(fracInputDelay);
for k=1:length(inDelays)
   idx = find(fracInputDelay==inDelays(k));
   Bd(:,idx) = expm(-A*inDelays(k)) * B(:,idx);
end
Bd=Ad*Bd;

Cd = C(IzeroFracOutputDelay,:);

Bf = B;
Bf(:,IposFracInputDelay) = 0;
Dd = Cd * Bf;  % contribution of impulses at t=k*Ts

%Augment state when there are nonzero output delays
%Ad -> [Ad 0 ; R 0]
%Bd -> [Bd ; Bdtilde]
%Cd -> [C(idx,:) 0;0 I]  where idx = rows with zero output delay
%Dd -> [Dd ; 0]
if nxaug>=1
   outDelays = unique(fracOutputDelay); 
   R0 = C(IposFracOutputDelay,:);
   for k=1:length(outDelays)
      idx = find(fracOutputDelay==outDelays(k)); 
      R0(idx,:) = R0(idx,:)*expm(-A*outDelays(k));
   end      
   R=R0*Ad; %multiply Ad outside the loop to save repetition
   
   %The i,jth position of Bdtilde is row_i(R0)*col_j(Bd)*(alpha_i+beta_j<=T)
   Bdtilde = (R0*Bd) .* (fracIODelay(IposFracOutputDelay,:)<=(1+100*eps));
   
   Ad = [Ad zeros(numStates,nxaug); R  zeros(nxaug)];
   Bd = [Bd ; Bdtilde];  
   Cd = blkdiag(Cd,eye(nxaug));
   Dd = [Dd ; zeros(nxaug,numInputs)];
   % Reorder rows
   rperm = [IzeroFracOutputDelay;IposFracOutputDelay];
   Cd(rperm,:) = Cd;
   Dd(rperm,:) = Dd;
   % State names
   sn(numStates+1:numStates+nxaug,:) = {''};
end

% State mapping matrix
gic = blkdiag(eye(numStates),zeros(nxaug,numInputs));