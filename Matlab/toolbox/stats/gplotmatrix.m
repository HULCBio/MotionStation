function [h,ax,BigAx] = gplotmatrix(x,y,g,clr,sym,siz,doleg,dispopt,xnam,ynam)
%GPLOTMATRIX  Scatter plot matrix with grouping variable.
%   GPLOTMATRIX(X,Y,G) creates a matrix of scatter plots of the
%   columns of X against the columns of Y grouped by G.  If X is
%   P-by-M and Y is P-by-N, GPLOTMATRIX will produce a N-by-M matrix
%   of axes.  If you omit Y or specify it as [], the function graphs
%   X vs. X.  G is a grouping variable that determines the marker and
%   color assigned to each point in each matrix, and it can be a vector,
%   string matrix, or cell array of strings.  Alternatively G can be a
%   cell array of grouping variables (such as {G1 G2 G3}) to group the
%   values in X by each unique combination of grouping variable values.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ) specifies the colors, markers, and
%   size to use.  CLR is a string of color specifications, and SYM is
%   a string of marker specifications.  Type "help plot" for more
%   information.  For example, if SYM='o+x', the first group will be
%   plotted with a circle, the second with plus, and the third with x.
%   SIZ is a marker size to use for all plots.  By default, the
%   colors are 'bgrcmyk', the marker is '.', and the marker size
%   depends on the number of plots and the size of the figure window.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG) lets you control whether
%   legends are created.  Set DOLEG to 'on' (default) or 'off'.
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG,DISPOPT) lets you control how
%   to fill the diagonals in a plot of X vs. X.  Set DISPOPT to 'none'
%   to leave them blank, 'hist' (default) to plot histograms, or
%   'variable' to write the variable names. 
%
%   GPLOTMATRIX(X,Y,G,CLR,SYM,SIZ,DOLEG,DISPOPT,XNAM,YNAM)
%   specifies XNAM and YNAM as the names of the X and Y variables.
%   Each must be a character array of the appropriate dimension.
%
%   [H,AX,BigAx] = GPLOTMATRIX(...) returns an array of handles to
%   the objects created in H, a matrix of handles to the individual
%   subaxes in AX, and a handle to big (invisible) axes framing the
%   subaxes in BigAx.  BigAx is left as the CurrentAxes so that a
%   subsequent TITLE, XLABEL, or YLABEL will be centered with respect
%   to the matrix of axes.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.6.2.1 $  $Date: 2003/11/01 04:26:25 $

error(nargchk(1,10,nargin,'struct'));
nin = nargin;

if (nin < 2), y = []; end
if length(y)==0, % gplotmatrix(y)
  rows = size(x,2); cols = rows;
  y = x;
  XvsX = 1;
else, % gplotmatrix(x,y)
  rows = size(y,2); cols = size(x,2);
  XvsX = 0;
end
if (nin > 2)
   [g,gn] = mgrp2idx(g,size(x,1),',');
   ng = max(g);
else
   g = [];
   gn = [];
   ng = 1;
end

% Default colors, markers, etc.
if (nin < 4), clr = ''; end
if (isempty(clr)), clr = 'bgrcmyk'; end
if (nin < 5), sym = ''; end
if (isempty(sym)), sym = '.'; end
if (nin < 6), siz = []; end
if (nin < 7), doleg = 'on'; end
if (nin < 8), dispopt = 'h';
elseif isempty(dispopt), dispopt = 'h';
end
if (nin < 9), xnam = ''; end
if (nin < 10), ynam = ''; end

% What should go into the plot matrix?
doleg = strcmp(doleg, 'on');
dohist = XvsX & (dispopt(1)=='h');
if (~isempty(xnam))
   if (size(xnam,1) ~= cols)
      error('stats:gplotmatrix:InputSizeMismatch',...
            'XNAM must have one row for each column of X.');
   end
end
if (~isempty(ynam))
   if (size(ynam,1) ~= rows)
      error('stats:gplotmatrix:InputSizeMismatch',...
            'YNAM must have one row for each column of Y.');
   end
elseif (XvsX)
   ynam = xnam;
end
donames = (XvsX & (dispopt(1)=='v'));

% Don't plot anything if either x or y is empty
if isempty(rows) | isempty(cols),
   if nargout>0, h = []; ax = []; BigAx = []; end
   return
end

if (ndims(x)==2) & any(size(x)==1), x = x(:); end
if (ndims(y)==2) & any(size(y)==1), y = y(:); end

if ndims(x)>2 | ndims(y)>2
   error('stats:gplotmatrix:MatrixRequired','X and Y must be 2-D.');
end
if size(x,1)~=size(y,1)
  error('stats:gplotmatrix:InputSizeMismatch',...
        'X and Y must have the same length.');
end
if (length(g)>0) & (length(g) ~= size(x,1)),
  error('stats:gplotmatrix:InputSizeMismatch',...
        'There must be one value of G for each row of X.');
end

% Create/find BigAx and make it invisible
clf;
BigAx = newplot;
hold_state = ishold;
set(BigAx,'Visible','off','color','none')

