function [Roots,Gains,OLz,OLp,OLk] = genrlocus(sys,Gains)
%GENRLOCUS  Generates gains and roots for root locus plot.

%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc. 
%  $Revision: 1.2.4.2 $  $Date: 2004/04/20 23:15:52 $

% RE: Computes root locus for a single SISO model

% Make GAINS a row vector
ng = length(Gains);
if ng>0
   SpecifiedGains = reshape(Gains,[1 ng]);
end

% Reduce improper case to proper case by transform gain->1/gain and inverting SYS
IsProper = isproper(sys);
if ~IsProper
   sys = inv(sys);
   if ng>0
      SpecifiedGains = LocalInvertGains(SpecifiedGains);
   end
end

% Convert to state-space
[a,b,c,d] = ssdata(sys);
ns = size(a,1);
OLp = eig(a);  % open-loop poles

% Reduce to Hessenberg form (stabilizes trajectories of roots going to Inf)
% RE: Perform balancing + io scaling to enhance numerics 
[a,b,c] = abcbalance(a,b,c,[],1/eps,'perm','scale');  
M = hessabc(a,b,c);   % modif of HESS to prevent permutation of 1st column
a = M(2:ns+1,2:ns+1);
b = M(2:ns+1,1);
c = M(1,2:ns+1);

% Compute open-loop zeros
% Use HESSZERO to exploit Hessenberg structure and make C,D consistent with 
% the computed relative degree (ensures proper convergence to OLz as k->Inf)
% Cf. sys = ss(Gservo * tf(1,[1 1936 1e6])) + random ss2ss
[OLz,OLk] = sisozero([d c;b a],[],100*eps);
m = length(OLp)-length(OLz);  % computed rel degree

% Enforce consistency w/ relative degree (d=c*b=...=c*A^(m-2)*b=hard zero)
d = (m==0) * d;
c(:,1:m-1) = 0; 

% Generate root locus
if ng>0
   % Compute the roots at the specified gains (output is NS by length(Gains))
   Roots = genrloc(a,b,c,d,SpecifiedGains,OLz,OLp,'sort');
elseif OLk==0 || (isempty(OLz) && isempty(OLp))
   % Limit cases
   Roots = [];  
   Gains = zeros(1,0);
else
   % Adaptively generate gain values if they are not specified
   [Gains,Roots] = gainrloc(a,b,c,d,OLz,OLp,OLk);
   if ~IsProper
      Gains = fliplr(LocalInvertGains(Gains));
      Roots = fliplr(Roots);
   end
end

% Undo system inversion in improper case
if ~IsProper && nargout>2
   OLk = 1/OLk;
   tmp = OLp;
   OLp = OLz;
   OLz = tmp;
end

%---------------------------------------------------------

function Gains = LocalInvertGains(Gains)
% Transforms Gains -> 1/Gains

isz = (~Gains);
Gains(:,isz) = Inf;
Gains(:,~isz) = 1./Gains(:,~isz);

