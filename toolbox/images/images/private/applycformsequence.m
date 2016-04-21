function out = applycformsequence(in, cforms)
%APPLYCFORMSEQUENCE Apply a sequence of cforms.
%   OUT = APPLYCFORMSEQUENCE(IN, CFORMS) applys a sequence of cforms to
%   the input data, IN.  CFORMS is a cell array containing the cform
%   structs.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:57:39 $

out = in;
for k = 1:length(cforms)
    out = applycform(out, cforms{k});
end
