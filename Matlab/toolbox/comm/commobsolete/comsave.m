function comsave(com_fig)
%COMSAVE Save a file for COMMGUI.
%
%WARNING: This is an obsolete function and may be removed in the future.

%  Wes Wang, original design
%  Jun Wu, last update, Mar-07, 1997
%  Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.15 $

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
 
 for i = 1: 5
    popm_valu(i) = get(popmu(i), 'Value');
 end;
 
 valu_size = [];
 valu_valu = [];
 for i = 1 : 20
    str = get(entr_valu(i), 'String');
    valu_size = [valu_size length(str)];
    valu_valu = [valu_valu str];
 end;
 str = get(exec(5), 'String');
 valu_size = [valu_size length(str)];
 valu_valu = [valu_valu str];
 
 curr_child = get(exec(8), 'Child');
 curr_data = [get(curr_child(5),'XData'); get(curr_child(5), 'YData')];
 for i = 2:5
    tmp_child  = get(exec(i+7), 'Child');
    tmp = [get(tmp_child(5), 'XData');get(tmp_child(5), 'YData')];
    if i == 2
       comp_data1 = tmp;
    elseif i == 3
       comp_data2 = tmp;
    elseif i == 4
       comp_data3 = tmp;
    else
       comp_data4 = tmp;
    end;
 end;

 for i = 1:2
    %  str = get(load_save(i), 'String');
    str = '';
    valu_size = [valu_size length(str)];
    %  valu_valu = [valu_valu str];
 end;
 
 [filename, filepath] = uiputfile('*.mat', 'Save Communications error rate computation GUI setting data to');
 if isempty(filename) | (filename == 0)
    return;
 end;
 str = [filepath filename];
 eval(['save ', str, ' popm_valu valu_size valu_valu comp_data1 comp_data2 comp_data3 comp_data4 curr_data'])
