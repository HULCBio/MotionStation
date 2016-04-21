function optlims(Editor)
%OPTLIMS  Calculates and stores the optimum X/Y limits for Nichols plot.

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/10/04 20:06:59 $

% Determine desirable limits for Nichols plot
[Editor.XlimOpt, Editor.YlimOpt] = ...
   niclims('frame', Editor.Phase, Editor.Magnitude, 'deg', 'abs');
