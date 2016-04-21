% function addrunf(fh,all)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function addrunf(fh,all)

    if nargin < 2		% might not see hidden ones though..
      all = get(0,'chi');
    end

    [a1,a2,a3,a4] = findmuw(all);
    if ~isempty(a1)
        storefig = min(a1);
        rv = gguivar('RUNNING',storefig);
        if isempty(rv)	% incommensurate array  GJW 09/10/96
            sguivar('RUNNING',[fh],storefig);
        else
            sguivar('RUNNING',[fh;rv],storefig);
        end;
    else
        error('NO MUGUIS found')
        return
    end