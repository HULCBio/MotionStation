function hh = cellplot(c,lims)
%CELLPLOT Display graphical depiction of cell array.
%   CELLPLOT(C) displays the structure of a cell array as nested
%   colored boxes.  
%
%   H = CELLPLOT(C) returns a vector of surface, line and text handles.
%
%   H = CELLPLOT(C,'legend') also puts a legend next to the plot.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.20.4.1 $  $Date: 2004/01/26 23:20:44 $

if nargin<1 
    error('MATLAB:cellplot:nargin', 'Not enough input arguments.'); 
end

nin = nargin;
if nargin==2 && ischar(lims),
  nin = 1;
  legend = strcmp(lims,'legend');
else
  legend = 0;
end

if isempty(c),if nargout>0, hh = []; end, return, end

if nin==1, % Do stuff for top level call
  if ~iscell(c) 
      error('MATLAB:cellplot:arg1NotCellArray', 'C must be a cell array.'); 
  end
  ax = newplot;
  hold_state = ishold;
  next = get(ax,'NextPlot');
  hold on
  m = size(c,1); n = size(c,2);
  if n==1, xlims = [.5 1.5]; else xlims = [0 n]; end
  if m==1, ylims = [.5 1.5]; else ylims = [0 m]; end
  lims = [xlims ylims];
  set(ax,'xlim',xlims,'ylim',ylims)
end

m = size(c,1); n = size(c,2);
X = zeros(m,n);

edgec = get(gca,'xcolor');
for i=1:m*n,
  contents = c{i};
  X(i) = 2*ischar(contents) + 2*issparse(contents) + ...
         isa(contents,'double') + ...
         4*isstruct(contents); % Values from 1 to 4
  if X(i)==0, X(i)=5; end % Other case
end

% Draw cell grid
dx = diff(lims(1:2)/n);
dy = diff(lims(3:4)/m);
delta = min(dx,dy);
[x,y] = meshgrid(((0:n)-n/2)*delta+sum(lims(1:2))/2,...
                 ((0:m)-m/2)*delta+sum(lims(3:4))/2);
if ndims(c)==2
  d = 0;
  h = pcolor(x,y,ones(size(x))); 
  set(h,'facecolor',get(gcf,'defaultaxescolor'),'edgecolor',edgec)
else
  % Draw N-D cell array grid
  d = min(dx,dy)/5;
  [m,n,p] = size(c); h = [];
  for i=p-1:-1:0,
    h = [h;pcolor(x+d*i/(p-1),y-d*i/(p-1),ones(size(x)))];
  end
  set(h,'facecolor',get(gcf,'defaultaxescolor'),'edgecolor',edgec)
  c = c(:,:,1); % Only recursively transverse the 1st page
end
lims = [([-n/2 n/2])*delta+sum(lims(1:2))/2 ...
        ([-m/2 m/2])*delta+sum(lims(3:4))/2];
for i=1:m
  for j=1:n,
    contents = c{i,j};
    dx = diff(lims(1:2))/n; dy = diff(lims(3:4))/m;
    xlims = lims(1) + (j-1)*dx + [.1 .9]*dx;
    ylims = lims(3) + (i-1)*dy + [.1 .9]*dy;
    if iscell(contents),
      % Recursively display contents
      h = [h;cellplot(contents,[xlims ylims])];
    elseif ~isempty(contents),
      mm = size(contents,1); nn = size(contents,2);
      dx = diff(xlims/nn);
      dy = diff(ylims/mm);
      delta = min(dx,dy);
      [x,y] = meshgrid(((0:nn)-nn/2)*delta+sum(xlims)/2,...
                       ((0:mm)-mm/2)*delta+sum(ylims)/2);
      if ndims(contents)==2
        col = X(i,j)*ones(size(x));
        hp = pcolor(x,y,col);
        if ~isempty(contents) && ischar(contents), 
          col = X(i,j)*ones(size(contents));
          col(contents==' ')=NaN;
          set(hp,'CData',col)
        end

      else
        [mm,nn,pp] = size(contents); hp = [];
        for ii=pp-1:-1:0,
          hp = [hp;pcolor(x+delta/5*ii/(pp-1),y-delta/5*ii/(pp-1), ...
                 X(i,j)*ones(size(x)))];
        end
      end
      set(hp,'FaceColor','flat')
      h = [h;hp];
      if ischar(contents) && size(contents,1)==1 && ...
         length(contents)<15 && ndims(contents)==2
        mm = size(contents,1); nn = size(contents,2);
        h = [h;text(sum(xlims)/2,sum(ylims/2),0, ...
          fliplr(deblank(fliplr(deblank(contents)))), ...
          'horizontalalignment','center',...
          'verticalalignment','middle','clipping','on')];
      elseif (isnumeric(contents) || islogical(contents)) && length(contents)==1,
        mm = size(contents,1); nn = size(contents,2);
        h = [h;text(sum(xlims)/2,sum(ylims/2),0,num2str(double(contents)), ...
          'horizontalalignment','center',...
          'verticalalignment','middle','clipping','on')];
      end
    end
  end
end

if nin==1, % Do stuff for top level call
  if ~hold_state, 
    hold off
    set(ax,'xtick',[],'ytick',[],'nextplot',next)
    axis image, axis ij, axis off
    caxis([1 6]),
    colormap(prism(5))
    if legend,
      hc = colorbar;
      set(hc,'ytick',(1:5)+.5,'yticklabel', ...
         {'double','char','sparse','structure','other'},...
         'ticklength',[0 0])
    end
    set(ax,'xlim',get(ax,'xlim')+[0 d],'ylim',get(ax,'ylim')-[d 0])
  end
%  h = [h;hc];
end

if nargout>0, hh = h; end
