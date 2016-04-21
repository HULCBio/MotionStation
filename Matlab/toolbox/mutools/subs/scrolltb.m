%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [mainhandle,exhan,allhan,table_han,out5,out6] = ...
    scrolltb(flag,titlename,summarynames,...
        rowstyle,row_cb,row_bdf,namestyle,name_bdf,...
        llcx,llcy,winhan,dimvec)

%   flag = 'create'
%   flag = 'dimquery'
%   flag = 'l'
%   flag = 'r'
%   flag = 'refill', titlename = mainhandle
%   flag = 'newdata', titlename = mainhandle, summarynames = newdata
%   flag = 'highlight', titlename = mainhandle, summarynames = matrix col to highlight

%   selectable column to get highlighted
%   editable rows
%   autocallbacks

%   DATA, COUNTER, HANDLES
 if strcmp(flag,'create')
    [numnames,dum] = size(summarynames);
    if isempty(row_cb)
        row_cb = setstr(ones(numnames,1)*'rand(');
    end
    if isempty(row_bdf)
        row_bdf = setstr(ones(numnames,1)*'rand(');
    end
    if isempty(name_bdf)
        name_bdf = setstr(ones(numnames,1)*'rand(');
    end
    bw = dimvec(1);
    th = dimvec(2);
    bth = dimvec(3);
    tth = dimvec(4);
    nw = dimvec(5);
    bbw = dimvec(6);
    xbo = dimvec(7);
    numcols = dimvec(8);
    sgap = dimvec(9);
    tgap = dimvec(10);
    bgap = dimvec(11);
    dgap = dimvec(12);
    hgap = dimvec(13);
    ytopbo = dimvec(14);
    ybotbo = dimvec(15);
    scroll_lim = dimvec(16);
    if bth<0
        scrflag = -1;
        bth = abs(bth);
        bgap = 0;
    elseif bth>0
        scrflag = 1;
    else
        scrflag = 0;
    end
    figw = 2*xbo+nw+dgap+(numcols)*bw+(numcols+1)*hgap;
    figh = ybotbo + bth + bgap + numnames*th+(numnames+1)*sgap + tgap + tth + ytopbo;

%   SPACE
    spacex = llcx + xbo;
    spacey = llcy + ybotbo;
    spaceh = bth;
    spacew = nw;
%   NAMES
    namex = spacex;
    namey = spacey + spaceh + bgap;
    nameh = numnames*(th+sgap) + sgap;
    namew = nw;
%   TITLE
    titlex = namex;
    titley = namey + nameh + tgap;
    titleh = tth;
    titlew = figw - 2*xbo;
%   PUSHBUTTONS
    pbx = spacex + nw + dgap;
    pby = spacey;
    pbh = spaceh;
%   TABLE
    tablex = pbx;
    tabley = namey;
    tableh = nameh;
    tablew = numcols*bw + (numcols+1)*hgap;
%   LEFTOVERS
    pbw = tablew;

    exhan = [];
    allhan = [];
    mainhandle = uicontrol(winhan,...
        'Style','frame',...
        'Position',[llcx llcy figw figh]);
    allhan = [allhan;mainhandle];


    if tth > 0
        tithan = uicontrol(winhan,...
            'Style','text',...
            'String',titlename,...
            'Position',[titlex titley titlew titleh]);
        exhan = [exhan;tithan];
        allhan = [allhan;tithan];
    end

    namehandles = zeros(numnames,1);
    sepnamey = namey+sgap;
    for k=1:numnames
        tmp = uicontrol(winhan,...
            'Style',deblank(namestyle(numnames-k+1,:)),...
            'callback',[deblank(name_bdf(numnames-k+1,:)) int2str(numnames-k+1) ');'],...
            'String',[deblank(summarynames(numnames-k+1,:)) ' '],...
            'horizontalalignment','right',...
            'Position',[namex sepnamey nw th]);
        exhan = [exhan;tmp];
        allhan = [allhan;tmp];
        namehandles(numnames-k+1) = tmp;
        sepnamey = sepnamey + th + sgap;
    end
    tableframe = uicontrol(winhan,'style','frame',...
        'position',[tablex tabley tablew tableh]);
    exhan = [exhan;tableframe];
    allhan = [allhan;tableframe];
    TOPSTUFF = [192 192 192]/255;

    xloc = tablex + hgap;
    table_han = [];
    for j=1:numcols
        colhan = [];
        yloc = tabley + sgap;
        for k=1:numnames
            view = uicontrol(winhan,...
                'Style',deblank(rowstyle(numnames-k+1,:)),...
                'buttondownfcn',[deblank(row_bdf(numnames-k+1,:)) int2str(numnames-k+1) ',' int2str(j) ');'],...
                'callback',[deblank(row_cb(numnames-k+1,:)) int2str(numnames-k+1) ',' int2str(j) ');'],...
                'ForeGroundColor',[0.0 0.0 0.0],...
                'BackGroundColor',TOPSTUFF,...
                'userdata',mainhandle,...
                'Position',[xloc yloc bw th]);
