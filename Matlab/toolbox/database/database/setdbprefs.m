function h = setdbprefs(p,v)
%SETDBPREFS Set preferences for database actions for handling null values.
%   SETDBPREFS(P,V) sets the preferences for database actions.  P is the 
%   list of properties to be set and V is the corresponding value list.
%
%   SETDBPREFS(P) returns the property with its current setting.
%
%   SETDBPREFS returns the property list with all current values.
%
%   The valid properties are NullNumberRead, NullNumberWrite, NullStringRead,
%   NullStringWrite, DataReturnFormat, and ErrorHandling.   The value for each 
%   property is entered as a string.
%
%   For example, the command
%
%      setdbprefs('NullStringRead','null')
%  
%   translates all NULL strings read from the database into the string
%   'null'.
%
%   The command
% 
%      setdbprefs({'NullStringRead';'NullStringWrite';'NullNumberRead';'NullNumberWrite'},...
%                 {'null';'null';'NaN';'NaN'})
%
%   translates NULL strings read into the string 'null', NULL values to NaN.  A NaN in the 
%   data written to the database is translated to a NULL and a 'null' string is translated to
%   NULL.
%
%   The command setdbprefs('DataReturnFormat','cellarray') returns the data in the cursor Data
%   field as a cell array which is the default behavior.   Other values for DataReturnFormat
%   are 'numeric' which returns the data as a matrix of doubles and 'structure' which returns
%   the data as a structure with the fieldnames corresponding to the fetched fields.
%
%   The command setdbprefs('ErrorHandling','store') returns any error messages to the object Message
%   field and will cause the next function that uses the object to return an error.   This is the default
%   behavior.   Other values for ErrorHandling are 'report' which causes any function encountering an error
%   to report the error and stop processing and 'empty' which causes the fetch command to return the cursor
%   Data field as [] when given a bad cursor object resulting from exec.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.3 $   $Date: 2004/04/06 01:05:53 $

%Set global preferences variable and initialize if empty
global DatabasePrefs

if isempty(DatabasePrefs)
  DatabasePrefs = com.mathworks.toolbox.database.databasePrefs;
end

%Build property list
prps = {'DataReturnFormat';...
    'ErrorHandling';...
    'NullNumberRead';...
    'NullNumberWrite';...
    'NullStringRead';...
    'NullStringWrite';...
  };

%Validate properties
if nargin > 0
  if ischar(p) %Convert property list to cell string array
    p = cellstr(p);
  end
  p = chkprops(DatabasePrefs,p,prps);
else
  p = prps;
end

%Return values for given properties if no values given
L = length(p);
if nargin <= 1
  for i = 1:L
    eval(['x.' p{i} '= get' p{i} '(DatabasePrefs);'])
  end
end

%Set properties to given values
if nargin == 2
  if ischar(v)  %Convert values list to cell string array
    v = cellstr(v);
  elseif ~iscellstr(v)
    error('database:setdbprefs:valueFormatNotChar','Value must be entered as character or cell string array.')
  end
  
  %Validate settings for properties with fixed value choices
  i = find(strcmp(p,'DataReturnFormat'));
  if ~isempty(i) && nargin == 2
  
    fmts = {'cellarray','numeric','structure'};
    j = find(strcmp(lower(v{i}),fmts));
    if isempty(j)
      error('database:setdbprefs:invalidDataReturnFormatValue',...
          '%s must be set to cellarray, numeric, or structure',p{:})
    end
   
  end
  
  i = find(strcmp(p,'ErrorHandling'));
    if ~isempty(i) && nargin == 2
    j = find(strcmp(lower(v{i}),{'store','report','empty'}));
    if isempty(j)
      error('database:setdbprefs:invalidErrorHandlingValue',...
          '%s must be set to store, report, or empty',p{:})
    end
  end
  
  %Set properties
  for i = 1:L
    eval(['set' p{i} '(DatabasePrefs,''' v{i} ''')'])
  end
  return
end

if nargout == 0   %Display if no output argument
  disp(' ')
  disp(x)
end

if nargout == 1   %Return structure if output argument
  if L == 1
    eval(['h = x.' p{1} ';'])
  else
    h = x;
  end
end
