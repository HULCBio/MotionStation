function line = addline(obj, hwline, varargin)
%ADDLINE Add lines to a digital I/O object.
% 
%    LINES = ADDLINE(OBJ,HWLINE,DIRECTION) adds an array of lines, the
%    length of vector HWLINE, to digital I/O object OBJ.  The lines are
%    assigned to the hardware lines specified in vector HWLINE.  The 
%    line array is returned to LINES.  OBJ must be 1-by-1.  DIRECTION 
%    specifies the line direction and can be either 'In' or 'Out'.  
%    If multiple lines are added, DIRECTION can be either a single 
%    direction in which case all lines added will have the same 
%    direction or DIRECTION can be a cell string array with the same
%    length as HWLINE.  By default, lines are added from port 0.
% 
%    LINES = ADDLINE(OBJ,HWLINE,PORT,DIRECTION) adds an array of lines 
%    to the specified PORT of digital I/O object, OBJ.  PORT can be a 
%    single port value or an array of ports.
%
%    LINES = ADDLINE(OBJ,HWLINE,DIRECTION,NAMES)
%    LINES = ADDLINE(OBJ,HWLINE,PORT,DIRECTION,NAMES) adds an array of 
%    lines to the digitalio object, OBJ, with the names, NAMES.  If a 
%    single line is added, NAMES can be either a cell string array or a 
%    string.  If multiple lines are added, NAMES can be either a single 
%    name in which case all lines added will have the same name or NAMES 
%    can be a cell string array with the same length as HWLINE.
%
%    Line objects are added to the digital I/O device object sequentially.
%    Each line is addressable by its position in the list (Index property
%    value), or optionally by its name (LineName property value).
%
%    The first line indexed in the line group represents the least 
%    significant bit (LSB), and the highest indexed line represents
%    the most significant bit (MSB).
%
%    In a single call to ADDLINE, multiple lines can be added from one 
%    port or the same line ID can be added from multiple ports.  Multiple
%    lines from multiple ports cannot be added with one call to ADDLINE.
%
%    Example:
%       hline = addline(dio, 0:7, 'In');
%       hline = addline(dio, 1, 1:2, 'Out');
%       hline = addline(dio, [0 4], {'In', 'Out'});
%       hline = addline(dio, 6:7, 2, 'Out', {'Line1';'Line2'});
%
%    See also DIGITALIO, GETVALUE, PUTVALUE, BINVEC2DEC, DEC2BINVEC,
%    DAQHELP.
%

%    MP 2-19-99
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.4 $  $Date: 2003/08/29 04:41:35 $

% ADDLINE does not accept device arrays.
if length(obj) > 1
   error('daq:addline:invalidobject', 'OBJ must be a 1-by-1 digital I/O object.');
end

