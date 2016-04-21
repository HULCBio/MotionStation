function sys = hdsReplicateArray(sys,Pattern)
%HDSREPLICATE  Replicates data point array along grid dimensions.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:50 $
sys = repsys(sys,Pattern);