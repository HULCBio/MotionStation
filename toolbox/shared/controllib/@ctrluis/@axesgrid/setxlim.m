function setxlim(h,Xlim,varargin)
%SETXLIM  Sets X limits across columns of axes group.
%
%   SETXLIM(AXGROUP,XLIM,J) sets the X limits to XLIM across the 
%   J-th column of the axes group.  The index J is relative to 
%   entire grid of axes, as returned by GETAXES(AXGROUP,'2d').
%
%   SETXLIM(AXGROUP,XLIM,[J1 J2]) sets the X limits across the 
%   entire column specified by the integers J1 and J2, where
%   J1 is relative to the major grid (size=AXGROUP.Size(1:2)),
%   and J2 is relative to the minor grid (size=AXGROUP.Size(3:4)).
%
%   SETXLIM(...,'silent') sets the limits without triggering the 
%   limit picker (no ViewChanged event broadcasted).
%
%   SETXLIM(...,'basic') sets the limits without changing the axes
%   group's XlimMode nor triggering the limit picker.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:56 $

%REVISIT: Call parent method when possible to do all work except
%         AxesGrouping related tweaks (see line 39)

% Look for option flags
if nargin>2 & ischar(varargin{end})
   Option = varargin(end);
   varargin = varargin(1:end-1);
else
   Option = '';
end

% Get grid of HG axes
axgrid = h.Axes2d;
[nr,nc] = size(axgrid);

% Find affected columns in axes grid
if isempty(varargin) | strcmp(h.XLimSharing,'all') | any(strcmp(h.AxesGrouping,{'all' 'column'}))
   % Uniform X limits for all axes
   col_index = 1:nc;
else
   col_index = varargin{1};
   % Convert 2x1 index into absolute index
   if length(col_index)==2
      col_index = (col_index(1)-1) * h.Size(4) + col_index(2);
   end
   if strcmp(h.XLimSharing,'peer')
      stride = h.Size(4);
      start = rem(col_index,stride);
      col_index = start+(~start)*stride:stride:nc;
   end
end   

% Error checking
if Xlim(1)<=0 & any(strcmp(h.XScale(col_index),'log'))
   error('Lower limit must be positive on log scale.')
end

% Turn off backdoor listeners and set limits
h.LimitManager = 'off';
set(axgrid(:,col_index),'Xlim',Xlim);

% Update XlimMode  
if ~strcmp(Option,'basic')
   % REVISIT: replace next three when h.XlimMode(col_index) = {'manual'}; works
   XlimMode = h.XlimMode;
   XlimMode(col_index) = {'manual'};
   h.XlimMode = XlimMode;
end

% Turn backdoor listeners back on
% RE: Force HG to update Y limits before turning listeners back on, otherwise auto Y
%     update triggers listener and switches YlimMode to manual for other axes in column
get(axgrid(:,1),'Ylim');  
h.LimitManager = 'on';

% Trigger limit update 
if isempty(Option)
   h.send('ViewChanged')  % invokes limit picker
end

