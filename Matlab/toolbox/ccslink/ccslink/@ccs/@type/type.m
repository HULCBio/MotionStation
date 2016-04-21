function td = type(varargin)
% TYPE Constructor for Type object.

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/01 16:03:54 $

td = ccs.type;

td = constructType(td,varargin);

p_specialTIDatatypes(td); % add special TI data types

%--------------------------------------------------------------------------
% Process constructor's input arguments, if any
function td = constructType(td,args)

nargs = length(args);

if nargs <= 1
    error('Cannot create Type object without board and proc number.');
else
    
    if(mod(nargs,2)~=0)
        error(['Type constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
    end
    % 'boardproc' & 'apiversion' MUST always be passed
    props = {args{1:2:end}};
    if iscellstr(props)
        if isempty(strmatch('boardproc',props,'exact')) || ...
           isempty(strmatch('apiversion',props,'exact'))
            error(['Cannot create Type object without specifying the ',...
                '''boardproc'' and ''apiversion'' values.']);
        end
    else
        error(['Cannot create Type object: property must be string.']);
    end
        

    % Get property / value pairs from argument list
    for i = 1:2:nargs
        prop = lower(args{i});
        val  = args{i+1};

        % Argument checking
        switch prop
            case 'boardproc'
                if ~isa(val,'double') & length(val) ~= 2  ,
                    error('Cannot create Type object without board and proc number ');
                end
                td.boardnum =  val(1);
                td.procnum  =  val(2);
            case 'apiversion'
                td.ccsversion = p_createCCSVersionObj(val);
            otherwise
                error('Unknown property specified for Type object.')
        end
    end

end

% [EOF] type.m