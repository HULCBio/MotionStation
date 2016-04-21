function sys = conj(sys)
%CONJ   Forms model with complex conjugate coefficients.
% 
%   SYSC = CONJ(SYS) constructs a complex conjugate model SYSC
%   by applying complex conjugation to all coefficients of the 
%   LTI model SYS.  For example, if SYS is the transfer function
%       (2+i)/(s+i)
%   then CONJ(SYS) produces the transfer function (2-i)/(s-i).
%   This operation is useful for manipulating partial fraction 
%   expansions.
% 
%   See also TF, ZPK, SS, RESIDUE.

%   Author: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/04/10 06:08:25 $

for ct=1:prod(size(sys.num))
    sys.num{ct} = conj(sys.num{ct});
    sys.den{ct} = conj(sys.den{ct});
end