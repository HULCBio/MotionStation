function cstrs = makeuniqcellstrs(cstrs)
%MAKEUNIQCELLSTRS Make a unique cell array of strings.
%   C = MAKEUNIQCELLSTRS(S) makes unique strings within a cell array of
%   strings, S. If identical strings are found, the repeated strings are
%   appended with a '_#' after the first occurence of the string.
%
%   EXAMPLE:
%   s = {'one','one','two','one','two','three'};
%   c = makeuniqcellstrs(s)
%   c = 
%       'one'    'one_1'    'two'    'one_2'    'two_1'    'three'

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:30 $

% unique returns the values in cstrs but with no repetitions.
c = unique(cstrs);
if (length(c) < length(cstrs)), 
    for n = 1:length(c),
        cstrs_idx = strmatch(c{n},cstrs,'exact');
        if (length(cstrs_idx) > 1), 
            cstrs = incrementvars(cstrs,cstrs_idx);
        end
    end
end

% -------------------------------------------------------------------------
function cstrs = incrementvars(cstrs, idxs)
%INCREMENTVARS Increment non-unique variable strings.

idx2incr = idxs(2:end);
for p = 1:length(idx2incr),
    cstrs{idx2incr(p)} = [cstrs{idx2incr(p)},'_',int2str(p)];
end

% [EOF]
