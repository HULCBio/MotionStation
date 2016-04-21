function boo=isempty(MPCobj)
%ISEMPTY  True for empty MPC objects.
% 
%   ISEMPTY(MPCOBJ) returns 1 (true) if the MPC object MPCOBJ is empty
%    

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $  $Date: 2003/12/04 01:32:45 $   

if nargin<1,
    error('mpc:isempty:none','No MPC object supplied.');
end
if ~isa(MPCobj,'mpc'),
    error('mpc:isempty:obj','Invalid MPC object');
end

boo=logical(MPCobj.MPCData.isempty);
