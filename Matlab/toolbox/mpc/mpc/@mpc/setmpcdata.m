function setmpcdata(MPCobj,MPCData)
%SETMPCDATA  Set private MPCDATA structure.

%   Author: A. Bemporad
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2003/12/04 01:32:55 $   

MPCobj.MPCData=MPCData;

% Assign MPCobj in caller's workspace
try
   assignin('caller',inputname(1),MPCobj);
end
