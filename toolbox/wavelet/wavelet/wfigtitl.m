function out1 = wfigtitl(option,fig,in3,in4,in5,in6)
%WFIGTITL Titlebar for Wavelet Toolbox figures.
%   OUT1 = WFIGTITL(OPTION,FIG,IN3,IN4,IN5,IN6)
%
%   OUT1 is the handle of the text containing the
%   the title of the figure which handle is FIG.
%
%   OPTION = 'vis'
%   IN3 = 'on' or 'off'
%
%   OPTION = 'string'
%   IN3 is a string (the title of the figure)
%   IN4 = 'on' or 'off' is optional.
%
%   OPTION = 'set'
%   IN3 is the height of the title (in pixels).
%   IN4 is a string (the title of the figure)
%   IN5 is 'on' or 'off' (visibility value).
%   IN6 is the Background Color of the title.
%
%   OPTION = 'handle'

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11 $  $Date: 2002/04/14 19:45:29 $

% Tag property of objects.
%-------------------------
tag_fig_title = 'Txt_Fig_Title';

out1 = findobj(fig,'Style','text','Tag',tag_fig_title);
opt  = option(1:3);

switch opt
  case 'vis'
    if isempty(out1) , return; end
    set(out1,'Visible',in3);

  case 'str'  % string
    if isempty(out1) , return; end
    if nargin==3 , in4 = get(out1,'Visible'); end
    set(out1,'String',in3,'Visible',in4);

  case 'set'
    tmp   = get(0,'defaultUicontrolPosition');
    h_tit = tmp(4);
    uni   = get(fig,'Units');
    pos_f = get(fig,'Position');
    if strcmp(uni,'pixels')
        pos_t = [0,pos_f(4)-h_tit,pos_f(3)*in3,h_tit];
    elseif strcmp(uni,'normalized')
        h = h_tit/pos_f(4);
        pos_t = [0,1-h,in3,h];
    end
    if isempty(out1)
        out1 = uicontrol(fig,...
            'Style','Text',        ...
            'Units',uni,           ...
            'Position',pos_t,      ...
            'Backgroundcolor',in6, ...
            'Visible',in5,         ...
            'String',in4,          ...
            'Tag',tag_fig_title    ...
            );

    else
        set(out1,...
            'Units',uni,           ...
            'Position',pos_t,      ...
            'String',in4,          ...
            'Backgroundcolor',in6, ...
            'Visible',in5          ...
            );
    end

  case 'han'

  otherwise
    errargt(mfilename,'Unknown Option','msg');
    error('*');
end

