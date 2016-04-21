function sz = gui_sizes
% GUI_SIZES Sizes and spaces used in building the Filter Design GUI.
% 
% Ouput:
%    sz - a structure containing several fields with uicontrol size and
%         spacing information.

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/03/28 19:26:18 $ 

% Determine a scale factor based on screen resolution.
pf = get(0,'screenpixelsperinch')/96;
if isunix,
    pf = 1;
end
sz.pixf = pf;

% Figure width and height
sz.fig_w = 770;
sz.fig_h = 549;

% Frame heights - pick one.
sz.fh1 = 252*pf;    % Analysis Area and Current Filter Info (w/o Tab)
sz.fh2 = 81*pf;     % Window Specs
sz.fh3 = 109*pf;    % Filter Order
sz.fh4 = 35*pf;     % Quantization frame height.
sz.fh5 = 76*pf;     % Design Method
sz.fh6 = 176*pf;    % Current Filter Info w/ Tab
sz.fh7 = 205*pf;    % Specifications + QFilt objs
sz.fh8 = 20*pf;     % Action Frame
sz.fh9 = 248*pf;    % Recessed Frame
sz.fh10 = 61 *pf;   % Quantization Switch

% Frame Widths
sz.fw1 = 178*pf;    % Current Filter Info, Design Method, Filter Type, etc.
                    % Qfiltobjs
sz.fw2 = 548*pf;    % Analysis Frame & Quantizer Props
sz.fw3 = 356*pf;    % Width of Freq/Mag.
sz.fw4 = 715*pf;    % Width of the Action Frame
sz.fw5 = 713*pf;    % Import Parameters
sz.fw6 = 732*pf;    % Recessed Frame

% Frame Ys
sz.fy1 = 282*pf;    % Analysis Areas, Quantization Switch, and CFI (w/o tab)
sz.fy2 = 358*pf;    % Current Filter Information w/tab
sz.fy3 = 55*pf;     % All Specifications except Filter Order
sz.fy4 = 151*pf;    % Filter Order
sz.fy5 = 32*pf;     % Action Frame
sz.fy6 = 28*pf;     % Recessed Frame

% Frame Xs
sz.fx1 = 34*pf;      % CFI, QSwitch, Filter Type and Design Method
sz.fx2 = 217*pf;    % Analysis Area Filter Order and Window Specifications
sz.fx3 = 400*pf;    % Frequency Specifications & FREQMAG
sz.fx4 = 583*pf;    % Magnitude Specifications
sz.fx5 = 40*pf;     % Action Frame
sz.fx6 = 34*pf;     % Recessed Frame

% Spacing
sz.vfus = 5*pf;     % vertical space between frame and uicontrol 
sz.hfus = 10*pf;    % horizontal space between frame and uicontrol 
sz.ffs  = 5*pf;     % frame/figure spacing and horizontal frame/frame spacing
sz.vffs = 15*pf;    % vertical space between frame and frame
sz.lfs  = 10*pf;    % label/frame spacing
sz.uuvs = 10*pf;    % uicontrol/uicontrol vertical spacing
sz.uuhs = 10*pf;    % uicontrol/uicontrol horizontal spacing

% Sizes
sz.uh   = 18*pf;    % uicontrol height
sz.ebw  = 90*pf;    % edit box width
sz.bh   = 20*pf;    % pushbutton heightsz.bw   = 165; % button width
sz.tw   = 100*pf;   % text width

sz.lh = get(0,'defaultuicontrolfontsize')+10;  % label height

% Tweak factors
sz.lblTweak = 3*pf; % text ui tweak to vertically align popup labels
sz.popwTweak = 20;  % Extra width for popup
sz.rbwTweak  = 20;  % Extra width for radio button

% [EOF] gui_sizes.m

