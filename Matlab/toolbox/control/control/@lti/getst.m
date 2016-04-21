function Ts = getst(sys)
%GETST  Fast access to sample time of LTI models
%
%   TS = GETST(SYS) returns the sample time of the
%   LTI object SYS.
%
%   See also GET.

%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.6 $  $Date: 2002/04/10 05:50:50 $

Ts = sys.Ts;