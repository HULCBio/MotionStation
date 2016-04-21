function nn = construct_structure(ns,args)
%STRUCT  Constructor for raw memory object 
%  MM = STRUCT('PropertyName',PropertyValue,...)  Constructs an ..
%
%  Major Properties (See MEMORYOBJ)
%  -----------------
%  Field Names - Description 
%
%  See Also CAST, READ, WRITE.

% 
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $ $Date: 2004/04/08 20:47:06 $

% Process constructors input arguments if any
% Defaults
ns.size = 1;
ns.address = [0 0];           % Offset = 0, Page = 0
ns.storageunitspervalue = 1;
ns.link = [];
ns.member = struct([]);
ns.membnumber = 0;
ns.membname = 0;


if nargin <= 1
    return;      % Use defaults
end
nargs = length(args);

if(mod(nargs,2)~=0)
    error(['STRUCTURE constructor requires property and value ', ...
            'arguments to be specified in pairs.']);
end

%structP = findpackage('ccs');
% structC = structP.findclass('structure');

% Get property / value pairs from argument list
for i = 1:2:nargs,
    prop = lower(args{i});
    val  = args{i+1};
    
    % Argument checking
    if isempty(prop)  % ignore nulls
        continue;
    elseif ~ischar(prop),
        error('Property Name must be a string entry');
    end
    if ~isempty( strmatch(prop,{'name','address','storageunitspervalue','link','size','member'},'exact')),
        ns.(prop) = val;
        args{i}   = [];
        args{i+1} = [];
    else
        error(['Unknown property ''' prop ''' specified for STRUCTURE object.'])
    end
end

ns.memboffset = getprop(ns.member,'containerobj_memboffset');
ns.membname   = getprop(ns.member,'containerobj_membname');

% This avoid the (slow) call to create the object until necessary
function fetchobj(h, eventData)

if isempty(h.(get(eventData.Source, 'Name'))),
    set(h, get(eventData.Source, 'Name'), 'link');
end
% [EOF] construct_structure.m
 