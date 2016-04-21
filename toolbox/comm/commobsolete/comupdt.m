function comupdt(com_fig, ctr)
%WARNING: This is an obsolete function and may be removed in the future.

%  Copyright 1996-2002 The MathWorks, Inc.
%  $Revision: 1.12 $

handle = get(com_fig, 'UserData');
if ~isempty(handle)
    h_axes = handle(1);
    h_plot = handle(2);
    testl  = handle(3:7);
    popmu  = handle(8:12);
    entr_text = handle(13:32);
    entr_valu = handle(33:52);
    exec = handle(53:63);
    data_h = handle(60:63);
    load_save = handle(64:67);
    bar_color = handle(68:69);
else
    error('The GUI figure is destroyed. Close the window and restart COMMGUI.');
end;

curr_data = get(data_h(3), 'UserData');
tmp  = get(data_h(4), 'UserData');
if size(curr_data, 2) == size(tmp, 2)
  curr_data = [curr_data; tmp];
else
  error('Warning: Your computed data is not complete. Failed to save all data.');
  curr_data = [];
end;

if ctr == 1
    % replace
elseif ctr == 2
    % combine
    comp_data = get(data_h(1), 'UserData');
    tmp  = get(data_h(2), 'UserData');
    if size(comp_data, 2) == size(tmp, 2)
      comp_data = [comp_data; tmp];
    else
      disp('Warning: Your comparing data is not complete. Failed to save all data.');
      comp_data = [];
    end;
    curr_data = [curr_data, comp_data];
    [tmp1, tmp2] = sort(curr_data(1, :));
    curr_data(1,:) = curr_data(1, tmp2);
    curr_data(2,:) = curr_data(2, tmp2);
else
    error('Calling error.');
end;
if isempty(curr_data)
    set(data_h(1), 'UserData', [],...
                'String','');
    set(data_h(2), 'UserData', [],...
                'String','');
else
    set(data_h(1), 'UserData', curr_data(1,:),...
                'String',mat2str(curr_data(1,:),6));
    set(data_h(2), 'UserData', curr_data(2,:),...
                'String',mat2str(curr_data(2,:),6));
end
set(data_h(3), 'UserData', [], 'String','');
set(data_h(4), 'UserData', [], 'String','');
