function txt_msg = wwaiting(option,fig,in3,in4)
%WWAITING Wait and display a message.
%   OUT1 = WWAITING(OPTION,FIG,IN3,IN4)
%   fig is the handle of the figure.
%
%   OPTION = 'on' , 'off'
%
%   OPTION = 'msg'    (display a message)
%    IN3 is a string.
%
%   OPTION = 'create' (create a text for messages)
%   IN3 and in4 are optional.
%   IN3 is height of the text (in pixels).
%   IN4 is a string.
%   OUT1 is the handle of the text.
%
%   OPTION = 'handle'
%   OUT1 is the handle of the text.
%
%   OPTION = 'close'  (delete the text)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 11-Feb-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.11.4.2 $

child = wfindobj('figure');
if isempty(child) | isempty(find(child==fig)) , return; end
tag_msg = 'Txt_Message';
txt_msg = findobj(fig,'Style','text','Tag',tag_msg);

switch option
    case {'on','off'}
        if ~isempty(txt_msg) , set(txt_msg,'Visible',option); end
        mousefrm(0,'arrow');
        drawnow;

    case 'msg'
        %  in3 = msg
        %------------------
        if ~isempty(txt_msg)
            mousefrm(0,'watch');
            nblines = size(in3,1);
            if nblines==1 , in3 = strvcat(' ',in3); end
            set(txt_msg,'Visible','On','String',in3);
            drawnow;
        end

    case 'create'
        % in3 = "position"  (optional)
        % in4 = msg         (optional)
        % out1 = txt_msg
        %------------------
        uni = get(fig,'Units');
        pos = get(fig,'Position');
        tmp = get(0,'defaultUicontrolPosition');
        yl  = 2.5*tmp(4);
        if uni(1:3)=='pix'
            xl = pos(3);
        elseif uni(1:3)=='nor'
            xl = 1;
            [nul,yl] = wfigutil('prop_size',fig,1,yl);
        end
        if nargin>2
            xl = xl*in3;
            if nargin==3
                msg = '';
                vis = 'off';
            else
                msg = in4;
                nblines = size(msg,1);
                if nblines==1 , msg = strvcat(' ',msg); end
                vis = 'on';
                mousefrm(0,'watch');
            end
        end
        pos_txt_msg = [0 0 xl yl];
        txt_msg = uicontrol(...
                        'Parent',fig,...
                        'Style','text',...
                        'Units',uni,...
                        'Position',pos_txt_msg,...
                        'Visible',vis,...
                        'String',msg,...
                        'Tag',tag_msg...
                        );
        if lower(vis(1:2))=='on' , drawnow; end

    case 'handle'

    case 'close'
        delete(txt_msg);
        mousefrm(0,'arrow');

    otherwise
        errargt(mfilename,'Unknown Option','msg');
        error('*');
end
