function ts1 = timestamp(Model)
% TIMESTAMP Retrieve information about when a model was created.
%
%   ts = TIMESTAMP(Model)
%
%   ts is returned as a string that gives information about when Model 
%   was created,and when it was last modified.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:14 $

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
