function resp = cast(re,datatype,size)
% CAST - Creates a copy RE, change its representation to DATATYPE and 
% optionally reshape to SIZE.
%
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.6.2 $  $Date: 2003/11/30 23:10:53 $

nargchk(2,3,nargin);
if ~ishandle(re),
    error('First Parameter must be a RENUM Handle.');
end

if any(strcmp(re.procsubfamily,{'C6x','R1x','R2x'})),

    if isempty( strmatch(datatype,      ...
		{   'uint8',        'int8',     ...
            'uint16',       'int16',    ...
            'int64',        'uint64',   ...
		    'char',         'unsigned char',    'signed char',  ...
            'short',        'unsigned short',   'signed short', ...
		    'long',         'unsigned long',    'signed long',  ...
		    'double',       'long double',      'long long'     ...
		},  'exact') ),
    
       if nargin==2
           resp = cast_rnumeric(re,datatype);
       else
           resp = cast_rnumeric(re,datatype,size);
       end
	else
        error('An enum cannot have a non-32 bit datatype.');
	end
    
elseif any(strcmp(re.procsubfamily,{'C54x','C55x','C28x'})), % C5000, C2800
    
	if isempty( strmatch(datatype, ...
		{   'uint8',        'int8',     ...
            'int32',        'uint32',   ...
            'int64',        'uint64',   ...
		    'long',         'unsigned long',    'signed long',  ...
		    'float',        ...
            'double',       'long double',      'long long'...
		},  'exact') ),
    
       if nargin==2
           resp = cast_rnumeric(re,datatype);
       else
           resp = cast_rnumeric(re,datatype,size);
       end
	else
        error('An enum cannot have a non-16 bit datatype.');
	end
    
end
        

% [EOF] cast.m

