function str = initdisplay(this,x,optimValues)
% STR = INITDISPLAY(THIS,X,OPTIMVALUES,STATE)

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $ $Date: 2004/03/10 21:51:11 $

str = cell(5,1);
str{1} = '<font face="monospaced"; size=3>';
str{2} = ' Optimizing to solve for all desired dx/dt=0, x(k+1)-x(k)=0, and y=ydes.';
str{3} = ' ';
str{4} = '(Maximum Error)  Block';
str{5} = ' ---------------------------------------------------------';
