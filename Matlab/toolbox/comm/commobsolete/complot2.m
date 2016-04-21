function complot2(bt_flag)
%WARNING: This is an obsolete function and may be removed in the future.

%  Copyright 1996-2002 The MathWorks, Inc.
%  $Revision: 1.12 $

if nargin < 1
    error('There must be two input variables in calling COMBTND.')
end;
if bt_flag == 0
    % find the origination of the button down.
    point_pos = get(gcf, 'currentpoint');
    handle = get(gcf, 'userdata');
    
    fram_x = [1 1 1 1 1]*point_pos(1);
    fram_y = [1 1 1 1 1]*point_pos(2);
    set(handle(2), 'XData', fram_x, 'YData', fram_y);

    set(gcf, 'windowbuttonmotionfcn', ['complot2(' num2str(handle(2), 20), ');']);
    set(gcf, 'windowbuttonupfcn', ['complot2(-1);']);
    set(get(handle(2),'parent'),'Xlim',[-1 1],'Ylim',[-1 1]);
    drawnow
elseif bt_flag < 0
    % button up flag
    set(gcf, 'windowbuttonmotionfcn', '');
    set(gcf, 'windowbuttonupfcn', '');
    handle = get(gcf, 'UserData');
    x_o = get(handle(2), 'XData');
    y_o = get(handle(2), 'YData');

    set(handle(2),'XData',[],'YData',[]);
    if max(x_o) == min(x_o)
        return;
    elseif max(y_o) == min(y_o)
        return;
    end;
    point_pos = get(gcf,'currentpoint');
    x_o = x_o(1);
    y_o = y_o(1);
    x_f = point_pos(1);
    y_f = point_pos(2);
    axis_pos = get(handle(1), 'position');
    lim_x = get(handle(1),'Xlim');
    lim_y = get(handle(1),'Ylim');
    axis_pos(3) = axis_pos(1) + axis_pos(3);
    axis_pos(4) = axis_pos(2) + axis_pos(4);
    score = 0;
    if (x_o >= axis_pos(1)) & (x_o <= axis_pos(3))
        score = score + 1;
    end;
    if (x_f >= axis_pos(1)) & (x_f <= axis_pos(3)) 
        score = score + 1;
    end;
    if (y_o >= axis_pos(2)) & (y_o <= axis_pos(4))
        score = score + 1;
    end;
    if (y_f >= axis_pos(2)) & (y_f <= axis_pos(4)) 
        score = score + 1;
    end;
    if score == 0
        % set the original axis back
        set(handle(1),'Xlim',handle(3:4));
        set(handle(1),'Ylim',handle(5:6));
    elseif score == 4
        % the normal case
        lim_x = log10(lim_x);
        lim_y = log10(lim_y);
        % the ratio
        x_o = (x_o - axis_pos(1)) / (axis_pos(3) - axis_pos(1));
        x_f = (x_f - axis_pos(1)) / (axis_pos(3) - axis_pos(1));
        y_o = (y_o - axis_pos(2)) / (axis_pos(4) - axis_pos(2));
        y_f = (y_f - axis_pos(2)) / (axis_pos(4) - axis_pos(2));
        x_lim = lim_x(1) + (lim_x(2) - lim_x(1)) * sort([x_o x_f]);
        y_lim = lim_y(1) + (lim_y(2) - lim_y(1)) * sort([y_o y_f]);
        set(handle(1), 'Xlim', 10.^x_lim, 'Ylim', 10.^y_lim);
    else
        % don't care.    
    end;
elseif bt_flag>0
    % button moving flag
    point = get(gcf, 'currentpoint');                
    x = get(bt_flag, 'XData');
    y = get(bt_flag, 'YData');
    x(2:3) = [1 1]*point(1);
    y(3:4) = [1 1]*point(2);
    set(bt_flag, 'Xdata', x, 'Ydata', y);
    set(get(bt_flag,'parent'), 'Xlim', [0 1], 'YLim', [0 1]);
end;
