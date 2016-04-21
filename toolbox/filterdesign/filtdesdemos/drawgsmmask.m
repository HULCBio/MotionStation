function drawgsmmask(hfig)
%DRAWGSMMASK Utility to draw a GSM mask for the GSMDDC demo.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/04/20 23:16:43 $

if nargin < 1, hfig = gcf; end

args = {'Color',[1 0 1],'LineWidth',1,'LineStyle','--'};
line([0 100],[0 0],args{:})

line([100 100],[0 -18],args{:})

line([100 300],[-18 -18],args{:})

line([300 300],[-18 -50],args{:})

line([300 500],[-50 -50],args{:})

line([500 500],[-50 -85],args{:})

line([500 700],[-85 -85],args{:})

line([700 700],[-85 -95],args{:})

line([700 1100],[-95 -95],args{:})