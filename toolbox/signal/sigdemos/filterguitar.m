function filterguitar
%FILTERGUITAR   Launches the virtual guitar demo.
%   FILTERGUITAR   Launches the virtual guitar demo which allows you to
%   specify chords on a guitar fretboard and synthesize them using
%   discrete-time filters.
%
% See also FILTERGUITARDEMO

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/20 23:20:39 $

frets.e    = 0;
frets.a    = 0;
frets.d    = 0;
frets.g    = 0;
frets.b    = 0;
frets.e2   = 0;
strum.e    = true;
strum.a    = true;
strum.d    = true;
strum.g    = true;
strum.b    = true;
strum.e2   = true;
filters.e  = [];
filters.a  = [];
filters.d  = [];
filters.g  = [];
filters.b  = [];
filters.e2 = [];
sound.e    = [];
sound.a    = [];
sound.d    = [];
sound.g    = [];
sound.b    = [];
sound.e2   = [];

hplayer = [];

Fs = 44.1e3;
seconds = 3.5;
strumoffset = 60; % In milliseconds
strumdirection = 'down'; % can be {'up' or 'down'}
strumstyle = 'down'; % can be {'up', 'down' or 'alternate'};

panelswitch = 0;

pixf = get(0,'screenpixelsperinch')/96;

updatefilters;

hfig = figure('menubar','none', ...
    'visible','off', ...
    'NumberTitle', 'Off', ...
    'ResizeFcn', @resize_cb, ...
    'Position', [0 0 700 500]*pixf, ...
    'Name', 'Synthetic Guitar Demo', ...
    'HandleVisibility', 'Off');

addmenu(hfig, 1, {'&File', 'New Guitar Demo', 'Close'}, ...
    {'', @new_cb, @close_cb});

addmenu(hfig, 2, '&Tools');

render_zoommenus(hfig, [2 1]);

render_sptwindowmenu(hfig, 3);
h = render_spthelpmenu(hfig, 4);

uimenu(h, ...
    'Position', 3, ...
    'Label', 'Launch Play Show Demo ...', ...
    'Callback', @playshow_cb);

render_zoombtns(hfig);

h.plotpanel = uipanel('Parent', hfig, ...
    'Units', 'Pixels', ...
    'tag','fvtool', ...
    'Position', [0 0 600 600]*pixf);

%     'ButtonDownFcn', @switch_cb, ...

h.axes = axes('Parent', h.plotpanel, ...
    'XGrid', 'On', ...
    'YGrid', 'On', ...
    'XLim', [0 22050], ...
    'Box', 'On');

h.morecontrolspanel = uipanel('Parent', hfig, ...
    'Units', 'Pixels', ...
    'tag','morecontrols', ...
    'Visible','Off', ...
    'Position', [0 0 600 600]*pixf);

% 'ButtonDownFcn', @switch_cb, ...

h.seconds_lbl = uicontrol(h.morecontrolspanel, ...
    'Position', [50 50 100 20]*pixf, ...
    'HorizontalAlignment', 'Left', ...
    'String', 'Length of sound', ...
    'Visible','Off', ...
    'Style','text');

h.seconds = uicontrol(h.morecontrolspanel, ...
    'Position', [145 53 60 20]*pixf, ...
    'String', num2str(seconds), ...
    'HorizontalAlignment', 'Left', ...
    'BackgroundCOlor','w', ...
    'Visible','Off', ...
    'Style','edit', ...
    'Callback', @seconds_cb);

h.strumoffset_lbl = uicontrol(h.morecontrolspanel, ...
    'Position', [50 75 100 20]*pixf, ...
    'HorizontalAlignment', 'Left', ...
    'String', 'Strum Offset', ...
    'Visible','Off', ...
    'Style','text');

