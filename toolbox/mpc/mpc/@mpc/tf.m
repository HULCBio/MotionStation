function sys=tf(MPCobj)
%TF  Transfer function corresponding to linearized MPC object (no constraints)
%
%   See also SS, ZPK

%   Author(s): A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2003/12/04 01:33:03 $

if nargin<1,
    error('mpc:tf:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:tf:obj','Invalid MPC object');
end

if MPCobj.MPCData.isempty,
    sys=tf;
    return
end

try
    sys=tf(ss(MPCobj));
catch
    rethrow(lasterror);
end