%           exhan = [exhan;view];
            allhan = [allhan;view];
            colhan = [colhan;view];
            yloc = yloc + th + sgap;
        end
        table_han = [table_han flipud(colhan)];
        xloc = xloc + bw + hgap;
    end

    slh = nan;
    if scrflag > 0
        pbl = uicontrol(winhan,...
            'Style','Pushbutton',...
            'userdata',mainhandle,...
            'Callback','scrolltb(''l'');',...
            'String','<<<',...
            'HorizontalAlignment','Center',...
            'Position',[pbx pby bbw bth]);
        pbr = uicontrol(winhan,...
            'Style','Pushbutton',...
            'userdata',mainhandle,...
            'Callback','scrolltb(''r'');',...
            'String','>>>',...
            'Position',...
                [pbx+pbw-bbw pby bbw bth]);
        pbhan = [pbl pbr];
        allhan = [allhan;pbl;pbr];
    elseif scrflag < 0  % slider
        pos = [pbx pby pbw abs(bth)];
        info = [numcols+1;numcols;2];
        usecb = 'scrolltb(''sm'');';
        slh = ourslid(0,'create',pos,info,usecb,mainhandle,winhan);
        allhan = [allhan;slh];
    end
    stdata = [];
    stdata = ipii(stdata,table_han,2); % Table handles
    tmp = [1;0;scroll_lim;numcols;1];
        % number of matrix column in first col of table
        % number of matrix column to be highlighted
        % scroll limit, 0=DK, 1=FITSTATUS
        % number of columns
        % modefill, 0 freeform, 1 column
    stdata = ipii(stdata,tmp,3);
    stdata = ipii(stdata,allhan,6);
    stdata = ipii(stdata,namehandles,7);
    stdata = ipii(stdata,ones(numnames,1),8);   % tells which
                        % rows are visible, see enablerow, disablerow
    NOMBGC = [1 1 1]; % clicked FGC for names
    NOMFGC = [0 0 0]; % clicked BGC for names
    stdata = ipii(stdata,NOMBGC,9);
    stdata = ipii(stdata,NOMFGC,10);
    namerv = zeros(numnames,1); %    start out NOT reverse videod
    stdata = ipii(stdata,namerv,11);
    stdata = ipii(stdata,[scrflag slh],12);
    set(mainhandle,'Userdata',stdata);
 elseif strcmp(flag,'delete')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    allhan = xpii(stdata,6);
    delete(allhan)
 elseif strcmp(flag,'normalized')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    allhan = xpii(stdata,6);
    set(allhan,'units','normalized')
 elseif strcmp(flag,'visible')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    allhan = xpii(stdata,6);
    if strcmp(summarynames,'off')
        set(allhan,'visible','off')
    else
        set(allhan,'visible','on')
    end
 elseif strcmp(flag,'dimquery')
    [numnames,dum] = size(summarynames);
    bw = dimvec(1);
    th = dimvec(2);
    bth = dimvec(3);
    tth = dimvec(4);
    nw = dimvec(5);
    bbw = dimvec(6);
    xbo = dimvec(7);
    numcols = dimvec(8);
    sgap = dimvec(9);
    tgap = dimvec(10);
    bgap = dimvec(11);
    dgap = dimvec(12);
    hgap = dimvec(13);
    ytopbo = dimvec(14);
    ybotbo = dimvec(15);
    scroll_lim = dimvec(16);
    if bth<0
        bth = abs(bth);
        bgap = 0;
    end
    figw = 2*xbo+nw+dgap+(numcols)*bw+(numcols+1)*hgap;
    figh = ybotbo + bth + bgap + numnames*th+(numnames+1)*sgap + tgap + tth + ytopbo;
    mainhandle = [llcx llcy figw figh];
 elseif strcmp(flag,'sm')
    slh = get(gcf,'currentobject');
    allinfo = get(slh,'userdata');
    mainhandle = allinfo(5);
    stdata = get(mainhandle,'userdata');
    scroll_mat = xpii(stdata,1);scroll_matrv = xpii(stdata,5);scroll_mask = xpii(stdata,4);
    scroll_han = xpii(stdata,2);scroll_info = xpii(stdata,3);cnt = scroll_info(1);
    lim = scroll_info(3);
    ntcols = scroll_info(4);modefill = scroll_info(5);
    [numprop,dum] = size(scroll_han);
    if isempty(scroll_mat)
        colsofdata = 0;
    else
        [dum,colsofdata] = size(scroll_mat);
        if all(isinf(scroll_mat(:,colsofdata))) % if last column is
            colsofdata = colsofdata-1;      % all INF, don't count
        end
    end
    scroll_info(1) = allinfo(1)-allinfo(2)+2-allinfo(4);
    stdata = ipii(stdata,scroll_info,3);
    set(mainhandle,'userdata',stdata);
    scrolltb('refill2',mainhandle);
 elseif strcmp(flag,'l') | strcmp(flag,'r')
    co = get(gcf,'currentobject');
    mainhandle = get(co,'userdata');
    stdata = get(mainhandle,'userdata');
    scroll_mat = xpii(stdata,1);scroll_matrv = xpii(stdata,5);scroll_mask = xpii(stdata,4);
    scroll_han = xpii(stdata,2);scroll_info = xpii(stdata,3);cnt = scroll_info(1);
    lim = scroll_info(3);
    ntcols = scroll_info(4);modefill = scroll_info(5);
    [numprop,dum] = size(scroll_han);
    if isempty(scroll_mat)
        colsofdata = 0;
    else
        [dum,colsofdata] = size(scroll_mat);
        if all(isinf(scroll_mat(:,colsofdata))) % if last column is
            colsofdata = colsofdata-1;      % all INF, don't count
        end
    end
    if strcmp(flag,'l')
        if cnt > 1
            scroll_info(1) = cnt-1;
            stdata = ipii(stdata,scroll_info,3);
            set(mainhandle,'userdata',stdata);
            scrolltb('refill2',mainhandle);
        end
    elseif strcmp(flag,'r')
        if (cnt < colsofdata & lim==0) | (lim==1 & cnt+ntcols-1<colsofdata)
            scroll_info(1) = cnt+1;
            stdata = ipii(stdata,scroll_info,3);
            set(mainhandle,'userdata',stdata);
            scrolltb('refill2',mainhandle);
        end
    end
