% function [out1,out2,out3] = parmwin(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2,out3] = parmwin(in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11)

 if (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'frwtit')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    th =  dimvec(5);
    tw = dimvec(6);
    frw = tw;
    frh = ybotbo + th + ytopbo;
    hal = 'center';
    if nargin == 6;
        hal = 'left';
    end
    if strcmp(in1,'create')
        windowhan = in4;
        if nargin == 4
            titlestring = '';
        else
            titlestring = in5;
        end
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        if th > 0
            tith = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment',hal,...
                'position',[lx+3 ly+ybotbo tw-6 th],...
                'string',titlestring);
            set(mainh,'userdata',tith);
        end
        if nargin == 6;
            set(tith,'backgroundcolor',get(mainh,'backgroundcolor'));
        end
        out1 = mainh;
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'nwd')
    if nargin == 8
        in9 = 'andy';
    end
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    varnames = in4;
    vardefault = in5;
    nvar = size(in4,1);
    frw = xlbo + nw + hgap + dw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    et_bgc = in8;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        than = [];
        ethan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','right',...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            than = [han;than];
            if isempty(vardefault)
                thestring = '';
            else
                thestring = agv2str(vardefault(nvar-i+1,:));
            end
            if isempty(thestring)
                thestring = '';
            end
            if strcmp(in9,'callbackscript')
                cb = in7;
            else
                cb = [in7 int2str(nvar-i+1) ');'];
            end
            han = uicontrol(windowhan,...
                'style','edit',...
                'callback',cb,...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',thestring);
            ethan = [han;ethan];
        end
        for i=1:nvar
            set(ethan(i),'userdata',[ethan;mainh]);
        end
        out1 = mainh;
        out2 = than;
        set(mainh,'userdata',[ethan than]);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'nwet')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    varnames = in4;
    vardefault = in5;
    nvar = length(in5);
    nvar = size(in4,1);
    frw = xlbo + nw + hgap + dw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    et_bgc = in8;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        than = [];
        ethan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','right',...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            than = [han;than];
            if isempty(vardefault)
                thestring = '';
            else
                thestring = vardefault(nvar-i+1,:);
            end
            if strcmp(in9,'callbackscript')
                cb = in7;
            else
                cb = [in7 int2str(nvar-i+1) ');'];
            end
            han = uicontrol(windowhan,...
                'style','edit',...
                'callback',cb,...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',deblank(thestring));
            ethan = [han;ethan];
        end
        for i=1:nvar
            set(ethan(i),'userdata',[ethan;mainh]);
        end
        out1 = mainh;
        out2 = than;
        set(mainh,'userdata',ethan);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'cbwet')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    varnames = in4;
    vardefault = in5;
    nvar = length(in5);
    nvar = size(in4,1);
    frw = xlbo + nw + hgap + dw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    et_bgc = in8;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        than = [];
        ethan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','checkbox',...
                'value',0,...
                'horizontalalignment','right',...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            than = [han;than];
            if isempty(vardefault)
                thestring = '';
            else
                thestring = vardefault(nvar-i+1,:);
            end
            if strcmp(in9,'callbackscript')
                cb = in7;
            else
                cb = [in7 int2str(nvar-i+1) ');'];
            end
            han = uicontrol(windowhan,...
                'style','edit',...
                'callback',cb,...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',deblank(thestring));
            ethan = [han;ethan];
        end
        for i=1:nvar
            set(ethan(i),'userdata',[ethan;mainh]);
        end
        out1 = mainh;
        out2 = than;
        set(mainh,'userdata',ethan);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'cbwetwnet')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    mw = dimvec(12);
    varnames = in4;
    vardefault = in5;
    nvar = size(in4,1);
    frw = xlbo + nw + hgap + dw +hgap + mw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    et_bgc = in8;
    mdefault = in10;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        cbhan = [];
        ethan = [];
        mhan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','checkbox',...
                'value',0,...
                'horizontalalignment','right',...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            cbhan = [han;cbhan];
            if isempty(vardefault)
                thestring = '';
            else
                thestring = vardefault(nvar-i+1,:);
            end
            if strcmp(in9,'callbackscript')
                cb = in7;
            else
                cb = [in7 int2str(nvar-i+1) ');'];
            end
            han = uicontrol(windowhan,...
                'style','edit',...
                'callback',cb,...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',deblank(thestring));
            ethan = [han;ethan];
            if isempty(mdefault)
                thestring = '';
            else
                thestring = mdefault(nvar-i+1,:);
            end
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','left',...
                'position',[lx+xlbo+nw+hgap+dw+hgap ly+ybotbo+(i-1)*(vgap+th) mw th],...
                'string',deblank(thestring));
            mhan = [han;mhan];
        end
        for i=1:nvar
            set(ethan(i),'userdata',[ethan;mainh]);
            set(cbhan(i),'userdata',[cbhan;mainh]);
        end
        out1 = mainh;
        out2 = cbhan;
        out3 = mhan; % extra handles
        set(mainh,'userdata',[cbhan ethan mhan]);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'pbwetwnet')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    mw = dimvec(12);
    varnames = in4;
    vardefault = in5;
    nvar = size(in4,1);
    frw = xlbo + nw + hgap + dw +hgap + mw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    et_bgc = in8;
    mdefault = in10;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        pbhan = [];
        ethan = [];
        mhan = [];
        for i=1:nvar
            cb = deblank(in7(nvar-i+1,:));
            han = uicontrol(windowhan,...
                'style','pushbutton',...
                'value',0,...
                'horizontalalignment','center',...
                'callback',cb,...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            pbhan = [han;pbhan];
            if isempty(vardefault)
                thestring = '';
            else
                thestring = vardefault(nvar-i+1,:);
            end
            cb = deblank(in9(nvar-i+1,:));
            han = uicontrol(windowhan,...
                'style','edit',...
                'callback',cb,...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',deblank(thestring));
            ethan = [han;ethan];
            if isempty(mdefault)
                thestring = '';
            else
                thestring = mdefault(nvar-i+1,:);
            end
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','left',...
                'position',[lx+xlbo+nw+hgap+dw+hgap ly+ybotbo+(i-1)*(vgap+th) mw th],...
                'string',deblank(thestring));
            mhan = [han;mhan];
        end
        for i=1:nvar
            set(ethan(i),'userdata',[ethan;mainh]);
            set(pbhan(i),'userdata',mhan(1));
        end
        out1 = mainh;
        set(mainh,'userdata',[pbhan ethan mhan]);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'longed')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    dw = dimvec(8);
    vgap = dimvec(9);
    heading = in4;
    estring = in5;
    frw = xlbo + dw + xrbo;
    frh = ybotbo + th + vgap + th + ytopbo;
    et_bgc = in8;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        head_han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','left',...
                'position',[lx+xlbo ly+ybotbo+vgap+th dw th],...
                'string',heading);
        ethan = uicontrol(windowhan,...
                'style','edit',...
                'callback',[in7 ';'],...
                'horizontalalignment','left',...
                'backgroundcolor',et_bgc,...
                'position',[lx+xlbo ly+ybotbo dw th],...
                'string',estring);
        set(ethan,'userdata',[head_han;ethan;mainh]);
        out1 = mainh;
        set(mainh,'userdata',[head_han;ethan]);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'lorb')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    rbh =  dimvec(7);
    rbw = dimvec(8);
    vgap = dimvec(9);
    varnames = in4;
    vardefaultval = in5;
    nvar = length(in5);
    frw = xlbo + rbw + xrbo;
    frh = ybotbo + nvar*rbh +(nvar-1)*vgap + ytopbo;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        rbhan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','radiobutton',...
                'callback',[in7 int2str(nvar-i+1) ');'],...
                'horizontalalignment','left',...
                'value',vardefaultval(nvar-i+1),...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+rbh) rbw rbh],...
                'string',varnames(nvar-i+1,:));
            rbhan = [han;rbhan];
        end
        out1 = mainh;
        set(mainh,'userdata',rbhan);
        for i=1:nvar
            set(rbhan(i),'userdata',[rbhan;mainh]);
        end
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'locb')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    rbh =  dimvec(7);
    rbw = dimvec(8);
    vgap = dimvec(9);
    varnames = in4;
    vardefaultval = in5;
    nvar = length(in5);
    frw = xlbo + rbw + xrbo;
    frh = ybotbo + nvar*rbh +(nvar-1)*vgap + ytopbo;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        rbhan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','checkbox',...
                'callback',[in7 int2str(nvar-i+1) ');'],...
                'horizontalalignment','left',...
                'value',vardefaultval(nvar-i+1),...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+rbh) rbw rbh],...
                'string',varnames(nvar-i+1,:));
            rbhan = [han;rbhan];
        end
        out1 = mainh;
        set(mainh,'userdata',rbhan);
        for i=1:nvar
            set(rbhan(i),'userdata',[rbhan;mainh]);
        end
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'lopb')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    rbh =  dimvec(7);
    rbw = dimvec(8);
    vgap = dimvec(9);
    varnames = in4;
    nvar = size(varnames,1);
    frw = xlbo + rbw + xrbo;
    frh = ybotbo + nvar*rbh +(nvar-1)*vgap + ytopbo;
    if strcmp(in1,'create')
        windowhan = in5;
        cbstring = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        pbhan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','pushbutton',...
                'callback',deblank(cbstring(nvar-i+1,:)),...
                'horizontalalignment','center',...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+rbh) rbw rbh],...
                'string',deblank(varnames(nvar-i+1,:)));
            pbhan = [han;pbhan];
        end
        out1 = mainh;
        out2 = pbhan;
        set(mainh,'userdata',pbhan);
    else
        out1 = [lx ly frw frh];
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'merb')
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    rbh =  dimvec(7);
    rbw = dimvec(8);
    vgap = dimvec(9);
    varnames = in4;
    vardefaultval = in5;
    nvar = length(in5);
    frw = xlbo + rbw + xrbo;
    frh = ybotbo + nvar*rbh +(nvar-1)*vgap + ytopbo;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        rbhan = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','radiobutton',...
                'callback',['parmwin(''cb'',''merb'');' ...
                        in7 int2str(nvar-i+1) ');'],...
                'horizontalalignment','left',...
                'value',vardefaultval(nvar-i+1),...
                'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+rbh) rbw rbh],...
                'string',varnames(nvar-i+1,:));
            rbhan = [han;rbhan];
        end
        out1 = mainh;
        set(mainh,'userdata',rbhan);
        for i=1:nvar
            set(rbhan(i),'userdata',[rbhan;mainh]);
        end
    else
        out1 = [lx ly frw frh];
    end
 elseif strcmp(in1,'cb') & strcmp(in2,'merb')
    co = get(gcf,'currentobject'); % just got clicked
    rbvalue = get(co,'value');
    rbhan = get(co,'userdata');
    rbhan = rbhan(1:length(rbhan)-1);
    if rbvalue == 1
        others = find(rbhan~=co);
        for i=1:length(others)
            set(rbhan(others(i)),'value',0);
        end
    else
        set(co,'value',1);
    end
 elseif strcmp(in1,'getvalues') & strcmp(in2,'nwd')
    ethan = get(in3,'userdata');
    out1 = zeros(length(ethan)-1,1);
    for i=1:length(ethan)-1
        out1(i) = str2double(get(ethan(i),'string'));
    end
 elseif strcmp(in1,'setvalues') & strcmp(in2,'nwd')
    enxt = get(in3,'userdata');
    numfld = size(enxt,1);
    ngiven = size(in4,1);
    if ngiven>numfld
        error('Too Many Fields Specified');
        return
    else
        for i=1:ngiven
            set(enxt(i,1),'string',deblank(in4(i,:)));
        end
    end
 elseif strcmp(in1,'getstring') & strcmp(in2,'nwet')
    ethan = get(in3,'userdata');
    out1 = deblank(get(ethan(in4),'string'));
 elseif strcmp(in1,'setstring') & strcmp(in2,'nwet')
    ethan = get(in3,'userdata');
    set(ethan(in4),'string',in5);
 elseif strcmp(in1,'getvalues') & ...
	(strcmp(in2,'lorb') | strcmp(in2,'merb') | strcmp(in2,'locb'))
    rbhan = get(in3,'userdata');
    out1 = zeros(length(rbhan),1);
    for i=1:length(rbhan)
        out1(i) = get(rbhan(i),'value');
    end
 elseif (strcmp(in1,'create') | strcmp(in1,'dimquery')) & strcmp(in2,'tct')
