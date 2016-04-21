%DNG_GAUGEWINDOW Figure window containing a gauge.
%   This is a helper function designed exclusively for use by
%   the dng_offblock documentation example.

% Copyright 1998-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/06/17 11:59:21 $

f = figure;
h = actxcontrol('mwagauge.agaugectrl.1', [100 100 100 100], f);
