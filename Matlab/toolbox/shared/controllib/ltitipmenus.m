function ltitipmenus(tiphandle,varargin)
%LTITIPMENUS Add UIContextMenu items to datatip
%
%  h.addmenu('alignment','fontsize','movable','delete') adds any of the standard menus
%  are added to the h.UIContextMenu handle according to the users selection.
%
%

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%   $ $  $Date: 2004/04/11 00:27:47 $

if nargin > 1
    for i= 2:nargin
        switch lower(varargin{i-1})
            case 'fontsize'
                %---FontSize
                CM1 = uimenu(tiphandle.UIContextMenu,'Label',sprintf('FontSize'),'Tag','FontSize');
                CM2 = uimenu(CM1,'Label','6', 'Tag','6', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',6));
                CM2 = uimenu(CM1,'Label','8', 'Tag','8', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',8));
                CM2 = uimenu(CM1,'Label','10','Tag','10','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',10));
                CM2 = uimenu(CM1,'Label','12','Tag','12','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',12));
                CM2 = uimenu(CM1,'Label','14','Tag','14','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',14));
                CM2 = uimenu(CM1,'Label','16','Tag','16','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',tiphandle,'FontSize',16));
                CH = get(CM1,'Children');
                set(findobj(CH,'flat','Tag',num2str(get(tiphandle,'FontSize'))),'Checked','on');

            case 'alignment'
                %---Alignment
                CM1 = uimenu(tiphandle.UIContextMenu,'Label',sprintf('Alignment'),'Tag','Alignment');
                CM2 = uimenu(CM1,'Label',sprintf('Top-Right'),   'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',tiphandle,'H','left','V','bottom'));
                CM2 = uimenu(CM1,'Label',sprintf('Top-Left'),    'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',tiphandle,'H','right','V','bottom'));
                CM2 = uimenu(CM1,'Label',sprintf('Bottom-Right'),'Callback',{@LocalSelectMenu,'alignment'},'Sep','on',...
                    'UserData',struct('DataTip',tiphandle,'H','left','V','top'));
                CM2 = uimenu(CM1,'Label',sprintf('Bottom-Left'), 'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',tiphandle,'H','right','V','top'));

                CH = get(CM1,'Children');
                switch tiphandle.Orientation
                    case 'top-right'
                        set(findobj(CH,'flat','Position',1),'Checked','on');
                    case 'top-left'
                        set(findobj(CH,'flat','Position',2),'Checked','on');
                    case 'bottom-right'
                        set(findobj(CH,'flat','Position',3),'Checked','on');
                    case 'bottom-left'
                        set(findobj(CH,'flat','Position',4),'Checked','on');
                end

                %---Add a listener to the alignment property to set the menu
                %   item checkbox properly
                l = handle.listener(tiphandle,tiphandle.findprop('Orientation'),'PropertyPostSet',{@LocalUpdateAlignment, tiphandle});
                tiphandle.addlistener(l)

            case 'movable'
                %---Movable
                CM1 = uimenu(tiphandle.UIContextMenu,'Label',sprintf('Movable'),...
                    'Callback',{@LocalSelectMenu,'movable'},...
                    'UserData',struct('DataTip',tiphandle));
                if     strcmpi(tiphandle.Draggable,'on')
                    set(CM1,'Checked','on');
                else
                    set(CM1,'Checked','off');
                end

            case 'delete'
                %---Delete Menu
                CM1 = uimenu(tiphandle.UIContextMenu,'Label',sprintf('Delete'),'Callback',{@LocalSelectMenu,'delete'},...
                    'UserData',struct('DataTip',tiphandle));

            case 'interpolation'

                %---Interpolation
                CM1 = uimenu(tiphandle.UIContextMenu,'Label',sprintf('Interpolation'),'Tag','Interpolation');
                CM2 = uimenu(CM1,'Label',sprintf('Nearest'),'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',tiphandle,'Interpolate','off'));
                CM2 = uimenu(CM1,'Label',sprintf('Linear'),'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',tiphandle,'Interpolate','on'));
                CH = get(CM1,'Children');
                if strcmpi(tiphandle.Interpolate,'on')
                    set(findobj(CH,'flat','Position',2),'Checked','on');
                else
                    set(findobj(CH,'flat','Position',1),'Checked','on');
                end

            case 'trackmode'

                %---Track Mode
                CM1 = uimenu(h.UIContextMenu,'Label',sprintf('Track Mode'),'Tag','Trackmode');
                CM2 = uimenu(CM1,'Label',sprintf('x'),'Callback',{@LocalSelectMenu,'trackmode'},...
                    'UserData',struct('DataTip',h,'Tracking','x'));
                CM2 = uimenu(CM1,'Label',sprintf('y'),'Callback',{@LocalSelectMenu,'trackmode'},...
                    'UserData',struct('DataTip',h,'Tracking','y'));
                CM2 = uimenu(CM1,'Label',sprintf('xy'),'Callback',{@LocalSelectMenu,'trackmode'},...
                    'UserData',struct('DataTip',h,'Tracking','xy'));
                CH = get(CM1,'Children');

                if strcmpi(h.Tracking,'xy')
                    set(findobj(CH,'flat','Position',3),'Checked','on');
                elseif strcmpi(h.Tracking,'y')
                    set(findobj(CH,'flat','Position',2),'Checked','on');
                else
                    set(findobj(CH,'flat','Position',1),'Checked','on');
                end

            case 'minmax'
                %---Min/Max
                CM1 = uimenu(h.UIContextMenu,'Label',sprintf('Min/Max'),'Sep','on',...
                    'UserData',struct('DataTip',h));
                CM2 = uimenu(CM1,'Label',sprintf('Min'),  'Callback',{@LocalSelectMenu,'minmax'},...
                    'UserData',struct('DataTip',h,'MinMax','min'));
                CM2 = uimenu(CM1,'Label',sprintf('Max'),  'Callback',{@LocalSelectMenu,'minmax'},...
                    'UserData',struct('DataTip',h,'MinMax','max'));

            otherwise
                disp([varargin{i-1},' is not a valid menu selection'])
        end
    end