h.strumoffset = uicontrol(h.morecontrolspanel, ...
    'Position', [145 78 60 20]*pixf, ...
    'String', num2str(strumoffset), ...
    'HorizontalAlignment', 'Left', ...
    'BackgroundColor','w', ...
    'Style','edit', ...
    'Visible','Off', ...
    'Callback', @strumoffset_cb);

h.strumgroup = uibuttongroup('Parent', h.morecontrolspanel, ...
    'Units','pixels', ...
    'Visible','Off', ...
    'position', [50 105 150 80]*pixf);

set(h.strumgroup, 'SelectionChangeFcn', @strumstyle_cb);

h.strumstyle(1) = uicontrol(h.strumgroup, ...
    'Position', [5 5 120 20]*pixf, ...
    'style','radio', ...
    'string', 'Alternate Strums', ...
    'Visible','Off', ...
    'tag', 'alternate');

h.strumstyle(2) = uicontrol(h.strumgroup, ...
    'Position', [5 30 120 20]*pixf, ...
    'style','radio', ...
    'string', 'Strum Up', ...
    'Visible','Off', ...
    'tag','up');

h.strumstyle(3) = uicontrol(h.strumgroup, ...
    'Position', [5 55 120 20]*pixf, ...
    'style','radio', ...
    'string', 'Strum Down', ...
    'Visible','Off', ...
    'tag', 'down');

set(h.strumstyle(3), 'Value', 1);

guitarw = 130;

h.guitarpanel = uipanel('Parent', hfig, ...
    'Units', 'Pixels', ...
    'Tag', 'guitar', ...
    'Position', [600 0 guitarw 600]*pixf);

h.controlpanel = uicontainer('Parent', h.guitarpanel, ...
    'Units', 'Pixels', ...
    'tag', 'controls', ...
    'Position', [5 5 guitarw-10 55]*pixf);

h.labelpanel = uicontainer('Parent', h.guitarpanel, ...
    'Units', 'Pixels', ...
    'Tag', 'labels', ...
    'Position', [5 400 guitarw-10 40]*pixf);

h.info = uicontrol(hfig, ...
    'style', 'edit', ...
    'Max', 2, ...
    'BackgroundColor', 'w', ...
    'HorizontalAlignment', 'Left', ...
    'String', sprintf('%s%s%s%s%s', 'The virtual guitar demo uses discrete-time ', ...
        'filter objects (DFILTs) to generate sound waves that simulate ', ...
        'the strumming of a guitar string.  The magnitude plot shows how each ', ...
        'filter has peaks at the harmonics for the string it is meant to represent.  ', ...
        'For more information run ''playshow filterguitardemo''.'), ...
    'position', [1 1 600 50]*pixf);

h.play = uicontrol(h.controlpanel, ...
    'Position', [5 5 guitarw-20 20]*pixf, ...
    'Callback', @play_cb, ...
    'String', 'Play Chord');

h.chord_lbl = uicontrol(h.controlpanel, ...
    'Position', [5 27 35 18]*pixf, ...
    'Style','Text', ...
    'HorizontalAlignment', 'Left', ...
    'String', 'Chord');

h.chord = uicontrol(h.controlpanel, ...
    'Position', [45 30 guitarw-60 20]*pixf, ...
    'Style', 'Popup', ...
    'BackgroundColor', 'w', ...
    'Callback', @chord_cb, ...
    'String', {'Custom', 'C', 'G','A','E','D','F','Am','Em','Bm','Dm',...
       'Fm'}); %,'C7','G7','A7','E7','D7','F7'});

h.fretboard = axes('Parent', h.guitarpanel, ...
    'XTick', [], ...
    'YTick', [], ...
    'Box', 'On', ...
    'Units', 'Pixels', ...
    'Position', [5 60 guitarw-10 400]*pixf, ...
    'Tag', 'fretboard', ...
    'XLim', [.4 6.9], ...
    'YLim', [-1 23], ...
    'ButtonDownFcn', @string_cb, ...
    'Color', [.5 .25 .25]);

setappdata(h.fretboard, 'zoomable', 'off');