elseif strcmp(flag,'refill')
    TOPSTUFF = [0.75 0.75 0.75];
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_mat = xpii(stdata,1);scroll_matrv = xpii(stdata,5);scroll_mask = xpii(stdata,4);
    scroll_han = xpii(stdata,2);scroll_info = xpii(stdata,3);cnt = scroll_info(1);
    ntcols = scroll_info(4);
    [numprop,dum] = size(scroll_han);
    if isempty(scroll_mat)
        colsofdata = 0;
    else
        [dum,colsofdata] = size(scroll_mat);
        if all(isinf(scroll_mat(:,colsofdata))) % if last column is
            colsofdata = colsofdata-1;      % all INF, don't count
        end
    end
    for i=1:numprop
        for j=1:min([ntcols colsofdata-cnt+1])
            set(scroll_han(i,j),...
                'String',gjb2(scroll_mat(i,cnt+j-1),scroll_mask(i,cnt+j-1)),...
                'backgroundcolor',(1-scroll_matrv(i,cnt+j-1))*TOPSTUFF,...
                'foregroundcolor',scroll_matrv(i,cnt+j-1)*TOPSTUFF,...
                'value',scroll_matrv(i,cnt+j-1));
        end
        for j=min([ntcols colsofdata-cnt+1])+1:ntcols  % DKsummary-style
            set(scroll_han(i,j),'String','',...
                'backgroundcolor',(1-scroll_matrv(i,cnt+j-1))*TOPSTUFF,...
                'foregroundcolor',scroll_matrv(i,cnt+j-1)*TOPSTUFF,...
                'value',scroll_matrv(i,cnt+j-1));
        end
    end