end

%%%%%%%%%%%%%%%%%%%
% LocalUpdateAlignment %
%%%%%%%%%%%%%%%%%%%
function LocalUpdateAlignment(eventSrc,eventData,tiphandle)

MenuChildren = get(tiphandle.UIContextMenu,'Children');
CH1 = findobj(MenuChildren,'Label','Alignment');

if ~isempty(CH1)
    CH = get(CH1,'Children');

    set(CH(:),'Checked','off');
    switch tiphandle.Orientation
        case 'top-right'
            set(findobj(CH,'flat','Position',1),'Checked','on');
        case 'top-left'
            set(findobj(CH,'flat','Position',2),'Checked','on');
        case 'bottom-right'
            set(findobj(CH,'flat','Position',3),'Checked','on');
        case 'bottom-left'
            set(findobj(CH,'flat','Position',4),'Checked','on');
    end
end

%%%%%%%%%%%%%%%%%%%
% LocalSelectMenu %
%%%%%%%%%%%%%%%%%%%

function LocalSelectMenu(eventSrc,eventData,action)

Menu = eventSrc;
mud = get(Menu,'UserData');
h  = mud.DataTip;

switch lower(action)

    case 'fontsize'
        set(h,'FontSize',mud.FontSize);
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
    case 'alignment'
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');

        if     strcmpi(mud.V,'top') & strcmpi(mud.H,'right')
            h.Orientation = 'bottom-left';
        elseif strcmpi(mud.V,'top') & strcmpi(mud.H,'left')
            h.Orientation = 'bottom-right';
        elseif strcmpi(mud.V,'bottom')    & strcmpi(mud.H,'right')
            h.Orientation = 'top-left';
        elseif strcmpi(mud.V,'bottom')    & strcmpi(mud.H,'left')
            h.Orientation = 'top-right';
        end

    case 'movable'
        if strcmpi(get(Menu,'Checked'),'on')
            h.Draggable = 'off';
            set(Menu,'Checked','off')
        else
            h.Draggable = 'on';
            set(Menu,'Checked','on')
        end

    case 'delete'
        delete(h);
        return

    case 'interpolation'
        h.Interpolate = mud.Interpolate;

    case 'trackmode'
        h.Tracking = mud.Tracking;

    case 'minmax'
        %     set(h.TipListeners{8},'Enabled','off');
        if strcmpi(mud.MinMax, 'max')
            xdata = get(h.Host,'Xdata');
            ydata = get(h.Host,'Ydata');
            [Ymax,i] = max(ydata);
            Xmax = xdata(i);
            h.Position = [Xmax, Ymax, h.Position(3)];

        elseif strcmpi(mud.MinMax, 'min')
            xdata = get(h.Host,'Xdata');
            ydata = get(h.Host,'Ydata');
            [Ymin,i] = min(ydata);
            Xmin = xdata(i);
            h.Position = [Xmin, Ymin, h.Position(3)];
        end
end
