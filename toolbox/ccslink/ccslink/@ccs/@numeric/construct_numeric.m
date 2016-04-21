function nn = construct_numeric(nn,args)
%CONSTRUCT_NUMERIC  Constructor for raw memory object 
%  MM = CONSTRUCT_NUMERIC('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  REPRESENT - 
%
%  See Also NUMERIC,MEMORYOBJ

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.2 $ $Date: 2004/04/08 20:46:37 $

% Process constructors input arguments if any
if nargin <= 1,
    return;      % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['NUMERIC constructor requires property and value ', ...
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
        error('Property Name must be a string entry');        
    end
    if ~isempty( strmatch(prop,{'name','storageunitspervalue','prepad','postpad','arrayorder','endianness','size','represent','binarypt'},'exact'))
        nn.(prop) = val;
        args{i} = [];
        args{i+1} = [];
    end
end
construct_memoryobj(nn,args);  % Call base constructor

% should be done in schema, but this seems to work

%p = findprop(findclass(findpackage('ccs'),'numeric'), 'size'); % Should really be a double vector (soon!) 
%p.SetFunction = @checkerforsize;

%p = findprop(findclass(findpackage('ccs'),'numeric'), 'storageunitspervalue'); % Should really be a double vector (soon!) 
%p.SetFunction = @checkerforsuperval;

% [EOF] construct_numeric.m
 