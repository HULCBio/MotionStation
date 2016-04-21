echo off
% POPDEMO
%    --------------   Population Demo   ---------------
%   This system models a population in which the number of 
%   members follows the law dm/dt = a * m - b * m * m.
%   A is taken to represent a reproductive rate and b 
%   represents competition.
%
%   20 simulations will be run using different starting 
%   populations.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.17 $

clc
clf
hold off; 
help popdemo
echo on
pause % Strike any key to continue.
axis([0,300,0,100]);
plot(0,0,300,100);
grid;
xlabel('Time');
ylabel('Population Size');
hold on;
echo on;

%
% open the pops model
if isempty(find_system(0,'flat','Name','pops')),
  pops([],[],[],0);
end

%
% This loop runs 20 simulations and plots the results.

for ind = 20:-1:1
  initial_pop = ind * 5 + 1;
  [t,x] = sim('pops',300); 
  % use ODE-23 to simulate pops until t = 300.
  plot(t,x);
end
% Different numbers in a and b will result in different 
% final populations.  You can change these values 
% and select this demo from the menu again.
%
pause   
% Select this window and strike any key to end this demo.
echo off;
hold off;
clc;
