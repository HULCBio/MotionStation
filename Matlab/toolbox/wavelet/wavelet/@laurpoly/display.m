function display(P)
%DISPLAY Display function for LP objects.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:38:34 $ 

% Use the "DISP" method if it exits.
varName = inputname(1);
disp(P,varName);
