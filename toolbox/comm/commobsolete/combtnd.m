function combtnd(bt_flag, frm_handle)
%COMBTND WindowButtonDown function for COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.24 $

if nargin < 2
    error('There must be two input variables in calling COMBTND.')
end;
to_handle = 0;
% find the origination of the button down.
x = get(gcf, 'currentpoint');

% all position units are 'normalized'
pos_t_x = .05;              %the left sub_plot window's left x-axis
pos_t_y = [.175 .325];      %all sub_plot window's bottom/top y-axis
pos_r_x = [.87 .98];        %trash can's position
pos_r_y = [.008 .108];
pos_w_x = [.665 .79];        %To/From Workspace's position
pos_w_y = [.008 .114];

position_in_area1 = [];     % button is in sub-plot windows area
position_in_area2 = [];     % button is in workspace area
position_in_area3 = [];     % button is in trash area
% check out if the button is in the following areas: one of the sub_plot windows, workspace and trash can.
for i = 1:5
   if x(1) > (i-1)*.19+pos_t_x(1) & x(1)<(i-1)*.19+pos_t_x(1)+.15 & x(2)>pos_t_y(1) & x(2)<pos_t_y(2)
      position_in_area1 = 1;   
   end;
end;
if x(1) > pos_w_x(1) & x(1) < pos_w_x(2) & x(2) > pos_w_y(1) & x(2) < pos_w_y(2)
   position_in_area2 = 1;
elseif x(1) > pos_r_x(1) & x(1) < pos_r_x(2) & x(2) > pos_r_y(1) & x(2) < pos_r_y(2)
   position_in_area3 = 1;
elseif isempty(position_in_area1)
   return;
end;

if isempty(position_in_area1) & isempty(position_in_area2) & isempty(position_in_area3) 
   return;
