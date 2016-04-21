function [v34_rate_b, v34_rate_p, v34_rate_j] = v34prep(SRATE, BRATE, con_code, v34_plot_flag);
%V34PREP prepares the data for the v34 modem example.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       [RATE_B, RATE_P, RATE_J] = V34PREP(SRATE, BRATE, CON_CODE, PLOT_FLAG)
%       calculates the rate information for the V34 modem. When PLOT_FLAG = 0,
%       there is no plot generated from this function. When PLOT_FLAG = 1, a
%       figure is generated and the constellation matching this parameter
%       is produced.  When PLOT_FLAG = 2, the number in the figure is binary
%       numbered.
%
%       See also V34CONST, V34PARAM, V34STRUC.

%       Wes Wang 2/6/96
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.14 $

if nargin < 2
    BRATE = 9600;
end;

if nargin < 1
    SRATE = 3200;
    BRATE = 28800;
end

if nargin < 3
    con_code = 1;
end;
if nargin < 4
    v34_plot_flag = 1;
end; 

[v34_rate, v34_sm, v34_convolution_coder, v34_inp, v34_qua] = v34param(SRATE, BRATE, con_code, 1);
v34_rate_b = v34_rate(6);
v34_rate_p = v34_rate(4);
v34_rate_j = v34_rate(3);

if ~exist('v34_plot_flag')
    v34_plot_flag = 0;
end;
if v34_plot_flag >= 1
    % checkout the figure.
    v34_fig_name = 'V34 Parameter';
    v34_handle = allchild(0);
    v34_found_fig = 0;
    if ~isempty(v34_handle)
        for i = 1 : length(v34_handle)
            if strcmp(get(v34_handle(i), 'Name'), v34_fig_name)
                v34_found_fig = v34_handle(i);
            end;
        end;
    end;
    if v34_found_fig > 0
        set(v34_found_fig, 'Visible','off',...
            'HandleVisibility',  'off');
        v34_child = allchild(v34_found_fig);
        if ~isempty(v34_child);
            delete(v34_child);
        end
        clear v34_child;
        set(0,'CurrentFigure',v34_found_fig);
    else
        v34_found_fig = figure(...
            'Name', v34_fig_name,...
            'NumberTitle','off',...
            'Unit', 'normal',...
            'MenuBar', 'none',...
            'Position', [.01, .01, .5, .8],...
            'Visible','off',...
            'HandleVisibility', 'off'...
            );            
    end;
    set(v34_found_fig,'DefaultTextFontSize',9)
    v34_child(1) = axes('Position',[0 0 1 1],...
                        'Visible','off',...
                        'Parent', v34_found_fig,...
                        'HandleVisibility', 'off');

    V34_VAR_NAME = {'Symbol Rate S:';
                    'Bit Rate R:';
                    '# of Dataframe per Superframe J:';
                    '# of Mapframe per Dateframe P:';
                    '# of bit per Dataframe N:';
                    '# of bit per Mapframe b:';
                    '# of dividing bit in parser q:';
                    '# of shell mapping bit K:';
                    '# of rings in shell mapping M:';
                    'Extended M:';
                    '# of points in 2D constellation L:';
                    'Extended L:'};
    set(v34_child(1),'DefaultTextFontSize',9)
    for i = 1 : 12
        v34_tmp = text(.05, 1 - i*.03, V34_VAR_NAME{i},...
                       'parent', v34_child(1));
        set(v34_tmp,'Color',[0 0 1])
        v34_tmp = text(.65, 1 - i*.03, num2str(v34_rate(i), 10), ...
                       'parent', v34_child(1));
        set(v34_tmp,'Color',[1 0 1])
    end
    if (v34_rate_b <= 12) | (v34_rate_b > 72) ...
       | (BRATE/SRATE ~= floor(BRATE/SRATE))
        v34_tmp = text(.05, .61, ['The designed Call modem and ',...
                  'Answer modem cannot simulate your given rate.'],...
                  'parent', v34_child(1));
        set(v34_tmp,'Color',[1 0 0]);    
    end;
    v34_tmp = text(.05, .58, ...
              'One quarter of the points in the constellation:', ...
              'parent', v34_child(1));
    set(v34_tmp,'Color',[0 0 0])
    v34_child(2) = axes('position',[0.05, .06, .9, .5],...
        'FontSize',9,...
        'parent', v34_found_fig,...
        'HandleVisibility',  'off');
%    v34_tmp = get(v34_child(2),'DataAspect');
%    set(v34_child(2),'DataAspect',[1,v34_tmp(2)]);
    v34_tmp = plot(v34_inp, v34_qua, 'm.', 'parent', v34_child(2));
    set(v34_tmp, 'MarkerSize', 10);
    set(v34_child(2),'DefaultTextFontSize',7,...
        'Xlim',[min(v34_inp)-5, max(v34_inp)+5],...
        'Ylim',[min(v34_qua)-3, max(v34_qua)+3],...
        'DataAspectRatio',[1,1,1]);
    if v34_plot_flag == 2
        for i = 1 : length(v34_qua)
            text(v34_inp(i)+.1, v34_qua(i), ...
              num2str(de2bi(i-1, ceil(log(length(v34_qua)/log(10))))),...
              'parent', v34_child(2));
        end;
    else
        for i = 1 : length(v34_qua)
            text(v34_inp(i)+.1, v34_qua(i), num2str(i-1),...
              'parent', v34_child(2));
        end;
    end
    set(v34_found_fig,'Visible','on');
%    xlabel('In-phase', 'parent', v34_child(2));
%    ylabel('Quadrature', 'parent', v34_child(2));
    set(get(v34_child(2), 'Xlabel'), 'String', 'In-phase');
    set(get(v34_child(2), 'Ylabel'), 'String', 'Quadrature');
    clear v34_tmp v34_child v34_found_fig v34_fig_name
end;
clear v34_rate v34_sm v34_convolution_coder v34_inp v34_qua

