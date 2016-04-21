function varargout = prefutils(varargin)
% PREFUTILS Utilities used by set/get/is/add/rmpref

%   $Revision: 1.7 $  $Date: 2002/06/17 13:18:24 $
%   Copyright 1984-2002 The MathWorks, Inc.


% Switchyard: call the subfunction named by the first input
% argument, passing it the remaning input arguments, and returning
% any return arguments from it.
[varargout{1:nargout}] = feval(varargin{:});


function prefName = truncToMaxLength(prefName)
% This is necessary because SETFIELD/GETFIELD/ISFIELD/RMFIELD do
% not operate the same as dotref and dotassign when it comes to
% variable names longer than 'namelengthmax'.  Dotref/dotassign 
% do an implicit truncation, so both operations appear to work 
% fine with longer names, even though they're really paying 
% attention only to the first 31 characters.  But the *field 
% functions don't do the truncation, so GETFIELD and ISFIELD 
% and RMFIELD report errors when you pass them a longer name that
% you've just used with SETFIELD.  So the suite of pref functions 
% are using truncToMaxLength until that bug is fixed - when it is, 
% just remove this.

prefName = prefName(1:min(end, namelengthmax));


function prefFile = getPrefFile
% return name of preferences file, create pref dir if it does not exist

prefFile = [prefdir(1) filesep 'matlabprefs.mat'];


function Preferences = loadPrefs
% return ALL preferences in the file.  Return empty matrix if file
% doesn't exist, or it is empty.

prefFile = getPrefFile;
Preferences = [];
if exist(prefFile)
  fileContents = load(prefFile);
  if isfield(fileContents, 'Preferences')
    Preferences = fileContents.Preferences;
  end
end


function savePrefs(Preferences)
prefFile = getPrefFile;
save(prefFile, 'Preferences');


function [val, existed_out] = getFieldOptional(s, f)
fMax = truncToMaxLength(f);
existed = isfield(s, fMax);
if existed == 1
  val = s.(fMax);
else
  val = [];
end
if nargout == 2
  existed_out = existed;
end

function val = getFieldRequired(s, f, e)
[val, existed] = getFieldOptional(s, f);
if ~existed
  error(e);
end

function [p_out, v_out] = checkAndConvertToCellVector(pref, value)
% Pref must be a string or cell array of strings.
%   return it as a cell vector.
% Value (if passed in) must be the same length as Pref.
%   return it as a cell vector (only convert it to cell if we
%   converted Pref to cell)

if ischar(pref)
  p_out = {pref};
elseif iscell(pref)
  p_out = {pref{:}};
  for i = 1:length(p_out)
    if ~ischar(p_out{i})
      error('PREF cell array must contain strings');
    end
  end
else
  error('PREF must be a string or cell array of strings');
end

if nargin == 2
  if ischar(pref)
    v_out = {value};
  elseif iscell(value)
    v_out = {value{:}};
  else
    error('VALUE type must match PREF');
  end
  if length(v_out) ~= length(p_out)
    error('VALUE type must match PREF');
  end
end

function checkGroup(group)
% Error out if group is not a string:
if ~ischar(group)
  error('GROUP must be a string');
end
