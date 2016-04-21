function a = hdsReplicateArray(a,Pattern)
%HDSREPLICATE  Replicates data point array along grid dimensions.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:29:57 $
a = repmat(a,Pattern);