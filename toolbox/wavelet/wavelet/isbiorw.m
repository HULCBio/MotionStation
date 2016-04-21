function R = isbiorw(wname)
%ISBIORW True for a biorthogonal wavelet.
%   R = ISBIORW(W) returns 1 if W is the name of 
%   a biorthogonal wavelet and 0 if not.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 20-Jun-2003.
%   Last Revision 20-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:45 $ 

R = wavetype(wname,'bior');
