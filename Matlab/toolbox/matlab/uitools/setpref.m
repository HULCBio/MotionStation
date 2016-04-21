function setpref(group,pref,value)
%SETPREF Set preference.
%   SETPREF('GROUP','PREF',VAL) sets the preference specified by GROUP
%   and PREF to the value VAL. Setting a preference that does not yet
%   exist causes it to be created.
%
%   GROUP labels a related collection of preferences.  You can choose
%   any name that is a legal variable name, and is descriptive enough
%   to be unique, e.g. 'MathWorks_GUIDE_ApplicationPrefs'.
%
%   PREF identifies an individual preference in that group, and
%   must be a legal variable name.
%
%   SETPREF('GROUP',{'PREF1','PREF2',...'PREFn'},{VAL1,VAL2,...VALn})
%   sets each preference specified in the cell array of names to the
%   corresponding value.
%
%   Preference values are persistent and maintain their values between
%   MATLAB sessions.  Where they are stored is system dependent.
%
%   Example:
%      addpref('mytoolbox','version',0.0)
%      setpref('mytoolbox','version',1.0)
%      getpref('mytoolbox','version')
%
%   See also GETPREF, ADDPREF, RMPREF, ISPREF.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $

% perform all error checks and conversion of inputs:
error(nargchk(3, 3, nargin));
prefutils('checkGroup',group);
[pref, value] = prefutils('checkAndConvertToCellVector', pref, value);

% load the whole preferences struct (ok if file doesn't exist):
Preferences = prefutils('loadPrefs');

% get the particular group (ok if Preferences was []):
Group = prefutils('getFieldOptional',Preferences,group);

% add or change each field in the group:
for i = 1:length(pref)
  Group.(pref{i}) =  value{i};
end

% update that group in the overall preferences struct:
Preferences.(group) = Group;

% write it back out to the file (if file didn't exist, this will
% create it):
prefutils('savePrefs', Preferences);

