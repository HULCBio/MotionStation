function pack(MPCobj)
%PACK Clean up information build at initialization from object

%   Author: A. Bemporad
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:35:09 $   

MPCData=MPCobj.MPCData;
MPCData.QP_ready=0;
MPCData.L_ready=0;
MPCData.Init=0;
MPCData.MPCstruct=[];
MPCobj.MPCData=MPCData;

% Assign MPCobj in caller's workspace
try
   assignin('caller',inputname(1),MPCobj);
end
