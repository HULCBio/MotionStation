function resp = cast(en,datatype,size)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.4 $  $Date: 2003/11/30 23:07:53 $

error(nargchk(2,3,nargin));
if ~ishandle(en),
    error(generateccsmsgid('InvalidHandle'),'First Parameter must be a ENUM Handle.');
end

if ~ischar(datatype),
    error(generateccsmsgid('InvalidInput'),'Second parameter DATATYPE must be a string.');
end

if any(strcmp(en.procsubfamily,{'C6x','R1x','R2x'})),
    
	if isempty( strmatch(datatype, ...
		{   'uint8',    'int8', ...
            'uint16',   'int16', ...
            'int64',    'uint64',...
		    'char',     'unsigned char',    'signed char',...
		    'short',    'unsigned short',   'signed short',...
		    'long',     'unsigned long',    'signed long',...
		    'double',   'long double',      'long long',...
            'Q0.15' ...
		},  'exact') ),
    
       if nargin==2
           resp = cast_numeric(en,datatype);
       else
           resp = cast_numeric(en,datatype,size);
       end
    else
        error(generateccsmsgid('InvalidCastOperation'),'An enum cannot have a non-32 bit datatype.');
    end
    
elseif any(strcmp(en.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
    
	if isempty( strmatch(datatype, ...
		{   'uint8',    'int8',    ...
            'int32',    'uint32',...
            'int64',    'uint64',...
		    'long',     'unsigned long',    'signed long',...
		    'single',   'float',    'double',       ...
            'long long','long double',...
            'Q0.31' ...
		},'exact') ),
       if nargin==2
           resp = cast_numeric(en,datatype);
       else
           resp = cast_numeric(en,datatype,size);
       end
	else
        error(generateccsmsgid('InvalidCastOperation'),'An enum cannot have a non-16 bit datatype.');
	end
    
end

% [EOF] cast.m

