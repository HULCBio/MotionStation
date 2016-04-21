function combtnd2(bt_flag, plot_handle)
%WARNING: This is an obsolete function and may be removed in the future.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.12 $

if nargin < 2
    error('There must be two input variables in calling COMBTND2.')
end;
if plot_handle <= 0
    %button down calling
    % find the origination of the button down.
    x = get(gcf, 'currentpoint');
    pos_t_x = [.9 1];
    pos_t_y = [0, 1];
    pos_r_x = [1/5-0.07, 1];
    pos_r_y = [0 .061 .063 .124 .126 .187 .189 .25]+.103;
    pos_w_x = [0 1] *.15+ .73;
    pos_w_y = [0 1]*.08+.01;
    if x(1) < pos_r_x(1)
        return;
    elseif x(2) > max(pos_r_y)
        return;
    elseif (x(2) < min(pos_r_y)) & (x(1) < pos_w_x(1))
        return
    else
        handle = get(gcf, 'UserData');
        if ~isempty(handle)
            data_h = handle(60:63);
            load_save = handle(64:67);
            bar_color = handle(68);
        else
            error('The handle is destroyed. Close the window and open again.');
        end;
        if (x(2) <= .1) & (x(1) >= .9)
            %trash
            return
            % currently, this doing nothing.
        elseif (x(2) >= pos_r_y(7))
            % record 1
            frm_handle = data_h(1);
            fram = [pos_r_x; pos_r_y(7:8)];
        elseif (x(2) >= pos_r_y(5))
            % record 2
            frm_handle = data_h(2);
            fram = [pos_r_x; pos_r_y(5:6)];
        elseif (x(2) >= pos_r_y(3))
            % record 3
            frm_handle = data_h(3);
            fram = [pos_r_x; pos_r_y(3:4)];
        elseif (x(2) >= pos_r_y(1))
            % current computation data
            frm_handle = data_h(4);
            fram = [pos_r_x; pos_r_y(1:2)];
        elseif (x(1) >= pos_w_x(1)) & (x(1) <= pos_w_x(2))...
             & (x(2) >= pos_w_y(1)) & (x(2) <= pos_w_y(2))
            frm_handle = -1;
            fram = [pos_w_x; pos_w_y];
        else
            return;
        end;
        selection_type = get(gcf,'selectiontype');
        set(bar_color, 'Visible','on','String','Coping or remove data record...')

        set(load_save(4), 'XData', fram(1, [1 2 2 1 1]),...
                          'YData', fram(2, [1 1 2 2 1]),...
                          'UserData',[frm_handle, x(1), x(2)]);


%                          'ZData', 0*[2 2  2 2 2],...
        % set the button moving function.
        set(gcf,'WindowButtonMotionFcn',['combtnd2(''motion'',', num2str(load_save(4), 20), ')']);
        set(gcf,'WindowButtonUpFcn',['combtnd2(''up'',', num2str(load_save(4), 20), ')']);

        % set(gcf,'unit','pixel');
        % pos = get(gcf, 'position');
        % fram(1,:) = fram(1,:)*pos(3);
        % fram(2,:) = fram(2,:)*pos(4);

        % dragrect([fram(1,1), fram(2,1), fram(1,2)-fram(1,1), fram(2,2)-fram(2,1)]);

        % set(gcf, 'unit', 'norm');
        drawnow
    end
elseif bt_flag(1) == 'm'
    % motion
    x = get(gcf, 'currentpoint');
    udata = get(plot_handle, 'UserData');
    set(plot_handle, 'XData', get(plot_handle, 'XData') - udata(2) + x(1), ...
                     'YData', get(plot_handle, 'YData') - udata(3) + x(2), ...
                     'UserData', [udata(1), x(1), x(2)]);
%    udata = get(plot_handle,'parent');
%    udata = gcf;
%    set(udata,'color',get(udata,'color'));
elseif bt_flag(1) == 'u'
    % button up flag
    x = get(gcf, 'currentpoint');
    udata = get(plot_handle, 'UserData');
    frm_handle = udata(1);
    set(gcf,'WindowButtonMotionFcn','');
    set(gcf,'WindowButtonUpFcn','');
    set(plot_handle, 'XData',[], 'YData',[],'ZData', []);

    pos_t_x = [.9 1];
    pos_t_y = [0, 1];
    pos_r_x = [1/5-0.07, 1];
    pos_r_y = [0 .061 .063 .124 .126 .187 .189 .25]+.103;
    pos_w_x = [0 1] *.15+ .73;
    pos_w_y = [0 1]*.08+.01;

    handle = get(gcf, 'UserData');
    if ~isempty(handle)
        data_h = handle(60:63);
        load_save = handle(64:67);
        bar_color = handle(68);
    else
        error('The handle is destroyed. Close the window and open again.');
    end;

    if (x(2) <= .1) & (x(1) >= .9)
        %trash
        if (frm_handle > 0)
            set(frm_handle,'UserData',[],...
               'Visible','off');
        end;
    elseif (x(2) >= pos_r_y(7)) & (x(1) > pos_r_x(1))
        % record 1
        to_handle = data_h(1);
    elseif (x(2) >= pos_r_y(5)) & (x(1) > pos_r_x(1))
        % record 2
        to_handle = data_h(2);
    elseif (x(2) >= pos_r_y(3)) & (x(1) > pos_r_x(1))
        % record 3
        to_handle = data_h(3);
    elseif (x(2) >= pos_r_y(1)) & (x(1) > pos_r_x(1))
        % current computation data
        to_handle = data_h(4);
    elseif (x(1) >= pos_w_x(1)) & (x(1) <= pos_w_x(2))...
        & (x(2) >= pos_w_y(1)) & (x(2) <= pos_w_y(2))
        to_handle = 0;
        if frm_handle ~= -1;
            % open a window inputting put xx into
            % snr and ber variables
            xx=get(frm_handle, 'UserData');
            % write xx(1,:) to snr
            % write xx(2,:) to ber
            %%%%%%%%%%%%%%
            comwksp(1, xx);
        end;
    else
        to_handle = 0;
    end;
    if to_handle ~= frm_handle
       if to_handle
          if frm_handle > 0
             data = get(frm_handle,'UserData');
             if ~isempty(data)
                 set(to_handle, 'UserData', get(frm_handle,'UserData'),...
                     'Visible', 'on',...
                     'String', get(frm_handle,'String'));
             end
          else
              % open a window outputting snr and ber variable name into 
              % to_handle userdata and string
              %%%%%%%%%%%%%%
              comwksp(0, to_handle);
          end;
       end;
    end;
    set(bar_color, 'Visible','off','String','Loading setup, please wait...')
end;
