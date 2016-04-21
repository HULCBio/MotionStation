function nn = construct_renum(en,args)
%CONSTRUCT_ENUM  Constructor for raw memory object 
%  MM = CONSTRUCT_ENUM('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See NUMERIC)
%  -----------------
%  REPRESENT - 
%
%  See Also NUMERIC,MEMORYOBJ

% 
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $ $Date: 2003/11/30 23:10:54 $

en.label = {};
en.value = [];

% Process constructors input arguments if any
if nargin <= 1
    return;      % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['ENUM constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

% Get property / value pairs from argument list
for i = 1:2:nargs
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error('Property name must be a string entry.');
    end
    if ~isempty( strmatch(prop,{'value','label'},'exact'))
        en.(prop) = val;
        args{i} = [];
        args{i+1} = [];
    end
end

construct_rnumeric(en,args);  % Call base constructor (rest of properties ..)
convert_rnumeric(en,'int');   % by default, enum is stored as integer

% [EOF] construct_renum.m