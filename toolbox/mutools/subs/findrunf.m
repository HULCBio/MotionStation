% function rr = findrunf

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function rr = findrunf

    [a1,a2,a3,a4] = findmuw;
    if ~isempty(a1)
        storefig = min(a1);
        rr = gguivar('RUNNING',storefig);
    else
        error('NO MUGUIS found')
        return
    end