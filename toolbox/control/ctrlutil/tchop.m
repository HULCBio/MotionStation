function Tf = tchop(Tf)
%TCHOP  Rounds the simulation horizon Tf to a convenient value 
%       for plotting purposes.

%   Pascal Gahinet, 10-23-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17 $

% Define rounding preference for integers between 11 and 20
pref = [12 12 14 15 15 16 18 18 20 20];

% Write z=0.999*Tf as  z=x*10^y with 10<x<=100
z = 0.999*Tf;
y10 = 10^(ceil(log10(z))-2);  % 10^y
x = z/y10;       

% Reset Tf
if x>50, 
   Tf = 10*ceil(x/10)*y10;
elseif x>20,
   Tf = 5*ceil(x/5)*y10;
else
   Tf = pref(max(1,ceil(x)-10))*y10;
end
