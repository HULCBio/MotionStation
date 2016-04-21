function en = convert(en,datatype,size)
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.8.6.3 $  $Date: 2004/04/08 20:45:58 $

nargchk(2,3,nargin);
if ~ishandle(en),
    error('First Parameter must be a ENUM Handle.');
end

if any(strcmp(en.procsubfamily,{'C6x','R1x','R2x'})),
    
	if isempty( strmatch(datatype, ...
		{   'uint8',    'int8', ...
            'uint16',   'int16', ...
            'int64',    'uint64',...
		    'char',     'unsigned char',    'signed char',...
		    'short',    'unsigned short',   'signed short',...
		    'long',     'unsigned long',    'signed long',...
		    'double',   'long double',      'long long'...
		},  'exact') ),
    
       if nargin==2
           convert_numeric(en,datatype);
       else
           convert_numeric(en,datatype,size);
       end
    else
        error('An enum cannot have a non-32 bit datatype.');
    end
    
elseif any(strcmp(en.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
    
	if isempty( strmatch(datatype, ...
		{   'uint8',    'int8',    ...
            'int32',    'uint32',...
            'int64',    'uint64',...
		    'long',     'unsigned long',    'signed long',...
		    'float',    'double',       ...
            'long long',    'long double'...
		},'exact') ),
       if nargin==2
           convert_numeric(en,datatype);
       else
           convert_numeric(en,datatype,size);
       end
	else
        error('An enum cannot have a non-16 bit datatype.');
	end
    
end

% [EOF] CONVERT.M

