function y = cminfo(varargin)
%CMINFO Information about configuration managers defined in this file.
%   A new configuration manager is defined by including its name in 
%   in "allCMSupported" function and by creating a new AllInfo function.
%   
%   CMINFO('All') returns all configuration managers defined.
%   CMINFO('RCS') returns the tags for RCS configuration manager.
%   CMINFO('Tags', currentSystem) returns tags for the current installed 
%      configuration manager, specified in the "ConfigurationManager" 
%      property of the root block diagram. 
%
%   CMINFO('Fields', currentSystem) returns fields for the current 
%      installed configuration manager specified in the "ConfigurationManager"
%      property of the root block diagram. 
%
%   CMINFO('Separators', currentSystem) returns the separators of 
%      the value given by a tag. For RCS, Visual Source Safe, and
%      PVCS, the separators are ':' and '$'.
%      
%   CMINFO('Commands', currentSystem) returns the commands to check in 
%      and out.
%      
%   CMINFO('RCS', 'AllInfo') returns all the information provided when a 
%      configuration manager was defined.

% Copyright 1984-2000 The MathWorks, Inc. 
% $Revision: 1.12 $

  switch nargin
  case 0
    action = 'all';
    currentSystem = bdroot(gcs);
    
  case 1
    action = varargin{1};
    currentSystem = '';
    
  otherwise
    action = varargin{1};
    currentSystem = bdroot(varargin{2});
    
  end
  
  % 
  % get the CM in case that currentSystem is not empty
  %
  CM = '';
  if ~isempty(currentSystem)
	CM = get_param(currentSystem, 'ConfigurationManager');
  end
  % If cm is empty then get the one as registered in the preferences.
  if (isempty(CM))
      CM = cmopts;
  end
  
  action(1) = upper(action(1));
  switch action
  case 'All'
    y = allCMSupported;
    
  case {'Fields', 'Separators', 'Commands'}
    y  = getCMData(CM, action);

  case 'Tags'
    y = getCMData(CM, 'Fields');
    if ~isempty(y)
      y = y(:, 1);
    end
    
  otherwise
    % 
    % action may be a config manager's name
    %
    y = getCMData(action, 'AllInfo');  
    if isempty(y)
      y.fields = [];
      y.separators = [];
      y.commands = [];
    end
    
  end
  
return  % cminfo

% ==============================================================
function y = getCMData(CM, field)
% Returns the configuration manager data requested by field.
% Field can be 'AllInfo', 'Fields', 'Separators', 'Commands'

  CM = lower(CM);  % make it case insensitive

  if isempty(CM) | strcmpi(CM, 'none')
    CM = 'none';
    y = '';
    return;
  end
  
  % 
  % check to see if CM is in allCMSupported list
  %
  CMInList = find(strcmpi(allCMSupported, CM));
  if isempty(CMInList)
    % 
    % installed CM is not in the list, so we do not know how to get its data.
    % The calling function must handle this situation
    %
    y = ''; 
  else
    if findstr(CM, 'rcs')
      y = rcsAllInfo;
    elseif findstr(CM, 'sourcesafe')
      y = msvsAllInfo;
    elseif findstr(CM, 'pvcs')
      y = pvcsAllInfo;
    end
    
    switch field
    case 'AllInfo'
      
    case 'Fields'
      y = y.fields;
      
    case 'Separators'
      y = y.separators;
      
    case 'Commands'
      y = y.commands;
      
    end
  end
  
return  % getCMData

% ==============================================================
%                            R C S
% ==============================================================
function y = rcsAllInfo
% Returns all data for RCS

  y.fields = {'Author',    ['$' 'Author: $'],     ''; ...
              'Date',      ['$' 'Date: $'],       ''; ...
              'Revision',  ['$' 'Revision: $'],   ''; ...
              'Header',    ['$' 'Header: $'],     ''; ...
              'Id',        ['$' 'Id: $'],         ''; ...
              'Locker',    ['$' 'Locker: $'],     ''; ...
              'RCSfile',   ['$' 'RCSfile: $'],    ''; ...
              'Source',    ['$' 'Source: $'],     ''; ...
              'State',     ['$' 'State: $'],      ''};
          
  y.separators.startValue = ':';
  y.separators.endValue   = '$';
  
  % not used in this release
  y.commands.checkin  = 'ci';
  y.commands.checkout = 'co';
  y.commands.lock     = '-l'; 
  y.commands.unlock   = '-u';
  
return  % rcsAllInfo

% ==============================================================
%                            M S V S
% ==============================================================
function y = msvsAllInfo
% Returns all data for Visual Source Safe
  
  y.fields = {'Author',    ['$' 'Author: $'],     ''; ...
              'Date',      ['$' 'Date: $'],       ''; ...
              'Revision',  ['$' 'Revision: $'],   ''; ...
              'Archive',   ['$' 'Archive: $'],    ''; ...
              'Header',    ['$' 'Header: $'],     ''; ...
              'Logfile',   ['$' 'Logfile: $'],    ''; ...
              'Modtime',   ['$' 'Modtime: $'],    ''; ...
              'WorkFile',  ['$' 'Workfile: $'],   ''; ...
              'JustDate',  ['$' 'JustDate: $'],   ''};
          
  y.separators.startValue = ':';
  y.separators.endValue   = '$';
  
  % not used in this release
  y.commands.checkin  = 'ci';
  y.commands.checkout = 'co';
  y.commands.lock     = '-l'; 
  y.commands.unlock   = '-u';
  
return  % msvsAllInfo

% ==============================================================
%                            P V C S
% ==============================================================
function y = pvcsAllInfo
% Returns all data for PVCS

  y.fields = {'Author',    ['$' 'Author: $'],     ''; ...
              'Revision',  ['$' 'Revision: $'],   ''; ...
              'Modtime',   ['$' 'Modtime: $'],    ''; ...
              'Archive',   ['$' 'Archive: $'],    ''; ...
              'Header',    ['$' 'Header: $'],     ''; ...
              'WorkFile',  ['$' 'Workfile: $'],   ''};
          
  y.separators.startValue = ':';
  y.separators.endValue   = '$';
  
  % not used in this release
  y.commands = [];
  
return  % pvcsAllInfo

% ====================================================
function y = allCMSupported
% Returns all configuration managers defined

  y = {'None'; 'RCS'; 'Microsoft Visual SourceSafe'; 'PVCS (Merant)'};
  
return  % allCMSupported

% ==============================================================

