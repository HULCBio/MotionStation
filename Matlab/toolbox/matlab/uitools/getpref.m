function retval = getpref(group,pref,default)
%GETPREF Get preference.
%   GETPREF('GROUP','PREF') returns the value for the preference
%   specified by GROUP and PREF.  It is an error to get a preference
%   that does not exist.
%
%   GROUP labels a related collection of preferences.  You can choose
%   any name that is a legal variable name, and is descriptive enough
%   to be unique, e.g. 'MathWorks_GUIDE_ApplicationPrefs'.
%
%   PREF identifies an individual preference in that group, and
%   must be a legal variable name.
%
%   GETPREF('GROUP','PREF',DEFAULT) returns the current value if the
%   preference specified by GROUP and PREF exists.  Otherwise creates
%   the preference with the specified default value and returns that
%   value.
%
%   GETPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) returns a cell array
%   containing the values for the preferences specified by GROUP and
%   the cell array of preferences.  The return value is the same size as the
%   input cell array.  It is an error if any of the preferences do not
%   exist.
%
%   GETPREF('GROUP',{'PREF1',...'PREFn'},{DEFAULT1,...DEFAULTn})
%   returns a cell array with the current values of the preferences
%   specified by GROUP and the cell array of preference names.  Any
%   preference that does not exist is created with the specified
%   default value and returned.
%
%   GETPREF('GROUP') returns the names and values of all
%   preferences in the GROUP as a structure.
%
%   GETPREF returns all groups and preferences as a structure.
%
%   Preference values are persistent and maintain their values between
%   MATLAB sessions.  Where they are stored is system dependent.
%
%   Example:
%      addpref('mytoolbox','version',1.0)
%      getpref('mytoolbox','version')
%
%   Example:
%      getpref('mytoolbox','version',1.0);
% 
%   See also SETPREF, ADDPREF, RMPREF, ISPREF, UIGETPREF, UISETPREF

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.11 $

Preferences = prefutils('loadPrefs');
% perform all error checks appropriate to number of inputs:
% - group must be a string
% - pref must be a string or cell array
% - default must match pref in size and type
if nargin >= 1

  prefutils('checkGroup',group);

  if nargin == 2
    prefCell = prefutils('checkAndConvertToCellVector',pref);
  elseif nargin == 3
    [prefCell,defaultCell] = prefutils('checkAndConvertToCellVector',pref,default);
  end
end

  
% now produce the desired output:
switch nargin
  
 case 0
  % GETPREF: Return all prefs in all groups:
  retval = Preferences;
 
 case 1
  % GETPREF(GROUP) Return all prefs in this group
  retval = prefutils('getFieldOptional', Preferences, group);
 
 case 2
  % GETPREF(GROUP, PREF) Return this pref; error out if it doesn't exist
  Group = prefutils('getFieldRequired',Preferences,group,...
                    ['group ',group,' does not exist']);
  for i=1:length(prefCell)
     retval{i} = prefutils('getFieldRequired',Group,prefCell{i},...
            ['preference ',prefCell{i},' does not exist in group ',group]);
  end
 
 otherwise
  % GETPREF(GROUP, PREF, DEFAULT) Return this pref; set and return
  % default value if it didn't exist:
  Group = prefutils('getFieldOptional',Preferences,group);
  for i=1:length(prefCell)
     [retval{i},existed] = prefutils('getFieldOptional',Group,prefCell{i});
     if ~existed
       retval{i} = defaultCell{i};
       addpref(group, prefCell{i}, defaultCell{i});
     end
  end

end % switch

% don't return cell if input was scalar
if nargin >= 2
  if ~iscell(pref)
    retval = retval{1};
  end
end