elseif strcmp(flag,'refill2')
    mainhandle = titlename;
    stdata       = get(mainhandle,'userdata');
    scroll_mat   = xpii(stdata,1);
    scroll_matrv = xpii(stdata,5);
    scroll_mask  = xpii(stdata,4);
    scroll_han   = xpii(stdata,2);
    scroll_info  = xpii(stdata,3);
    cnt          = scroll_info(1);
    ntcols = scroll_info(4);
    [numprop,dum] = size(scroll_han);
    if isempty(scroll_mat)
        colsofdata = 0;
    else
        [dum,colsofdata] = size(scroll_mat);
        if all(isinf(scroll_mat(:,colsofdata))) % if last column is
            colsofdata = colsofdata-1;      % all INF, don't count
        end
    end
    for i=1:numprop
        for j=1:min([ntcols colsofdata-cnt+1])
            set(scroll_han(i,j),...
                'String',gjb2(scroll_mat(i,cnt+j-1),scroll_mask(i,cnt+j-1)),...
                'value',scroll_matrv(i,cnt+j-1));
        end
        for j=min([ntcols colsofdata-cnt+1])+1:ntcols  % DKsummary-style
            set(scroll_han(i,j),'String','',...
                'value',scroll_matrv(i,cnt+j-1));
        end
    end
elseif strcmp(flag,'rv') % only MATRV
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_matrv = xpii(stdata,5);
    if nargin == 4
        rownum = summarynames;
        colnum = rowstyle;
        scroll_matrv(rownum,colnum) = ~scroll_matrv(rownum,colnum);
    else
        rcind = summarynames;
        for i=1:size(rcind,1)
            scroll_matrv(rcind(i,1),rcind(i,2)) = ~scroll_matrv(rcind(i,1),rcind(i,2));
        end
    end
    stdata = ipii(stdata,scroll_matrv,5);
    set(mainhandle,'userdata',stdata);
    scrolltb('refill',mainhandle);
elseif strcmp(flag,'rv2') % only MATRV
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_matrv = xpii(stdata,5);
    rcind = summarynames;
    on_off = rowstyle;
    for i=1:size(rcind,1)
       scroll_matrv(rcind(i,1),rcind(i,2)) = on_off(i);
    end
    stdata = ipii(stdata,scroll_matrv,5);
    set(mainhandle,'userdata',stdata);
    scrolltb('refill2',mainhandle);
elseif strcmp(flag,'rvname2')
    mainhandle = titlename;
    rownum = summarynames;
    stdata = get(mainhandle,'userdata');
    namehandles = xpii(stdata,7);
    namerv = xpii(stdata,11);
    if isempty(rowstyle)
        namerv(rownum) = ~namerv(rownum);
    else
        namerv(rownum) = rowstyle;
    end
    stdata = ipii(stdata,namerv,11);
    co = namehandles(rownum);
