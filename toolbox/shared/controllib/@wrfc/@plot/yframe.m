function yframe(this,r)
%YFRAME  Adjust Y limits to keep Y data in focus.
%
%  Used for fast limit adjustment during real-time plot updating.

%  Author(s): P. Gahinet, Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:31 $

% RE: Applies only to rows with YlimMode=auto

AxGrid = this.AxesGrid;
if strcmp(this.Visible, 'off') | strcmp(AxGrid.LimitManager, 'off')
   % No updating if global mode is not custom.
   return
end
s = AxGrid.Size;

% Turn off backdoor listeners
AxGrid.LimitManager = 'off';

% Checks Y limits and expands Y range if dynamically updated response gets out of focus
% Find rows that are visible + in autoY mode
DataVis = datavis(this);
AutoY = strcmp(AxGrid.YLimMode,'auto');
if length(AutoY)==1
   DataVis = DataVis & AutoY;
else
   AutoY = reshape(AutoY,[s(3) s(1)])';
   AutoY = reshape(AutoY,[s(1) 1 s(3) 1]);
   DataVis = DataVis & repmat(AutoY,[1 s(2) 1 s(4)]);
end
if ~any(DataVis(:))
   return
end

% Y extent
ax = getaxes(this,'2d');
Yextent = LocalGetExtent(r.yextent(DataVis,0),get(ax(1),'Xlim'));
if any(strcmp(this.IOGrouping,{'all','outputs'}))
   % Row grouping
   row_indices = ones(1,s(1)*s(3));
   Yextent = cat(1,Yextent{:});
   Yextent = {[min(Yextent(:,1)) , max(Yextent(:,2))]};
else
   row_indices = 1:s(1)*s(3);
end

% Expand Y limits if data is getting out of focusfor ct=1:length(indrow)
for ct=find(cellfun('length',Yextent))'
   axesrow = ax(row_indices(ct),:);
   [InFocus,Ylim] = LocalExpandYlim(Yextent{ct},axesrow);
   if ~InFocus
      set(axesrow,'Ylim',Ylim,'YtickMode','auto')
   end
end

% Turn backdoor listeners back on
AxGrid.LimitManager = 'on';


%----------------- Local Functions -------------------------------


function [InFocus,Ylim] = LocalExpandYlim(Yextent,ax)
%YEXPAND  Expands Y limits if Y data extent exceeds current limits.
InFocus = 1;
idx = find(strcmp(get(ax,'Visible'),'on'));
ax = ax(idx(1));
Ylim = get(ax,'Ylim');
LinearScale = strcmp(get(ax,'Yscale'),'linear');

if Yextent(1)<Ylim(1)
   InFocus = 0;
   if LinearScale
      Ylim(1) = 1.1*Ylim(1)-0.1*Ylim(2);  % Ylim(1) - 0.1 * dY
   else
      Ylim(1) = Ylim(1)^1.1 * Ylim(2)^0.9;
   end
end

if Yextent(2)>Ylim(2)
   InFocus = 0;
   if LinearScale
      Ylim(2) = 1.1*Ylim(2)-0.1*Ylim(1);  % Ylim(2) + 0.1 * dY
   else
      Ylim(2) = Ylim(2)^1.1 * Ylim(1)^0.9;
   end
end


function Yextent = LocalGetExtent(Yhandles,XRange)
% Computes Y extent spanned by handles YHANDLES when X limits set to XRANGE.
% REVISIT: This should be an HG primitive!!
Yhandles = permute(Yhandles,[3 1 2]);
[s1,s2,s3] = size(Yhandles);
Yhandles = reshape(Yhandles,[s1*s2 s3]);  % nrows x nobjects
nr = s1*s2;
Yextent = cell(nr,1);
for ctr=1:nr
   Yh = Yhandles(ctr,:);
   Yh = Yh(ishandle(Yh));
   Yx = zeros(0,2);
   for ctc=1:length(Yh)
      Xdata = get(Yh(ctc),'Xdata');
      Ydata = get(Yh(ctc),'Ydata');
      Ydata = Ydata(Xdata>=XRange(1) & Xdata<=XRange(2));
      Yx = [Yx ; [min(Ydata) , max(Ydata)]];
      Yx = [min(Yx(:,1)) , max(Yx(:,2))];
   end
   Yextent{ctr} = Yx;
end