function sys=zpk(MPCobj)
%ZPK  Zero-pole-gain corresponding to linearized MPC object (no constraints)
%
%   See also SS, TF

%   Author(s): A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2003/12/04 01:33:06 $

if nargin<1,
    error('mpc:zpk:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:zpk:obj','Invalid MPC object');
end

if MPCobj.MPCData.isempty,
    sys=zpk;
    return
end

try
    sys=zpk(ss(MPCobj));
catch
    rethrow(lasterror);
end