function GradModel = makeGradient(this)
% Creates a gradient model for accurate gradient estimation.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:16 $
%   Copyright 1986-2003 The MathWorks, Inc.
GradModel = slcontrol.GradientModel( this.Model, this.Parameters );
set_param(GradModel.GradModel,'SignalLoggingName','GradLog')