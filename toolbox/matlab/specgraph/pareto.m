function [hh,ax] = pareto(varargin)
%PARETO Pareto chart.
%   PARETO(Y,NAMES) produces a Pareto chart where the values in the
%   vector Y are drawn as bars in descending order.  Each bar will
%   be labeled with the associated name in the string matrix or 
%   cell array NAMES.
%
%   PARETO(Y,X) labels each element of Y with the values from X.
%   PARETO(Y) labels each element of Y with its index.
%
%   PARETO(AX,...) plots into AX as the main axes, instead of GCA.
%
%   [H,AX] = PARETO(...) returns a combination of patch and line object
%   handles in H and the handles to the two axes created in AX.
%
%   See also HIST, BAR.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.23.4.4 $  $Date: 2004/04/10 23:31:58 $

% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});

cax = newplot(cax);
fig = ancestor(cax,'figure');

hold_state = ishold(cax);
if nargs==0,
  error('Not enough input arguments.');
end
if nargs==1,
  y = args{1};
  m = length(sprintf('%.0f',length(y)));
  names = reshape(sprintf(['%' int2str(m) '.0f'],1:length(y)),m,length(y))';
elseif nargs==2
  y = args{1};  names = args{2};
  if iscell(names)
    names = char(names);
  elseif ~isstr(names)
    names = num2str(names(:));
  end
end

if (min(size(y))~=1),
   error('Y must be a vector.');
end
y = y(:);
[yy,ndx] = sort(y);
yy = flipud(yy); ndx = flipud(ndx);

h = bar('v6',cax,1:length(y),yy);
h = [h;line(1:length(y),cumsum(yy),'parent',cax)];
ysum = sum(yy);

if ysum==0, ysum = eps; end
k = min(min(find(cumsum(yy)/ysum>.95)),10);

if isempty(k), k = min(length(y),10); end

set(cax,'xlim',[.5 k+.5])
set(cax,'xtick',1:k,'xticklabel',names(ndx,:),'ylim',[0 ysum])

raxis = axes('position',get(cax,'position'),'color','none', ...
             'xgrid','off','ygrid','off','YAxisLocation','right',...
             'xlim',get(cax,'xlim'),'ylim',get(cax,'ylim'), ...
             'HandleVisibility',get(cax,'HandleVisibility'), ...
             'parent',fig);
yticks = get(cax,'ytick');
if max(yticks)<.9*ysum,
  yticks = unique([yticks,ysum]);
end
set(cax,'ytick',yticks)
s = '';
for i=1:length(yticks),
  s = strvcat(s,[int2str(round(yticks(i)/ysum*100)) '%']);
end
set(raxis,'ytick',yticks,'yticklabel',s,'xtick',[])
set(cax,'ytick',get(cax,'ytick'))
set(fig,'currentaxes',cax)
if ~hold_state, hold(cax,'off'), set(fig,'Nextplot','Replace'), end

if nargout>0, hh = h; ax = [cax raxis]; end


