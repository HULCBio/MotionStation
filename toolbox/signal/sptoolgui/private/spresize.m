function varargout = spresize(varargin)
%SPRESIZE Resize function for spectview.

%   Copyright 1988-2002 The MathWorks, Inc.
% $Revision: 1.10 $

if nargin == 0
    action = 'resize';
    fig = gcbf;
elseif ~isstr(varargin{1})
    % syntax: spresize(0,fig)
    action = 'resize';
    fig = varargin{2};
else
    action = varargin{1};
end

lw = 75;  % label width  DEFINED AT TOP OF SPRESIZE
switch action
case 'resize'

    ud = get(fig,'userdata');
    sz = ud.sz;

    fp = get(fig,'position');   % in pixels already

    left_width = ud.left_width;

    ruler_port = [left_width 0 fp(3)-ud.left_width sz.rh*ud.prefs.tool.ruler];

    mainaxes_port = [left_width ruler_port(4) ...
                     fp(3)-left_width fp(4)-ruler_port(4)];
    mainaxes_pos = mainaxes_port + ...
               [sz.as(1) sz.as(2) -(sz.as(1)+sz.as(3)) -(sz.as(2)+sz.as(4))];

    if mainaxes_pos(3)<ud.prefs.minsize(1)  ...
         | fp(4)<ud.prefs.minsize(2)
       % disp('    SPECTVIEW: figure too small - resizing')
       
       % minsize(1)   - minimum width of main axes in pixels
       % minsize(2)   - minimum height of main axes in pixels

       w = left_width+sz.rw*ud.prefs.tool.ruler+sz.as(1)+...
             sz.as(3)+ud.prefs.minsize(1);
       w = max(w,fp(3));
      % h = max(0, sz.as(2)+sz.as(4)+ud.prefs.minsize(2));
       h = ud.prefs.minsize(2);
       h = max(h,fp(4));
       fp = [fp(1) fp(2)+fp(4)-h w h];
       set(fig,'position',fp)
       %return
    end
    % recompute with new fp:
    mainaxes_port = [left_width ruler_port(4) ...
                     fp(3)-left_width fp(4)-ruler_port(4)];
    mainaxes_pos = mainaxes_port + ...
               [sz.as(1) sz.as(2) -(sz.as(1)+sz.as(3)) -(sz.as(2)+sz.as(4))];

    hand = ud.hand;
    pfp = [0 0 left_width fp(4)];  % propFrame position
    
    % Tweak position & size of frames: [horz_pos ver_pos width height]
    switch computer
    case 'MAC2'
        sfpTweak =  [0 -5  0  3];
        pmfpTweak = [0 -10 0 10];
    case 'PCWIN' 
        sfpTweak =  [0  5 0 -2];
        pmfpTweak = [0 -5 0 10];
    otherwise  % UNIX
        sfpTweak =  [0 -8  0  6];
        pmfpTweak = [0 -10 0 10];
    end

    sfp = [pfp(1)+sz.fus pfp(2)+pfp(4)-(sz.lh/2+3*sz.lh) ... % signalFrame position
                      pfp(3)-2*sz.fus 2.5*sz.lh+sz.fus] + sfpTweak; 

    N = 11;  % number of uicontrols in parameters frame
    param_height = sz.lh/2+N*(sz.lbs+sz.uh+1);
    pmfp = [pfp(1)+sz.fus sfp(2)-sz.fus-sz.lh/2-param_height ...
               pfp(3)-2*sz.fus param_height] + pmfpTweak;  %paramFrame position
    
    slExtent = get(hand.signalLabel,'extent');
    plExtent = get(hand.paramLabel,'extent');
    buttonWidth = (pmfp(3)-sz.fus)/2;
    
    %  lw = 65;  % label width  DEFINED AT TOP OF SPRESIZE
    fw = pmfp(3)-lw-2*sz.fus-sz.lbs;  % field width (for edit boxes)
    
    % 1-by-4 position vectors
    pos = {
    ud.mainaxes        mainaxes_pos
    ud.mainaxes_border mainaxes_pos+[-1 -1 2 2]
    hand.propFrame     pfp
    hand.signalFrame   sfp
    hand.paramFrame    pmfp
    hand.signalLabel   [sfp(1)+sz.lbs sfp(2)+sfp(4)-sz.lh/2 ...
                          slExtent(3)+2*sz.lbs sz.lh]
    hand.siginfo1Label [sfp(1)+sz.fus sfp(2)+2+sz.lh sfp(3)-2*sz.fus sz.uh ]
    hand.siginfo2Label [sfp(1)+sz.fus sfp(2)+2 sfp(3)-2*sz.fus sz.uh ]
    hand.paramLabel    [pmfp(1)+sz.lbs pmfp(2)+pmfp(4)-sz.lh/2 ...
                          plExtent(3)+2*sz.lbs sz.lh]
    hand.revertButton  [pfp(1)+sz.fus pmfp(2)-sz.fus-sz.uh buttonWidth sz.uh]
    hand.applyButton   [pfp(1)+pfp(3)-sz.fus-buttonWidth pmfp(2)-sz.fus-sz.uh ...
                           buttonWidth sz.uh]
    hand.methodLabel   [pmfp(1)+sz.fus pmfp(2)+pmfp(4)-sz.lh/2-sz.uh lw sz.uh]
    hand.methodPopup   [pmfp(1)+sz.fus+lw+sz.lbs ...
                        pmfp(2)+pmfp(4)-sz.lh/2-sz.uh+2 fw sz.uh]
    ud.hand.confidenceCheckbox  [pmfp(1)+sz.fus pmfp(2)+2*sz.fus+sz.uh ...
                                 lw sz.uh]
    ud.hand.confidenceEdit  [pmfp(1)+sz.fus+lw+sz.lbs pmfp(2)+3*sz.lbs+sz.uh ...
                                 fw sz.uh]
    hand.inheritPopup  [pmfp(1)+sz.fus pmfp(2)+2*sz.lbs pmfp(3)-2*sz.fus sz.uh];
    };
   % hand.propLabel     [pfp(1)+sz.fus pfp(2)+pfp(4)-sz.fus-sz.uh ...
   %                     pfp(3)-2*sz.fus sz.uh];

    set([pos{:,1}],{'position'},pos(:,2))

    for i=1:length(hand.label)
        setuiposition(i,hand.label(i),hand.uicontrol(i),hand.paramFrame,sz,lw,fw)
    end

    ut = get(ud.toolbar.whatsthis,'parent');
    tbfillblanks(ut,ud.toolbar.lineprop,ud.toolbar)
 
