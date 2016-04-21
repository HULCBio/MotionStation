function ts1 = timestamp(Model)
% TIMESTAMP Retrieve information about when an IDDATA object was
%   created.
%
%   ts = TIMESTAMP(DATA)
%
%   ts is returned as a string that gives information about when
%   DATA was created, and when it was last modified.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2001/04/06 14:22:04 $

try
   ts = timemark(Model,'g');
catch
   ts ='';
end
if nargout
   ts1 = ts;
else
   disp(ts);
end
