function x = vitplot1(input, expense, aft_state, plot_flag);
%WARNING: This is an obsolete function and may be removed in the future.

% VITPLOT1
%     X = VITPLOT1(INPUT, EXPENSE, AFT_STATE, PLOT_FLAG);
%

%   Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $

num_state = input(1);
i = input(2);
expen_flag = input(3);
n_code = input(4);
M = num_state;
n_std_sta = 2^num_state;

xx = [];
if i == 1
  plot_flag(1) = figure(plot_flag(1));
  %drawnow;
  delete(get(plot_flag(1),'child'))
  set(plot_flag(1), 'NextPlot','add', 'Clipping','off');
  if length(plot_flag) >= 5
    set(plot_flag(1),'Position',plot_flag(2:5));
  end;
  axis([0, n_code, 0, n_std_sta-1]);
  handle_axis = get(plot_flag(1),'Child');
  xx=text(0, 0, '0');
  set(xx,'Color',[0 1 1]);
  hold on
  set(handle_axis, 'Visible', 'off');
%  plot_w = plot(0, 0, 'w--');
  plot_y = plot(0, 0, 'y-');
  plot_r = plot(0, 0, 'r-');
  for iii = 0 : n_std_sta-1
    text(-n_code/8, iii, ['State ', num2str(bi2de(fliplr(de2bi(iii,num_state))))]);
  end;
  text(n_code/2.1, -n_std_sta/15, 'Time');
  set(handle_axis, 'Visible', 'off');
  set(plot_flag(1),'UserData',[plot_y plot_r]);
end; % if i == 1

plot_flag(1) = figure(plot_flag(1));
plot_y = get(plot_flag(1),'UserData');
if isempty(plot_y)
  plot_y = get(1,'UserData');
end;
plot_r = plot_y(2);
plot_y = plot_y(1);

% end of vitplot1.m
flipped = zeros(1, n_std_sta);
for iii = 1 : n_std_sta 
    flipped(iii) =  bi2de(fliplr(de2bi(iii-1, M)));
end;

plot_curv_x = [];
plot_curv_y = [];
for j = 1 : n_std_sta
    tmp = expense((j-1)*n_std_sta+1: j*n_std_sta);
    if expen_flag
	tmp_tmp = max(tmp(find(~isnan(tmp))));
	if isempty(tmp_tmp)
            expen_rec(j) = - realmax;
	else
            expen_rec(j) = tmp_tmp;
	end
    else
	tmp_tmp = min(tmp(find(~isnan(tmp))));
	if isempty(tmp_tmp)
            expen_rec(j) = realmax;
	else
            expen_rec(j) = tmp_tmp;
	end
    end;
    for j2 = 1 : length(tmp)
        if ~isnan(tmp(j2))
            plot_curv_x = [plot_curv_x, i-1+.1, i, NaN];
            plot_curv_y = [plot_curv_y, flipped(j2), flipped(j), NaN];
        end;
    end;
end;

%find out the plot lines:

% plot only; no computation function here.
plot_curv_x = [get(plot_y, 'XData'), NaN, plot_curv_x];
plot_curv_y = [get(plot_y, 'YData'), NaN, plot_curv_y];
for j = 1 : length(aft_state)
    xx=[xx; text(i, flipped(aft_state(j)), num2str(expen_rec(aft_state(j))))];
    set(xx,'Color',[0 1 1]);
end;

set(plot_y, 'XData', plot_curv_x, 'YData', plot_curv_y);


