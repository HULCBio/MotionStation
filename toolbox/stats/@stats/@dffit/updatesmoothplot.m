function updatesmoothplot(fit)
%UPDATESMOOTHPLOT Update the plot of smooth (nonparametric) fit

%   $Revision: 1.1.6.6 $  $Date: 2004/01/24 09:32:56 $
%   Copyright 2003-2004 The MathWorks, Inc.

changed = 0;
dffig = dfgetset('dffig');

if fit.plot && fit.isgood
   % Get the axes and make sure they include our x range
   ax = get(dffig,'CurrentAxes');
   
   ds = fit.dshandle;
   [ydata,cens,freq] = getincludeddata(ds,fit.exclusionrule);

   % Find a good color and line style
   [c,m,l,w] = dfswitchyard('statgetcolor',ax,'fit',fit);
   m = 'none';
   
   % Special handling for probability plots
   if isequal(fit.ftype, 'probplot')
      if ~isempty(fit.linehandle) && ishandle(fit.linehandle)
         delete(fit.linehandle);
      end
      params = {ydata cens freq fit.support fit.kernel fit.bandwidth};

      fit.linehandle = probplot(ax,@cdfnp,params);
      set(fit.linehandle, 'Color',c, 'Marker',m, 'LineStyle',l, ...
                          'LineWidth',w);
      if ~isempty(fit.boundline) && ishandle(fit.boundline)
         delete(fit.boundline);
         fit.boundline = [];
      end
      fit.x = get(fit.linehandle,'XData');
      ydata = get(fit.linehandle,'YData');
      cdffunc = getappdata(ax,'CdfFunction');
      fit.y = ydata;
   else
      % draw the fit
      x = fit.x;
      xlim = get(ax,'XLim');
      if isempty(xlim)
         xlim = [0 1];
      end
      if isempty(x) || x(1)~=xlim(1) || x(end)~=xlim(end)
         x = linspace(xlim(1),xlim(2),fit.numevalpoints);
         fit.x = x;
      end
      [y,ignore,outwidth] = ksdensity(ydata, x, 'cens',cens, ...
                    'weight',freq,...
                    'support',fit.support,'function',fit.ftype, ...
                    'kernel',fit.kernel, 'width',fit.bandwidth);
      fit.y = y;
      fit.bandwidth = outwidth;
      if isempty(fit.linehandle) || ~ishandle(fit.linehandle)
         fit.linehandle=line(x,y,...
            'Color',c, 'Marker',m, 'LineStyle',l, 'LineWidth',w, ...
            'Parent',ax);
      else
         set(fit.linehandle,'XData',x,'YData',y,'UserData',fit,'Marker',m);
      end
   end
   changed = 1;
   set(fit.linehandle,'ButtonDownFcn',dfittool('gettipfcn'),...
                      'Tag','distfit','UserData',fit);
   savelineproperties(fit);

   % Give it a context menu
   if isempty(get(fit.linehandle,'uiContextMenu'))
      ctxt = findall(get(ax,'Parent'),'Type','uicontextmenu',...
                     'Tag','fitcontext');
      set(fit.linehandle,'uiContextMenu',ctxt);
   end
else
   if ~isempty(fit.linehandle)
      notzooming = isequal(zoom(dffig,'getmode'),'off');
      savelineproperties(fit);
      if ishandle(fit.linehandle)
         delete(fit.linehandle);
      end
      fit.linehandle=[];
      changed = 1;
   end
end

% -----------------------------------------------
function f=cdfnp(x, y,cens,freq,support,kernel,width)
%CDFNP Compute cdf for non-parametric fit, used in probability plot

f = ksdensity(y, x, 'cens',cens, 'weight',freq, 'function','cdf',...
                    'support',support, 'kernel',kernel, 'width',width);
