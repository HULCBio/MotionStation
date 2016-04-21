function updatelims(this)
%UPDATELIMS  Custom limit picker for time plots.
%
%  UPDATELIMS(H) implements a custom limit picker for time plots. 
%  This limit picker
%     1) Computes an adequate X range from the data or source
%     2) Computes common Y limits across rows for axes in auto mode.

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:13 $

AxesGrid = this.AxesGrid;
% Update X range by merging time Focus of all visible data objects.
% RE: Do not use SETXLIM in order to preserve XlimMode='auto'
% REVISIT: make it unit aware
ax = getaxes(this);  % takes I/O grouping into account
AutoX = strcmp(AxesGrid.XLimMode,'auto');
if any(AutoX)
   set(ax(:,AutoX),'Xlim',getfocus(this));
end

if strcmp(AxesGrid.YNormalization,'on')
   % Reset auto limits to [-1,1] range
   set(ax(strcmp(AxesGrid.YLimMode,'auto'),:),'Ylim',[-1.1 1.1])
else
   % Update Y limits
   AxesGrid.updatelims('manual',[])
end
