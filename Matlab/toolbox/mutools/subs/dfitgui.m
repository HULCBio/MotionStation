% function [out1,out2,out3] = dfitgui(message,toolhan,in1,in2,in3,in4,in5)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [out1,out2,out3] = dfitgui(message,toolhan,in1,in2,in3,in4,in5)


if nargin == 0
    message = 'create';
end
if nargin >= 2
    if isempty(toolhan)
        toolhan = gcf;
    end
end

if strcmp(message,'create')
    dgkwinpos = gguivar('ORIGWINPOS');
    dgkwin_h = dgkwinpos(4);          % original Window Height
    dgkwin_w = dgkwinpos(3);         % original Window Width
    numcols = in1;
    numscales = in2;
    WIN = in3;
    scroll_llx = in4(1);
    scroll_lly = in4(2);
    winposw = in5(3);       % pixels
    winposh = in5(4);       % pixels
    wf = winposw/dgkwin_w;
    hf = winposh/dgkwin_h;

    uiobjs = [];
    summarynames = str2mat('Scaling','Order');
    titlename = 'D Scaling Order';
    pbh = 0;
    if numscales > numcols
        pbh = 15*hf;
    end
    dimvec = [28*wf;19*hf;-pbh*hf;20*hf;120*wf;55*wf;3*wf;...
                numcols;2*hf;4*hf;2*hf;4*wf;2*hf;2*hf;2*hf;1];
    [DFITTAB,exhan,allhan] = ...
        scrolltb('create',titlename,summarynames,setstr(str2mat('text','edit')),...
            str2mat('dfitgui(''swcol'',[],','dfitgui(''edit'',[],'),...
            str2mat('dfitgui(''swcol'',[],','dfitgui(''edit'',[],'),...
            setstr(str2mat('text','text')),[],...
            scroll_llx,scroll_lly,WIN,dimvec);
    fpos = get(DFITTAB,'position');
    figure(WIN);
    REAUTOFIT = uicontrol('style','pushbutton',...
        'position',[fpos(1) fpos(2)+fpos(4)+2*hf fpos(3) 21*hf],...
        'string','Repeat Auto-Fit',...
        'visible','off',...
        'callback','dfitgui(''fullautoprefit'',[])');
    ordbuty = abs(dimvec(3)) + dimvec(9) + dimvec(11) + dimvec(15);
    ordbutw = 30*wf;
    ordbutgap = 4*wf;
    DOWN = uicontrol('style','pushbutton','position',...
        [scroll_llx+ordbutgap scroll_lly+ordbuty ordbutw dimvec(2)],...
        'visible','off',...
        'callback','dfitgui(''decord'',[])','string','--');
    UP = uicontrol('style','pushbutton','position',...
        [scroll_llx+2*ordbutgap+ordbutw scroll_lly+ordbuty ordbutw dimvec(2)],...
        'visible','off',...
        'callback','dfitgui(''incord'',[])','string','++');
    ordbuty = ordbuty + dimvec(9) + dimvec(2);
    DOWNN = uicontrol('style','pushbutton','position',...
        [scroll_llx+ordbutgap scroll_lly+ordbuty ordbutw dimvec(2)],...
        'visible','off',...
        'callback','dfitgui(''decsca'',[])','string','--');
    UPP = uicontrol('style','pushbutton','position',...
        [scroll_llx+2*ordbutgap+ordbutw scroll_lly+ordbuty ordbutw dimvec(2)],...
        'visible','off',...
        'callback','dfitgui(''incsca'',[])','string','++');
    if numscales == 1
        set(DOWNN,'enable','off');
        set(UPP,'enable','off');
    end
    scrolltb('firstdata',DFITTAB,[1:numscales;ones(1,numscales)]);
    scrolltb('visible',DFITTAB,'off');
    scrolltb('setrv',DFITTAB,zeros(2,numscales));
    scrolltb('refill',DFITTAB);
    sguivar('DFITTAB',DFITTAB,'UPDOWN',[UP DOWN UPP DOWNN],...
        'REAUTOFIT',REAUTOFIT,toolhan);
    scrolltb('rv',DFITTAB,[1 2],1);
    scrolltb('normalized',DFITTAB);
    uiobjs = [REAUTOFIT;UP;DOWN;UPP;DOWNN];
    set(uiobjs,'units','normalized');
    out1 = DFITTAB;
