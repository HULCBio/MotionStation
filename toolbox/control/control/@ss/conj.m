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
%   $Revision: 1.4 $  $Date: 2002/04/10 06:02:26 $

for ct=1:prod(size(sys.a))
    sys.a{ct} = conj(sys.a{ct});
    sys.b{ct} = conj(sys.b{ct});
    sys.c{ct} = conj(sys.c{ct});
    sys.e{ct} = conj(sys.e{ct});
end

sys.d = conj(sys.d);
