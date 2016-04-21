function comload(com_fig, ini_flag)
%COMLOAD Load a file for COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.17 $

if nargin < 1
  com_fig = gcf;
end;
if nargin < 2
  ini_flag = 0;
end;

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
   set(bar_color(1), 'visible', 'off');
   ord = str2num(get(exec(5),'String'));
   
   if ini_flag
      load comfoo.mat
      % To fix the previous version comfoo.mat
      if ~exist('comp_data1', 'var')
         comp_data1 = comp_data;
         comp_data2 = [];
         comp_data3 = [];
         comp_data4 = [];
      end;
   else
      [filename, filepath] = uigetfile('*.mat', ...
         'Load Communications error rate computation GUI setting data from');
      if isempty(filename) | (filename == 0)
         return;
      end;
      eval(['load ', [filepath filename]]);
      if ~exist('comp_data1', 'var')
         comp_data1 = comp_data;
         comp_data2 = [];
         comp_data3 = [];
         comp_data4 = [];
      end;
   end;
   
   for i = 1 : 5
      set(popmu(i), 'Value', popm_valu(i));
   end;
   
   for i = 1 : 20
      if valu_size(i) > 0
         str = valu_valu(1:valu_size(i));
         valu_valu(1:valu_size(i)) = [];
         set(entr_valu(i), 'String', str);
      end;
   end;
   
   if valu_size(21) > 0
      str = valu_valu(1:valu_size(21));
      valu_valu(1:valu_size(21)) = [];
      set(exec(5), 'String', str);
   end;

   for i = 1:2
      if valu_size(21+i) > 0
         str = valu_valu(1:valu_size(21+i));
         valu_valu(1:valu_size(21+i)) = [];
      end;
   end;
   
   if ~isempty(comp_data1) | ~isempty(comp_data2) | ~isempty(comp_data3) | ~isempty(comp_data4)
      for i = 1:4
         if i == 1
            tmp = comp_data1;
         elseif i == 2
            tmp = comp_data2;
         elseif i == 3
            tmp = comp_data3;
         else
            tmp = comp_data4;
         end;
         yy1 = tmp(2,:);
         xx11 = tmp(1,:);
         child = get(exec(i+8), 'Child');
         set(findobj(child,'type','line'), 'XData', xx11, ...
            'YData', yy1);
         if i == 1
            set(findobj(child,'type','line'), 'Marker', 'x', 'Color', 'r');
         elseif i == 2
            set(findobj(child,'type','line'), 'Marker', '+', 'Color', 'b');
         elseif i == 3
            set(findobj(child,'type','line'), 'Marker', 'o', 'Color', 'm');
         elseif i == 4
            set(findobj(child,'type','line'), 'Marker', 'h', 'Color', 'g');
         end;
      end;
      set(exec(3), 'Enable', 'on');
   end;
   
   if ~isempty(curr_data)
      yy1 = curr_data(2,:);
      xx11 = curr_data(1,:);
      [xx11, st] = sort(xx11);
      yy1 = yy1(st);
      %[xx11,yy1] = comalog(curr_data, ord);
      child = get(exec(8), 'Child');
      set(findobj(child,'type','line'), 'XData', xx11, ...
         'YData', yy1, ...
         'Color', 'k', ...
         'Marker', '*', ...
         'linestyle', '-');
      set(exec(3), 'Enable', 'on');
   end;
   
   for i = 1 : 5
      comermn(i, com_fig);
   end;
end;
set(bar_color(1), 'visible', 'off');

% end of comload.m