h.head = line([0 7], [22 22], ...
    'Parent', h.fretboard, ...
    'HitTest', 'Off', ...
    'Color', [0 0 0], ...
    'LineWidth', 3);

for indx = 1:21
    h.frets(indx) = line([0 7], [22-indx 22-indx], ...
        'Parent', h.fretboard, ...
        'HitTest', 'Off', ...
        'Tag', sprintf('%d', indx), ...
        'Color', [.7 .7 .7]);
end

dots = [2.5 4.5 6.5 8.5 14.5 16.5 18.5 20.5];

for indx = 1:length(dots)
    h.dots(indx) = line(3.5, dots(indx), ...
        'Parent', h.fretboard, ...
        'Marker', 'o', ...
        'Color', 'w', ...
        'MarkerSize', 7, ...
        'MarkerFaceColor', 'w');
end

h.dots(end+1) = line([4.5 2.5], [11.5 11.5], ...
    'Parent', h.fretboard, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'Color', 'w', ...
    'MarkerSize', 7, ...
    'MarkerFaceColor', 'w');

tags = getstringnames;

spacer = (guitarw-20-18*6)/5*pixf;
pos = [5 5 18 18]*pixf;

for indx = 1:6

    h.labels.(tags{indx}) = uicontrol(h.labelpanel, ...
        'Tag', tags{indx}, ...
        'Style', 'Text', ...
        'HorizontalAlignment', 'Left', ...
        'String', upper(tags{indx}), ...
        'Position', pos+[0 11 0 0]*pixf);

    h.checkbox.(tags{indx}) = uicontrol(h.labelpanel, ...
        'Tag', tags{indx}, ...
        'Style', 'Checkbox', ...
        'Value', 1, ...
        'Callback', @checkbox_cb, ...
        'Position', pos);

    h.string.(tags{indx}) = line([indx indx], [-1 22], ...
        'Parent', h.fretboard, ...
        'LineWidth', 3-indx*.4, ...
        'HitTest', 'Off', ...
        'Color', [0 0 0]);
    %         'ButtonDownFcn', {@string_cb, tags{indx}}, ...

    h.finger.(tags{indx}) = line(indx, 22.5, ...
        'Parent', h.fretboard, ...
        'ButtonDownFcn', @finger_cb, ...
        'Color', 'b', ...
        'tag', tags{indx}, ...
        'Marker', 'o', ...
        'MarkerSize', 8, ...
        'MarkerFaceColor', 'b');

    pos(1) = pos(1)+spacer+18*pixf;
end

resize_cb(hfig);
movegui(hfig, 'center');

updateplot;

set(hfig, 'Visible', 'On');

% -------------------------------------------------------------------------
    function chord_cb(hcbo, eventStruct)
        
        panelswitch = 0;
        set(h.play, 'Enable', 'Off');
        
        ptr = getptr(hfig);
        set(hfig, 'Pointer', 'watch');
        
        switch lower(popupstr(hcbo))
            case 'custom'
                set(hfig, ptr{:});
                return;
            case 'c'
                fret = {[], 3, 2, 0, 1, 0};
            case 'g'
                fret = {3, 2, 0, 0, 0, 3};
            case 'a'
                fret = {[], 0, 2, 2, 2, 0};
            case 'e'
                fret = {0, 2, 2, 1, 0, 0};
            case 'd'
                fret = {[], [], 0, 2, 3, 2};
            case 'f'
                fret = {1, 3, 3, 2, 1, 1};
            case 'am'
                fret = {0,0,2,2,1,0};
            case 'em'
                fret = {0,2,2,0,0,0};
            case 'bm'
                fret = {2, 2, 4, 4, 3, 2};
            case 'dm'
                fret = {5, 5, 7, 7, 6, 5};
            case 'fm'
                fret = {1, 3, 3, 1, 1, 1};
            case 'c7'
                fret = {[], 3, 2, 3, 1, []};
            case 'g7'
                fret = {[], [], 0, 0, 0, 1};
            case 'a7'
                fret = {[], 0, 2, 0, 2, 0};
            case 'e7'
                fret = {0, 2, 2, 1, 3, 0};
            case 'd7'
                fret = {[], [], 0, 2, 1, 2};
            case 'f7'
                fret = {1,3,1,2,1,1};
        end

        tags = getstringnames;
        
        for indx = 1:length(tags)
            if isempty(fret{indx})
                strum.(tags{indx}) = false;
            else
                if fret{indx} ~= frets.(tags{indx})
                    frets.(tags{indx}) = fret{indx};
                    filters.(tags{indx}) = [];
                    sound.(tags{indx}) = [];
                end
                strum.(tags{indx}) = true;
            end
        end

        updatecheckboxes;
        updatefingers;
        drawnow;
        updatefilters;
        updateplot;
        set(hfig, ptr{:});
        set(h.play, 'Enable', 'On');
    end

