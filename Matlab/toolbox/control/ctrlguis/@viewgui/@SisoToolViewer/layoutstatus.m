function layoutstatus(this,varargin)
% LAYOUTSTATUS  positions the status bar and text in the figure window.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/10 23:14:34 $
set(this.Figure,'Units','Character');
FigPos = get(this.Figure,'Position');

set(this.HG.StatusBar,'Units','Character',...
    'Position',[2.5 0.25 FigPos(3)-5 2.4],'Units','pixels');
set(this.HG.StatusText,'Units','Character',...
    'Position',[3.5 0.45 FigPos(3)-7 2.0],'Units','pixels');
 
% Real-time check box
set(this.HG.StatusCheckBox,'Units','Character',...
   'Position',[FigPos(3)-25 0.45 22 2.0])
set(this.Figure,'Units','pixels')    % Reset units to pixels

