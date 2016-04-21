function varargout = scanstr(obj,varargin)
%SCANSTR Parse formatted data from instrument.
% 
%   A = SCANSTR(OBJ) reads formatted data from the instrument connected 
%   to interface object, OBJ and parses the data using both a comma and 
%   a semicolon delimiter and returns to cell array, A. Each element of  
%   the cell array is determined to be either a double or a string.
%
%   A = SCANSTR(OBJ, 'DELIMITER') reads data from the instrument connected 
%   to interface object, OBJ, and parses the string into separate variables 
%   based on the DELIMITER string and returns to cell array, A. The DELIMITER
%   can be a single character or a string array. If the DELIMITER is a string
%   array then each character in the array is used as a delimiter. By default, 
%   a comma and a semicolon DELIMITER is used. Each element of the cell array
%   is determined to be either a double or a string.
%
%   A = SCANSTR(OBJ, 'DELIMITER', 'FORMAT') reads data from the instrument 
%   connected to interface object, OBJ, and converts it according to the
%   specified FORMAT string. A may be a matrix or a cell array depending
%   on FORMAT. See the TEXTREAD on-line help for complete details.
%
%   FORMAT is a string containing C language conversion specifications. 
%   Conversion specifications involve the character % and the conversion 
%   characters d, i, o, u, x, X, f, e, E, g, G, c, and s. See the SSCANF
%   file I/O format specifications or a C manual for complete details.
%
%   If the FORMAT is not sepcified then the best format, either a double
%   or a string, is chosen.
%
%   [A,COUNT]=SCANSTR(OBJ,...) returns the number of values read to COUNT.
%
%   [A,COUNT,MSG]=SCANSTR(OBJ,...) returns a message, MSG, if SCANSTR
%   did not complete successfully. If MSG is not specified a warning is 
%   displayed to the command line. 
%
%   OBJ's ValuesReceived property will be updated by the number of values
%   read from the instrument including the terminator.
% 
%   If OBJ's RecordStatus property is configured to on with the RECORD
%   function, the data received will be recorded in the file specified
%   by OBJ's RecordName property value.
%
%   Example:
%       g = gpib('ni', 0, 2);
%       fopen(g);
%       fprintf(g, '*IDN?');
%       idn = scanstr(g, ',');
%       fclose(g);
%       delete(g);
%
%   See also ICINTERFACE/FOPEN, ICINTERFACE/FSCANF, ICINTERFACE/RECORD, 
%   INSTRHELP, SSCANF, STRREAD, TEXTREAD.
%

%   MP 11-18-00
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2004/01/16 20:00:45 $

% Error checking.
if nargout > 3
   error('instrument:scanstr:invalidSyntax', 'Too many output arguments.');
end  

if ~isa(obj, 'icinterface')
   error('instrument:scanstr:invalidOBJ', 'OBJ must be an interface object.');
end	

if length(obj)>1
    error('instrument:scanstr:invalidOBJ', 'OBJ must be a 1-by-1 interface object.');
end

% Parse the input.
switch nargin
case 1
    delimiter = ',;';
    format = '%s';
case 2
    delimiter = varargin{1};
    format = '%s';
case 3
    [delimiter, format] = deal(varargin{1:2});
otherwise
    error('instrument:scanstr:invalidSyntax', 'Too many input arguments.');
end

% Error checking.
if ~ischar(delimiter)
    error('instrument:scanstr:invalidDELIMITER', 'DELIMITER must be a string.');
end

if ~ischar(format)
    error('instrument:scanstr:invalidFORMAT', 'FORMAT must be a string.');
end

% Read the data.
[data, count, msg] = fscanf(obj, '%c');
varargout = cell(1,3);

if isempty(data)
    varargout{1} = data;
    varargout{2} = count;
    varargout{3} = msg;
else    
	% Parse the data.
    try
    	out=strread(data,format,'delimiter',delimiter);
		
        if nargin < 3
            for i = 1:length(out)
                if ~isnan(str2double(out{i}))
                    out{i} = str2double(out{i});  
                end
            end
		end
    catch
        out = data;
        msg = lasterr;
    end
	
	varargout{1} = out;
	varargout{2} = count;
	varargout{3} = msg;
end

% Warn if the MSG output variable is not specified.
if (nargout ~= 3) && ~isempty(varargout{3})
    % Store the warning state.
    warnState = warning('backtrace', 'off');

    warning('instrument:scanstr:unsuccessfulRead', varargout{3});
    
    % Restore the warning state.
    warning(warnState);
end




