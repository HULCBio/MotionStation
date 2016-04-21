function [n,d] = sisoplus(n1,d1,n2,d2)
%SISOPLUS  Adds two SISO transfer functions 
%               N1     N2     N1*D2 + N2*D1
%               --  +  --  =  -------------
%               D1     D2         D1*D2

%      Author: P. Gahinet, 5-1-96
%      Copyright 1986-2002 The MathWorks, Inc. 
%      $Revision: 1.9 $  

% RE: Assumes (N1,D1) and (N2,D2) have equal length, in which case
%     the resulting N,D always have equal length.

if ~any(n1),
   % N1 = 0
   n = n2; 
   d = d2;
elseif ~any(n2),
   % N2 = 0
   n = n1; 
   d = d1;
else
   % General case
   n = conv(n1,d2) + conv(n2,d1);
   d = conv(d1,d2);
end

% end sisoplus
