function [a,b,c,d] = comden(num,den)
%COMDEN  Realization of SIMO or MISO TF model with common denominator. 
%
%   [A,B,C,D] = COMDEN(NUM,DEN)  returns a state-space
%   realization for the SIMO or MISO model with data NUM,DEN.

%    Author: P. Gahinet, 5-1-96
%    Copyright 1986-2002 The MathWorks, Inc. 
%    $Revision: 1.14 $  $Date: 2002/04/10 06:09:01 $

% RE: Assumes DEN(1) = 1.

% Get number of outputs/inputs 
[p,m] = size(num);
num = cat(1,num{:});

% Handle various cases
if ~any(num(:)),
   % All zero
   a = [];   
   b = zeros(0,m);  
   c = zeros(p,0);  
   d = zeros(p,m);
   
else
   % Realize with COMPREAL
   [a,b,c,d] = compreal(num,den);
   
   % Transpose/permute A,B,C,D in MISO case to make A upper Hessenberg
   if p<m,
      b0 = b;
      a = a.';  b = c.';  c = b0.';  d = d.';
      perm = size(a,1):-1:1;
      a = a(perm,perm);
      b = b(perm,:);
      c = c(:,perm);
   end
end

   

