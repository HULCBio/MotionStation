function cftips(varargin)
%CFTIPS Display data and fit tips for Curve Fitting figure

%No input arguments are used here.

%   $Revision: 1.11.2.5 $  $Date: 2004/02/01 21:38:57 $
%   Copyright 2001-2004 The MathWorks, Inc.

% Only regular click should display tips, not shift-click
f = gcbf;
if ~isequal(get(f,'SelectionType'),'normal')
   return;
end
h = hittest;

cftip = findobj(f,'tag','cftip');
cfdot = findobj(f,'tag','cfdot');
%cfbox = findobj(f,'tag','cfbox');

% Figure out if the cursor is on something we know how to label
msg = '';
if (~isempty(h)) && ishandle(h) && isequal(get(h,'type'),'line')
   ax = get(h,'Parent');
   if isempty(ax) || ~isequal(get(ax,'Type'),'axes')
      ax = get(f,'CurrentAxes');
   end
   pt = get(ax,'CurrentPoint');
   x = pt(1,1);
   y = pt(1,2);
   htag = get(h,'tag');
   xlim = get(ax,'XLim');
   ylim = get(ax,'YLim');
   x = max(xlim(1), min(xlim(2),x));
   y = max(ylim(1), min(ylim(2),y));
   dx = diff(xlim) * 0.02;
   dy = 0;

   % First preference is to label data, so look for data under a line
   if isequal(htag,'curvefit') || isequal(htag,'cfconf')
      oldh = h;
      oldhtag = htag;
      hidden = [];
      while isequal(htag,'curvefit') || isequal(htag,'cfconf')
         set(h,'HitTest','off');
         hidden(end+1) = h;
         h = hittest;
         htag = get(h,'tag');
      end
      if ~isequal(htag,'cfdata') && ~isequal(htag,'cfresid')
         h = oldh;
         htag = oldhtag;
      end
      set(hidden,'HitTest','on');
   end
   
   % Label the scattered points with the row number and coordinates
   if isequal(htag,'cfdata') || isequal(htag,'cfresid')
      xd = get(h,'XData');
      yd = get(h,'YData');
      xyd = abs((xd-x)/diff(xlim)) + abs((yd-y)/diff(ylim));
      [ignore,j] = min(xyd);
      if (length(j)>0)
         j = j(1);
         x = xd(j);
         y = yd(j);
         ds = [];
         if isequal(htag,'cfresid')
            % Residuals are sorted by x; get original row number
            ud = get(h,'UserData');
            if iscell(ud) && length(ud)>=3
               idx = ud{3};
               if j<=length(idx)
                  j = idx(j);
               end
               ds = ud{2};
            end
         else
            ds = get(h,'UserData');
         end
         if ~isempty(ds) && ishandle(ds)
            if isempty(ds.weight)
               msg = sprintf('%s, point #%d\n(x=%g, y=%g)',ds.name,j,x,y);
            else
               msg = sprintf('%s, point #%d\n(x=%g, y=%g, weight=%g)',...
                             ds.name,j,x,y,ds.weight(j));
            end
         else
            msg = sprintf('Point #%d\n(x=%g, y=%g)',j,x,y);
         end
      end
   elseif isequal(htag,'cfconf')
      % Try to label fitted curve, but label conf bounds as a last resort
      msg = xlate('Confidence bounds');
      ud = get(h,'UserData');
      if ishandle(ud)
         h = ud;
         htag = get(ud,'Tag');
      end
   end
   if isequal(htag,'curvefit')
      if isequal(class(handle(h)),'cftool.boundedline')
         msg = get(handle(h),'String');
         fun = get(handle(h),'Function');
         bounded = 0;
         if ~isempty(fun)
            bline = handle(h);
            bounded = isequal(bline.ShowBounds, 'on');
         end
         
         % Round x a bit
         xrange = diff(xlim);
         if xrange>0
            pwr = floor(log10(0.005 * xrange));
            mult = 10 ^ -pwr;
            x = round(mult * x) / mult;
         end

         if bounded
            try
               % Position marker at closest curve and create label
               oldy = y;
               [ci,y] = predint(fun, x, bline.ConfLevel);
               msg = sprintf('%s\nf(%g) = %g +/- %g',msg,x,y,abs(ci(2)-y));
               yy = [ci(:);y];
               [ymin,yidx] = min(abs(yy-oldy));
               y = yy(yidx);
            catch
               bounded = 0;
            end
         end
         if ~bounded
            y = feval(fun,x);
            msg = sprintf('%s\nf(%g) = %g',msg,x,y);
         end
         dy = feval(fun,x+dx) - y;
      else
         msg = xlate('Fitted curve');
      end
   end
end

% If we can't label this thing, delete the label components
if isempty(msg)
   removetips(f);
   
% Otherwise we need to create the proper label
else
   if ~isempty(cfdot) && ishandle(cfdot)
      if isequal(x,get(cfdot,'XData')) && isequal(y,get(cfdot),'YData')
         return;
      end
   end

   % Create the text and line components of the label if missing
   if isempty(cftip) || ~ishandle(cftip)
      yellow = [1 1 .85];
      cftip = text(x,y,'','Color','k','VerticalAlignment','bottom',...
                          'Parent',ax, 'Tag','cftip','Interpreter','none',...
                          'HitTest','off','FontWeight','bold',...
                          'Backgroundcolor',yellow,'Margin',3,...
                          'Edgecolor','k');
   end
   if isempty(cfdot) || ~ishandle(cfdot)
      cfdot = line(x,y,'Marker','o','LineStyle','none','Color','k',...
                       'Tag','cfdot','Parent',ax,'HitTest','off');
   end
   % Position the text so it is not clipped, then write the label
   if (x<sum(xlim)/2)
      ha = 'left';
   else
      ha = 'right';
      dx = - dx;
   end
   if sign(dx)==sign(dy)
      va = 'top';
   else
      va = 'bottom';
   end
   set(cftip,'Position',[x+dx y 0],'String',msg,...
             'HorizontalAlignment',ha,'VerticalAlignment',va);
   set(cfdot,'XData',x,'YData',y);


   set(f, 'WindowButtonMotionFcn',@cftips);
   set(f, 'WindowButtonUpFcn',@disabletips);
end

% ------------------- remove tips from plot
function disabletips(varargin)
cffig = gcbf;
removetips(cffig);
set(cffig, 'WindowButtonUpFcn','');
set(cffig, 'WindowButtonMotionFcn','');

function removetips(cffig)
delete(findobj(cffig,'tag','cftip'));
delete(findobj(cffig,'tag','cfdot'));


