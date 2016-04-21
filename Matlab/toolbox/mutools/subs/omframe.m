% function [out1] = omframe(toolhan,objhan,in1,in2,in3,in4,in5,in6)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1] = omframe(toolhan,objhan,in1,in2,in3,in4,in5,in6)

 if isempty(toolhan)
	toolhan = gcf;
 end
 if isempty(objhan)
	co = get(gcf,'currentobject');
	if ~isempty(co)
		hh = get(co,'userdata');
	end
 else
	hh = objhan;
 end
 thstr = int2str(toolhan);

%   DATA, COUNTER, HANDLES
 if strcmp(in1,'create')
    dimvec = in2;
    llx = dimvec(1);
    lly = dimvec(2);
    winhan = in3;
    rbh = dimvec(3);
    ytopbo = dimvec(4);
    th = dimvec(5);
    ygap = dimvec(6);
    ybotbo = dimvec(7);
    xbo = dimvec(8);
    tw = dimvec(9);
    xgap = dimvec(10);
    et_bgc = in4;

    framew = xbo + tw + xgap + tw + xgap + tw + xbo;
    frameh = ybotbo + th + ygap + th + ytopbo + rbh;
    rbw = framew/2-xbo;

    exhan = [];
    allhan = [];
    mainhandle = uicontrol(winhan,...
        'Style','frame',...
        'Position',[llx lly framew frameh]);