elseif strcmp(message,'dimquery')
    dgkwinpos = gguivar('ORIGWINPOS');
    dgkwin_h = dgkwinpos(4);          % original Window Height
    dgkwin_w = dgkwinpos(3);         % original Window Width
    winposw = in5(3);       % pixels
    winposh = in5(4);       % pixels
    wf = winposw/dgkwin_w;
    hf = winposh/dgkwin_h;

    numcols = in1;
    numscales = in2;
    WIN = in3;
    scroll_llx = in4(1);
    scroll_lly = in4(2);

    summarynames = str2mat('Scaling','Order');
    titlename = 'D Scaling Order';
    pbh = 0;
    if numscales > numcols
        pbh = 15*hf;
    end
    dimvec = [28*wf;19*hf;-pbh*hf;20*hf;120*wf;55*wf;3*wf;...
                numcols;2*hf;4*hf;2*hf;4*wf;2*hf;2*hf;2*hf;1];
    out1 = ...
        scrolltb('dimquery',titlename,summarynames,setstr(str2mat('text','edit')),...
            str2mat('dfitgui(''swcol'',[],','dfitgui(''edit'',[],'),...
            str2mat('dfitgui(''swcol'',[],','dfitgui(''edit'',[],'),...
            setstr(str2mat('text','text')),[],...
            scroll_llx,scroll_lly,WIN,dimvec);
elseif strcmp(message,'delete')
    [DFITTAB,UPDOWN,REAUTOFIT] = gguivar('DFITTAB','UPDOWN','REAUTOFIT',toolhan);
    scrolltb('delete',DFITTAB);
    delete(UPDOWN,REAUTOFIT)
elseif strcmp(message,'edit')
    str = get(get(gcf,'currentobject'),'string');
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    num = str2double(str);
    if ~isempty(num)
        if all(size(num)==1) & floor(num)==ceil(num) & num<inf & num>(-inf)
            if num >= 0
                data(in1,in2+cnt-1) = num; % FIT
                mask(in1,in2+cnt-1) = 0;
                message = 'dofit';
                quantity = [in2+cnt-1 num];
             else
                data(in1,in2+cnt-1) = abs('d'); % replace with DATA
                mask(in1,in2+cnt-1) = 1;
                message = 'showdata';
                quantity = [in2+cnt-1];
             end
        else
            disp('Message 1') % number, but screwed up
        end
    elseif strcmp(str,'d')
        data(in1,in2+cnt-1) = abs('d');  % replace with DATA
        mask(in1,in2+cnt-1) = 1;
        message = 'showdata';
        quantity = [in2+cnt-1];
    else
        disp('Message 2') % wrong string
    end
    scrolltb('newdata',DFITTAB,data,mask);
    scrolltb('rv',DFITTAB,[1 2],[COLSEL]);
    scrolltb('rv',DFITTAB,[1 2],[in2+cnt-1]);
    sguivar('COLSEL',in2+cnt-1,toolhan);
    dfitgui(message,toolhan,quantity);
elseif strcmp(message,'swcol')
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    newcol = in2+cnt-1;
    if COLSEL~=newcol
        scrolltb('rv',DFITTAB,[1 2],[COLSEL newcol]);
        sguivar('COLSEL',newcol,toolhan);
        % refresh SENSITIVITY and D-scale stuff
        dfitgui('switchscale',toolhan,newcol)
    end
elseif strcmp(message,'incord')
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    if mask(2,COLSEL) == 0
        data(2,COLSEL) = data(2,COLSEL) + 1;
    else
        data(2,COLSEL) = 0;
        mask(2,COLSEL) = 0;
    end
    scrolltb('newdata',DFITTAB,data,mask);
    dfitgui('dofit',toolhan,[COLSEL data(2,COLSEL)])
    scrolltb('refill',DFITTAB);
elseif strcmp(message,'decord')
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    if mask(2,COLSEL) == 0
        if data(2,COLSEL) > 0
            data(2,COLSEL) = data(2,COLSEL) - 1;
            scrolltb('newdata',DFITTAB,data,mask);
            scrolltb('refill',DFITTAB);
            dfitgui('dofit',toolhan,[COLSEL data(2,COLSEL)])
        else
            data(2,COLSEL) = abs('d');
            mask(2,COLSEL) = 1;
            scrolltb('newdata',DFITTAB,data,mask);
            scrolltb('refill',DFITTAB);
            dfitgui('showdata',toolhan,COLSEL)
        end
    end
