function R = reflect(M)
%REFLECT Reflection for a Laurent matrix.
%   R = REFLECT(M) returns the Laurent matrix R obtained by
%   a reflection on the Laurent matrix M: R(z) = M(1/z).
%   
%   See also NEWVAR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Jun-2003.
%   Last Revision: 21-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:37:53 $ 

R = newvar(M,'1/z');
