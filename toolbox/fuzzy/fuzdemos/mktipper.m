%MKTIPPER Build tipper FIS with commands.
%   This script shows how you would build an entire fuzzy
%   inference system from the command line.

%   Ned Gulley, 2-1-95
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:15:20 $

a=newfis('tipper');

% Add the first input variable
a=addvar(a,'input','service',[0 10]);
a=addmf(a,'input',1,'poor','gaussmf',[1.5 0]);
a=addmf(a,'input',1,'good','gaussmf',[1.5 5]);
a=addmf(a,'input',1,'excellent','gaussmf',[1.5 10]);

% Add the second input variable
a=addvar(a,'input','food',[0 10]);
a=addmf(a,'input',2,'rancid','trapmf',[-2 0 1 3]);
a=addmf(a,'input',2,'delicious','trapmf',[7 9 10 12]);

% Add the output variable
a=addvar(a,'output','tip',[0 30]);
a=addmf(a,'output',1,'cheap','trimf',[0 5 10]);
a=addmf(a,'output',1,'average','trimf',[10 15 20]);
a=addmf(a,'output',1,'generous','trimf',[20 25 30]);

% Add the rules
ruleList=[ ...
1 1 1 1 2 
2 0 2 1 1 
3 2 3 1 2 ];
a=addrule(a,ruleList);
