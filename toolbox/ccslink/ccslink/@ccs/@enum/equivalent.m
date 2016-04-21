function resp = equivalent(en,lorv)
%EQUIVALENT Get numeric equivalent of enum label and vice versa.
%   Copyright 2001-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.2 $ $Date: 2004/04/08 20:46:00 $

if ischar(lorv),
    resp = conversion_elem(lorv,en);
elseif isnumeric(lorv),
    resp = conversion_elem(lorv,en);
elseif iscellstr(lorv),
    resp = [];
    for ic = 1:prod(size(lorv)),
        resp(end+1) = conversion_elem(lorv{ic},en);
    end
    resp = reshape(resp,size(lorv));
else
    error('Enumerated types must be either string or numeric values.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
% converts a single element (numeric value or label)
function resp = conversion_elem(lorv,en),
if isnumeric(lorv),
    % same numeric class as en.value ??
    if ~strcmp(class(lorv), class(en.value) ),
        nclass = class(en.value) % convert input to class of en.value
        eval(['cval =' nclass '(' lorv ');']);
    else
        cval = lorv;   % direct compare OK ?
    end
    resp = [];
    nvals = prod(size(cval));
    for iv = 1:nvals,
        v = cval(iv);
        ilab = find(v==en.value);
        if isempty(ilab),
            warning(['Input value ''' num2str(double(v)) ''' does not match any defined enumerated label.']);
            resp{end+1} = '';
        else
            resp{end+1} = en.label{ilab};
        end
    end
    if size(lorv) == 1,
        resp = resp{:};
    else
        resp = reshape(resp,size(lorv));
    end
elseif ischar(lorv),
    ilab = strmatch(lorv,en.label,'exact');
    if isempty(ilab),
        warning(['Input label ''' lorv ''' does not match any defined enumerated value.']);
        resp = [];
    else
        resp = en.value(ilab);
    end
else
    error('Enumerated types must be either a string or a numeric value');
end

% [EOF] equivalent.m
