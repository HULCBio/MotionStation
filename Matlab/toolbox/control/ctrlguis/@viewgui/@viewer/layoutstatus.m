function layoutstatus(this,varargin)
% LAYOUTSTATUS  positions the status bar and text in the figure window.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/04 15:19:24 $

set(this.Figure,'Units','Character');
FigPos = get(this.Figure,'Position');
set(this.HG.StatusBar,'Units','Character',...
    'Position',[2.5 0.25 FigPos(3)-5 2.4],'Units','pixels');
set(this.HG.StatusText,'Units','Character',...
    'Position',[3.5 0.45 FigPos(3)-7 2.0],'Units','pixels');
set(this.Figure,'Units','pixels')    % Reset units to pixels