% Error if an invalid object was passed.
if ~isvalid(obj)
   error('daq:addline:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Initialize variables.
name = [];
port = [];
nameflag = 0;

% Parse the input.
switch nargin
case 1
   % addline(obj)
   error('daq:addline:argcheck', 'Not enough input arguments. HWLINE and DIRECTION must be defined.');
case 2
   % addline(obj, 1)
   error('daq:addline:argcheck', 'Not enough input arguments. DIRECTION must be defined.');
case 3
   % addline(obj, 1, 'in')
   direction = varargin{1};
case 4
   % addline(obj, 1, 0, 'in'); or addline(obj, 1, 0, {'in'});
   % addline(obj, 1, 'in', 'Sydney');
   if ischar(varargin{1}) || iscell(varargin{1})
      [direction, name] = deal(varargin{:});
      nameflag = 1;
   elseif isnumeric(varargin{1})
      [port, direction] = deal(varargin{:});
   else
      error('daq:addline:argcheck', 'Invalid input argument. PORT must be a double.');
   end
case 5
   % addline(obj, 1, 0, 'in', 'Sydney');
   [port, direction, name] = deal(varargin{:});
   nameflag = 1;
end

% Error if an invalid HWLINE was passed.
if ~isa(hwline, 'double') || isempty(hwline)
   error('daq:addline:invalidhwline', 'An invalid HWLINE was specified. HWLINE must be a double.');
end

% Error if multiple ports and multiple lines are added with one call
% to addline.
if length(hwline) > 1 && length(port) > 1
   error('daq:addline:invalidhwline', 'In a single call to ADDLINE, multiple lines can be added from\none port or the same line ID can be added from multiple ports.')
end

% Determine the port if not specified.
if isempty(port)
    % Get the port structure.
	
	totalLines = daqhwinfo(obj, 'TotalLines')-1;

% Check the limits.
	if max(hwline) > totalLines;
   		error('daq:addline:invalidhwline', 'Unable to set ''HwLine'' above its maximum value of %s.' , num2str(totalLines));
	end
	port=0;  %daqmex will take care of assigning the ports
end

% Error if direction is not a string or a cell array of strings.
if ~(ischar(direction) || iscellstr(direction)) || (isempty(direction)) 
   error('daq:addline:invaliddirection', 'An invalid DIRECTION value was specified.  DIRECTION must be either ''In'' or ''Out''.');
end

% Error if DIRECTION is not an array of strings.
if iscell(direction) && length(direction)~=prod(numel(direction))
   error('daq:addline:invaliddirection', 'DIRECTION must be a 1-D array of cell strings.')
end

% If a single direction is given convert it to a cell.
if ischar(direction)
   direction = {direction};
end

% Error if the number of directions provided does not equal the number of
% hardware ids specified (if more than one direction is supplied).
if length(direction) > 1 && (length(direction) ~= (length(hwline)*length(port)))
   error('daq:addline:invaliddirection', 'Invalid number of DIRECTIONs provided for the number of lines\nspecified by HWLINE and/or PORT.');
end

% Error if direction is not 'in' or 'out'.
if sum(ismember(lower(direction), {'in', 'out', 'i', 'o', 'ou'})) ~= length(direction)   
   error('daq:addline:invaliddirection', 'An invalid DIRECTION value was specified.  DIRECTION must be either ''In'' or ''Out''.');
end

% Error if the name is not a string or a cell array of strings.
if nameflag
   if ~(ischar(name) || iscellstr(name)) || (iscell(name) && isempty(name))
      error('daq:addline:invalidname', 'An invalid NAMES value was specified.  NAMES must be a string or cell array of strings.');
   end
end

% Error if NAMES is not an array of strings.
if iscell(name) && length(name)~=prod(numel(name)),
   error('daq:addline:invalidname', 'NAMES must be a 1-D array of cell strings.')
end

% If a single name is given convert it to a cell.
if ischar(name)
   name = {name};
end

% Error if the number of names provided does not equal the number of
% hardware ids specified (if more than one name is supplied).
if length(name) > 1 && (length(name) ~= (length(hwline)*length(port)))
   error('daq:addline:invalidname', 'Invalid number of NAMES provided for the number of lines\nspecified by HWLINE and/or PORT.');
end

% Create the line objects.  
line={};
lineindex = [];

for j = 1:length(port)
   for i = 1:length(hwline)
      try
         % Create the line cell array.
         linei = daqmex(obj, 'dioline', hwline(i), port(j));
         line = [line; {linei}];
         
         % Store what indices have been added
         lineindex = [lineindex daqmex(linei, 'get', 'Index')];
         
         % Assign the direction.
         daqmex(linei, 'set', 'Direction', direction{1});
         if length(direction) > 1
            direction(1) = [];
         end
         
         % Assign the name to the line if one was supplied.
         if ~isempty(name) 
            daqmex(linei, 'set', 'LineName', name{1});
            if length(name) > 1
               name(1) = [];
            end
         end
 
      catch
         % Delete any lines that may have been added and then error.
         if ~isempty(lineindex)
            delchan = get(obj, 'Line');
            delete(delchan(lineindex))
         end      
         error('daq:addline:unexpected', lasterr);
      end
   end
end

% Construct the line array from line cell array.
line = [line{:}]';

