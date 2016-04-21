function Log = findLog(this, LogObject, LogName, LogWho)
% FINDLOG Extracts signal log with a given name.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:32:04 $

if isempty(LogObject)
  Log = [];  return
end

if nargin < 4
  LogWho = LogObject.who('all');
end

% Find index in log
s = regexp(LogWho, ['(\.', LogName, '$|', LogName, '$)'], 'once');
idx = find( ~cellfun('isempty', s) );
if isempty(idx)
  error('No signal with name %s found.', LogName)
end

% Extract log for specified signal
Log = eval( ['LogObject.' LogWho{idx}] );
if isa(Log, 'Simulink.TsArray')
  members = Log.Members;
  ts = Log.(members{1});
  for ct = 2:length(members)
    tsct = Log.(members{ct});
    [ts, tsct] = merge(ts, tsct, 'union');
    ts.Data = [ts.Data, tsct.Data];
  end
  Log = ts;
end

% Support for non-double data types
if ~isa(Log.Data, 'double')
  Log.Data = double(Log.Data);
end
