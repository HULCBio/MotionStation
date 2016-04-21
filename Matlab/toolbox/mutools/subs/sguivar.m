% function sguivar(varname1,varval1,varname2,varval2,varname3,varval3,...
%     varname4,varval4,varname5,varval5,varname6,varval6,varname7)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function sguivar(varname1,varval1,varname2,varval2,varname3,varval3,...
    varname4,varval4,varname5,varval5,varname6,varval6,varname7)

    if floor(nargin/2)~=ceil(nargin/2)
        eval(['mh = varname' int2str(ceil(nargin/2)) ';']);
        nargina = nargin - 1;
    else
        mh = unique([gcbf gcf]);
        if length(mh) > 1
            [ours,othw,theirs,splts] = findmuw(mh);
            if ~isempty(ours) & ~isempty(theirs)        % DEMO creates wsgui
                mh = ours;
            elseif isempty(theirs)                      % both MU tools
                mh = gcbf;
            else
                error('Cannot find a mutools GUI.  Please report this bug.');
            end
        end
        nargina = nargin;
    end

%   h2v pointers
    gonumcol = 4;
    numlinks = 3;

%   OGLINK pointers
    out_go = 1;
    rec_tool = 2;
    rec_go = 3;

    allhandles = get(mh,'userdata');
    anames = get(allhandles(1),'userdata');
    pimnum = get(allhandles(2),'userdata');
    if nargina == 2
        index1 = h2v(anames,pimnum,varname1);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
    elseif nargina == 4
        [index1,index2] = h2v(anames,pimnum,varname1,varname2);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        ud = get(allhandles(index2(1)),'Userdata');
        set(allhandles(index2(1)),'Userdata',ipii(ud,varval2,index2(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
        if index2(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index2(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval2);']);
            end
        end
    elseif nargina == 6
        [index1,index2,index3] = h2v(anames,pimnum,varname1,varname2,varname3);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        ud = get(allhandles(index2(1)),'Userdata');
        set(allhandles(index2(1)),'Userdata',ipii(ud,varval2,index2(2)));
        ud = get(allhandles(index3(1)),'Userdata');
        set(allhandles(index3(1)),'Userdata',ipii(ud,varval3,index3(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
        if index2(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index2(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval2);']);
            end
        end
        if index3(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index3(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval3);']);
            end
        end
    elseif nargina == 8
        [index1,index2,index3,index4] = ...
            h2v(anames,pimnum,varname1,varname2,varname3,varname4);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        ud = get(allhandles(index2(1)),'Userdata');
        set(allhandles(index2(1)),'Userdata',ipii(ud,varval2,index2(2)));
        ud = get(allhandles(index3(1)),'Userdata');
        set(allhandles(index3(1)),'Userdata',ipii(ud,varval3,index3(2)));
        ud = get(allhandles(index4(1)),'Userdata');
        set(allhandles(index4(1)),'Userdata',ipii(ud,varval4,index4(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
        if index2(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index2(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval2);']);
            end
        end
        if index3(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index3(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval3);']);
            end
        end
        if index4(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index4(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval4);']);
            end
        end
    elseif nargina == 10
        [index1,index2,index3,index4,index5] = ...
             h2v(anames,pimnum,varname1,varname2,varname3,varname4,varname5);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        ud = get(allhandles(index2(1)),'Userdata');
        set(allhandles(index2(1)),'Userdata',ipii(ud,varval2,index2(2)));
        ud = get(allhandles(index3(1)),'Userdata');
        set(allhandles(index3(1)),'Userdata',ipii(ud,varval3,index3(2)));
        ud = get(allhandles(index4(1)),'Userdata');
        set(allhandles(index4(1)),'Userdata',ipii(ud,varval4,index4(2)));
        ud = get(allhandles(index5(1)),'Userdata');
        set(allhandles(index5(1)),'Userdata',ipii(ud,varval5,index5(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
        if index2(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index2(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval2);']);
            end
        end
        if index3(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index3(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval3);']);
            end
        end
        if index4(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index4(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval4);']);
            end
        end
        if index5(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index5(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval5);']);
            end
        end
    elseif nargina == 12
        [index1,index2,index3,index4,index5,index6] = ...
             h2v(anames,pimnum,varname1,varname2,varname3,varname4,varname5,varname6);
        ud = get(allhandles(index1(1)),'Userdata');
        set(allhandles(index1(1)),'Userdata',ipii(ud,varval1,index1(2)));
        ud = get(allhandles(index2(1)),'Userdata');
        set(allhandles(index2(1)),'Userdata',ipii(ud,varval2,index2(2)));
        ud = get(allhandles(index3(1)),'Userdata');
        set(allhandles(index3(1)),'Userdata',ipii(ud,varval3,index3(2)));
        ud = get(allhandles(index4(1)),'Userdata');
        set(allhandles(index4(1)),'Userdata',ipii(ud,varval4,index4(2)));
        ud = get(allhandles(index5(1)),'Userdata');
        set(allhandles(index5(1)),'Userdata',ipii(ud,varval5,index5(2)));
        ud = get(allhandles(index6(1)),'Userdata');
        set(allhandles(index6(1)),'Userdata',ipii(ud,varval6,index6(2)));
        if index1(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index1(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval1);']);
            end
        end
        if index2(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index2(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval2);']);
            end
        end
        if index3(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index3(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval3);']);
            end
        end
        if index4(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index4(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval4);']);
            end
        end
        if index5(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index5(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval5);']);
            end
        end
        if index6(numlinks)>0
            OGLINK = gguivar('OGLINK',mh);
            links = find(OGLINK(:,out_go)==index6(gonumcol));
            for i=1:length(links)
                proghan = OGLINK(links(i),rec_tool);
                pname = deblank(gguivar('MFILENAME',proghan));
                retpim = OGLINK(links(i),rec_go);
                eval([pname '(proghan,''acceptlinkdata'',retpim,varval6);']);
            end
        end
    end