if (isempty(siz))
   siz = repmat(get(0,'defaultlinemarkersize'), size(sym));
   if any(sym=='.'),
      units = get(BigAx,'units');
      set(BigAx,'units','pixels');
      pos = get(BigAx,'Position');
      set(BigAx,'units',units);
      siz(sym=='.') = max(1,min(15, ...
                       round(15*min(pos(3:4))/size(x,1)/max(rows,cols))));
   end
end

% Create and plot into axes
ax = zeros(rows,cols);
ax2 = zeros(max(rows,cols),1);
pos = get(BigAx,'Position');
width = pos(3)/cols;
height = pos(4)/rows;
space = .02; % 2 percent space between axes
pos(1:2) = pos(1:2) + space*[width height];
[m,n,k] = size(y);
xlim = repmat(NaN, [rows cols 2]);
ylim = repmat(NaN, [rows cols 2]);
hh = zeros(rows, cols, ng);
for i=rows:-1:1,
   for j=cols:-1:1,
      axPos = [pos(1)+(j-1)*width pos(2)+(rows-i)*height ...
               width*(1-space) height*(1-space)];
      ax(i,j) = axes('Position',axPos, 'visible', 'on', 'Box','on');

      if ((i==j) & XvsX)
         if (dohist)
            histax = axes('Position',axPos);
            ax2(j) = histax;
            [nn,xx] = hist(reshape(y(:,i,:),[m k]));
            hh(i,i,1) = bar(xx,nn,'hist');
            set(histax, 'YAxisLocation', 'right', ...
                        'Visible','off', 'XTick',[], 'YTick',[], ...
                        'XGrid','off', 'YGrid','off', ...
                        'XTickLabel','', 'YTickLabel','');
            axis tight;
            xlim(i,j,:) = get(gca,'xlim');
         end
      else
         hh(i,j,:) = iscatter(reshape(x(:,j,:),[m k]), ...
                              reshape(y(:,i,:),[m k]), ...
                              g, clr, sym, siz);
         axis tight;
         ylim(i,j,:) = get(gca,'ylim');
         xlim(i,j,:) = get(gca,'xlim');

         % Store information for gname
         set(gca, 'UserData', {'gscatter' x(:,j,:) y(:,i,:) g});
      end
      set(ax(i,j),'xlimmode','auto', 'ylimmode','auto', ...
                  'xgrid','off', 'ygrid','off')
   end
end

xlimmin = min(xlim(:,:,1),[],1); xlimmax = max(xlim(:,:,2),[],1);
ylimmin = min(ylim(:,:,1),[],2); ylimmax = max(ylim(:,:,2),[],2);

% Set all the limits of a row or column to be the same and leave 
% just a 5% gap between data and axes.
inset = .05;
for i=1:rows,
  set(ax(i,1),'ylim',[ylimmin(i,1) ylimmax(i,1)])
  dy = diff(get(ax(i,1),'ylim'))*inset;
  set(ax(i,:),'ylim',[ylimmin(i,1)-dy ylimmax(i,1)+dy])
end
for j=1:cols,
  set(ax(1,j),'xlim',[xlimmin(1,j) xlimmax(1,j)])
  dx = diff(get(ax(1,j),'xlim'))*inset;
  set(ax(:,j),'xlim',[xlimmin(1,j)-dx xlimmax(1,j)+dx])
  if (ax2(j))
     set(ax2(j),'xlim',[xlimmin(1,j)-dx xlimmax(1,j)+dx])
  end
end

% Label plots one way or the other
if (donames)
   for j=1:cols
      set(gcf,'CurrentAx',ax(j,j))
      text(xlimmin(1,j), ylimmax(j,1), deblank(xnam(j,:)), ...
           'HorizontalAlignment','left','VerticalAlignment','top');
   end
else
   for j=1:size(xnam,1)
      set(gcf,'CurrentAx',ax(rows,j))
      xlabel(deblank(xnam(j,:)));
   end
   for j=1:size(ynam,1)
      set(gcf,'CurrentAx',ax(j,1))
      ylabel(deblank(ynam(j,:)));
   end
end

% Ticks and labels on outer plots only
set(ax(1:rows-1,:),'xticklabel','')
set(ax(:,2:cols),'yticklabel','')
set(BigAx,'XTick',get(ax(rows,1),'xtick'),'YTick',get(ax(rows,1),'ytick'), ...
          'userdata',ax,'tag','PlotMatrixBigAx')

% Create legend if requested; must base it on one plot
if (doleg & ((rows>1) | (cols>1) | ~XvsX) & ~isempty(gn))
   if (~XvsX)
      axes(ax(1,1));
   elseif (rows>1)
      axes(ax(2,1));
   else
      axes(ax(1,2));
   end
   legend(gn);
end

% Make BigAx the CurrentAxes
set(gcf,'CurrentAx',BigAx)
if ~hold_state,
   set(gcf,'NextPlot','replace')
end

% Also set Title and X/YLabel visibility to on and strings to empty
set([get(BigAx,'Title'); get(BigAx,'XLabel'); get(BigAx,'YLabel')], ...
 'String','','Visible','on')

if nargout~=0,
  h = hh;
  if (~all(ax2==0))
     ax = [ax; ax2'];
  end
end