%       'backgroundcolor',[0.8 0.8 0.8]);

    lf_et = uicontrol(winhan,...
        'style','edit',...
        'horizontalalignment','left',...
        'position',[llx+xbo lly+ybotbo tw th],...
        'backgroundcolor',et_bgc,...
        'callback',['omframe(' thstr ',[],''olow'');']);

    hf_et = uicontrol(winhan,...
        'style','edit',...
        'horizontalalignment','left',...
        'position',[llx+xbo+tw+xgap lly+ybotbo tw th],...
        'backgroundcolor',et_bgc,...
        'callback',['omframe(' thstr ',[],''ohigh'');']);

    npts_et = uicontrol(winhan,...
        'style','edit',...
        'horizontalalignment','left',...
        'position',[llx+xbo+tw+xgap+tw+xgap lly+ybotbo tw th],...
        'backgroundcolor',et_bgc,...
        'callback',['omframe(' thstr ',[],''onpts'');']);

	ehan = [lf_et;hf_et;npts_et];

    lf_txt = uicontrol(winhan,...
        'style','text',...
        'horizontalalignment','left',...
        'string','Low',...
        'position',[llx+xbo lly+ybotbo+th+ygap tw th]);

    hf_txt = uicontrol(winhan,...
        'style','text',...
        'horizontalalignment','left',...
        'string','High',...
        'position',[llx+xbo+tw+xgap lly+ybotbo+th+ygap tw th]);

    npts_txt = uicontrol(winhan,...
        'style','text',...
        'horizontalalignment','left',...
        'string','# Points',...
        'position',[llx+xbo+tw+xgap+tw+xgap lly+ybotbo+th+ygap tw th]);

    ctitle = uicontrol(winhan,...
        'style','text',...
        'position',[llx+xbo lly+ybotbo+th+ygap 3*tw+2*xgap th],...
        'horizontalalignment','left',...
        'visible','off',...
        'string','M-File(OLIC,K,CLP)');

    cedit = uicontrol(winhan,...
        'style','edit',...
        'position',[llx+xbo lly+ybotbo 3*tw+2*xgap th],...
        'horizontalalignment','left',...
        'visible','off',...
        'backgroundcolor',et_bgc,...
        'callback',['omframe(' thstr ',[],''mkomega'');'],...
        'string','');

    logspace_rb = uicontrol(winhan,...
        'style','radiobutton',...
        'string','Logspace',...
        'value',1,...
        'position',[llx+xbo lly+ybotbo+th+ygap+th+ytopbo rbw rbh-xbo],...
        'callback',['omframe(' thstr ',[],''logspace'');']);

    custom_rb = uicontrol(winhan,...
        'style','radiobutton',...
        'string','Custom',...
        'value',0,...
        'position',[llx+xbo+rbw lly+ybotbo+th+ygap+th+ytopbo rbw rbh-xbo],...
        'callback',['omframe(' thstr ',[],''custom'');']);

    data = [1;nan;nan;nan;logspace_rb;custom_rb]; % 1-6
    lhan = [lf_et;hf_et;npts_et;lf_txt;hf_txt;npts_txt]; % 7-12
    chan = [ctitle;cedit]; % 13-14
    % 1=logspace, 2=custom;olow;ohigh;onpts;radio;radio
    set(mainhandle,'userdata',[data;lhan;chan]);
    set([logspace_rb;custom_rb;lhan;chan],'userdata',mainhandle);
    out1 = mainhandle;
 elseif strcmp(in1,'dimquery')
    dimvec = in2;
    rbh = dimvec(3);
    ytopbo = dimvec(4);
    th = dimvec(5);
    ygap = dimvec(6);
    ybotbo = dimvec(7);
    xbo = dimvec(8);
    tw = dimvec(9);
    xgap = dimvec(10);
    framew = xbo + tw + xgap + tw + xgap + tw + xbo;
    frameh = ybotbo + th + ygap + th + ytopbo + rbh;
    out1 = [dimvec(1) dimvec(2) framew frameh];
 elseif strcmp(in1,'olow')
    data = get(hh,'userdata');
    olow = str2double(get(co,'string'));
    data(2) = nan;
    if isinf(olow)
        set(co,'string','');
    elseif isnan(olow)
        set(co,'string','');
    elseif isempty(olow)
        set(co,'string','');
    elseif olow<=0
        set(co,'string','');
    else
        data(2) = olow;
    end
    set(hh,'userdata',data);
    omframe(toolhan,[],'chkomega',data);
 elseif strcmp(in1,'ohigh')
    data = get(hh,'userdata');
    ohigh = str2double(get(co,'string'));
    data(3) = nan;
    if isinf(ohigh)
        set(co,'string','');
    elseif isnan(ohigh)
        set(co,'string','');
    elseif isempty(ohigh)
        set(co,'string','');
    elseif ohigh<=0
        set(co,'string','');
    else
        data(3) = ohigh;
    end
    set(hh,'userdata',data);
    omframe(toolhan,[],'chkomega',data);
 elseif strcmp(in1,'onpts')
    data = get(hh,'userdata');
    onpts = str2double(get(co,'string'));
    data(4) = nan;
    if isinf(onpts)
        set(co,'string','');
    elseif isnan(onpts)
        set(co,'string','');
    elseif isempty(onpts)
        set(co,'string','');
    elseif onpts<=0 | floor(onpts)~=ceil(onpts)
        set(co,'string','');
    else
        data(4) = onpts;
    end
    set(hh,'userdata',data);
    omframe(toolhan,[],'chkomega',data);
 elseif strcmp(in1,'chkomega')
    data = in2;
    if ~any(isnan(data(2:4)))
        if data(2) < data(3)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% APPLICATION-SPECIFIC START
            [BUTSTAT,CITER,INUM,ISREADY] = gguivar('BUTSTAT','CITER','INUM','ISREADY',toolhan);
            ISREADY(4,2) = 1;
            sguivar('ISREADY',ISREADY);
            if (BUTSTAT(4) >=2 | BUTSTAT(5) >= 2) & INUM >= 1
                dk_able(3,2,toolhan);
            elseif all(BUTSTAT==1)
                rready(toolhan);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% APPLICATION-SPECIFIC END
        else
            [ISREADY] = gguivar('ISREADY',toolhan);
            ISREADY(4,2) = nan;
            sguivar('ISREADY',ISREADY,toolhan);
            rready(toolhan);
        end
    else
        [ISREADY] = gguivar('ISREADY',toolhan);
        ISREADY(4,2) = nan;
        sguivar('ISREADY',ISREADY,toolhan);
        rready(toolhan);
    end
 elseif strcmp(in1,'mkomega')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% APPLICATION-SPECIFIC START
    [BUTSTAT,CITER,INUM,ISREADY] = gguivar('BUTSTAT','CITER','INUM','ISREADY',toolhan);
    ISREADY(4,2) = 1;
    sguivar('ISREADY',ISREADY,toolhan);
    if (BUTSTAT(4) >=2 | BUTSTAT(5) >= 2) & INUM >= 1
        dk_able(3,2,toolhan);
    elseif all(BUTSTAT==1)
        rready(toolhan);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% APPLICATION-SPECIFIC END
 elseif strcmp(in1,'getomega')
    data = get(in2,'userdata');
    if data(1)==1
        if ~any(isnan(data(2:4)))
            if data(2) < data(3)
                out1 = logspace(log10(data(2)),log10(data(3)),data(4));
		lf = num2str(data(2));
		hf = num2str(data(3));
		pt = num2str(data(4));
                out1 = ['logspace(log10(' lf '),log10(' hf '),' pt ');'];
            else
                out1 = [];
            end
        else
            out1 = [];
        end

    else
        out1 = get(data(14),'string');
    end
 elseif strcmp(in1,'logspace')
    data = get(hh,'userdata');
    data(1) = 1;
    set(data(5),'value',1);
    set(data(6),'value',0);
    set(data(13:14),'visible','off');
    set(data(7:12),'visible','on');
    set(hh,'userdata',data);
 elseif strcmp(in1,'custom')
    data = get(hh,'userdata');
    data(1) = 2;
    set(data(5),'value',0);
    set(data(6),'value',1);
    set(data(7:12),'visible','off');
    set(data(13:14),'visible','on');
    set(hh,'userdata',data);
 elseif strcmp(in1,'setcustomstr')
    data = get(hh,'userdata');
    data(1) = 2;
    set(data(5),'value',0);
    set(data(6),'value',1);
    set(data(7:12),'visible','off');
    set(data(13:14),'visible','on');
    set(data(14),'string',in2);
    set(hh,'userdata',data);
 else
	disp('Warning (OMFRAME): Message not found');
 end
