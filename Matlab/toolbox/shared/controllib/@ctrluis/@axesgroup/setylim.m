function setylim(h,Ylim,varargin)
%SETYLIM  Sets Y limits across rows of axes group.
%
%   SETYLIM(AXGROUP,YLIM,I) sets the Y limits to YLIM across the 
%   entire I-th row of the axes group.  The index I is relative to 
%   entire grid of axes, as returned by GETAXES(AXGROUP,'2d').
%
%   SETYLIM(AXGROUP,YLIM,[I1 I2]) sets the Y limits across the 
%   entire row specified by the integers I1 and I2, where
%   J1 is relative to the major grid (size=AXGROUP.Size(1:2)),
%   and J2 is relative to the minor grid (size=AXGROUP.Size(3:4)).
%
%   SETYLIM(...,'silent') sets the limits without triggering the 
%   limit picker (no ViewChanged event broadcasted).
%
%   SETYLIM(...,'basic') sets the limits without changing the axes
%   group's YlimMode nor triggering the limit picker.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:22 $

% Look for option flags
if nargin>2 & ischar(varargin{end})
   Option = varargin(end);
   varargin = varargin(1:end-1);
else
   Option = '';
end

% Turn off backdoor listeners
h.LimitManager = 'off';

% Get grid of HG axes
axgrid = h.Axes2d;
[nr,nc] = size(axgrid);

% Find affected rows in axes grid
if isempty(varargin)  | strcmpi(h.YLimSharing,'all')
   % Uniform Y limits for all axes
   row_index = 1:nr;
else
   row_index = varargin{1};
   % Convert 2x1 index into absolute index
   if length(row_index)==2
      row_index = (row_index(1)-1) * h.Size(3) + row_index(2);
   end
   if strcmp(h.YLimSharing,'peer')
      stride = nr/h.Size(1);
      start = rem(row_index,stride);
      row_index = start+(~start)*stride:stride:nr;
   end
end

% Error checking
if Ylim(1)<=0 & any(strcmp(h.YScale(row_index),'log'))
   error('Lower limit must be positive on log scale.')
end

% Turn off backdoor listeners and set limits
h.LimitManager = 'off';
set(axgrid(row_index,:),'Ylim',Ylim);

% Update YlimMode
if ~strcmp(Option,'basic')
   % REVISIT: replace next three when h.YlimMode(row_index) = {'manual'}; works
   YlimMode = h.YlimMode;
   YlimMode(row_index) = {'manual'};
   h.YlimMode = YlimMode;
end

% Turn backdoor listeners back on
% RE: Force HG to update X limits before turning listeners back on
get(axgrid(1,:),'Xlim'); 
h.LimitManager = 'on';

% Trigger limit update 
if isempty(Option)
   h.send('ViewChanged')  % invokes limit picker
end