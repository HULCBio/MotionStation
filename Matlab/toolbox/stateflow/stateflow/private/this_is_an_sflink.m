function isLink = this_is_an_sflink(blockH),
%
% Determine if a block is a link
%

%   Jay Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.7.2.1 $  $Date: 2004/04/15 01:01:09 $

if isempty(get_param(blockH, 'ReferenceBlock')),
   isLink = 0;
else,
   isLink = 1;
end;