else
   handle = get(gcf, 'UserData');
   if ~isempty(handle)
      ord = str2num(get(handle(57), 'String'));
      sub_win = handle(60:64);
      load_save = handle(68:69);
      bar_color = handle(70);
   else
      error('The handle is destroyed. Close the window and open again.');
   end;

   % while the button position is in one of these 5 sub_plot windows
   if ~isempty(position_in_area1)
      if x(1) < .2
         frm_handle = sub_win(1);
         frm_child = get(frm_handle,'Child');
         fram = [.05 pos_t_y(1) .15 .15];
      elseif x(1) < .39   
         frm_handle = sub_win(2);
         frm_child = get(frm_handle,'Child');
         fram = [.24 pos_t_y(1) .15 .15];
      elseif x(1) < .58   
         frm_handle = sub_win(3);
         frm_child = get(frm_handle,'Child');
         fram = [.43 pos_t_y(1) .15 .15];
      elseif x(1) < .77   
         frm_handle = sub_win(4);
         frm_child = get(frm_handle,'Child');
         fram = [.62 pos_t_y(1) .15 .15];
      elseif x(1) < .96
         frm_handle = sub_win(5);
         frm_child = get(frm_handle,'Child');
         fram = [.81 pos_t_y(1) .15 .15];
      end;
      for i = 1:length(frm_child)
         set(frm_child(i), 'Erasemode','background');
      end;
      if strcmp(computer, 'PCWIN')
         if get(findobj(frm_child,'type','line'),'linewidth') < 1
            set(findobj(frm_child,'type','line'),'linewidth',1.5);
         else
            set(findobj(frm_child,'type','line'),'linewidth',.5);
         end;
      elseif strcmp(computer,'MAC2')
         if get(findobj(frm_child,'type','line'),'linewidth') <= 1
            set(findobj(frm_child,'type','line'),'linewidth',2);
         else
            set(findobj(frm_child,'type','line'),'linewidth',1);
         end;
      else
         if get(findobj(frm_child,'type','line'),'linewidth') <= 1
            set(findobj(frm_child,'type','line'),'linewidth',3);
         else
            set(findobj(frm_child,'type','line'),'linewidth',1);
         end;
      end;	
      set(frm_handle, 'drawmode','fast');
      % while the button is in "To/From-Workspace"
   elseif ~isempty(position_in_area2)
      frm_handle = -1;
      fram = [.665 .063 .1 .1];
      % while the button is in "Trash Can"
   elseif ~isempty(position_in_area3)
      return;
      % currently, this is doing nothing.
   else
      return;
   end;
   
   selection_type = get(gcf,'selectiontype');
   set(bar_color, 'FontUnits', 'normal', 'Fontsize', .025, 'Color', [1 0 1], ...
      'Visible','on','String','Copying or removing data record...');
   drawnow
      
   % set the button moving function.
   set(gcf,'unit','pixel');
   pos = get(gcf, 'position');
   fram(1:2) = fram(1:2)*pos(3);
   fram(3:4) = fram(3:4)*pos(4);

   % set the button-up function.
   dragrect([fram(1), fram(2)-38, fram(3)+35, fram(4)]);
   
   set(gcf, 'unit', 'norm');
   % button up flag
      
   x = get(gcf, 'currentpoint');
   position_in_area11 = [];
   position_in_area22 = [];
   position_in_area33 = [];
   % check out if the button is in the following areas: one of the sub_plot windows, workspace and trash can.
   for i = 1:5
      if x(1) > (i-1)*.19+pos_t_x(1) & x(1)<(i-1)*.19+pos_t_x(1)+.15 & x(2)>pos_t_y(1) & x(2)<pos_t_y(2)
         position_in_area11 = 1;   
      end;
   end;
   if x(1) > pos_w_x(1) & x(1) < pos_w_x(2) & x(2) > pos_w_y(1) & x(2) < pos_w_y(2)
      position_in_area22 = 1;
   elseif x(1) > pos_r_x(1) & x(1) < pos_r_x(2) & x(2) > pos_r_y(1) & x(2) < pos_r_y(2)
      position_in_area33 = 1;
   elseif x(1) < 0
      return;
   end;
   
   if ~isempty(position_in_area33)
      %trash can
      if (frm_handle > 0)
         %dump the figure data into the trash can
         if length(frm_child) ~= 0
	   		set(findobj(frm_child,'type','line'), 'XData', [], 'YData', []);	    
         else
            return;
         end;
      elseif frm_handle < 0
         to_handle = 0;
      end;
   elseif ~isempty(position_in_area11)
      % while it is from workspace
      if x(1) < .2
         to_handle = sub_win(1);
      elseif x(1) < .39   
         to_handle = sub_win(2);
      elseif x(1) < .58   
         to_handle = sub_win(3);
      elseif x(1) < .77   
         to_handle = sub_win(4);
      elseif x(1) < .96
         to_handle = sub_win(5);
      end;
      if frm_handle == -1
         % open a window to input snr and ber variable name into to_handle
         comwksp(0, to_handle);
         xx = get(to_handle,'Userdata');
         if isempty(xx)
            return;
         end;
         y1 = xx(2,:);
         x1 = xx(1,:);
         [xdata, st] = sort(x1);
         ydata = y1(st);
         to_child = get(to_handle,'Child');
         set(findobj(to_child,'type','line'), ...
            'XData', xdata, ...
            'YData', ydata);
         %drawnow;
      else 
         xdata = get(findobj(frm_child,'type','line'), 'XData');
         ydata = get(findobj(frm_child,'type','line'), 'YData');
         % to manully change the X axis and Y axis's limitation.
         set(to_handle, 'Xlim', get(frm_handle, 'Xlim'), ...
            'Ylim', get(frm_handle, 'Ylim'),...
            'Xlimmode', 'manu', ...
            'Ylimmode', 'manu');
         to_child = get(to_handle,'Child');
         set(findobj(to_child,'type','line'), ...
            'XData', xdata, ...
            'YData', ydata);
         %drawnow;
         set(to_handle, 'Xlimmode', 'auto', ...
            'Ylimmode', 'auto');
      end;
   elseif ~isempty(position_in_area22)
      to_handle = 0;
      if frm_handle ~= -1;
         % open a window inputting put xx into
         % snr and ber variables
         xdata = get(findobj(frm_child,'type','line'), 'XData');
         ydata = get(findobj(frm_child,'type','line'), 'YData');
         xx=[xdata;ydata];
         % write xx(1,:) to snr
         % write xx(2,:) to ber
         %%%%%%%%%%%%%%
         comwksp(1, xx, frm_handle);
      end;
   else
      to_handle = 0;
   end;
   set(bar_color, 'Visible','off','String','Loading setup, please wait...')
end;

% search if the plot exists.
plot_fig_name = 'plot for Communications error rate estimation';
fig_exist = get(0, 'child');
plot_figure = 0;
if ~isempty(fig_exist)
   i = 1;
   while (~plot_figure & i <= length(fig_exist))            %check out all existing figure
      if strcmp(get(fig_exist(i), 'name'), plot_fig_name)   %compare each figure's name with 'name'
         plot_figure = fig_exist(i);                        %if it exists, we set main_figure--1, otherwise it is --0.
      end;
      i = i + 1;        
   end;
end;
%highlight the selected data figure
if plot_figure
  tmp_child = get(plot_figure,  'Child');
  tmp_child = get(tmp_child(2), 'Child');
  for i = 5:length(tmp_child)
    set(tmp_child(i), 'Erasemode', 'Xor');
  end;
  for i = 1:5
    childp = get(sub_win(i), 'Child'); 	%sub_plot
    line_color = get(findobj(childp,'type','line'), 'color');
    if line_color == [1 1 1]
      line_color = [0 0 0];
    elseif line_color == [0 0 0]
      line_color = [1 1 1];
    end;
    if get(findobj(childp,'type','line'), 'Linewidth') <= 1
      for j = 5:length(tmp_child)
			if get(tmp_child(j), 'color') == line_color & ~strcmp(get(tmp_child(j),'type'), 'text')
	  			set(tmp_child(j), 'Visible', 'off');
			end;
      end;
    else
      for j = 5:length(tmp_child)
			if get(tmp_child(j), 'color') == line_color & ~strcmp(get(tmp_child(j),'type'), 'text')
	  			set(tmp_child(j), 'Visible', 'on');
			end;
      end;
    end;
  end;
end;