% -------------------------------------------------------------------------
    function finger_cb(hcbo, eventStruct)
                
        panelswitch = 0;
        string = get(hcbo, 'Tag');
        
        sound.(string) = getsound(filters.(string));
        
        playsound(sound.(string));
    end

% -------------------------------------------------------------------------
    function string_cb(hax, eventStruct)

        panelswitch = 0;
        set(h.chord, 'Value', 1);
        set(h.play, 'Enable', 'Off');

        ptr = getptr(hfig);
        set(hfig, 'Pointer', 'watch');
        
        cp = get(hax, 'CurrentPoint');

        fret = 23-ceil(cp(1,2));
        
        if fret < 0,  fret = 0;  end
        if fret > 21, fret = 21; end

        string = round(cp(1,1));

        switch string
            case {0, 1}
                string = 'e';
            case 2
                string = 'a';
            case 3
                string = 'd';
            case 4
                string = 'g';
            case 5
                string = 'b';
            case {6, 7}
                string = 'e2';
        end

        if frets.(string) == fret && strum.(string)
            set(hfig, ptr{:});
            return;
        end
        
        frets.(string)   = fret;
        sound.(string)   = [];
        strum.(string)   = true;
        filters.(string) = [];

        updatecheckboxes;
        updatefingers;
        drawnow;
        updatefilters;
        updateplot;
        set(hfig, ptr{:});
        set(h.play, 'Enable', 'On');

    end

% -------------------------------------------------------------------------
    function play_cb(hcbo, eventStruct)
        
        panelswitch = 0;
        ptr = getptr(hfig);
        set(hfig, 'Pointer', 'watch');

        tags = getstringnames;
        
        for indx = 1:length(tags)
            if strum.(tags{indx}) && isempty(sound.(tags{indx}))
                sound.(tags{indx}) = getsound(filters.(tags{indx}));
            end
        end

        sounds2play = sound;
        for indx = 1:length(tags)
            if ~strum.(tags{indx})
                sounds2play = rmfield(sounds2play, tags{indx});
            end
        end

        y = struct2cell(sounds2play);

        playsound(y{:});
        set(hfig, ptr{:});
    end

% -------------------------------------------------------------------------
    function checkbox_cb(hcbo, eventStruct)
        panelswitch = 0;
        set(h.play, 'Enable', 'Off');
        set(h.chord, 'Value', 1);

        ptr = getptr(hfig);
        set(hfig, 'Pointer', 'watch');
        strum.(get(hcbo, 'tag')) = logical(get(hcbo, 'Value'));

        updatefingers;
        drawnow;
        updateplot;
        set(hfig, ptr{:});
        set(h.play, 'Enable', 'On');
    end

