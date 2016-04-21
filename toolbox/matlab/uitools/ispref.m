function exists = ispref(group,pref)
%ISPREF Test for existence of preference.
%   ISPREF('GROUP','PREF') returns 1 if the preference specified by
%   GROUP and PREF exists, and 0 otherwise.
%
%   ISPREF('GROUP') returns 1 if the GROUP exists, and 0 otherwise.
%
%   ISPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) returns a logical
%   array the same length as the cell array of preference names,
%   containing 1 where each preference exists, and 0 elsewhere.
%
%   Example:
%      addpref('mytoolbox','version',1.0)
%      ispref('mytoolbox','version')
%
%   See also ADDPREF, GETPREF, SETPREF, RMPREF.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.6 $

error(nargchk(1, 2, nargin));
prefutils('checkGroup',group);

if nargin == 1
  exists = 0;
else % nargin == 2
  pref = prefutils('checkAndConvertToCellVector', pref);
  exists = zeros(size(pref));
end

% load the whole preferences struct (ok if file doesn't exist):
Preferences = prefutils('loadPrefs');

[Group,g_exists] = prefutils('getFieldOptional', Preferences, group);
if g_exists
  if nargin == 1
    exists = 1;
  else
    for i = 1:length(pref)
      [ignore, exists(i)] = prefutils('getFieldOptional', ...
				      Group, pref{i});
    end
  end
end

exists = logical(exists);
