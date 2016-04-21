function mpcnew = d2d(mpcobj,ts)
%D2D  Change MPC controller sampling time.
%
%   MPCOBJ = D2D(MPCOBJ,TS) resamples the MPC models to produce an equivalent 
%   MPC object with sampling time TS.
%
%   See also MPC.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2003/12/04 01:32:36 $   


if nargin<1,
    error('mpc:d2d:none','No MPC object supplied.');
end
if nargin<2,
    error('mpc:d2d:ts','No sampling time supplied.');
end
if ~isa(mpcobj,'mpc'),
    error('mpc:d2d:obj','Invalid MPC object');
end

mpcnew=mpcobj;

if isempty(mpcobj),
    return
end

try
    set(mpcnew,'ts',ts);
catch
    rethrow(lasterror);
end