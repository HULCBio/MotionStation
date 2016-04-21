function nn = construct_rstring(nn,args)
%CONSTRUCT_RTSRING  Constructor for register string object 
% Copyright 2002-2003 The MathWorks, Inc.

%   $Revision: 1.4.4.1 $  $Date: 2003/11/30 23:12:08 $

% Process constructors input arguments if any
nn.charconversion = 'ASCII';

if nargin <= 1,
    return; % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['RSTRING constructor requires property and value ', ...
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

% Call super class
construct_rnumeric(nn,args);  % Call base constructor

% [EOF] construct_rstring.m 