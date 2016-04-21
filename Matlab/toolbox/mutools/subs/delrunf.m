% function delrunf(all)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function delrunf(all)

    if nargin < 1               % might not see hidden ones though..
      all = get(0,'chi');
    end

    [a1,a2,a3,a4] = findmuw(all);
    if ~isempty(a1)
        storefig = min(a1);
        rv = gguivar('RUNNING',storefig);
        lrv = length(rv);
        sguivar('RUNNING',rv(2:lrv),storefig);
    else
        error('NO MUGUIS found')
        return
    end