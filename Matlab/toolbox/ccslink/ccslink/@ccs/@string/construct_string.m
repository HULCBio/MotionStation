function nn = construct_string(nn,args)
%   Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2003/11/30 23:12:47 $

% Process constructors input arguments if any
nn.charconversion = 'ASCII';

if nargin <= 1,
    return;      % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['STRING constructor requires property and value ', ...
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
    
    if ~isempty( strmatch(prop,{'charconversion'},'exact'))
        nn.(prop) = val;
        args{i}   = [];
        args{i+1} = [];
    end
end

construct_numeric(nn,args);  % Call base constructor
convert(nn,'char');

% [EOF] construct_string.m 