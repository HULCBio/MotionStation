function s = status( pj )
%STATUS Return structure of status on PrintJob.

%   Copyright 1984-2002 The MathWorks, Inc. 
% $Revision: 1.4 $

%Currently everything in PrintJob is made public. 
%May want to trim this later.
s = struct(pj);
