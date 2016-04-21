function b = blanks(n)
%BLANKS String of blanks.
%   BLANKS(n) is a string of n blanks.
%   Use with DISP, eg.  DISP(['xxx' BLANKS(20) 'yyy']).
%   DISP(BLANKS(n)') moves the cursor down n lines.
%
%   See also CLC, HOME, FORMAT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10 $  $Date: 2002/04/15 03:53:35 $

space = ' ';
b = space(ones(1,n));
