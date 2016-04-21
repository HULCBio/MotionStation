% function [out1,out2,out3] = colbut(toolhan,message,in1,in2,in3,in4,in5,in6)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2,out3] = colbut(toolhan,message,in1,in2,in3,in4,in5,in6)

if isempty(toolhan)
    co = get(gcf,'currentobject');
    if ~isempty(co)
        toolhan = get(co,'userdata'); % incorrect with slider, but that gets done
    end
end

 if strcmp(message,'create') | strcmp(message,'dimquery')
    dimvec = in1;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    ih =  dimvec(7);
    hgap = dimvec(8);
    vgap = dimvec(9);
    cstyle = in2;
    colw = in3;
    nrows = in4;
    et_bgc = in5;
    if nargin == 8
        guitoolname = in6;
    else
        guitoolname = [];
    end
    pbcols = find(cstyle=='p');
    cbcols = find(cstyle=='c');
    rbcols = find(cstyle=='r');
    txtcols = find(cstyle=='t');
    etxtcols = find(cstyle=='e');
    numpb = length(pbcols);
    numcb = length(cbcols);
    numrb = length(rbcols);
    numtxt = length(txtcols);
    numetxt = length(etxtcols);
    frw = xlbo + sum(colw) + (length(colw)-1)*hgap + xrbo;
    frh = ybotbo + nrows*ih +(nrows-1)*vgap + ytopbo;
    if strcmp(message,'create')
        out2 = [];
        mainh = uicontrol(toolhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        allcolhan = [];
        rbcol = [];
        for j=1:length(cstyle)
            if cstyle(j)=='p'
                style = 'pushbutton';
            elseif cstyle(j)=='c';
                style = 'checkbox';
            elseif cstyle(j)=='r';
                style = 'radiobutton';
                rbcol = [rbcol j];
            elseif cstyle(j)=='e';
                style = 'edit';
            elseif cstyle(j)=='t';
                style = 'text';
            elseif cstyle(j)=='m';
                style = 'popup';
            else
                error('Style not found');
                return
            end
            xpos = lx + xlbo + (j-1)*hgap + sum(colw(1:j-1));
            colhan = [];
            for i=1:nrows
                han = uicontrol(toolhan,...
                    'style',style,...
                    'horizontalalignment','right',...
                    'position',[xpos ly+ybotbo+(i-1)*(vgap+ih) colw(j) ih]);
                colhan = [han;colhan];
            end
            if cstyle(j)=='e'
                set(colhan,'backgroundcolor',et_bgc);
            elseif cstyle(j)=='t'
                out2 = [out2 colhan];
            end
            allcolhan = [allcolhan colhan];
        end
        out1 = mainh;
        stdata = [];
        stuserdata = [];
        rbdata = [rbcol;1:length(rbcol)];
        stdata = ipii(stdata,allcolhan,1);
        stdata = ipii(stdata,cstyle,2);
        stdata = ipii(stdata,toolhan,3);    % gui-Parent
        stdata = ipii(stdata,guitoolname,4);
        stdata = ipii(stdata,stuserdata,5);
        stdata = ipii(stdata,rbdata,6);     % keeps track of which Radio Button is pressed
        set(allcolhan,'userdata',mainh);    % each object has toolhan as USERDATA
        set(mainh,'userdata',stdata);
    else
        out1 = [lx ly frw frh];
    end
elseif strcmp(message,'getpos')
    out1 = get(toolhan,'position');
elseif strcmp(message,'setpos')
    curpos = get(toolhan,'position');
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    [nr,nc] = size(hans);
    offx = in1(1)-curpos(1);
    offy = in1(2)-curpos(2);
    set(toolhan,'visible','off');
    set(hans,'visible','off');
    set(toolhan,'position',curpos+[offx offy 0 0]);
    for i=1:nr
        for j=1:nc
            curposi = get(hans(i,j),'position');
            set(hans(i,j),'position',[curposi(1)+offx curposi(2)+offy curposi(3:4)]);
        end
    end
    set(toolhan,'visible','on');
    set(hans,'visible','on');
elseif strcmp(message,'setcb')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    rows = in3;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cbs = in4;
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    for i=1:length(rows)
        set(hans(rows(i),column),'callback',deblank(cbs(i,:)));
    end
elseif strcmp(message,'getcb')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    out1 = 'hi';
    for i=1:length(rows)
        out1 = str2mat(out1,get(hans(rows(i),column),'callback'));
    end
    out1 = out1(2:length(rows)+1,:);
elseif strcmp(message,'setstr')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cbs = in4;
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    for i=1:length(rows)
        set(hans(rows(i),column),'string',deblank(cbs(i,:)));
    end
elseif strcmp(message,'disable')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    set(hans(rows,column),'enable','off');
elseif strcmp(message,'enable')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    set(hans(rows,column),'enable','on');
elseif strcmp(message,'getstr')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    out1 = 'hi';
    for i=1:length(rows)
        out1 = str2mat(out1,get(hans(rows(i),column),'string'));
    end
    out1 = out1(2:length(rows)+1,:);
elseif strcmp(message,'gethan')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    cstyle = xpii(stdata,2);
    colstyle = in1;
    colnum = in2;
    if strcmp(in3,'all')
        rows = 1:size(hans,1);
    else
        rows = in3;
    end
    cols = find(cstyle==colstyle);
    column = cols(colnum);
    out1 = hans(rows,column);
elseif strcmp(message,'getguitoolname')
    stdata = get(toolhan,'userdata');
    out1 = xpii(stdata,4);
elseif strcmp(message,'setguitoolname')
    stdata = get(toolhan,'userdata');
    stdata = ipii(stdata,in1,4);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'getuserdata')
    stdata = get(toolhan,'userdata');
    out1 = xpii(stdata,5);
elseif strcmp(message,'setuserdata')
    stdata = get(toolhan,'userdata');
    stdata = ipii(stdata,in1,5);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'delete')
    stdata = get(toolhan,'userdata');
    hans = xpii(stdata,1);
    delete(hans);
    delete(toolhan);
else
    disp('Warning (in COLBUT): Message not found');
end