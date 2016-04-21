function [imsource, X, Y, W] = cftoolmakepreview(x,y,width,height,ds)
% For use by CFTOOL

%   $Revision: 1.10.2.4 $  $Date: 2004/03/02 21:46:10 $
%   Copyright 2001-2004 The MathWorks, Inc.

usedatasetxy = 1;

% This function expects either 2 or 5 input parameters.
% Last three output arguments are valid only if ds is specified
if nargin < 3
    width = 250;
    height = 250;
    usedatasetxy = 0;
    if nargout > 1
        error('curvefit:cftoolmakepreview:incompatibleInOutArgs', ...
              'ds required to get X, Y, and Z outputs');
    end
end

if (usedatasetxy == 1)
    x = ds.x;
    y = ds.y;
    xlim = [min(x), max(x)];
    ylim = [min(y), max(y)];
    if xlim(1)==xlim(2)
       xlim = xlim(1) + [-1 1] * max(1,eps(xlim(1)));
    end
    if ylim(1)==ylim(2)
       ylim = ylim(1) + [-1 1] * max(1,eps(ylim(1)));
    end

    tempfigure=figure('units','pixels','position',[0 0 width height], ...
	      'handlevisibility','off', ...
	      'integerhandle','off', ...
	      'visible','off', ...
	      'paperpositionmode', 'auto', ...
	      'color','w');
	tempaxes=axes('position',[.05 .05 .9 .9], ...
	      'parent',tempfigure, ...
	      'xtick',[],'ytick',[], ...
	      'box','on', ...
	      'visible','off', 'XLim',xlim , 'YLim',ylim);
      hDS = handle(ds);
      X = hDS.x;
      Y = hDS.y;
      W = hDS.weight;
  else
	tag=['helper figure for ' mfilename];
	tempfigure=findall(0,'type','figure','tag',tag);

	if isempty(tempfigure)
	   tempfigure=figure('units','pixels','position',[0 0 width height], ...
	      'handlevisibility','off', ...
	      'integerhandle','off', ...
	      'visible','off', ...
	      'paperpositionmode', 'auto', ...
	      'color','w', ...
	      'tag',tag);
	   tempaxes=axes('position',[.05 .05 .9 .9], ...
	      'parent',tempfigure, ...
	      'xtick',[],'ytick',[], ...
	      'box','on', ...
	      'visible','off');
	else
	   tempaxes=get(tempfigure,'children');
	end

    NONE='(none)';

    % if only x is given, swap x and y
    if isequal(y,NONE)
        y=x;
        x=NONE;
    end

    y=evalin('base',y);

    if isequal(x,NONE)
        x=1:length(y);
    else
        x=evalin('base',x);
    end
end

% If data has a complex part, it will spit a warning to the command line, so
% turn off warnings before plotting.
warnstate=warning('off', 'all');
h=line(x,y,'parent',tempaxes,'marker','.','linestyle','none');
warning(warnstate);

x=hardcopy(tempfigure,'-dzbuffer','-r0');
% give the image a black edge
x(1,:,:)=0; x(end,:,:)=0; x(:,1,:)=0; x(:,end,:)=0;
imsource=im2mis(x);

if (usedatasetxy == 1)
	delete(tempfigure);
else
	delete(h);
end
