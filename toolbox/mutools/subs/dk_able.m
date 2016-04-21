% function dk_able(ptr,level,toolhan)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function dk_able(ptr,level,toolhan)

% Level Meaning
% -------------
% 1 disable
% 2 available
% 3 next

    [BUTSTAT,MAINPB,PBSTRS,INUM,CITER,EXTRALOAD] = ...
        gguivar('BUTSTAT','MAINPB','PBSTRS','INUM','CITER','EXTRALOAD',toolhan);
    mustat = BUTSTAT(4);
    for i=1:length(ptr)
        if BUTSTAT(ptr(i)) ~= level(i)
            BUTSTAT(ptr(i)) = level(i);
            if level(i) == 3
                set(MAINPB(ptr(i)),...
                    'String',deblank(PBSTRS(2*ptr(i),:)),...
                    'enable','on');
            elseif level(i) == 2
                set(MAINPB(ptr(i)),...
                    'String',deblank(PBSTRS(2*ptr(i)-1,:)),...
                    'enable','on');
            elseif level(i) == 1
                set(MAINPB(ptr(i)),'String',deblank(PBSTRS(2*ptr(i),:)));
                set(MAINPB(ptr(i)),'enable','off');
            end
        end
    end
    if any(BUTSTAT==3)
        [AMENUHANS,MULTISTEP] = gguivar('AMENUHANS','MULTISTEP',toolhan);
        set(AMENUHANS,'enable','on');
        set(MULTISTEP,'enable','on');
    else
        [AMENUHANS,MULTISTEP] = gguivar('AMENUHANS','MULTISTEP',toolhan);
        set(AMENUHANS,'enable','off');
        set(MULTISTEP,'enable','off');
    end
    if BUTSTAT(4) >= 2 & mustat == 1 & INUM >= 1
        dkitgui(toolhan,'enableblked');
        dataent('setbenable',EXTRALOAD,1);
    end   % disabled in NEXT ITER
    sguivar('BUTSTAT',BUTSTAT,toolhan);
    if BUTSTAT(1) > 1 & gguivar('DELTAMOD',toolhan)==1
        dk_able(1,1,toolhan) % changed DELTA, lockout HINF design
    end