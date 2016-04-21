function scale(this,factor,y0)
% Rescale constraint using y -> y0 + f * (y-y0).

%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:46:02 $
%   Copyright 1990-2004 The MathWorks, Inc.
this.LowerBoundY = factor * this.LowerBoundY + (1-factor) * y0;
this.UpperBoundY = factor * this.UpperBoundY + (1-factor) * y0;
