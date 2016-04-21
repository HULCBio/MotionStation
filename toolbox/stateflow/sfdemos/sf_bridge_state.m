function sf_bridge_state(cmd, arg)

% Copyright 2002-2003 The MathWorks, Inc.

    persistent north;
    persistent south;
    persistent east;
    persistent west;
    persistent bids;
    persistent dealer;
    persistent fig;
    persistent bidders;

    if isempty(fig)
        fig = init_GUI_l;
    end

    switch cmd
    case 'deal'
        dealer = arg;
        bids = [];
        bidders = {'North','East','South','West'};
        dealerIndex = find(~cellfun('isempty', regexp(bidders, dealer)));
        bidders = {bidders{dealerIndex:end} bidders{1:dealerIndex-1}};
    case 'bid'
        bids(end+1) = arg;
    case 'north'
        north = arg;
    case 'south'
        south = arg;
    case 'east'
        east = arg;
    case 'west'
        west = arg;
    case 'all_pass'
        s = get(fig, 'UserData');
        set(s.dealerString, 'String', [dealer ' dealer']);

        set(s.northHand, 'String', gen_hand_l('North', north));
        set(s.eastHand, 'String', gen_hand_l('East', east));
        set(s.southHand, 'String', gen_hand_l('South', south));
        set(s.westHand, 'String', gen_hand_l('West', west));

        set(s.aBids, 'String', gen_bids_l(bids, bidders, 1));
        set(s.bBids, 'String', gen_bids_l(bids, bidders, 2));
        set(s.cBids, 'String', gen_bids_l(bids, bidders, 3));
        set(s.dBids, 'String', gen_bids_l(bids, bidders, 4));

        set(fig, 'Visible', 'on');
    case 'resize'
        resize_l(fig);
    end

function fig = init_GUI_l

    fig = findall(0, 'type', 'figure', 'tag', 'SF_BRIDGE');
    if ~isempty(fig)
        return;
    end

    % screen size etiqette
    units = 'points';
    screenUnits = get(0, 'Units');
    set(0, 'Units', units);
    screenSize = get(0, 'ScreenSize');
    set(0, 'Units', screenUnits);

    % default figure size
    figureHeight = 300;
    figureWidth = 200;

    % create a figure
    fig = figure('doubleBuffer', 'on',...
                 'MenuBar', 'none',...
                 'Name', 'Bridge',...
                 'Tag', 'SF_BRIDGE',...
                 'NumberTitle', 'off',...
                 'Visible', 'off',...
                 'HandleVisibility', 'off',...
                 'IntegerHandle', 'off',...
                 'Color', 'white',...
                 'Units', units,...
                 'DefaultUIControlUnits', units,...
                 'CloseRequestFcn', 'set(gcbf, ''Visible'', ''off'');',...
                 'ResizeFcn', 'sf_bridge_state(''resize'');',...
                 'Position', [(screenSize(3)-figureWidth)/2 (screenSize(4)-figureHeight)/2 figureWidth figureHeight]);

    %%% destroy figure when simulation terminates
    set_param('sf_bridge','StopFcn',sprintf('if ishandle(%f); delete(%f); end;',fig,fig));

    s.axes = axes('Parent', fig,...
                  'visible', 'off',...
                  'position', [0 0 1 1]);

    s.dealerString = text([0], [0], '',...
                          'Parent',               s.axes,...
                          'Interpreter',          'none',...
                          'VerticalAlignment',    'Top',...
                          'Clipping',             'off',...
                          'HorizontalAlignment',  'Center');

    s.northHand = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.southHand = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.eastHand  = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.westHand  = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.aBids     = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.bBids     = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.cBids     = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

    s.dBids     = text([0], [0], '',...
                       'Parent',               s.axes,...
                       'Interpreter',          'tex',...
                       'VerticalAlignment',    'Top',...
                       'Clipping',             'off',...
                       'HorizontalAlignment',  'Left');

   set(fig, 'UserData', s);

   resize_l(fig);


function resize_l(fig);

    s = get(fig, 'UserData');

    % get the current size
    position = get(fig, 'Position');

    % reset the dimensions on the axes
    set(s.axes, 'xlim', [0 position(3)],...
                'ylim', [0 position(4)]);

    handHeight = 70;

    set(s.dealerString, 'Position', [position(3)/2 position(4)-5]);

    set(s.northHand, 'Position', [position(3)/2-20 position(4)-20]);
    set(s.westHand,  'Position', [10 position(4)-20-handHeight]);
    set(s.eastHand,  'Position', [position(3)-80 position(4)-20-handHeight]);
    set(s.southHand, 'Position', [position(3)/2-20 position(4)-20-2*handHeight]);

    bidsWidth = (position(3)-20)/4;

    set(s.aBids, 'Position', [10+0*bidsWidth position(4)-20-3*handHeight]);
    set(s.bBids, 'Position', [10+1*bidsWidth position(4)-20-3*handHeight]);
    set(s.cBids, 'Position', [10+2*bidsWidth position(4)-20-3*handHeight]);
    set(s.dBids, 'Position', [10+3*bidsWidth position(4)-20-3*handHeight]);


function str = gen_hand_l(player, hand)
    str = ['\bf' player '\rm' 10];
    str = [str '\spadesuit' hand.spades 10];
    str = [str '\heartsuit' hand.hearts 10];
    str = [str '\diamondsuit' hand.diamonds 10];
    str = [str '\clubsuit' hand.clubs];

function str = gen_bids_l(bids, bidders, index)
    club_mask = hex2dec('10');
    diamond_mask = hex2dec('20');
    heart_mask = hex2dec('40');
    spade_mask = hex2dec('80');
    no_trump_mask = hex2dec('08');

    str = ['\bf' bidders{index} '\rm' 10];
    while index<=length(bids)
        bid = bids(index);
        if bitand(bid, no_trump_mask)
            bid = [int2str(bitxor(bid, no_trump_mask)) ' NT'];
        elseif bitand(bid, spade_mask)
            bid = [int2str(bitxor(bid, spade_mask)) ' \spadesuit'];
        elseif bitand(bid, heart_mask)
            bid = [int2str(bitxor(bid, heart_mask)) ' \heartsuit'];
        elseif bitand(bid, diamond_mask)
            bid = [int2str(bitxor(bid, diamond_mask)) ' \diamondsuit'];
        elseif bitand(bid, club_mask)
            bid = [int2str(bitxor(bid, club_mask)) ' \clubsuit'];
        else
            switch(bid)
            case 0
                bid = 'Pass';
            case 1
                bid = 'Dbl';
            case 2
                bid = 'Rdbl';
            end
        end
        str = [str bid 10];
        index = index+4;
    end
   