%    val = get(co,'value');
    set(co,'value',namerv(rownum));
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'setrvname2') % 1 for REVERSED, 0 for NORMAL
    mainhandle = titlename;
    rowvideo = summarynames; %
    stdata = get(mainhandle,'userdata');
    namehandles = xpii(stdata,7);
    nombgc = xpii(stdata,9);
    nomfgc = xpii(stdata,10);
    for i=1:length(namehandles)
        if rowvideo(i) == 0
            set(namehandles(i),'value',0);
        else
            set(namehandles(i),'value',1);
        end
    end
    stdata = ipii(stdata,rowvideo,11);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'rvname')
    mainhandle = titlename;
    rownum = summarynames;
    stdata = get(mainhandle,'userdata');
    namehandles = xpii(stdata,7);
    namerv = xpii(stdata,11);
    namerv(rownum) = ~namerv(rownum);
    stdata = ipii(stdata,namerv,11);
    co = namehandles(rownum);
    bgc = get(co,'backgroundcolor');
    fgc = get(co,'foregroundcolor');
    set(co,'foregroundcolor',bgc);
    set(co,'backgroundcolor',fgc);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'setrvname') % 1 for REVERSED, 0 for NORMAL
    mainhandle = titlename;
    rowvideo = summarynames; %
    stdata = get(mainhandle,'userdata');
    namehandles = xpii(stdata,7);
    nombgc = xpii(stdata,9);
    nomfgc = xpii(stdata,10);
    for i=1:length(namehandles)
    if rowvideo(i) == 0
        set(namehandles(i),'foregroundcolor',nomfgc,'backgroundcolor',nombgc);
    else
        set(namehandles(i),'foregroundcolor',nombgc,'backgroundcolor',nomfgc);
    end
    end
    stdata = ipii(stdata,rowvideo,11);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'getrvname') % 1 for REVERSED, 0 for NORMAL
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    mainhandle = xpii(stdata,11);
elseif strcmp(flag,'getrv')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    mainhandle = xpii(stdata,5);
elseif strcmp(flag,'setrv')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    stdata = ipii(stdata,summarynames,5);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'getdata')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    mainhandle = xpii(stdata,1);
elseif strcmp(flag,'getmask')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    mainhandle = xpii(stdata,4);
elseif strcmp(flag,'namechange')
    mainhandle = titlename;
    newnames = summarynames;
    rownumbers = rowstyle;
    stdata = get(mainhandle,'userdata');
    nh = xpii(stdata,7);
    for i=1:length(rownumbers)
        set(nh(rownumbers(i)),'String',[deblank(newnames(i,:)) ' ']);
    end
elseif strcmp(flag,'getstuff') % [data,matrv,cnt,mask,visrows,gff]
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    mainhandle = xpii(stdata,1);
    exhan = xpii(stdata,5);
    scroll_info = xpii(stdata,3);
    allhan = scroll_info(1);
    scroll_mask = xpii(stdata,4);
    table_han = scroll_mask;
    out5 = xpii(stdata,8);
    out6 = scroll_info(5);
elseif strcmp(flag,'setgff') % (gff)
    mh = titlename;
    gff = summarynames;
    stdata = get(mh,'userdata');
    scroll_info = xpii(stdata,3);
    scroll_info(5) = gff;
    stdata = ipii(stdata,scroll_info,3);
    set(mh,'userdata',stdata);
elseif strcmp(flag,'getgff') % [gff]
    mh = titlename;
    stdata = get(mh,'userdata');
    scroll_info = xpii(stdata,3);
    gff = scroll_info(5);
    mainhandle = gff;
elseif strcmp(flag,'setstuff') % (data,matrv,cnt,mask,visrows,gff)
    mh = titlename;
    data = summarynames;
    matrv = rowstyle;
    cnt = row_cb;
    mask = row_bdf;
    visrows = namestyle;
    gff = name_bdf;
    stdata = get(mh,'userdata');
    stdata = ipii(stdata,data,1);
    stdata = ipii(stdata,matrv,5);
    scroll_info = xpii(stdata,3);
    scroll_info(1) = cnt;
    scroll_info(5) = gff;
    stdata = ipii(stdata,scroll_info,3);
    stdata = ipii(stdata,mask,4);
    stdata = ipii(stdata,visrows,8);
    set(mh,'userdata',stdata);