%------------------------------------------------------------------------
% spresize('paramPosition',uicontrolHand)
%   sets the position of uicontrolHand
%   if the uicontrol is type 'checkbox' or 'radiobutton', the control
%       takes up the entire width of the Parameters frame.
%   if the uicontrol is any other type, the control
%       takes up just the width of an edit field.
case 'paramPosition'

    uicontrolHand = varargin{2};
    fig = get(uicontrolHand,'parent');
    ud = get(fig,'userdata');
    sz = ud.sz;
    left_width = ud.left_width;
               
    % lw = 65;  % label width  DEFINED AT TOP OF SPRESIZE
    fw = left_width-2*sz.fus-lw-2*sz.fus-sz.lbs;  % field width (for edit boxes)
    
    hand = ud.hand;
    i = find(uicontrolHand == ud.hand.uicontrol);
    setuiposition(i,hand.label(i),hand.uicontrol(i),hand.paramFrame,sz,lw,fw)

end

function setuiposition(i,label,ui,paramFrame,sz,lw,fw)

    % Tweak position & size of popups: [horz_pos ver_pos width height]
    switch computer
    case 'MAC2'
        popTweak =  [0 -2 0 0];
    case 'PCWIN' 
        popTweak =  [0 0 0 0];
    otherwise  % UNIX
        popTweak =  [0 0 0 0];
    end

    pmfp = get(paramFrame,'position');

    set(label,'position',[pmfp(1)+sz.fus ...
       pmfp(2)+pmfp(4)-sz.lh/2-sz.uh-(sz.uh+sz.lbs+2)*i-2 lw sz.uh]);
    switch get(ui,'style')
    case {'checkbox','radiobutton'}
       set(ui,'position',[pmfp(1)+sz.fus ...
            pmfp(2)+pmfp(4)-sz.lh/2-sz.uh-(sz.uh+sz.lbs+2)*i fw+lw+sz.lbs sz.uh]);
    case 'popupmenu'
       set(ui,'position',[pmfp(1)+sz.fus+lw+sz.lbs ...
            pmfp(2)+pmfp(4)-sz.lh/2-sz.uh-(sz.uh+sz.lbs+2)*i fw sz.uh+2]+popTweak);
    otherwise
       set(ui,'position',[pmfp(1)+sz.fus+lw+sz.lbs ...
            pmfp(2)+pmfp(4)-sz.lh/2-sz.uh-(sz.uh+sz.lbs+2)*i fw sz.uh+2]);
    end