% -------------------------------------------------------------------------
    function resize_cb(hFig, eventStruct)

        figpos = get(hFig, 'Position')/pixf;

        set([h.plotpanel h.morecontrolspanel], 'Position', ...
            [0 50 figpos(3)-guitarw figpos(4)-51]*pixf);
        set(h.guitarpanel, 'Position', [figpos(3)-guitarw 0 guitarw figpos(4)]*pixf);
        set(h.fretboard,   'Position', [5 60 guitarw-10 figpos(4)-100]*pixf);
        set(h.labelpanel,  'Position', [5 figpos(4)-40 guitarw-10 35]*pixf);
        set(h.info,        'Position', [1 1 figpos(3)-guitarw-2 50]*pixf);
    end

% -------------------------------------------------------------------------
    function seconds_cb(hp, eventStruct)
        
        new_seconds = str2num(get(hp, 'String'));
        if isempty(new_seconds)
            set(hp, 'String', num2str(seconds));
        else
            seconds = new_seconds;
            sound.e = [];
            sound.a = [];
            sound.d = [];
            sound.b = [];
            sound.g = [];
            sound.e2 = [];
        end
    end

% -------------------------------------------------------------------------
    function strumoffset_cb(hp, eventStruct)
        
        new_strumoffset = str2num(get(hp, 'String'));
        if isempty(new_strumoffset)
            set(hp, 'String', num2str(strumoffset));
        else
            strumoffset = new_strumoffset;
            sound.e = [];
            sound.a = [];
            sound.d = [];
            sound.b = [];
            sound.g = [];
            sound.e2 = [];
        end
    end

% -------------------------------------------------------------------------
    function switch_cb(hp, eventStruct)
        
        hFig = ancestor(hp, 'figure');
        
        stype = get(hFig, 'SelectionType');

        pause(.1);
        
        switch lower(stype)
            case 'alt'
                if panelswitch == 2
                    if h.plotpanel == hp
                        vis1 = 'Off';
                        vis2 = 'On';
                    else
                        vis1 = 'On';
                        vis2 = 'Off';
                    end

                    set(h.plotpanel, 'Visible', vis1);
                    set([h.morecontrolspanel h.strumgroup h.strumoffset_lbl ...
                        h.strumoffset h.seconds_lbl h.seconds h.strumstyle], 'Visible', vis2);
                end
                panelswitch = 0;
            case 'open'
                if panelswitch == 1
                    panelswitch = 2;
                else
                    panelswitch = 0;
                end
            otherwise
                panelswitch = 1;
        end
    end

% -------------------------------------------------------------------------
    function strumstyle_cb(hp, eventStruct)
        
        strumstyle = get(get(hp, 'SelectedObject'), 'Tag');
    end

% -------------------------------------------------------------------------
    function updatecheckboxes
        
        tags = getstringnames;
        for indx = 1:length(tags)
            set(h.checkbox.(tags{indx}), 'Value', strum.(tags{indx}));
        end
        
    end

% -------------------------------------------------------------------------
    function updatefilters

        tags = getstringnames;
        for indx = 1:length(tags)
            if isempty(filters.(tags{indx}))
                filters.(tags{indx}) = guitarfilter(tags{indx}, frets.(tags{indx}));
            end
        end
    end

% -------------------------------------------------------------------------
    function updatefingers

        tags = getstringnames;
        for indx = 1:length(tags)
            if strum.(tags{indx})
                visState = 'On';
            else
                visState = 'Off';
            end
            set(h.finger.(tags{indx}), 'YData', 23-frets.(tags{indx})-.5, ...
                'Visible', visState);
        end
    end

% -------------------------------------------------------------------------
    function updateplot

        Hd = getplayedfilters;
        
        [H, W] = freqz(Hd, 8192, Fs);
        
        delete(allchild(h.axes));
        
        line(W, 20*log10(abs(H)), 'Parent', h.axes);
        
        title(h.axes,  'Harmonics');
        ylabel(h.axes, 'Magnitude (dB)');
        xlabel(h.axes, 'Frequency (Hz)');
        
        hu = siggetappdata(hfig, 'siggui','mousezoom');
        
        oldxlim = get(h.axes, 'XLim');
        oldylim = get(h.axes, 'Ylim');
        
        set(h.axes, 'XLim', [0 22050]);
        set(h.axes, 'YLimMode', 'auto');

        if ~isempty(hu)
            hu.capture(h.axes);
            hu.zoomin(h.axes, oldxlim, oldylim);
        end
    end

