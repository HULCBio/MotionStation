function outpipestr = set_pipestr(inpipestr, pos, str)
% SET_PIPESTR Sets the POS'th string in pipe delimited input string
%    INPIPESTR to be the string STR.  If the POS'th entry exceeds the
%    number of delimited strings in INPIPESTR, empty strings are
%    appended up to the POS'th position.

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.5 $  $Date: 2002/04/14 20:52:16 $

c=cellpipe(inpipestr);
if ~isstr(str),
   error('STR must be a string.');
end
if (pos<1),
   error('Invalid index specified.');
end
c{pos}=str;
outpipestr = cellpipe(c);
