function barplotm(figTag, data, yLim, sigNames),
%BARPLOTM M-file front end for example C-Mex S-function, barplot.c.
%  figTag   - the tag of the figure for plotting
%  data     - the data to plot (cell array, 1 cell per signal)
%  yLim     - vector of ylimits
%  sigNames - cell array of signal names (1 cell per signal)

%   See sfuntmpl.c for a general S-function template.
%   See barplot.c C-code backend.
%

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $

if ~isempty(figTag),
  hFig = findobj(allchild(0),'flat','Tag',figTag);
  if isempty(hFig),
    hFig = figure(...
	'Renderer',         'painters',...
	'DoubleBuffer',     'on', ...
	'IntegerHandle',    'off', ...
	'HandleVisibility', 'off', ...
	'NumberTitle',      'off', ...
	'Tag',              figTag, ...
	'Name',             figTag, ...
	'ToolBar',          'none', ...
	'MenuBar',          'none');
    
    set_param(figTag,'UserData',hFig);
  end
  
  set(hFig,'HandleVisibility','on');
  set(0,'CurrentFigure',hFig);
  
  lenYLim = length(yLim);
  
  try,
    nAxes = length(data);
    
    for i=1:nAxes,
      subplot(nAxes,1,i);
      thisDat = data{i};
      
      bar(thisDat);
      
      %
      % Get the y-limits for this axes.  If we've
      % run out of y-limits, then use the last
      % set of limits.
      %
      yLimIdx = (2*i)-1;
      if (yLimIdx < lenYLim),
	thisYLim = yLim([yLimIdx yLimIdx+1]);
      else,
	thisYLim = yLim([lenYLim-1 lenYLim]);
      end
      
      
      set(gca,'YLim',thisYLim,'YGrid','on');
      ht = title(sigNames{i});
      set(ht,'Interpreter','none');
    end
  end
  set(hFig,'HandleVisibility','off');
  drawnow; %need to get refresh in cmd-line sim

else,
  %
  % Execute the block callback
  %
  callback = data;
  
  switch callback,
   case {'DeleteFcn','NameChangeFcn'},
    h = get_param(gcb,'UserData');
    if ishandle(h),
      delete(h);
    end
  end
end

