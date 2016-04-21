function [a,b,c,d] = sioreal(num,den,pmap)
%SIOREAL   State-space realization of SIMO or MISO TF model.

%   Author: P. Gahinet, 5-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 06:08:49 $

[ny,nu] = size(num);
ne = max(ny,nu);  % number of entries

% Determine which entries are dynamic
dyn = logical(zeros(1,ne));
d = zeros(ny,nu);
for k=1:ne,
   dyn(k) = any(num{k}) & length(den{k})>1;
   d(k) = num{k}(1);
end
idyn = find(dyn);

% Compute realization for subset of non-static entries
if length(idyn)==0,
   % Static gain
   a = [];
   b = zeros(0,nu);
   c = zeros(ny,0);
   return

elseif length(idyn)<2 | isequal(den{idyn}),
   % Common denominator for entries with dynamics
   [a,bdyn,cdyn,ddyn] = comden(num(idyn),den{idyn(1)});
   
else
   % Entry-by-entry realization
   a = [];   bdyn = [];   cdyn = [];   ddyn = [];
   if nu==1,
      catop = 'vcat';
   else
      catop= 'hcat';
   end
   
   for k=idyn,
      [ak,bk,ck,dk] = comden(num(k),den{k});
      [a,bdyn,cdyn,ddyn] = ...
         ssops(catop,a,bdyn,cdyn,ddyn,[],ak,bk,ck,dk,[]);
   end
end


% Expand realization to include entries w/o dynamics
na = size(a,1);
if nu==1,
   c = zeros(ny,na);
   c(dyn,:) = cdyn;
   b = bdyn;
else
   b = zeros(na,nu);
   b(:,dyn) = bdyn;
   c = cdyn;
end
d(dyn) = ddyn;


