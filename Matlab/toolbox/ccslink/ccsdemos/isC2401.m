function resp = isC2401(cc)
% (Private) Determines if CC is a C2401 processor.

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/08/04 17:56:15 $

if ishandle(cc)
    resp = any(strfind(cc.info.boardname,'2401'));
else % if cc is ccinfo - from info(cc)
    resp = any(strfind(cc.boardname,'2401'));
end

% [eof] isC2401.m