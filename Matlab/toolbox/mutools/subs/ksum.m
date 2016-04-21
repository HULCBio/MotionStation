% function out = ksum(v1,v2)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = ksum(v1,v2)
 [rv1 cv1] = size(v1);
 [rv2 cv2] = size(v2);
 out = kron(ones(rv1,cv1),v2) + kron(v1,ones(rv2,cv2));