function ts = utFindLog(LogObject,LogName,LogWho)
% Extracts signal log with a given name.

%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:54 $
%   Copyright 1986-2004 The MathWorks, Inc.
if isempty(LogObject)
   ts = [];  return
end
if nargin<3
   LogWho = LogObject.who('all');
end

% Find index in log
s = regexp(LogWho, ['(\.', LogName, '$|', LogName, ')']);
idx = find(~cellfun('isempty', s));
if isempty(idx)
   error('No signal with name %s found.',LogName)
end

% Extract log for specified signal
ts = eval(['LogObject.' LogWho{idx}]);

% Support for non-double data types
if ~isa(ts.Data,'double')
   ts.Data = double(ts.Data);
end
