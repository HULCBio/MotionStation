function fixdng
% FIXDNG Fix the incorrect scaling in Gauges blocks.
%
%   This function will need to be run only once.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/08 21:04:14 $

open_system('gaugeslibv1')
set_param('gaugeslibv1','Lock','off')
set_param('gaugeslibv1/ActiveX Control','MaskSelfModifiable','off')
close_system('gaugeslibv1',1)