% -------------------------------------------------------------------------
    function Hd = getplayedfilters

        index = [strum.e strum.a strum.d strum.g strum.b strum.e2];
        Hd    = [filters.e filters.a filters.d filters.g filters.b filters.e2];

        Hd = Hd(logical(index));
    end

% -------------------------------------------------------------------------
    function playsound(varargin)

        offset = floor(strumoffset*Fs/1000);
        
        direction = strumstyle;
        if strcmpi(direction, 'alternate')
            direction = strumdirection;
        end
        
        % Add strumming "offset"
        for indx = 1:length(varargin)
            varargin{indx} = varargin{indx}-mean(varargin{indx});
            if strcmpi(direction, 'down')
                varargin{indx} = [zeros(offset*(indx-1),1); ...
                    varargin{indx}(1:end-offset*(indx-1))];
            else
                varargin{indx} = [zeros(offset*(6-indx),1); ...
                    varargin{indx}(1:end-offset*(6-indx))];
            end
        end
        
        y = sum([varargin{:}],2);
        y = y/max(abs(y));
                
        winlength = Fs/2;
        
        % We need to window the signal
        win = hann(winlength);
        win = win(winlength/2+1:end);
        
        y(end-winlength/2+1:end) = y(end-winlength/2+1:end).*win;

        hplayer = audioplayer(y, Fs);
        play(hplayer);
        
        if strcmpi(strumstyle, 'alternate')
            if strcmpi(strumdirection, 'up')
                strumdirection = 'down';
            else
                strumdirection = 'up';
            end
        end
    end

% -------------------------------------------------------------------------
    function y = getsound(Hd)
        
        if isa(Hd, 'dfilt.dfiltwfs')
            Hd = Hd.Filter;
        end

        Hd.ResetBeforeFiltering = 'Off';
        Hd.States.Numerator   = rand(length(Hd.Numerator)-1, 1);
        Hd.States.Denominator = rand(length(Hd.Denominator)-1, 1);

        y = filter(Hd, zeros(Fs*seconds, 1));
    end

% -------------------------------------------------------------------------
    function Hd = guitarfilter(string, fret)

        if isempty(fret)
            Hd = [];
        else
            s = guitarfrequency(string, fret);

            delay = round(Fs/s);

            b = firls(42, [0 1/delay 1.5/delay 1], [0 0 1 1]);
            a = [1 zeros(1,delay-1) -0.5 -0.5];

            Hd = dfilt.df1(b,a);
        end
    end

%------------------------------------------------------------
    function tags = getstringnames

        tags = {'e','a','d','g','b','e2'};
    end

%------------------------------------------------------------
    function a = guitarfrequency(string, fret)

        % a is at 440 Hz, the A string is 2 octaves below that.
        a = 440/4;
        
        % Guitar strings.
        switch lower(string)
            case 'e'
                fret = fret-5;
            case 'a'
            case 'd'
                fret = fret+5;
            case 'g'
                fret = fret+10;
            case 'b'
                fret = fret+14.1;
            case 'e2'
                fret = fret+19.1;
        end

        a = a*(2^(fret/12));
    end

%------------------------------------------------------------
    function new_cb(hcbo, eventStruct)
        
        dfiltguitar;
        
    end

%------------------------------------------------------------
    function close_cb(hcbo, eventStruct)

        close(ancestor(hcbo, 'figure'));
    end

%------------------------------------------------------------
    function playshow_cb(hcbo, eventStruct)

        playshow('filterguitardemo');
    end
end

% [EOF]
