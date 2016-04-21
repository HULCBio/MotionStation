function conn = conndef(num_dims,type)
%CONNDEF Default connectivity array.
%   CONN = CONNDEF(NUM_DIMS,TYPE) returns the connectivity array defined
%   by TYPE for NUM_DIMS dimensions.  TYPE can have either of the
%   following values:
%
%       'minimal'    Defines a neighborhood whose neighbors are touching
%                    the central element on an (N-1)-dimensional surface,
%                    for the N-dimensional case.
%
%       'maximal'    Defines a neighborhood including all neighbors that
%                    touch the central element in any way; it is
%                    ONES(REPMAT(3,1,NUM_DIMS)). 
%
%   Several Image Processing Toolbox functions use CONNDEF to create the
%   default connectivity input argument.
%
%   Example
%   -------
%       conn2 = conndef(2,'min')
%       conn3 = conndef(3,'max')

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2003/08/01 18:08:41 $

% I/O spec
% -------------
% Exactly two inputs required
%
% num_dims - a scalar integer >= 2.
% type - either 'minimal' or 'maximal', case-insensitive,
%        abbreviations OK.
%
% conn - connectivity

error(nargchk(2,2,nargin,'struct'))

if ~ischar(type)
    eid = 'Images:conndef:expectedString';
    error(eid, '%s', 'TYPE must be a string.');
end

if ~isnumeric(num_dims) | (prod(size(num_dims)) ~= 1)
    eid = 'Images:conndef:invalidNumDims';
    error(eid, '%s', 'NUM_DIMS must be a scalar integer >= 2.');
end
num_dims = double(num_dims);
if (num_dims ~= round(num_dims)) | (num_dims < 2)
    eid = 'Images:conndef:invalidNumDims';
    error(eid, '%s', 'NUM_DIMS must be a scalar integer >= 2.');
end

allowed_strings = {'minimal','maximal'};
idx = strmatch(lower(type),allowed_strings);
if isempty(idx)
    eid = 'Images:conndef:unrecognizedType';
    error(eid, 'Unrecognized TYPE string: %s', type);
elseif length(idx) > 1
    eid = 'Images:conndef:ambiguousType';
    error(eid, 'Ambiguous TYPE string: %s', type);
else
    type = allowed_strings{idx};
end

switch type
  case 'minimal'
    conn = zeros(repmat(3,1,num_dims));
    conn((end+1)/2) = 1;
    idx = repmat({2},1,num_dims);
    for k = 1:num_dims
        idx{k} = 1;
        conn(idx{:}) = 1;
        idx{k} = 3;
        conn(idx{:}) = 1;
        idx{k} = 2;
    end
    
  case 'maximal'
    conn = ones(repmat(3,1,num_dims));
    
  otherwise
    eid = 'Images:conndef:unexpectedType';
    error(eid, '%s', 'Internal error: unexpected TYPE string.');
end


