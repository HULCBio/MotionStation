function redimfig(option,hFig,varargin)
%REDIMFIG Reset the size for a new figure.
%   REDIMFIG('On',HFIG) resets the size of the figure whose
%   handle is HFIG. The ratio with the default size is 
%   computed and depends on the screen size.
%
%   REDIMFIG('On',HFIG,RATIO) uses the ratio RATIO to compute
%   the new size of the figure.
%
%   After computation of the default ratio, 
%   REDIMFIG('On',HFIG,BOUND_RATIO) computes the default ratio
%   and then uses BOUND_RATIO = [LowRAT, HighRAT] to define
%   the correct ratio.
%
%   REDIMFIG('On',HFIG,BOUND_RATIO,'left') set the figure
%   on the left of the screen.
%
%   REDIMFIG('Off' ,...) do nothing.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 15-Jul-2003.
%   Last Revision: 15-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:40:04 $

switch lower(option)
    case 'on'  , 
    case 'off' , return
    otherwise  , return
end

ScreenSize = get(0,'ScreenSize');
ScreenSize = ScreenSize(3:4);
if isequal(ScreenSize,[800,600]);
    ratio = 1.05;
    UIC = wfindobj(hFig,'type','uicontrol');
    set(UIC,'FontWeight','normal');
elseif isequal(ScreenSize,[1024,768]) % Base of construction
    ratio = 1;
elseif isequal(ScreenSize,[1152,864])
    ratio = 0.95;
elseif isequal(ScreenSize,[1280,768])
    ratio = 0.95;
elseif isequal(ScreenSize,[1280,960])
    ratio = 0.90;
elseif isequal(ScreenSize,[1280,1024])
    ratio = 0.85;
else
    ratScr = [1024,768]./ScreenSize;
    if max(ratScr)>1
        ratio = min([max(ratScr),1.05]);
    elseif max(ratScr)<1
        ratio = max([max(ratScr),0.85]);
    else
        ratio = 1;
    end
end

leftFLAG = false;
if nargin>2
    Input_1 = varargin{1};
    if isnumeric(Input_1)
        if length(Input_1)==1
            ratio = Input_1; % Force ratio value
        else
            minRatVal = min(Input_1);
            maxRatVal = max(Input_1);
            ratio = min([max([minRatVal,ratio]),maxRatVal]);
        end
    else
        error('## Not Used ##')
    end
    if nargin>3
        Input_2 = varargin{2};
        if isequal(lower(Input_2),'left') , leftFLAG = true; end
    end
end

if ~isequal(ratio,1)
    wtbxmngr('FigRatio',ratio);
    wfigmngr('normalize',hFig);
    wtbxmngr('FigRatio',1);
    if leftFLAG
        uniFIG = get(hFig,'Units');
        posFIG   = get(hFig,'Position');
        switch lower(uniFIG(1:3))
            case 'pix' , posFIG(1) = 5;
            case 'nor' , posFIG(1) = 5/ScreenSize(1);
        end
        set(hFig,'Position',posFIG);
    end
end
