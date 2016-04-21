function nn = construct_rnumeric(nn,args)
%CONSTRUCT_NUMERIC  Constructor for numeric object 
%  MM = CONSTRUCT_NUMERIC('PropertyName',PropertyValue,...)  Constructs an ..
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  REPRESENT - 
%
%  See Also NUMERIC,MEMORYOBJ
% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.2.2.1 $  $Date: 2003/11/30 23:11:24 $

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
    if ~isempty( strmatch( prop, {  'name'   ,'type'      , ...
                                    'storageunitspervalue'  ,'prepad'    ,'postpad'  ,'arrayorder' , ...
                                    'size' ,'represent' ,'binarypt' ,'endianness' , ...
                                 }, 'exact') )
        nn.(prop) = val;
        args{i} = [];
        args{i+1} = [];
    end
end
construct_registerobj(nn,args);  % Call base constructor

% [EOF] construct_rnumeric.m
 