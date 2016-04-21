function varargout = wdfigutl(option,varargin)
%WDFIGUTL Utilities for Wavelet Toolbox demos figures.
%   VARARGOUT = WDFIGUTL(OPTION,VARARGIN)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Nov-96.
%   Last Revision: 22-May-1999.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.12 $

scrSize = get(0,'ScreenSize');
switch option
    case 'menu'
        % Global variables initialization.
        %---------------------------------
        [ShiftTop_Fig,Btn_Height,Btn_Width] = ...
            mextglob('get','ShiftTop_Fig','Def_Btn_Height','Def_Btn_Width');

        figname = varargin{1};
        nbW     = varargin{2}(1);
        nbH     = varargin{2}(2);
        tag     = varargin{3};
        win_units = 'pixels';
        if scrSize(4)<700
           Btn_Height = 0.9*Btn_Height;
           Btn_Width  = 0.9*Btn_Width;
        end
        win_width  = ceil(nbW*Btn_Width);
        win_height = ceil(nbH*Btn_Height);
        pos_win    = [ scrSize(3)*0.01, ...
                       scrSize(4)-win_height-ShiftTop_Fig, ...
                       win_width, ...
                       win_height ...
                       ];
        fig = wfigmngr('init',        ...
                  'Name',figname,     ...
                  'Unit',win_units,   ...
                  'Position',pos_win, ...
                  'Tag',tag           ...
                  );
        varargout = {fig,pos_win,Btn_Width,Btn_Height,win_units};

    case 'create'
        [ShiftTop_Fig,Def_DefColor,Def_FigColor] = ...
                mextglob('get','ShiftTop_Fig','Def_DefColor','Def_FigColor');
        active_fig = colordef('new',Def_DefColor);

        titre   = varargin{1};
        H_Fig   = 500;
        YD_Fig  = scrSize(4)-H_Fig-ShiftTop_Fig;
        pos     = [380 YD_Fig 400 H_Fig];
        ftnsize = wdftnsiz(scrSize(4));

        set(active_fig,...
                'MenuBar','none',                    ...
                'visible','on',                      ...
                'Name',titre,                        ...
                'NumberTitle','off',                 ...
                'Unit','Pixels',                     ...
                'Position',pos,                      ...
                'DefaultAxesFontSize',ftnsize,       ...
                'DefaultTextFontSize',ftnsize,       ...
                'Color',Def_FigColor,                ...
                'DefaultUicontrolFontWeight','bold', ...
                'DefaultAxesFontWeight','bold',      ...
                'DefaultTextFontWeight','bold'       ...
                );
        set(active_fig,'Units','Normalized');
        varargout{1} = active_fig;

    case 'fontsize'
        varargout{1} = wdftnsiz(scrSize(4));
end


%------------------------------------
function siz = wdftnsiz(scr4)
if scr4<600
    siz = 9;
elseif scr4<=700
    siz = 10;
elseif scr4>700
    siz = 12;
end
CurScrPixPerInch = get(0,'ScreenPixelsPerInch');
StdScrPixPerInch = 72;
RatScrPixPerInch = StdScrPixPerInch / CurScrPixPerInch;
siz = floor(siz*RatScrPixPerInch);
%------------------------------------