elseif strcmp(message,'incsca')
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    if COLSEL ~= size(data,2)
        scrolltb('rv',DFITTAB,[1 2],[COLSEL COLSEL+1]);
        sguivar('COLSEL',COLSEL+1,toolhan);
        dfitgui('switchscale',toolhan,COLSEL+1)
    else
        scrolltb('rv',DFITTAB,[1 2],[COLSEL 1]);
        sguivar('COLSEL',1,toolhan);
        dfitgui('switchscale',toolhan,1)
    end
elseif strcmp(message,'decsca')
    [DFITTAB,COLSEL] = gguivar('DFITTAB','COLSEL',toolhan);
    [data,matrv,cnt,mask] = scrolltb('getstuff',DFITTAB);
    if COLSEL ~= 1
        scrolltb('rv',DFITTAB,[1 2],[COLSEL COLSEL-1]);
        sguivar('COLSEL',COLSEL-1,toolhan);
        dfitgui('switchscale',toolhan,COLSEL-1)
    else
        scrolltb('rv',DFITTAB,[1 2],[COLSEL size(data,2)]);
        sguivar('COLSEL',size(data,2),toolhan);
        dfitgui('switchscale',toolhan,size(data,2))
    end
elseif strcmp(message,'fullautoprefit')
    [DDATA,DSEN,MUBND,FITPLOTS,MP_D,PLT_WIN] = ...
        gguivar('DDATA','DSEN','MUBND','FITPLOTS','MP_D','PLT_WIN',toolhan);
    [NUM_D,CLPG,BLKSYN,D_CNT,DFITTAB,MESSAGE] = ...
        gguivar('NUM_D','CLPG','BLKSYN','D_CNT','DFITTAB','MESSAGE',toolhan);
    [DMAXORD,PRECSL,INUM,DISPLAY,DKSUM_HAN] = ...
        gguivar('DMAXORD','PRECSL','INUM','DISPLAY','DKSUM_HAN',toolhan);
    [REAUTOFIT,PLTCOL] = gguivar('REAUTOFIT','PLTCOL',toolhan);
    set(REAUTOFIT,'visible','off');
    PERCTOL = 1.06 - get(PRECSL,'value')*.05;
    allfigs = get(0,'children');
    if ~any(PLT_WIN==allfigs)
        dkitgui(toolhan,'createpltwin');
        FITPLOTS = gguivar('FITPLOTS',toolhan);
    else
        kids = get(PLT_WIN,'children');
        if ~any(kids==FITPLOTS(1)) | ~any(kids==FITPLOTS(2)) | ~any(kids==FITPLOTS(3))
            delete(PLT_WIN);
            dkitgui(toolhan,'createpltwin');
            FITPLOTS = gguivar('FITPLOTS',toolhan);
        end
    end
    omega = getiv(CLPG);
    npts = length(omega);
    uppermu = vunpck(sel(MUBND,1,1));
    peakmu = max(uppermu);
    lowcutoff = 0.5;    % needs to be adjustable
    lowtestval = 0.1;
    lowmu_f = find(uppermu<lowcutoff*peakmu);
    low_pts = length(lowmu_f);
    lowmu = xtracti(sel(MUBND,1,1),lowmu_f);
    highmu_f = find(uppermu>=lowcutoff*peakmu);
    high_pts = length(highmu_f);
    highmu = xtracti(sel(MUBND,1,1),highmu_f);
    blksum = cumsum([1 1;BLKSYN]);

    D_INFO = zeros(NUM_D,3);
    RAT_D = [];
    RAT_DG = [zeros(npts,NUM_D) ones(npts,1) omega;zeros(1,NUM_D) npts inf];
    [dleft,dright] = unwrapd(DDATA,BLKSYN);
    [FIXCLPL,FIXCLPR] = gguivar('FIXCLPL','FIXCLPR',toolhan);
    optscl_clpg = mmult(dleft,vrdiv(mmult(diag(FIXCLPL),CLPG,diag(FIXCLPR)),dright));
    ALLFITS = [];
    for i=1:NUM_D
        ALLFITSI = [];
        haved = 0;
        ord = 1;
        set(MESSAGE,'string',['Fitting Scaling #' int2str(i) '/' int2str(NUM_D)]);
        drawnow;
        while haved == 0
            sysd = fitsys(sel(MP_D,1,i),ord,sel(DSEN,1,i),1);
    	    [mattype,rowdd,coldd,nxdd] = minfo(sysd);
    	    if strcmp(mattype,'syst')
              if any(real(spoles(sysd))>=0) | any(real(spoles(minv(sysd)))>=0)
                sysd = extsmp(sysd);
                if isempty(sysd)
                    save muerrfil
                    disp('DFIT has failed, ErrorFile named MUERRFIL has been saved');
                    disp('     Contact The Mathworks for mu-Tools support');
                    error('Fatal error in DKIT(dfitgui)');
                    return
                end
              end
	    end
            ALLFITSI = ipii(ALLFITSI,sysd,ord+1);
            RAT_D = ipii(RAT_D,sysd,i);
            sysdg = frsp(sysd,omega);
            RAT_DG(1:npts,i) = sysdg(1:npts,1);
            inputs = [blksum(i,1):blksum(i+1,1)-1]';
            outputs = [blksum(i,2):blksum(i+1,2)-1]';
            dratodf = vrdiv(vabs(sysdg),sel(DDATA,1,i));
            scl_clpg = sclin(sclout(optscl_clpg,outputs,dratodf),inputs,minv(dratodf));
            nscl_clpg = vnorm(scl_clpg);
            if ~isempty(lowmu_f)
                low_nscl = xtracti(nscl_clpg,lowmu_f);
                lowtest = msub(low_nscl,lowmu,lowtestval*peakmu);
            else
                lowtest = -1;
            end
            high_nscl = xtracti(nscl_clpg,highmu_f);
            hightest = msub(high_nscl,mscl(highmu,PERCTOL));
            if ( all(vunpck(lowtest)<0) & all(vunpck(hightest)<0) ) | ord == DMAXORD
                haved = 1;
            else
                ord = ord+1;
            end
        end
    if i<NUM_D
        set(MESSAGE,'string',['Fitting Scaling #' int2str(i+1) '/' int2str(NUM_D)]);
        drawnow;
    end
        ALLFITS = ipii(ALLFITS,ALLFITSI,i);
        D_INFO(i,[1 3]) = [2 ord]; % 3rd column has order
    end
    mask = [zeros(1,NUM_D);abs(D_INFO(:,1)-2)'];
    mask = zeros(2,NUM_D);
    data = [1:NUM_D;D_INFO(:,3)'];

    scrolltb('setrv',DFITTAB,zeros(2,NUM_D));
    scrolltb('newdata',DFITTAB,data,mask);
    scrolltb('rv',DFITTAB,[1 2],1);
    scrolltb('refill',DFITTAB);
    sguivar('COLSEL',1,toolhan);
    set(gguivar('UPDOWN',toolhan),'visible','on');

    sguivar('RAT_D',RAT_D,'D_INFO',D_INFO,toolhan);
    CRNTSCL = vabs(RAT_DG);
    [dleft,dright] = unwrapd(CRNTSCL,BLKSYN);
    DSENCRNT = DSEN;
    [FIXCLPL,FIXCLPR] = gguivar('FIXCLPL','FIXCLPR',toolhan);
    SCL_CLPG = mmult(dleft,vrdiv(mmult(diag(FIXCLPL),CLPG,diag(FIXCLPR)),dright));
%       HEREXXX
    sguivar('RAT_DG',RAT_DG,'CRNTSCL',CRNTSCL,'DSENCRNT',DSENCRNT,...
        'SCL_CLPG',SCL_CLPG,toolhan);

    thefits = find(D_INFO(:,1)==2);
    theblks = abs(BLKSYN(thefits,:));
    theords = D_INFO(thefits,3);
    thezeros = find(theblks(:,2)==0);
    if ~isempty(thezeros)
        theblks(thezeros,2) = theblks(thezeros,1);
    end
    totord = sum(theblks')*theords;
    axes(FITPLOTS(1))
    % plot data from GENPHASE.  not quite same as DDATA
    rf_hand = vplot('liv,lm',sel(MP_D,1,D_CNT),...
        deblank(PLTCOL(2,:)),sel(RAT_DG,1,D_CNT),deblank(PLTCOL(3,:)),'gui');
    title(['Scaling #' int2str(D_CNT) ': Magnitude Data and Rational Fit'])
    NSCL_CLPG = vnorm(SCL_CLPG);
    SCLPEAK = pkvnorm(NSCL_CLPG);
    axes(FITPLOTS(2))
    vplot('liv,m',sel(MUBND,1,1),deblank(PLTCOL(2,:)),NSCL_CLPG,deblank(PLTCOL(3,:)),'gui')
    title('Mu Upper Bound and Current Scaled Bound')
    axes(FITPLOTS(3))
    vplot('liv,lm',sel(DSENCRNT,1,D_CNT),deblank(PLTCOL(2,:)),'gui');
    xlabel('Frequency, rads/sec')
    title('Sensitivity')
    scrolltb('visible',DFITTAB,'on');
    set(gguivar('PLT_WIN',toolhan),'visible','on');
    dk_able([1 2 3 4 5],[3 1 1 1 1],toolhan);
 elseif strcmp(message,'showdata')
    D_CNT = in1;
    [MESSAGE,INUM,DKSUM_HAN,DISPLAY,PLTCOL] = ...
        gguivar('MESSAGE','INUM','DKSUM_HAN','DISPLAY','PLTCOL',toolhan);
    set(MESSAGE,'string','Getting Optimal Magnitude Data...');
    drawnow
    [D_INFO,BLKSYN,DDATA,CRNTSCL,PLT_WIN] = ...
            gguivar('D_INFO','BLKSYN','DDATA','CRNTSCL','PLT_WIN',toolhan);
    [SCL_CLPG,FITPLOTS,MUBND,FITSUM_HAN,NUM_D] = ...
            gguivar('SCL_CLPG','FITPLOTS','MUBND','FITSUM_HAN','NUM_D',toolhan);
    D_INFO(D_CNT,1) = 1;
    sguivar('D_INFO',D_INFO,'D_CNT',D_CNT,toolhan);
    omega = getiv(SCL_CLPG);
    allfigs = get(0,'children');
    if ~any(PLT_WIN==allfigs)
        dkitgui(toolhan,'createpltwin');
        FITPLOTS = gguivar('FITPLOTS',toolhan);
    else
        kids = get(PLT_WIN,'children');
        if ~any(kids==FITPLOTS(1)) | ~any(kids==FITPLOTS(2)) | ~any(kids==FITPLOTS(3))
            delete(PLT_WIN);
            dkitgui(toolhan,'createpltwin');
            FITPLOTS = gguivar('FITPLOTS',toolhan);
        end
    end


        blksum = cumsum([1 1;BLKSYN]);
        inputs = [blksum(D_CNT,1):blksum(D_CNT+1,1)-1]';
        outputs = [blksum(D_CNT,2):blksum(D_CNT+1,2)-1]';
        dratodf = vrdiv(sel(DDATA,1,D_CNT),sel(CRNTSCL,1,D_CNT));
        SCL_CLPG = sclin(sclout(SCL_CLPG,outputs,dratodf),...
            inputs,minv(dratodf));
        axes(FITPLOTS(1))
        rf_hand = vplot('liv,lm',sel(DDATA,1,D_CNT),deblank(PLTCOL(2,:)),'gui');
        if D_INFO(D_CNT,3) < 0
            title(['Scaling #' int2str(D_CNT) ': Optimal Magnitude Data'])
        else
            title(['Scaling #' int2str(D_CNT) ': Optimal Magnitude Data (Fit exists)'])
        end
        if all(D_INFO(:,1)==1)
            axes(FITPLOTS(2))
            vplot('liv,m',sel(MUBND,1,1),deblank(PLTCOL(2,:)),'gui')
            xlabel('Frequency, rads/sec')
            title('Mu Upper Bound')
        else
            NSCL_CLPG = vnorm(SCL_CLPG);
            SCLPEAK = pkvnorm(NSCL_CLPG);
            axes(FITPLOTS(2))
            vplot('liv,m',sel(MUBND,1,1),deblank(PLTCOL(2,:)),NSCL_CLPG,...
                deblank(PLTCOL(3,:)),'gui')
            xlabel('Frequency, rads/sec')
            title('Mu Upper Bound and Current Scaled Bound')
        end
        CRNTSCL(1:length(omega),D_CNT) = DDATA(1:length(omega),D_CNT);
        sguivar('SCL_CLPG',SCL_CLPG,'NSCL_CLPG',NSCL_CLPG,'CRNTSCL',CRNTSCL,toolhan)
        set(MESSAGE,'string','');

        thefits = find(D_INFO(:,1)==2);
        theblks = abs(BLKSYN(thefits,:));
        theords = D_INFO(thefits,3);
        thezeros = find(theblks(:,2)==0);
        if ~isempty(thezeros)
            theblks(thezeros,2) = theblks(thezeros,1);
        end
        totord = sum(theblks')*theords;
        dk_able(1,1,toolhan)
 elseif strcmp(message,'switchscale')
    D_CNT = in1;
    [MESSAGE,NUM_D,D_INFO,FITPLOTS,DSENCRNT,PLTCOL] = ...
        gguivar('MESSAGE','NUM_D','D_INFO','FITPLOTS','DSENCRNT','PLTCOL',toolhan);
    [DDATA,RAT_DG,CRNTSCL,MP_D,PLT_WIN] = ...
        gguivar('DDATA','RAT_DG','CRNTSCL','MP_D','PLT_WIN',toolhan);
    allfigs = get(0,'children');
    if ~any(PLT_WIN==allfigs)
        dkitgui(toolhan,'createpltwin');
        FITPLOTS = gguivar('FITPLOTS',toolhan);
    else
        kids = get(PLT_WIN,'children');
        if ~any(kids==FITPLOTS(1)) | ~any(kids==FITPLOTS(2)) | ~any(kids==FITPLOTS(3))
            delete(PLT_WIN);
            dkitgui(toolhan,'createpltwin');
            FITPLOTS = gguivar('FITPLOTS',toolhan);
        end
    end
    set(MESSAGE,'string',['Switching to ' mkth(D_CNT) ' scaling...']);
    drawnow
    sguivar('D_CNT',D_CNT,toolhan);
    if D_INFO(D_CNT,1) == 1
        axes(FITPLOTS(1))
        if D_INFO(D_CNT,3) < 0
                vplot('liv,lm',sel(DDATA,1,D_CNT),deblank(PLTCOL(2,:)),'gui');
                title(['Scaling #' int2str(D_CNT) ': Optimal Magnitude Data'])
        else
                vplot('liv,lm',sel(DDATA,1,D_CNT),deblank(PLTCOL(2,:)),'gui');
                title(['Scaling #' int2str(D_CNT) ': Optimal Magnitude Data (Fit exists)'])
        end
    else
            axes(FITPLOTS(1))
            vplot('liv,lm',sel(MP_D,1,D_CNT),deblank(PLTCOL(2,:)),...
                sel(CRNTSCL,1,D_CNT),deblank(PLTCOL(3,:)),'gui');
            title(['Scaling #' int2str(D_CNT) ': Magnitude Data and Rational Fit'])
    end
    axes(FITPLOTS(3))
    vplot('liv,lm',sel(DSENCRNT,1,D_CNT),deblank(PLTCOL(2,:)),'gui');
    title('Sensitivity')
    set(MESSAGE,'string','');
    drawnow
 elseif strcmp(message,'dofit')
    allfigs = get(0,'children');
    D_CNT = in1(1);
    ord = in1(2);
    [DFITTAB,D_INFO,RAT_D,RAT_DG,CITER,DISPLAY] = ...
        gguivar('DFITTAB','D_INFO','RAT_D','RAT_DG','CITER','DISPLAY',toolhan);
    [MP_D,BLKSYN,FITPLOTS,CRNTSCL,SCL_CLPG,MUBND] = ...
        gguivar('MP_D','BLKSYN','FITPLOTS','CRNTSCL','SCL_CLPG','MUBND',toolhan);
    [DSENCRNT,DDATA,NUM_D,MESSAGE,INUM,DKSUM_HAN] = ...
        gguivar('DSENCRNT','DDATA','NUM_D','MESSAGE','INUM','DKSUM_HAN',toolhan);
    [PLT_WIN,PLTCOL] = gguivar('PLT_WIN','PLTCOL',toolhan);
    if ~any(PLT_WIN==allfigs)
        dkitgui(toolhan,'createpltwin');
        FITPLOTS = gguivar('FITPLOTS',toolhan);
    else
        kids = get(PLT_WIN,'children');
        if ~any(kids==FITPLOTS(1)) | ~any(kids==FITPLOTS(2)) | ~any(kids==FITPLOTS(3))
            delete(PLT_WIN);
            dkitgui(toolhan,'createpltwin');
            FITPLOTS = gguivar('FITPLOTS',toolhan);
        end
    end
    omega = getiv(SCL_CLPG);
    set(MESSAGE,'string',['Fitting with ' mkth(ord) ' order...']);
    drawnow
    D_INFO(D_CNT,[1 3]) = [2 ord];
    sysd = fitsys(sel(MP_D,1,D_CNT),ord,sel(DSENCRNT,1,D_CNT),1);
    [mattype,rowdd,coldd,nxdd] = minfo(sysd);
    if strcmp(mattype,'syst')
      if any(real(spoles(sysd))>=0) | any(real(spoles(minv(sysd)))>=0)
        sysd = extsmp(sysd);
        if isempty(sysd)
            save muerrfil
            disp('DFIT has failed, error file named MUERRFIL has been saved');
            disp('      Contact The Mathworks for mu-Tools support');
            error('Fatal error in DKIT(dfitgui)');
            return
        end
      end
    end
    RAT_D = ipii(RAT_D,sysd,D_CNT);
    sysdg = frsp(sysd,omega);
    RAT_DG(1:length(omega),D_CNT) = abs(sysdg(1:length(omega),1));
    axes(FITPLOTS(1))
    rf_hand = vplot('liv,lm',sel(MP_D,1,D_CNT),deblank(PLTCOL(2,:)),...
        sysdg,deblank(PLTCOL(3,:)),'gui');
    title(['Scaling #' int2str(D_CNT) ': Magnitude Data and Rational Fit'])
    blksum = cumsum([1 1;BLKSYN]);
    inputs = [blksum(D_CNT,1):blksum(D_CNT+1,1)-1]';
    outputs = [blksum(D_CNT,2):blksum(D_CNT+1,2)-1]';
    dratodf = vrdiv(vabs(sysdg),sel(CRNTSCL,1,D_CNT));
    SCL_CLPG = sclin(sclout(SCL_CLPG,outputs,dratodf),...
            inputs,minv(dratodf));
    NSCL_CLPG = vnorm(SCL_CLPG);
    SCLPEAK = pkvnorm(NSCL_CLPG);
    axes(FITPLOTS(2))
    vplot('liv,m',sel(MUBND,1,1),deblank(PLTCOL(2,:)),...
        NSCL_CLPG,deblank(PLTCOL(3,:)),'gui')
    title('Mu Upper Bound and Current Scaled Bound')
    CRNTSCL(1:length(omega),D_CNT) = abs(sysdg(1:length(omega),1));
    sguivar('D_INFO',D_INFO,'RAT_D',RAT_D,'RAT_DG',RAT_DG,'SCL_CLPG',SCL_CLPG,...
            'NSCL_CLPG',NSCL_CLPG,'CRNTSCL',CRNTSCL,toolhan);
    sguivar('SCLPEAK',SCLPEAK,'D_CNT',D_CNT,toolhan);
    set(MESSAGE,'string',['Results in Fitting window']);
    drawnow
    thefits = find(D_INFO(:,1)==2);
    theblks = abs(BLKSYN(thefits,:));
    theords = D_INFO(thefits,3);
    thezeros = find(theblks(:,2)==0);
    if ~isempty(thezeros)
            theblks(thezeros,2) = theblks(thezeros,1);
    end
    totord = sum(theblks')*theords;
    if all(D_INFO(:,1)==2)
        if CITER > 0 & CITER < 5
            dk_able(1,2,toolhan);
        else
            dk_able(1,3,toolhan);
        end
    else
        dk_able(1,1,toolhan);
    end
 end
