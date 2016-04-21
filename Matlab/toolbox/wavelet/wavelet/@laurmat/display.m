function display(M)
%DISPLAY Display function for LAURMAT objects.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:12 $ 

% Use the "DISP" method if it exits.
varName = inputname(1);
disp(M,varName);