elseif strcmp(flag,'setcnt')
    mh = titlename;
    cnt = summarynames;
    stdata = get(mh,'userdata');
    scroll_info = xpii(stdata,3);
    scroll_info(1) = cnt;
    stdata = ipii(stdata,scroll_info,3);
    set(mh,'userdata',stdata);
elseif strcmp(flag,'getcnt')
    mh = titlename;
    stdata = get(mh,'userdata');
    scroll_info = xpii(stdata,3);
    mainhandle = scroll_info(1);
elseif strcmp(flag,'togglemode')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_info = xpii(stdata,3);
    scroll_info(5) = ~scroll_info(5);
    stdata = ipii(stdata,scroll_info,3);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'disablerow')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_han = xpii(stdata,2);
    scroll_info = xpii(stdata,3);
    ntcols = scroll_info(4);
    visrows = xpii(stdata,8);
    disabler = summarynames;
    set(scroll_han(disabler,1:ntcols),'visible','off','enable','off');
    visrows(disabler) = zeros(length(disabler),1);
    stdata = ipii(stdata,visrows,8);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'enablerow')
    mainhandle = titlename;
    stdata = get(mainhandle,'userdata');
    scroll_han = xpii(stdata,2);
    scroll_info = xpii(stdata,3);
    ntcols = scroll_info(4);
    visrows = xpii(stdata,8);
    enabler = summarynames;
    set(scroll_han(enabler,1:ntcols),'visible','on','enable','on');
    visrows(enabler) = ones(length(enabler),1);
    stdata = ipii(stdata,visrows,8);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'firstdata')
    mainhandle = titlename;
    newdata = summarynames;
    if nargin > 3
        newmask = rowstyle;
    else
        newmask = zeros(size(newdata));
    end
    stdata = get(mainhandle,'userdata');
    scinfo = xpii(stdata,12);
    if scinfo(1)==-1    % slider is present
        lpp = ourslid(scinfo(2),'getlpp');
        ourslid(scinfo(2),'setnl',size(newdata,2));
        ourslid(scinfo(2),'setourval',size(newdata,2)-lpp+1);
    end
    stdata = ipii(stdata,newdata,1);
    stdata = ipii(stdata,0*newdata,5); % 0 regular: light background, dark letter
    stdata = ipii(stdata,newmask,4);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'newdata')
    mainhandle = titlename;
    newdata = summarynames;
    if nargin > 3
        newmask = rowstyle;
    else
        newmask = zeros(size(newdata));
    end

    stdata = get(mainhandle,'userdata');
    stdata = ipii(stdata,newdata,1);
    stdata = ipii(stdata,newmask,4);
    set(mainhandle,'userdata',stdata);
elseif strcmp(flag,'switchrowstyle')
    mainhandle = titlename;
    rownumbers = summarynames; % rowstyle is already 4th argument
    stdata = get(mainhandle,'userdata');
    scroll_han = xpii(stdata,2);
    ncols = size(scroll_han,2);
    for k=1:length(rownumbers)
        for j=1:ncols
            set(scroll_han(rownumbers(k),j),'Style',deblank(rowstyle(k,:)));
        end
    end
elseif strcmp(flag,'updateslid')
    mainhandle = titlename;
    stdata       = get(mainhandle,'userdata');
    scroll_info  = xpii(stdata,3);
    cnt          = scroll_info(1);
    scinfo       = xpii(stdata,12);
    if scinfo(1) < 0
    allinfo = get(scinfo(2),'userdata');
    ourslid(scinfo(2),'setourval',allinfo(1)-cnt-2);
    end
else
    disp('No such string in scrolltb');
end