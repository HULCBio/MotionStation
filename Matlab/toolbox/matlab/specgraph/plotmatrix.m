function [h,ax,BigAx,patches,pax] = plotmatrix(varargin)
%PLOTMATRIX Scatter plot matrix.
%   PLOTMATRIX(X,Y) scatter plots the columns of X against the columns
%   of Y.  If X is P-by-M and Y is P-by-N, PLOTMATRIX will produce a
%   N-by-M matrix of axes. PLOTMATRIX(Y) is the same as PLOTMATRIX(Y,Y)
%   except that the diagonal will be replaced by HIST(Y(:,i)). 
%
%   PLOTMATRIX(...,'LineSpec') uses the given line specification in the
%   string 'LineSpec'; '.' is the default (see PLOT for possibilities).  
%
%   PLOTMATRIX(AX,...) uses AX as the BigAx instead of GCA.
%
%   [H,AX,BigAx,P,PAx] = PLOTMATRIX(...) returns a matrix of handles
%   to the objects created in H, a matrix of handles to the individual
%   subaxes in AX, a handle to big (invisible) axes that frame the
%   subaxes in BigAx, a matrix of handles for the histogram plots in
%   P, and a matrix of handles for invisible axes that control the
%   histogram axes scales in PAx.  BigAx is left as the CurrentAxes so
%   that a subsequent TITLE, XLABEL, or YLABEL will be centered with
%   respect to the matrix of axes.
%
%   Example:
%       x = randn(50,3); y = x*[-1 2 1;2 0 1;1 -2 3;]';
%       plotmatrix(y)

%   Clay M. Thompson 10-3-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.3 $  $Date: 2004/04/10 23:32:02 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
error(nargchk(1,3,nargs));
nin = nargs;

sym = '.'; % Default scatter plot symbol.
dohist = 0;

if isstr(args{nin}),
  sym = args{nin};
  nin = nin - 1;
end

if nin==1, % plotmatrix(y)
  rows = size(args{1},2); cols = rows;
  x = args{1}; y = args{1};
  dohist = 1;
elseif nin==2, % plotmatrix(x,y)
  rows = size(args{2},2); cols = size(args{1},2);
  x = args{1}; y = args{2};
end

% Don't plot anything if either x or y is empty
patches = [];
pax = [];
if isempty(rows) | isempty(cols),
   if nargout>0, h = []; ax = []; BigAx = []; end
   return
end

if (ndims(x)==2) & any(size(x)==1), x = x(:); end
if (ndims(y)==2) & any(size(y)==1), y = y(:); end

if ndims(x)>2 | ndims(y)>2,
  error('X and Y must be 2-D.')
end
if size(x,1)~=size(y,1) | size(x,3)~=size(y,3),
  error('X and Y must have the same number of rows and pages.');
end

% Create/find BigAx and make it invisible
BigAx = newplot(cax);
fig = ancestor(BigAx,'figure');
next = lower(get(BigAx,'NextPlot'));
hold_state = ishold(BigAx);
set(BigAx,'Visible','off','color','none')

if any(sym=='.'),
  units = get(BigAx,'units');
  set(BigAx,'units','pixels');
  pos = get(BigAx,'Position');
  set(BigAx,'units',units);
  markersize = max(1,min(15,round(15*min(pos(3:4))/max(1,size(x,1))/max(rows,cols))));
else
  markersize = get(0,'defaultlinemarkersize');
end

% Create and plot into axes
ax = zeros(rows,cols);
pos = get(BigAx,'Position');
width = pos(3)/cols;
height = pos(4)/rows;
space = .02; % 2 percent space between axes
pos(1:2) = pos(1:2) + space*[width height];
[m,n,k] = size(y);
xlim = zeros([rows cols 2]);
ylim = zeros([rows cols 2]);
BigAxHV = get(BigAx,'HandleVisibility');
for i=rows:-1:1,
  for j=cols:-1:1,
    axPos = [pos(1)+(j-1)*width pos(2)+(rows-i)*height ...
             width*(1-space) height*(1-space)];
    findax = findobj(fig,'Type','axes','Position',axPos);
    if isempty(findax),
      ax(i,j) = axes('Position',axPos,'HandleVisibility',BigAxHV,'parent',fig);
      set(ax(i,j),'visible','on');
    else
      ax(i,j) = findax(1);
    end
    hh(i,j,:) = plot(reshape(x(:,j,:),[m k]), ...
                     reshape(y(:,i,:),[m k]),sym,'parent',ax(i,j))';
    set(hh(i,j,:),'markersize',markersize);
    set(ax(i,j),'xlimmode','auto','ylimmode','auto','xgrid','off','ygrid','off')
    xlim(i,j,:) = get(ax(i,j),'xlim');
    ylim(i,j,:) = get(ax(i,j),'ylim');
  end
end

xlimmin = min(xlim(:,:,1),[],1); xlimmax = max(xlim(:,:,2),[],1);
ylimmin = min(ylim(:,:,1),[],2); ylimmax = max(ylim(:,:,2),[],2);

% Try to be smart about axes limits and labels.  Set all the limits of a
% row or column to be the same and inset the tick marks by 10 percent.
inset = .15;
for i=1:rows,
  set(ax(i,1),'ylim',[ylimmin(i,1) ylimmax(i,1)])
  dy = diff(get(ax(i,1),'ylim'))*inset;
  set(ax(i,:),'ylim',[ylimmin(i,1)-dy ylimmax(i,1)+dy])
end
for j=1:cols,
  set(ax(1,j),'xlim',[xlimmin(1,j) xlimmax(1,j)])
  dx(j) = diff(get(ax(1,j),'xlim'))*inset;
  set(ax(:,j),'xlim',[xlimmin(1,j)-dx(j) xlimmax(1,j)+dx(j)])
end

set(ax(1:rows-1,:),'xticklabel','')
set(ax(:,2:cols),'yticklabel','')
set(BigAx,'XTick',get(ax(rows,1),'xtick'),'YTick',get(ax(rows,1),'ytick'), ...
          'userdata',ax,'tag','PlotMatrixBigAx')

if dohist, % Put a histogram on the diagonal for plotmatrix(y) case
  for i=rows:-1:1,
    histax = axes('Position',get(ax(i,i),'Position'),'HandleVisibility',BigAxHV,'parent',fig);
    [nn,xx] = hist(reshape(y(:,i,:),[m k]));
    patches(i,:) = bar(histax,xx,nn,'hist');
    set(histax,'xtick',[],'ytick',[],'xgrid','off','ygrid','off');
    set(histax,'xlim',[xlimmin(1,i)-dx(i) xlimmax(1,i)+dx(i)])
    pax(i) = histax;  % ax handles for histograms
  end
  patches = patches';
end

% Make BigAx the CurrentAxes
set(fig,'CurrentAx',BigAx)
if ~hold_state,
   set(fig,'NextPlot','replace')
end

% Also set Title and X/YLabel visibility to on and strings to empty
set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
 'String','','Visible','on')

if nargout~=0,
  h = hh;
end
 
