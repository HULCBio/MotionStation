%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2] = mudeclar(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12,...
                in13,in14,in15,in16,in17,in18,in19,in20,in21,in22,in23,in24,in25,in26,...
                in27,in28,in29,in30,in31,in32,in33,in34,in35,in36,in37)

    global mtgui_vn mtgui_pim
    cmax = 12;
    if nargin == 0
        varmax = 300;
        mtgui_vn = abs(' ')*ones(varmax,cmax);   % 12 character maximum, blank filled, room for 300
        mtgui_pim = zeros(varmax,1);
    elseif strcmp(in1,'mkvar')
        mpim = max(mtgui_pim);
        pimend = max(find(mtgui_pim==mpim));
        out1 = mtgui_vn(1:pimend,:);
        out2 = mtgui_pim(1:pimend,:);
        minval = min(out2);
        maxval = max(out2);
        pimind = zeros(pimend,1);
        for i=minval:maxval
            loc = find(out2(:)==i);
            pimind(loc) = (1:length(loc))';
        end
        idint = zeros(pimend,1);
        for i=1:pimend
            nn = deblank(setstr(out1(i,:)));
            idint(i) = length(nn)*(sum(abs(nn))-64*length(nn));
        end
        out2 = [out2 pimind 0*out2 idint]; % PIM_1, PIM_2, number of links, identifier
        out1 = out1';
        clear global mtgui_vn mtgui_pim
    elseif strcmp(in1,'done')
        handles = in2(:);
        mainw = in3;
        VN = in4;
        PIM = in5;
        set(mainw,'userdata',[handles;abs('MAIN')']);
        for i=6:nargin
            st = ['set(in' int2str(i)];
            st = [st ',''Userdata'',[handles; abs(''SUB'')'';mainw+(('];
            st = [st int2str(i) '-5)/100)]);'];
            eval(st)
        end
        set(handles(1),'userdata',VN); set(handles(2),'userdata',PIM);
    else
        mpim = max(mtgui_pim);
        if mpim==0
            pimindex = 3;
            pimstart = 1;
        else
            pimindex = mpim+1;
            pimstart = max(find(mtgui_pim==mpim)) + 1;
        end
        for i=1:nargin
            eval(['nlet = size(in' int2str(i) ');']);
            eval(['casn = abs(in' int2str(i) ');']);
            if nlet(2)>cmax
                error('WARNING: GUI_vars must be 12 or fewer characters');
                return
            else
                mtgui_pim(pimstart:pimstart+nlet(1)-1) = pimindex*ones(nlet(1),1);
                mtgui_vn(pimstart:pimstart+nlet(1)-1,1:nlet(2)) = casn;
            end
            pimstart = pimstart + nlet(1);
        end
    end