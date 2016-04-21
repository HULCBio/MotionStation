function status = odephas2(t,y,flag,varargin)
%ODEPHAS2  2-D phase plane ODE output function.
%   When the function odephas2 is passed to an ODE solver as the 'OutputFcn'
%   property, i.e. options = odeset('OutputFcn',@odephas2), the solver
%   calls ODEPHAS2(T,Y,'') after every timestep.  The ODEPHAS2 function plots
%   the first two components of the solution it is passed as it is computed,
%   adapting the axis limits of the plot dynamically.  To plot two
%   particular components, specify their indices in the 'OutputSel' property
%   passed to the ODE solver.
%   
%   At the start of integration, a solver calls ODEPHAS2(TSPAN,Y0,'init') to
%   initialize the output function.  After each integration step to new time
%   point T with solution vector Y the solver calls STATUS = ODEPHAS2(T,Y,'').
%   If the solver's 'Refine' property is greater than one (see ODESET), then
%   T is a column vector containing all new output times and Y is an array
%   comprised of corresponding column vectors.  The STATUS return value is 1
%   if the STOP button has been pressed and 0 otherwise.  When the
%   integration is complete, the solver calls ODEPHAS2([],[],'done').
%
%   When an ODE solver is called with additional input parameters, for example
%   ODE45(ODEFUN,TSPAN,Y0,OPTIONS,P1,P2...), the solver passes the parameters
%   to the output function, for example ODEPHAS2(T,Y,'',P1,P2...).  
%   
%   See also ODEPLOT, ODEPHAS3, ODEPRINT, ODE45, ODE15S, ODESET.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-24-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.26.4.2 $  $Date: 2004/04/16 22:05:32 $

status = 0;                             % Assume stop button wasn't pushed.
chunk = 128;                            % Memory is allocated in chunks.

if nargin < 3 || isempty(flag) % odephas2(t,y) [v5 syntax] or odephas2(t,y,'')
  ud = get(gcf,'UserData');
  % Append y to ud.y, allocating if necessary.
  nt = length(t);
  chunk = max(chunk,nt);
  rows = size(ud.y,1);
  oldi = ud.i;
  newi = oldi + nt;
  if newi > rows
    ud.y = [ud.y; zeros(chunk,2)];
  end
  ud.y(oldi+1:newi,:) = y(1:2,:).';
  ud.i = newi;
  set(gcf,'UserData',ud);
  
  if ud.stop == 1                       % Has stop button been pushed?
    status = 1;
  else
    % Rather than redraw all of the data every timestep, we will simply move
    % the line segments for the new data, not erasing.  But if the data has
    % moved out of the axis range, we redraw everything.
    xlim = get(gca,'xlim');
    ylim = get(gca,'ylim');
    % Replot everything if out of axis range or if just initialized.
    if (oldi == 1) || ...
          (min(y(1,:)) < xlim(1)) || (xlim(2) < max(y(1,:))) || ...
          (min(y(2,:)) < ylim(1)) || (ylim(2) < max(y(2,:)))
      set(ud.lines, ...
          'Xdata',ud.y(1:newi,1), ...
          'Ydata',ud.y(1:newi,2));
      set(ud.line, ...
          'Xdata',ud.y(oldi:newi,1), ...
          'Ydata',ud.y(oldi:newi,2));
    else
      % Plot only the new data.
      co = get(gca,'ColorOrder');
      set(ud.line,'Color',co(1,:));     % "erase" old segment
      set(ud.line, ...
          'Xdata',ud.y(oldi:newi,1), ...
          'Ydata',ud.y(oldi:newi,2), ...
          'Color',co(2,:));
    end
  end
  
else
  switch(flag)
  case 'init'                           % odephas2(tspan,y0,'init')
    ud.y = zeros(chunk,2);
    ud.i = 1;
    ud.y(1,:) = y(1:2).';
    
    % Rather than redraw all data at every timestep, we will simply move
    % the last line segment along, not erasing it.
    f = figure(gcf);
    co = get(gca,'ColorOrder');
    if ~ishold
      ud.lines = plot(y(1),y(2),'-o');
      hold on
      ud.line = plot(y(1),y(2),'-o','Color',co(2,:),'EraseMode','none');
      hold off
    else
      ud.lines = plot(y(1),y(2),'-o','EraseMode','none');
      ud.line = plot(y(1),y(2),'-o','Color',co(2,:),'EraseMode','none');
    end
    
    % The STOP button.
    h = findobj(f,'Tag','stop');
    if isempty(h)
      ud.stop = 0;
      pos = get(0,'DefaultUicontrolPosition');
      pos(1) = pos(1) - 15;
      pos(2) = pos(2) - 15;
      str = 'ud=get(gcf,''UserData''); ud.stop=1; set(gcf,''UserData'',ud);';
      uicontrol( ...
          'Style','push', ...
          'String','Stop', ...
          'Position',pos, ...
          'Callback',str, ...
          'Tag','stop');
    else
      set(h,'Visible','on');            % make sure it's visible
      if ishold
        oud = get(f,'UserData');
        ud.stop = oud.stop;             % don't change old ud.stop status
      else
        ud.stop = 0;
      end
    end
    set(f,'UserData',ud);
    
  case 'done'                           % odephas2([],[],'done')
    f = gcf;
    ud = get(f,'UserData');
    ud.y = ud.y(1:ud.i,:);
    set(f,'UserData',ud);
    set(ud.lines, ...
        'Xdata',ud.y(:,1), ...
        'Ydata',ud.y(:,2));
    if ~ishold
      set(findobj(f,'Tag','stop'),'Visible','off');
      refresh;                          % redraw figure to remove marker frags
    end
    
  end
end

drawnow;
