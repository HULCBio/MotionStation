function updateplot(fit)
%UPDATEPLOT Update the plot of this fit

%   $Revision: 1.17.2.4 $  $Date: 2004/03/09 16:15:41 $
%   Copyright 2001-2004 The MathWorks, Inc.

changed = 0;
minmax = xlim(fit);
cffig = cftool('makefigure');

if fit.plot
   ax2 = findall(cffig,'Type','axes','Tag','resid');
   if isempty(fit.line) || ~ishandle(fit.line)
      % Get the axes and make sure they include our x range
      ax = findall(cffig,'Type','axes','Tag','main');
      if ~isempty(minmax)
         cfswitchyard('cfupdatexlim',minmax);
      end
      
      % Find a good color and line style
      [c,m,l,w,c2,m2,l2,w2] = cfswitchyard('cfgetcolor',ax,'fit',fit);

      bndsonoff = cfgetset('showbounds');
      clev = cfgetset('conflev');

      % draw the fit
      fline=cftool.boundedline(fit, bndsonoff, clev, ...
         '-userargs',{fit.dataset fit.dshandle}, 'ButtonDownFcn',@cftips,...
         'Color',c, 'Marker',m, 'LineStyle',l, 'LineWidth',w, ...
         'Parent',ax, 'tag','curvefit');
      fit.line=fline;
      changed = 1;

      % Make sure the fit is visible
      cfswitchyard('cfupdateylim');
   else
      c2 = get(fit.line,'Color');
      l2 = get(fit.line,'LineStyle');
      m2 = '.';
      w2 = 1;
   end

   % Also add residual line if necessary
   ax = ax2;
   if ~isempty(ax)
      ptype = cfgetset('residptype');
      if ~isempty(fit.rline) && ishandle(fit.rline)
         % If line is already there, maybe can just change its properties
         oldl = get(fit.rline,'LineStyle');
         if ~isequal(oldl,'none') && isequal(ptype,'scat')
            set(fit.rline,'LineStyle','none');
            changed = 1;
         elseif isequal(oldl,'none') && isequal(ptype,'line')
            set(fit.rline,'LineStyle',l2);
            changed = 1;
         end
      end
      if isempty(fit.rline) || ~ishandle(fit.rline)
         if ~isequal(ptype,'line')
            l2 = 'none';
         end

         % Get non-excluded data for this fit, sort, remember row numbers
         ds = fit.dshandle;
         evec = getexcluded(ds,fit.outlier);
         idx = find(~evec);
         x = ds.x(idx);
         y = ds.y(idx);
         res = y - feval(fit.fit,x);
         if any(diff(x)<0)
            [x,idx2] = sort(x);
            res = res(idx2);
            idx = idx(idx2);
         end
         fline=line(x,res, 'Parent',ax, 'Color',c2, 'ButtonDownFcn',@cftips,...
                    'Marker',m2, 'LineStyle',l2,'LineWidth',w2);
         set(fline,'UserData',{fit.name ds idx}, 'Tag','cfresid');
         fit.rline=fline;
         changed = 1;
      end
   end
   savelineproperties(fit);
else
   if ~isempty(fit.line)
      zooming = zoom(cffig,'ison');
      savelineproperties(fit);
      if ishandle(fit.rline)
         delete(fit.rline);
      end
      fit.rline=[];
      if ishandle(fit.line)
         delete(fit.line);

         % Update axis limits if they were affected by this plot
         if ~isempty(minmax) && ~zooming
            cfswitchyard('cfupdatexlim');
            cfswitchyard('cfupdateylim');
         end
      end
      fit.line=[];
      cffig = cftool('makefigure');
      changed = 1;
   end
end
if changed
   cfswitchyard('cfupdatelegend',cffig);
end
