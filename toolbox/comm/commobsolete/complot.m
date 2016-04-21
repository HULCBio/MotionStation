function complot(com_fig)
%COMPLOT Curve fitting plot for COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.18 $

handle = get(com_fig, 'UserData');
if ~isempty(handle)
   h_axes = handle(1);
   h_plot = handle(2);
   textl  = handle(3:7);
   popmu  = handle(8:12);
   entr_text = handle(13:32);
   entr_valu = handle(33:52);
   exec = handle(53:67);
   load_save = handle(68:69);
   bar_color = handle(70:71);
else
    error('The GUI figure is destroyed. Close the window and restart COMMGUI.');
end;

fig_name = ['plot for ', get(com_fig, 'Name')];
list = get(0, 'child');
fd = 0;
i = 1;
while ~fd & (i <= length(list))
   if strcmp(get(list(i), 'name'), fig_name)
      fd = list(i);
      set(0, 'CurrentFigure', list(i));
      tmp = get(fd,'child');
      for i = tmp(:)'
         if ~isempty(get(i,'child'))
            delete(get(i,'child'))
         end
         delete(i);
      end;
   else
      i = i + 1;
   end;
end;

if ~fd
   fd=figure('name', fig_name, ...
      'NumberTitle','off', ...
      'Units', 'normal', ...
      'Position', [.637, .25, .35, .35]...
      );
else
   set(fd,'NextPlot','add')
end;

ord = str2num(get(exec(5), 'String'));
for i = 1 : 5
   data_h = get(exec(i+7), 'child');
   xx = [get(findobj(data_h,'type','line'), 'XData'); ...
         get(findobj(data_h,'type','line'), 'YData')];
   if ~isempty(xx)
      y1 = xx(2,:);
      x1 = xx(1,:);
      [x1, st] = sort(x1);
      y1 = y1(st);
      if i == 1
         loglog(x1, y1, 'w*');
         hold on
      elseif i == 2
         loglog(x1, y1, 'rx');
         hold on
      elseif i == 3
         loglog(x1, y1, 'b+');
         hold on
      elseif i == 4
         loglog(x1, y1, 'mo');
         hold on
      elseif i == 5
         loglog(x1, y1, 'gh');
         hold on
      end;
      if ord > 0
         % polynomial fitting
         [xx11,yy1] = comalog(xx, ord);
         if i == 1
            loglog(xx11, 10 .^yy1, 'w-');
         elseif i == 2
            loglog(xx11, 10 .^yy1, 'r-');
         elseif i == 3
            loglog(xx11, 10 .^yy1, 'b-');
         elseif i == 4
            loglog(xx11, 10 .^yy1, 'm-');
         elseif i == 5
            loglog(xx11, 10 .^yy1, 'g-');
         end;
      else
         % no fitting required, direct line connections.
         if i == 1
            loglog(x1, y1, 'w-')
         elseif i == 2
            loglog(x1, y1, 'r-')
         elseif i == 3
            loglog(x1, y1, 'b-')
         elseif i == 4
            loglog(x1, y1, 'm-')
         elseif i == 5
            loglog(x1, y1, 'g-')
         end;
      end;
   end;
end;

set(gca, 'Color', [.7 .7 .7]-.7, 'Xcolor', [.4 .4 .4], 'Ycolor', [.4 .4 .4]);
hold off
xlabel('Signal/Noise Ratio', 'Fontunits', 'normal', 'Fontsize', .03, 'Color', [0 0 0]);
ylabel('Bit Error Rate', 'FontUnits', 'normal', 'Fontsize', .03, 'Color', [0 0 0]);
zoom on