%   ('create','tct',dimvec,varnames,varsymbol,window)
    dimvec = in3;
    lx = dimvec(1);
    ly = dimvec(2);
    ybotbo =  dimvec(3);
    ytopbo = dimvec(4);
    xlbo = dimvec(5);
    xrbo = dimvec(6);
    th =  dimvec(7);
    nw = dimvec(8);
    dw = dimvec(9);
    hgap = dimvec(10);
    vgap = dimvec(11);
    varnames = in4;
    varsymbol = in5;
    nvar = size(in5,1);
    frw = xlbo + nw + hgap + dw + xrbo;
    frh = ybotbo + nvar*th +(nvar-1)*vgap + ytopbo;
    if strcmp(in1,'create')
        windowhan = in6;
        mainh = uicontrol(windowhan,...
                'style','frame',...
                'position',[lx ly frw frh]);
        thanl = [];
        thanr = [];
        for i=1:nvar
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','right',...
        'position',[lx+xlbo ly+ybotbo+(i-1)*(vgap+th) nw th],...
                'string',deblank(varnames(nvar-i+1,:)));
            thanl = [han;thanl];
            thestring = deblank(varsymbol(nvar-i+1,:));
            if isempty(thestring)
                thestring = '';
            end
            han = uicontrol(windowhan,...
                'style','text',...
                'horizontalalignment','left',...
                'position',[lx+xlbo+nw+hgap ly+ybotbo+(i-1)*(vgap+th) dw th],...
                'string',thestring);
            thanr = [han;thanr];
        end
        out1 = mainh;
        set(mainh,'userdata',[thanl thanr]);
    else
        out1 = [lx ly frw frh];
    end
 end
