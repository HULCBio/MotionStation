% function out = dkitgui(toolhan,in,in2,in3,in4,in5,in6,in7);

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.13.2.3 $

function out = dkitgui(toolhan,in,in2,in3,in4,in5,in6,in7);

 % Initialize this here to remove warnings.  GJW 09/10/96
 exportvar=[];

 if nargin == 0
   in = 'create';
   in2 = '';
   nin = 3;
 elseif isempty(toolhan)
    if ~isempty(get(0,'children'))
            toolhan = gcf;
    end
    nin = nargin;
    thstr = int2str(toolhan);
 else
    nin = nargin;
    thstr = int2str(toolhan);
 end


if strcmp(in,'hinfsyn')
    set(get(0,'children'),'pointer','watch');
    dk_able([1],[1],toolhan);
    % dkitgui(toolhan,'disableblked');dkitgui(toolhan,'disableyued')
    % dkitgui(toolhan,'disableeded')
    [BLK_HAN,BLKTABLE,YUEDIT,EDEDIT,INUM,EXTRALOAD] = ...
        gguivar('BLK_HAN','BLKTABLE','YUEDIT','EDEDIT','INUM','EXTRALOAD',toolhan);
    tabed(BLKTABLE,'disablecol',[1 2]);
    bd = get(BLK_HAN,'userdata');
    set(bd(1),'enable','off');
    set(YUEDIT,'enable','off');
    set(EDEDIT,'enable','off');
    [GLOW,GHIGH,GTOL,HD,PARMWIN_HANS,HPN] = ...
        gguivar('GLOW','GHIGH','GTOL','HDEFAULTS','PARMWIN_HANS','HINFPARMNAME',toolhan);
    dataent('setbdisable',EXTRALOAD,[1;2;3]);
    if INUM > 1
        [NUM_D,RAT_D,BLKSYN,NBLK,NMEAS,NCNTRL] = ...
            gguivar('NUM_D','RAT_D','BLKSYN','NBLK','NMEAS','NCNTRL',toolhan);
        MESSAGE = gguivar('MESSAGE',toolhan);
        set(MESSAGE,'string',['Forming scaling matrices...']);
        drawnow
        dsysl = []; dsysr = []; nextprevd = [];
        for i=1:NUM_D
            scalard = xpii(RAT_D,i);
            tmpd = [];
            for j=1:min([BLKSYN(i,1) BLKSYN(i,2)])
                tmpd = daug(tmpd,scalard);
            end
            if BLKSYN(i,1) < BLKSYN(i,2)
                tmpr = tmpd;
                for j=1:(BLKSYN(i,2)-BLKSYN(i,1))
                    tmpd = daug(tmpd,scalard);
                end
                tmpl = tmpd;
            elseif BLKSYN(i,2) < BLKSYN(i,1)
                tmpl = tmpd;
                for j=1:(BLKSYN(i,1)-BLKSYN(i,2))
                    tmpd = daug(tmpd,scalard);
                end
                tmpr = tmpd;
            else
                tmpl = tmpd;
                tmpr = tmpd;
            end
            dsysl = daug(dsysl,tmpl);
            dsysr = daug(dsysr,tmpr);
        end
        DSYSL = daug(dsysl,eye(BLKSYN(NBLK,2))); % NMEAS
        DSYSR = daug(dsysr,eye(BLKSYN(NBLK,1))); % NCNTRL
        [GAMPREDICT,OLIC,CONT,INUM,DISPLAY] = ...
            gguivar('GAMPREDICT','OLIC','CONT','INUM','DISPLAY',toolhan);
        [FIXCLPL,FIXCLPR] = gguivar('FIXCLPL','FIXCLPR',toolhan);
        hinfsyn_tit_f = get(PARMWIN_HANS(1,1),'userdata');
        alltxhans = get(hinfsyn_tit_f(1),'userdata');
        hstr = get(alltxhans(2,1),'string');
        if isempty(deblank(hstr))
            GAMPREDICT = 1;
            if GAMPREDICT == 1
                aa = hinfnorm(mmult(diag(FIXCLPL),...
                    starp(mmult(daug(DSYSL,eye(NMEAS)),...
                    OLIC,daug(minv(DSYSR),eye(NCNTRL))),...
                    CONT),diag(FIXCLPR)));
                ghigh = 1.01*aa(1);
                if isinf(ghigh)
                    ghigh = 100;
                end
            elseif GAMPREDICT == 2
                [SCLPEAK] = gguivar('SCLPEAK',toolhan);
                ghigh = 1.2*SCLPEAK;
            end
            set(alltxhans(2,2),'string',[deblank(HPN(2,:)) ' (' agv2str(ghigh) ')']);
            HD(GHIGH,2) = ghigh;
        end
        hstr = get(alltxhans(3,1),'string');
        if isempty(deblank(hstr))
            gtol = 0.01*(HD(GHIGH,2)-HD(GLOW,2));
            set(alltxhans(3,2),'string',[deblank(HPN(3,:)) ' (' agv2str(gtol) ')']);
            HD(GTOL,2) = gtol;
        end
        DISPLAY(2,INUM) = xnum(DSYSL) + xnum(DSYSR);
        set(MESSAGE,'string',['Absorbing Scalings...']);
        drawnow
        [DKSUM_HAN,EXPORTVALUE,SUFFIXNAME] = ...
            gguivar('DKSUM_HAN','EXPORTVALUE','SUFFIXNAME',toolhan);
        scrolltb('newdata',DKSUM_HAN,DISPLAY);
        scrolltb('refill',DKSUM_HAN);
        ABSORBED = 0;
        sguivar('ABSORBED',ABSORBED,'DSYSL',DSYSL,...
            'DSYSR',DSYSR,'DISPLAY',DISPLAY,'CITER',0,toolhan);
        set(MESSAGE,'string','');
        drawnow
        exportvar = [];
        if EXPORTVALUE(4) == 1
            [DSYSL,DSYSR] = gguivar('DSYSL','DSYSR',toolhan);
            exportvar = ipii(exportvar,2,1);
            exportvar = ipii(exportvar,'DSYSL',2);
            muname = ['dsysleft' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,muname,3);
            exportvar = ipii(exportvar,'DSYSR',4);
            muname = ['dsysright' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,muname,5);
        end
        sguivar('EXPORTVAR',exportvar,toolhan);
        drawnow;
    end
    sguivar('HDEFAULTS',HD,toolhan);

    [MESSAGE,ABSORBED,SUFFIXNAME,INUM,EXPORTVALUE,BLKSYN] = ...
        gguivar('MESSAGE','ABSORBED','SUFFIXNAME','INUM','EXPORTVALUE','BLKSYN',toolhan);
    [OLIC,NMEAS,NCNTRL,UCHOICE,YCHOICE,BLKFAC] = ...
        gguivar('OLIC','NMEAS','NCNTRL','UCHOICE','YCHOICE','BLKFAC',toolhan);
    [RESTARTHAN,SUMESSAGE,HDEFAULTS,DSYSL,DSYSR] = ...
        gguivar('RESTARTHAN','SUMESSAGE','HDEFAULTS','DSYSL','DSYSR',toolhan);
    [fixcl,fixcr,fixclpl,fixclpr,swolic,thismeas,thiscont] = ...
        yublksel(BLKSYN,OLIC,BLKFAC,NMEAS,YCHOICE,NCNTRL,UCHOICE);
%    [DSYSL,DSYSR] = gguivar('DSYSL','DSYSR',toolhan);
    SOLIC = mmult(daug(DSYSL,eye(thismeas)),swolic,daug(minv(DSYSR),eye(thiscont)));
    ABSORBED = 1;
    sguivar('SOLIC',SOLIC,'ABSORBED',ABSORBED,'FIXCLPL',fixclpl,'FIXCLPR',fixclpr,toolhan);
    [GLOW,GHIGH,GTOL,RICMTHD,EPR,EPP] = ...
        gguivar('GLOW','GHIGH','GTOL','RICMTHD','EPR','EPP',toolhan);
    glow = HDEFAULTS(GLOW,2);
    ghigh = HDEFAULTS(GHIGH,2);
    gtol = HDEFAULTS(GTOL,2);
    epr = HDEFAULTS(EPR,2);
    epp = HDEFAULTS(EPP,2);
    set(MESSAGE,'string','H_inf Synthesis: Gamma Iteration in Command Window');
    set(SUMESSAGE,'string',' '); drawnow
    dosyn = 1;
    cnt = 0;
    cntmax = 5;
    while dosyn==1 & cnt < cntmax
        [scont,SCLP,gf_dk] = hinfsyn(SOLIC,thismeas,thiscont,glow,ghigh,...
            gtol,RICMTHD,epr,epp);
        if ~isempty(gf_dk)
            dosyn = 0;
        else
            glow = ghigh;
            ghigh = 2*ghigh;
            gtol = .01*(ghigh-glow);
                set(MESSAGE,'string',...
                'Gamma Max is too low.  Increasing and Rerunning...');
            dkitgui(toolhan,'modhinfp',[GHIGH;GTOL],[ghigh;gtol]);
            drawnow
            cnt = cnt + 1;
        end
    end
    if cnt == cntmax
        sguivar('INTERUPT',1,toolhan);
        set(MESSAGE,'string','Something is terribly wrong with OLIC')
        dkitgui(toolhan,'restart');
    else
        sguivar('STARTED',1,toolhan);
        set(RESTARTHAN,'enable','on');
        CONT = mmult(fixcl,scont,fixcr);
	if isempty(exportvar)
	    exportvar_cnt1 = 0;
	    exportvar_cnt2 = 1;
	else
	    exportvar_cnt1 = 2;
	    exportvar_cnt2 = 5;
	end
        if EXPORTVALUE(1) == 1 & EXPORTVALUE(5) == 0
            exportvar = ipii(exportvar,exportvar_cnt1+1,1);
            exportvar = ipii(exportvar,'CONT',exportvar_cnt2+1);
            kname = ['K' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,kname,exportvar_cnt2+2);
        elseif  EXPORTVALUE(1) == 0 & EXPORTVALUE(5) == 1
            exportvar = ipii(exportvar,exportvar_cnt1+1,1);
            exportvar = ipii(exportvar,'OLIC',exportvar_cnt2+1);
            oname = ['olic' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,oname,exportvar_cnt2+2);
        elseif  EXPORTVALUE(1) == 1 & EXPORTVALUE(5) == 1
            exportvar = ipii(exportvar,exportvar_cnt1+2,1);
            exportvar = ipii(exportvar,'OLIC',exportvar_cnt2+1);
            oname = ['olic' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,oname,exportvar_cnt2+2);
            exportvar = ipii(exportvar,'CONT',exportvar_cnt2+3);
            kname = ['K' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,kname,exportvar_cnt2+4);
        end
        set(MESSAGE,'string','H_inf Synthesis: Results in Summary Table'); drawnow
        [DISPLAY,INUM,DKSUM_HAN] = ...
         gguivar('DISPLAY','INUM','DKSUM_HAN',toolhan);
        DISPLAY([3 4],INUM) = [xnum(CONT);gf_dk];
        scrolltb('newdata',DKSUM_HAN,DISPLAY);
        scrolltb('refill',DKSUM_HAN);
        sguivar('EXPORTVAR',exportvar,'CITER',1,'CONT',CONT,'HCONT',CONT,...
            'DISPLAY',DISPLAY,toolhan);
        dk_able([1;2;3;4;5],[1;3;1;1;1],toolhan);
        set(MESSAGE,'string',''); drawnow
    end
    set(get(0,'children'),'pointer','arrow');
 elseif strcmp(in,'formclp')
    dk_able([2],[1],toolhan);
    set(get(0,'children'),'pointer','watch');
    % dkitgui(toolhan,'disableblked');dkitgui(toolhan,'disableyued')
    % dkitgui(toolhan,'disableeded')
    [BLK_HAN,BLKTABLE,YUEDIT,EDEDIT,MESSAGE,DKSUM_HAN] = ...
        gguivar('BLK_HAN','BLKTABLE','YUEDIT','EDEDIT','MESSAGE','DKSUM_HAN',toolhan);
    tabed(BLKTABLE,'disablecol',[1 2]);
    bd = get(BLK_HAN,'userdata');
    set(bd(1),'enable','off');
    set(YUEDIT,'enable','off');
    set(EDEDIT,'enable','off');
    sguivar('STARTED',1,toolhan);
    set(MESSAGE,'string','Forming closed-loop with STARP'); drawnow
    [OLIC,CONT,NMEAS,NCNTRL,INUM,DISPLAY] = ...
        gguivar('OLIC','CONT','NMEAS','NCNTRL','INUM','DISPLAY',toolhan);
    [SUFFIXNAME,EXPORTVALUE,FIXCLPL,DSYSL,DSYSR,FIXCLPR] = ...
        gguivar('SUFFIXNAME','EXPORTVALUE','FIXCLPL','DSYSL','DSYSR','FIXCLPR',toolhan);
    CLP = starp(OLIC,CONT,NMEAS,NCNTRL);
    aa = hinfnorm(mmult(diag(FIXCLPL),DSYSL,CLP,minv(DSYSR),diag(FIXCLPR)));
    if isinf(aa(1)) | isinf(aa(2))
        set(MESSAGE,'string','CLP has RHP Poles -- Reload or Redesign K');
        sguivar('INTERUPT',1,toolhan);
        drawnow
        dk_able([1 2 3 4 5],[2 1 1 1 1],toolhan);
    else
        exportvar = [];
        if EXPORTVALUE(3) == 1
            exportvar = ipii(exportvar,1,1);
            exportvar = ipii(exportvar,'CLP',2);
            clpname = ['clp' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,clpname,3);
        end
        DISPLAY([3 4],INUM) = [xnum(CONT);aa(2)];
        sguivar('EXPORTVAR',exportvar,'CLP',CLP,'CITER',2,'DISPLAY',DISPLAY,toolhan);
        scrolltb('newdata',DKSUM_HAN,DISPLAY);
        scrolltb('refill',DKSUM_HAN);
        dk_able([2 3 4 5],[1 3 1 1],toolhan);
        set(MESSAGE,'string',''); drawnow
        set(get(0,'children'),'pointer','arrow');
     end
 elseif strcmp(in,'getomega')
    out1 = omframe(toolhan,[],'getomega',gguivar('OMEGA_HAN',toolhan));
    sguivar('OMEGASTRING',out1,toolhan);
 elseif strcmp(in,'dofrsp')
    dk_able([3],[1],toolhan);
    set(get(0,'children'),'pointer','watch');
    [BUTSTAT,MESSAGE,OMEGA,ITWIN,PLTCOL] = ...
        gguivar('BUTSTAT','MESSAGE','OMEGA','ITWIN','PLTCOL',toolhan);
    set(MESSAGE,'string','Frequency Response Counter...'); drawnow
    [CLP,BLKSYN,CITER,INUM,OLIC,K] = ...
        gguivar('CLP','BLKSYN','CITER','INUM','OLIC','CONT',toolhan);
    if ~isempty(OMEGA) & ~isstr(OMEGA) & min(size(OMEGA))==1
        [FIXCLPL,FIXCLPR] = gguivar('FIXCLPL','FIXCLPR',toolhan);
        NCLPG = frsp(CLP,OMEGA,[],[],[MESSAGE;3]);  % not rationally scaled
        [SUFFIXNAME,EXPORTVALUE] = gguivar('SUFFIXNAME','EXPORTVALUE',toolhan);
        exportvar = [];
        if EXPORTVALUE(3) == 1
            exportvar = ipii(exportvar,1,1);
            exportvar = ipii(exportvar,'NCLPG',2);
            clpname = ['clpg' int2str(INUM) SUFFIXNAME];
            exportvar = ipii(exportvar,clpname,3);
        end
        sguivar('EXPORTVAR',exportvar,'NCLPG',NCLPG,toolhan);
        if INUM > 1
            RAT_DG = gguivar('RAT_DG',toolhan);
            tmp = getiv(RAT_DG).';
            lom = length(OMEGA);
            redo = 0;
            if lom~=length(tmp)
                redo = 1;
            elseif ~all(tmp==OMEGA)
                redo = 1;
            end
            if redo==1
                [NBLK,RAT_D] = gguivar('NBLK','RAT_D',toolhan);
                % Probably need to do this for rational G too.
                RAT_DG = zeros(lom+1,NBLK+1);
                for i=1:NBLK-1
                    tmp = frsp(xpii(RAT_D,i),OMEGA);
                    RAT_DG(1:lom,i) = tmp(1:lom,1);
                end
                RAT_DG(1:lom,NBLK) = ones(lom,1);
                RAT_DG(lom+1,NBLK+1) = inf;
                RAT_DG(lom+1,NBLK) = lom;
                RAT_DG(1:lom,NBLK+1) = OMEGA.';
                sguivar('RAT_DG',RAT_DG,toolhan);
            end
            [dleft,dright] = muunwrap(RAT_DG,BLKSYN);
            dmdi = mmult(dleft,mmult(diag(FIXCLPL),NCLPG,diag(FIXCLPR)),minv(dright));
        else
            dmdi = mmult(diag(FIXCLPL),NCLPG,diag(FIXCLPR));
        end
        GGS = vnorm(dmdi);

        if gguivar('VISUAL',toolhan)
            [mainw,subw] = findmuw(get(0,'chi'));
            dksubs = xpii(subw,ITWIN);
            loc = find(dksubs(:,2)==4);     %   FR_WIN is #4
            if isempty(loc)
                dkitgui(toolhan,'createfrqwin');
                FR_WIN = gguivar('FR_WIN',toolhan);
            else
                FR_WIN = dksubs(loc,1);
            end
            figure(gguivar('FR_WIN',toolhan))
            vplot('liv,m',GGS,deblank(PLTCOL(1,:)),'gui')
            if INUM == 1
                set(gca,'fontsize',9);
                tt=get(gca,'title');
                set(tt,'string','SINGULAR VALUE PLOT: CLOSED-LOOP RESPONSE',...
                    'fontsize',9);
                xx=get(gca,'xlabel');
                set(xx,'string','Frequency  rad/s','fontsize',9);
                yy=get(gca,'ylabel');
                set(yy,'string','MAGNITUDE','fontsize',9);
                set(MESSAGE,'string','Singular Value in Plot Window'); drawnow;
            else
                set(gca,'fontsize',9);
                tt=get(gca,'title');
                set(tt,'string','SCALED SINGULAR VALUE PLOT: CLOSED-LOOP RESPONSE',...
                    'fontsize',9);
                xx=get(gca,'xlabel');
                set(xx,'string','Frequency  rad/s','fontsize',9);
                yy=get(gca,'ylabel');
                set(yy,'string','MAGNITUDE','fontsize',9);
                set(MESSAGE,'string','Scaled Singular Value in Plot Window'); drawnow;
            end
        end
        sguivar('CITER',3,'GGS',GGS,toolhan);
        dk_able([3 4 5],[1 3 1],toolhan);
    else
        set(MESSAGE,'string','Error in OMEGA definition.  Correct now.');
        drawnow;
        dk_able([1 2 3 4 5],[1 1 2 1 1],toolhan);
    end
    set(get(0,'children'),'pointer','arrow');
 elseif strcmp(in,'mucompute')
    dk_able([4],[1],toolhan);
    set(get(0,'children'),'pointer','watch');
    [MESSAGE,UNCBLK,NDIST,NERROR,UNCBLKFAC,ITWIN] = ...
        gguivar('MESSAGE','UNCBLK','NDIST','NERROR','UNCBLKFAC','ITWIN',toolhan);
    MUBLKSYN = [UNCBLK;[NDIST NERROR]];
    MUBLKFAC = [UNCBLKFAC;1];
    set(MESSAGE,'string','Points Completed...'); drawnow
    [NCLPG,MUMTHD,SUFFIXNAME,EXPORTVALUE,PLTCOL] = ...
        gguivar('NCLPG','MUMTHD','SUFFIXNAME','EXPORTVALUE','PLTCOL',toolhan);
    [DISPLAY,GGS,CITER,INUM,DKSUM_HAN,FR_WIN] = ...
        gguivar('DISPLAY','GGS','CITER','INUM','DKSUM_HAN','FR_WIN',toolhan);
    [mufixclpl,mufixclpr] = yublksel(MUBLKSYN,MUBLKFAC);
    realflag = 0;
    if any(MUBLKSYN(:,1)<0) | any(MUBLKSYN(:,2)==0)
        realflag = 1;
    end
    mat = mmult(diag(mufixclpl),NCLPG,diag(mufixclpr));
    if MUMTHD == 1
        [NMUBND,NDDATA,NDSEN,PERT] = mu(mat,MUBLKSYN,'cCsg',[MESSAGE;1]);
    else
        [NMUBND,NDDATA,NDSEN,PERT] = mu(mat,MUBLKSYN,'csg',[MESSAGE;1]);
    end
    DATA_BND = sel(NMUBND,1,1);
    if gguivar('VISUAL',toolhan)
        [mainw,subw] = findmuw(get(0,'chi'));
        dksubs = xpii(subw,ITWIN);
        loc = find(dksubs(:,2)==4);     %   FR_WIN is #4
        if isempty(loc)
                dkitgui(toolhan,'createfrqwin');
                FR_WIN = gguivar('FR_WIN',toolhan);
        else
                FR_WIN = dksubs(loc,1);
        end
        figure(FR_WIN);
        vplot('liv,m',GGS,deblank(PLTCOL(1,:)),DATA_BND,deblank(PLTCOL(2,:)),'gui');
        set(gca,'fontsize',9);
        tt=get(gca,'title');
        set(tt,'string','Upper Bound for Mu (solid) & Sigma_max (dashed)',...
               'fontsize',9,'interpreter','none')
        xx=get(gca,'xlabel');
        set(xx,'string','Frequency,  rad/sec','fontsize',9);
        yy=get(gca,'ylabel');
        set(yy,'string','Mu and Max Singular Value','fontsize',9);
    end
    if realflag == 0
%               Normalize last Dscale to 1
        [ddd,ddrp,ddindv,dder] = vunpck(NDDATA);
        [ddrows,ddcols] = size(ddd);
        dddn = ddd(:,ddcols*ones(1,ddcols)).\ddd;
        NDDATA(1:ddrows,1:ddcols) = abs(dddn);  % done with normalization
        sguivar('NMUBND',NMUBND,'NDDATA',NDDATA,'NDSEN',NDSEN,'PERT',PERT,toolhan);
        PEAKMU = pkvnorm(DATA_BND);
        DISPLAY(5,INUM) = PEAKMU;
        scrolltb('newdata',DKSUM_HAN,DISPLAY);
        scrolltb('refill',DKSUM_HAN);
        if gguivar('VISUAL',toolhan)
            set(MESSAGE,'string','Results in Plot Window'); drawnow
        end
        sguivar('CITER',4,'DISPLAY',DISPLAY,toolhan);
        dk_able([4 5],[1 3],toolhan);
    else
        sguivar('CITER',3,toolhan);
        dk_able([4;5],[2;1],toolhan);
        set(MESSAGE,'string',...
            'Mu-Analysis Only - Block Structure Contains Real Blocks');
        drawnow
    end
    exportvar = [];
    if EXPORTVALUE(2) == 1
        exportvar = ipii(exportvar,4,1);
        exportvar = ipii(exportvar,'NMUBND',2);
        muname = ['mubnd' int2str(INUM) SUFFIXNAME];
        exportvar = ipii(exportvar,muname,3);
        exportvar = ipii(exportvar,'NDDATA',4);
        muname = ['ddata' int2str(INUM) SUFFIXNAME];
        exportvar = ipii(exportvar,muname,5);
        exportvar = ipii(exportvar,'NDSEN',6);
        muname = ['dsens' int2str(INUM) SUFFIXNAME];
        exportvar = ipii(exportvar,muname,7);
        exportvar = ipii(exportvar,'PERT',8);
        muname = ['pert' int2str(INUM) SUFFIXNAME];
        exportvar = ipii(exportvar,muname,9);
    end
    sguivar('EXPORTVAR',exportvar,toolhan);
    gcf;
    set(get(0,'children'),'pointer','arrow');
 elseif strcmp(in,'nextiter')
    set(get(0,'children'),'pointer','watch');
    [EXTRALOAD,MESSAGE,UNCBLK,NDIST,NERROR,UNCBLKFAC] = ...
        gguivar('EXTRALOAD','MESSAGE','UNCBLK','NDIST','NERROR','UNCBLKFAC',toolhan);
    BLKSYN = [UNCBLK;[NDIST NERROR]];
    BLKFAC = [UNCBLKFAC;1];
    [FIXCLPL,FIXCLPR] = yublksel(BLKSYN,BLKFAC);
    dkitgui(toolhan,'disableblked');
    dataent('setbdisable',EXTRALOAD,1);
    sguivar('CITER',5,'DELTAMOD',0,'BLKSYN',BLKSYN,'BLKFAC',BLKFAC,...
        'FIXCLPL',FIXCLPL,'FIXCLPR',FIXCLPR,toolhan);
    dk_able(5,1,toolhan);
    [DISPLAY,INUM,NDDATA,NUM_D,MESSAGE,DKSUM_HAN] = ...
        gguivar('DISPLAY','INUM','NDDATA','NUM_D','MESSAGE','DKSUM_HAN',toolhan);
    [ITWIN,REAUTOFIT] = gguivar('ITWIN','REAUTOFIT',toolhan);
    set(REAUTOFIT,'visible','off')
    if INUM == 1;
        omega = getiv(NDDATA);
        sguivar('PREVRAT_DG',vpck(ones(length(omega),NUM_D),omega),toolhan);
        PREVRAT_D = [];
        for i=1:NUM_D
            PREVRAT_D = ipii(PREVRAT_D,1,i);
        end
        sguivar('PREVRAT_D',PREVRAT_D,toolhan);
    else
        [RAT_D,RAT_DG] = gguivar('RAT_D','RAT_DG',toolhan);
        sguivar('PREVRAT_D',RAT_D,'PREVRAT_DG',RAT_DG,toolhan);
    end
    DISPLAY = [DISPLAY inf*ones(5,1)];
    INUM = INUM + 1;
    cnt = scrolltb('getcnt',DKSUM_HAN);
    scrolltb('setrv',DKSUM_HAN,zeros(5,INUM+3));
    DISPLAY(1,INUM) = INUM;
    sguivar('DISPLAY',DISPLAY,'INUM',INUM,toolhan);
    scrolltb('newdata',DKSUM_HAN,DISPLAY);
    if INUM-3>cnt
        scrolltb('setcnt',DKSUM_HAN,INUM-3);
    end
    scrolltb('refill',DKSUM_HAN);
    [NMUBND,NDDATA,NDSEN,NCLPG] = gguivar('NMUBND','NDDATA','NDSEN','NCLPG',toolhan);
    sguivar('MUBND',NMUBND,'DDATA',NDDATA,'DSEN',NDSEN,'CLPG',NCLPG,toolhan);
    dk_able([1 2 3 4 5],[1 1 1 1 1],toolhan);
    set(MESSAGE,'string','Fitting Scalings...');
    drawnow
    [NUM_D,DDATA,INUM,CITER,MESSAGE,FIT_OPT] = ...
        gguivar('NUM_D','DDATA','INUM','CITER','MESSAGE','FIT_OPT',toolhan);
    [EXPORTVALUE,DKSUM_HAN,DFITTAB,COORDS] = ...
        gguivar('EXPORTVALUE','DKSUM_HAN','DFITTAB','COORDS',toolhan);
    winunits = get(ITWIN,'units');
    if ~strcmp('pixels',winunits)
        set(ITWIN,'units','pixels')
    end
    winpos = get(ITWIN,'position');
    c1 = COORDS(1)*winpos(3);
    c2 = COORDS(2)*winpos(4);
    c3 = COORDS(3)*winpos(3);
        MP_D = [];
        for i=1:NUM_D
            MP_D = sbs(MP_D,genphase(sel(DDATA,1,i)));
            set(MESSAGE,'string',['Converting Data: ' int2str(i) '/' int2str(NUM_D)]);
            drawnow
        end
        if INUM == 2
            set(MESSAGE,'string','Preparing Fitting Window...');
            drawnow;
            dk_able(1,1,toolhan);
            tabxywh = dfitgui('dimquery',[],min([4 NUM_D]),NUM_D,ITWIN,...
                [c1+30 c2],winpos);
            DFITTAB = dfitgui('create',[],min([4 NUM_D]),NUM_D,ITWIN,...
                [c3-tabxywh(3) c2],winpos);
            sguivar('DFITTAB',DFITTAB,toolhan);
        elseif size(scrolltb('getdata',DFITTAB),2) ~= NUM_D
            dk_able(1,1,toolhan);
            dfitgui('delete',toolhan);
            tabxywh = dfitgui('dimquery',[],min([4 NUM_D]),NUM_D,ITWIN,...
                [c1+30 c2],winpos);
            DFITTAB = dfitgui('create',toolhan,min([4 NUM_D]),NUM_D,ITWIN,...
                [c3-tabxywh(3) c2],winpos);
            sguivar('DFITTAB',DFITTAB,toolhan);
        end
        sguivar('MP_D',MP_D,'D_CNT',1,toolhan);
        if FIT_OPT == 1
            dfitgui('fullautoprefit',toolhan);
        end
    set(MESSAGE,'string',''); drawnow;
    set(get(0,'children'),'pointer','arrow');
elseif strcmp(in,'create')
    if nargin == 1 | nargin == 2
        in2 = '';
    end
    wsuff = in2;
    TOOLTYPE = 'dkit';
%   Declare all GUI-Vars
    mudeclar;
    mudeclar('DFITTAB','UPDOWN','COLSEL','DKSUM_HAN','MESSAGE','MESS_PARM','BGC',...
        'FGC','MAINPB','PBSTRS','OLIC_OIS','OLIC_NAME')
    mudeclar('DELTAMOD','NBLK','BLKSYN','BLKFAC','NUNCBLK','UNCBLK','UNCBLKFAC',...
        'NMEAS','NCNTRL','NDIST','NERROR','BINLOC','COORDS')
    mudeclar('OLIC')
    mudeclar('SOLIC')
    mudeclar('DSYSL')
    mudeclar('DSYSR','MIXED');
    mudeclar('CONT')
    mudeclar('HCONT')
    mudeclar('READY','ISREADY','FIT_OPT','OMEGA_HAN','OMEGA','OMEGASTRING',...
        'BLK_HAN','MUBND','RUNNING')
    mudeclar('DDATA')
    mudeclar('DSEN')
    mudeclar('PERT')
    mudeclar('CLP')
    mudeclar('GLOW','GHIGH','GTOL','GPERCTOL','OLOW','OHIGH','OPTS','EPP',...
        'RICMTHD','MUMTHD','MUNOTLOW','EPR','RAMSV','DISKSV');
    mudeclar('INUM','STARTED','CITER','SUFFIXNAME','WINDOWNAME','WINDOWPRE',...
        'CRNT_DG','REC_D','REC_DG','MP_D')
    mudeclar('SCL_CLPG')
    mudeclar('NSCL_CLPG')
    mudeclar('I_NBLK','NUM_D','D_INFO','ORD_CNT','D_CNT','V_CNT','VIEWNUM',...
        'GUI_VIEWER','ADDHANDLES','PLT_WIN','NAME_WIN','TOGHANDLES','TOGG_STAT',...
        'GUI_H','VISUAL')
    mudeclar('F_VIEWON_C','F_VIEWOFF_C','F_VIEW_FDP_C','F_OPT_ON','F_OPT_OFF',...
        'F_PLOT_C1','F_PLOT_C2','PLTCOL')
    mudeclar('OPT_HAN','BUTSTAT','DATA_D','ET_BGC','TMP','AXESHAN')
    mudeclar('EDITHANDLES','EDITRESULTS','RESTOOLHAN','ERRORCB','SUCCESSCB','MINFOTAB')
    mudeclar('NXPREV_D','NXPREV_DG','ABSORBED','LEN','DISPLAY','SUMTIT','RNBLK',...
        'FR_WIN','SETUPWIN','PARMWIN','PARMWIN_HANS','HINFPARMNAME','HDEFAULTS')
    mudeclar('hhn','CLPG','GGS','ITWIN','PREV_DG','SCLDMDG','SCLGIG','PEAKMU','SCLPEAK',...
        'FITPLOTS','RELOAD_PB','OLICCONTLOAD','SUMESSAGE')
    mudeclar('ULHAN','ULINKNAMES','TLINKNAMES','DDATACRNT','CRNTSCL',...
        'DSENCRNT','RAT_D','RAT_DG','GAMPREDICT','RESTARTHAN')
    mudeclar('YUEDIT','EDEDIT','NAUTOIT','AUTORK','AUTORP','STEPS',...
        'INTERUPT','AISTOPBUT','AIMS','MULTISTEP','AMENUHANS')
    mudeclar('NCLPG')
    mudeclar('NMUBND')
    mudeclar('NDDATA')
    mudeclar('NDSEN')
    mudeclar('DEFRAME','YUFRAME','EXTRALOAD','PRECSL','REAUTOFIT','EDDIM','YUDIM',...
                'ORIGWINPOS')
    mudeclar('PREVRAT_D','PREVRAT_DG','EXPORTVAR','EXPORTNAME','EXPORTVALUE','DMAXORD',...
        'PERCTOL','YCHOICE','UCHOICE','YCHOICE_STR','UCHOICE_STR')
    mudeclar('YCHOOSE','UCHOOSE','BLKTABLE','MAIN_BLKF','FIXCLPL','FIXCLPR','OGLINK',...
        'MFILENAME','TOOLTYPE','SHOWSETUPHAN','UDNAME','SETUPFLAG','CBLOG')
    [VARNAMES,PIMNUMBER] = mudeclar('mkvar');

    WINDOWSNAME = wsuff;
    ss = get(0,'Screensize');

    dgkwin_w = 520;         % Window Width
    dgkwin_h = 400;         % Window Height
    dgkwin_c = [192 192 192]/255; % Window Color
    dgkwin_xy = [20 ss(4)-470];   % Window XY Corner
    winpos = [dgkwin_xy dgkwin_w dgkwin_h];

    ITWIN = figure('visible','off',...
        'menubar','none',...
        'NumberTitle','off',...
        'Color',dgkwin_c,...
        'pointer','watch',...
        'Position',winpos,...
        'DoubleBuffer','on', ...
        'DockControls', 'off');

    thstr = int2str(ITWIN);
    toolhan = ITWIN;
    WINDOWPRE = ['muTools(' int2str(ITWIN) '): '];
    if ~isempty(wsuff)
        wsuff = [' - ' wsuff];
    end
    set(ITWIN,'Name',[WINDOWPRE 'DK Iteration' wsuff]);

    [a1,a2,a3,a4] = findmuw(get(0,'chi'));
    if ~isempty(a1)
        runkeeper = min(a1);
        if ITWIN<runkeeper
            RUNNING = gguivar('RUNNING',runkeeper);
        else
            RUNNING = [];
        end
    else
        RUNNING = [];
    end

    hardware = computer;
    if strcmp(hardware,'PCWIN')
        ET_BGC = [1 1 1];
        lvfs = 9;
    elseif strcmp(hardware,'MAC')
        ET_BGC = [1 1 1];
        lvfs = 10;
    else
        ET_BGC = [1 1 1];
        lvfs = 10;
    end

    ALLCONTROLS = zeros(500,1);
    NUMCONTROLS = 0;

    READY = 0; LEN = 5;
    GAMPREDICT = 1;
    BGC = [0.14 0.14 0.14; 0.35 0.35 0.35; 0.55 0.55 0.55];
    FGC = [0.34 0.34 0.34; 0.64 0.64 0.64; 1 0.9 0.9];
    EPP = 6; RICMTHD = 2; EPR = 5;
    EPP = 5; RICMTHD = 2; EPR = 4;
    RAMSV = 3; DISKSV = 3;
    vechandles = zeros(500,1);
    handlecnt = 1;

    NORMAX = mkdragtx('create',ITWIN);
    set(NORMAX,'xlim',[0 1],'ylim',[0 1]);

%   MENUS
    tmp = uimenu(ITWIN,'Label','File');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ttttmp = uimenu(tmp,'Label','Quit','enable','on',...
        'callback',['dkitgui(' thstr ',''quit'')']);
    vechandles(handlecnt) = [ttttmp];
    handlecnt = handlecnt + 1;
    tmp = uimenu(ITWIN,'Label','Iteration');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    ASMENUHAN = uimenu(tmp,'Label','Auto Steps','enable','off','Separator','on');
    ttmp = ASMENUHAN;

    % grandfathered ('interruptible','yes') changed to 'on'   GJW 09/06/96
    nttmp = uimenu(ttmp,'Label','Next 2 Steps','enable','off',...
        'callback',['sguivar(''STEPS'',2,' thstr ');oniter;'],'interruptible','on');
    nthtmp = uimenu(ttmp,'Label','Next 3 Steps','enable','off',...
        'callback',['sguivar(''STEPS'',3,' thstr ');oniter;'],'interruptible','on');
    nftmp = uimenu(ttmp,'Label','Next 4 Steps','enable','off',...
        'callback',['sguivar(''STEPS'',4,' thstr ');oniter;'],'interruptible','on');

    MULTISTEP = [nttmp;nthtmp;nftmp];
    vechandles(handlecnt:handlecnt+2) = MULTISTEP;
    handlecnt = handlecnt+3;
    ttmp = uimenu(tmp,'Label','Auto Iterate','enable','off','Separator','on');
    AIMENUHAN = ttmp;
    AMENUHANS = [AIMENUHAN;ASMENUHAN];
    pais = 1:8; % possible autoiters
    for i=1:length(pais)
        tttmp = uimenu(ttmp,'Label',int2str(pais(i)),'enable','on',...
            'callback',['sguivar(''STEPS'',inf,''NAUTOIT'',' int2str(pais(i)) ',' thstr ');oniter'],...
            'interruptible','on');
        vechandles(handlecnt) = tttmp;
        handlecnt = handlecnt+1;
    end
    vechandles(handlecnt) = [ttmp];
    handlecnt = handlecnt + 1;

    tttmp = uimenu(tmp,'Label','Restart','enable','off',...
        'separator','on','callback',['dkitgui(' thstr ',''restart'');']);
      vechandles(handlecnt) = [tttmp];
      handlecnt = handlecnt + 1;
    RESTARTHAN = tttmp;

    otmp = uimenu(ITWIN,'Label','Options');
    vechandles(handlecnt) = otmp;
    handlecnt = handlecnt + 1;

    AUTORK = uimenu(otmp,'Label','Auto_Refresh K',...
        'enable','on',...
        'separator','on',...
        'callback',['dkitgui(' thstr ',''autorefk'')'],...
        'checked','off');
    AUTORP = uimenu(otmp,'Label','Auto_Refresh Olic',...
        'enable','on',...
        'separator','on',...
        'callback',['dkitgui(' thstr ',''autorefp'')'],...
        'checked','off');
    TABFONT = uimenu(otmp,'label','Font','separator','on');
    fs = [8 9 10 11 12];
    for i=1:length(fs)
        uimenu(TABFONT,'label',int2str(fs(i)),'callback',...
            ['scrtxtn(''changefont'',gguivar(''AXESHAN'',' thstr '),' int2str(fs(i)) ');']);
    end

    tmp = uimenu(ITWIN,'Label','Window');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    tmp1 = uimenu(tmp,'Label','Hide Iteration','callback',['dkitgui(' thstr ',''hideiter'')']);
    tmp2 = uimenu(tmp,'Label','Setup','callback',['dkitgui(' thstr ',''showsetup'')'],...
        'separator','on','enable','off');
    SHOWSETUPHAN = tmp2;
    tmp3 = uimenu(tmp,'Label','Mu/SVD Plot','callback',['dkitgui(' thstr ',''showplot'')']);
    tmp4 = uimenu(tmp,'Label','Scalings','callback',['dkitgui(' thstr ',''showscl'')']);
    tmp5 = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);
    vechandles(handlecnt:handlecnt+4) = [tmp1;tmp2;tmp3;tmp4;tmp5];
    handlecnt = handlecnt + 5;
%       END MENUS

%   some dimensions
    xbo = 15;
    ybo = 8;
    vgap = 10;
    rightx = winpos(3)-xbo;
    hgap = 10;

%   Message Bar
    Mx = xbo; My = ybo; Mw = winpos(3) - 2*xbo; Mh = 20;
    MESSAGE = uicontrol(ITWIN,'style','text',...
        'horizontalalignment','left',...
        'backgroundcolor',dgkwin_c,...
        'Position',[Mx My Mw Mh]);
    set(MESSAGE,'string','Initializing DK Iteration GUI, please wait...');

%   Linkable Table
    Lx = Mx;
    Ly = My + Mh + vgap;
    Lw = 220; % 125 for 2nd col
    Lh = 70*(5/4);
    sliderw = 20;
    linktabpos = [Lx/winpos(3) Ly/winpos(4) Lw/winpos(3) Lh/winpos(4)];
    ULN = str2mat('Khinf','Kuse','UncBlk','Inum','Ydim','Udim',...
            'Edim','Ddim','IC','Clpg','Clp');
    TLN = str2mat('HCONT','CONT','BLKSYN','INUM','NMEAS','NCNTRL',...
            'NERROR','NDIST','OLIC','NCLPG','CLP');
    dl = str2mat('Khinf       ','Kuse','UncBlk','Inum','Ydim','Udim',...
            'Edim','Ddim','IC','Clpg','Clp');
    dr = str2mat('Hinf Controller   ','Implemented K','Uncertainty Structure',...
            'Iteration Number','Output Dim','Input Dim',...
            'Error Dim','Disturbance Dim','Open-Loop IC','Closed-Loop Freq','Closed-Loop');

    coltypemask = ['ds';'ss'];    %dragable/static(d/s), string/integer(p/s/i)
    colpt = [1 13;12 30];
    colpos = [.017 (Lw-115)/Lw];
    colstrings = str2mat('Constant','Empty','System','Varying');
    colalign = 'll';
    coltitles = str2mat('Tool Variables','Meaning');
    [AXESHAN,exhan] = scrtxtn('create',ITWIN,linktabpos,[0 1],[0.005 5 14],...
        coltypemask,colpos,colalign,colpt,colstrings,coltitles,lvfs);
    ndata = abs([dl dr]);
    scrtxtn('changedata',AXESHAN,ndata,(1:7)');
    scrtxtn('draw',AXESHAN);
    vechandles(handlecnt:handlecnt+length(exhan)-1) = exhan;
    handlecnt = handlecnt + length(exhan);

    % normalized
    COORDS = [(Lx+Lw+sliderw)/winpos(3) Ly/winpos(4) rightx/winpos(3)];

%   Iteration PUSHBUTTONS
    bigvgap = 38;
    fgap = 4;
    nxbh = 40;
    nxbh = 32;
    vgap = 6;
    vgap = 4;
    bw = 155;               % Button Width
    bh = 34;                % Button Height
    PBSTRS = ['<Control Design>    ';
         'Control Design      ';
         '<Form Closed Loop>  ';
         'Form Closed Loop    ';
         '<Frequency Response>';
         'Frequency Response  ';
         '<Compute Mu>        ';
         'Compute Mu          ';
         '(Next Iteration)    ';
         'Next Iteration      '];
%   Next Iteration Object
    nix = Lx;
    niy = Ly + Lh + bigvgap;
    dimvec = [nix;niy;fgap;fgap;3;3;nxbh;bw;vgap];
    pbstring = PBSTRS(10,:);
    cbstring = ['dkitgui(' thstr ',''nextiter'')'];
    na_xywh = parmwin('dimquery','lopb',dimvec,pbstring,ITWIN,cbstring);
    [frameh,nxbuttons] = parmwin('create','lopb',dimvec,pbstring,ITWIN,cbstring);
    vechandles(handlecnt) = frameh;
    handlecnt = handlecnt + 1;
    vechandles(handlecnt:handlecnt+length(nxbuttons)-1) = nxbuttons(:);
    handlecnt = handlecnt + length(nxbuttons);
    set(frameh,'userdata',[]);

%   Auto-Iteration Stop Button
    aisx = nix + na_xywh(3) + 20;
    aisy = niy;
    aisw = rightx-aisx;
    aish = 55;
    AISTOPBUT = uicontrol('style','pushbutton',...
        'string','Stop Auto Iteration','position',[aisx aisy aisw aish],...
        'callback',['sguivar(''INTERUPT'',1,' thstr ')'],'visible','off');

    mix = nix;
    miy = niy + na_xywh(4) + 2*vgap;
%   Main Iteration Pushbuttons
    dimvec = [mix;miy;fgap;fgap;3;3;bh;bw;vgap];
    pbstring = str2mat('SETUP',PBSTRS([4 6 8],:));
    cbstring = str2mat(['dkitgui(' thstr ',''showsetup1'');'],...
        ['dkitgui(' thstr ',''formclp'');muexport;'],...
    ['dkitgui(' thstr ',''getomega'');omegavl;dkitgui(' thstr ',''dofrsp'');muexport;'],...
                    ['dkitgui(' thstr ',''mucompute'');muexport;']);

    [mi_xywh] = parmwin('dimquery','lopb',dimvec,pbstring,ITWIN,cbstring);
    [frameh,mainbuttons] = parmwin('create','lopb',dimvec,pbstring,ITWIN,cbstring);
    vechandles(handlecnt) = frameh;
    handlecnt = handlecnt + 1;
    vechandles(handlecnt:handlecnt+length(mainbuttons)-1) = mainbuttons(:);
    handlecnt = handlecnt + length(mainbuttons);
    set(frameh,'userdata',[]);

    MAINPB = [mainbuttons(:);nxbuttons(:)];
    set(MAINPB,'enable','off');

    set(ITWIN,'Userdata',vechandles(1:handlecnt-1));
    allhandles = get(ITWIN,'userdata');
    set(allhandles(1),'userdata',VARNAMES); set(allhandles(2),'userdata',PIMNUMBER);

%   CREATE SUMMARY TABLE
    summarynames = str2mat('Iteration #','Total D Order','Controller Order',...
         'Gamma Achieved','Peak Mu Value');
    titlename = 'DK Iteration Summary';
    st_x = 0;
    st_y = 0;
%    dimvec = [40;17;25;20;130;55;3;4;1;4;3;4;1;2;3;0];
%    dimvec = [40;17;18;20;130;55;3;4;1;4;1;4;1;2;3;0];
%    dimvec = [40;17;18;20;130;55;3;4;1;4;1;4;1;1;1;0];
    dimvec = [40;20;20;20;130;55;3;4;1;4;1;4;1;1;1;0];
    sxywh = scrolltb('dimquery',titlename,summarynames,setstr(ones(6,1)*'text'),...
            [],[],setstr(ones(6,1)*'text'),[],...
            st_x,st_y,ITWIN,dimvec);
    gap = (winpos(3) - sxywh(3) - mix - mi_xywh(3))/2;
    st_x = mi_xywh(3) + mix + gap;
    st_y = miy;
    st_y = miy + mi_xywh(4) - sxywh(4);
    [DKSUM_HAN,exhan] = ...
        scrolltb('create',titlename,summarynames,setstr(ones(6,1)*'text'),...
            [],[],setstr(ones(6,1)*'text'),[],...
            st_x,st_y,ITWIN,dimvec);
    scrolltb('firstdata',DKSUM_HAN,[1;inf;inf;inf;inf]);
    scrolltb('setrv',DKSUM_HAN,zeros(5,4));
    tmp = length(exhan);
    vechandles(handlecnt:handlecnt+tmp-1) = exhan;
    handlecnt = handlecnt + tmp;

    set(ITWIN,'Userdata',vechandles(1:handlecnt-1));

    set(ITWIN,'visible','on');


%       SETUP WINDOW
%--------------------------------------
    SETUPWIN = 0;
    ifgap1_1 = 12;
    ifgap1_2 = 20;
    ifgapx1 = 12;
    ifgap2 = 4;
    xbo1 = 8;
    xbo2 = 6;
    ybotbo1 = 4;
    ybotbo2 = 3;
    ytopbo1 = 18;
    ytopbo2 = 1;
    xlgap1 = 4;
    xrgap1 = 4;
    ybgap1 = 4;
    ymgap1 = 6;
    xlgap2 = 3;
    xrgap2 = 3;
    ybgap2 = 3;
    ymgap2 = 5;
    xlgap3 = 3;
    xrgap3 = 3;
    ybgap3 = 3;
    ybgapbig3 = 120;
    ybgapbig3 = 90;
    ytitgap = 1;
    ymgap3 = ytitgap;
    ytgap1 = 1;

    ET_BGC = [1 1 1];


%   NAME STUFF
    llx = 12;
    lly = -20;

    messx = llx;
    messy = lly;
    if ss(4)<600
        messh = 1;
    else
%        messh = 18;
        messh = 20;
    end

    yutitle = 'Feedback Structure';
    yunames = str2mat('# of Measurements','# of Controls');
    yudefaults = [nan;nan];
%    yu_dv = [0;0;5;6;5;5;17;159;35;4;4];
    yu_dv = [0;0;5;6;5;5;20;159;35;4;4];
    yufx = llx + xlgap1;
    yufy = messy + messh + ybgap1 + ybgap1 + 5;
        yu_wh = parmwin('dimquery','nwd',yu_dv,yunames,yudefaults,SETUPWIN,...
            ['dkparmcb(' thstr ',''yudim'','],ET_BGC);
    yufw = xlgap2 + yu_wh(3) + xrgap2;
    yubotbo = ybgap2 + yu_wh(4) + ytitgap;
%    titleheight = 18;
    titleheight = 20;
    yufdv = [yufx;yufy;yubotbo;1;titleheight;yufw];
    yufwh = parmwin('dimquery','frwtit',yufdv,SETUPWIN,yutitle);
        yu_dv(1) = yufx + xlgap2;
        yu_dv(2) = yufy + ybgap2;

    detitle = 'Performance Structure';
    denames = str2mat('# of Errors','# of Disturbances');
    dedefaults = [nan;nan];
%    de_dv = [0;0;5;6;5;5;17;159;35;4;4]-2*[0;0;0;0;0;0;0;xlgap2;0;0;0];
    de_dv = [0;0;5;6;5;5;20;159;35;4;4]-2*[0;0;0;0;0;0;0;xlgap2;0;0;0];
    defx = yufx + xlgap2;
    defy = yufy + yufwh(4) + ymgap1 + ybgap2;
        de_wh = parmwin('dimquery','nwd',de_dv,denames,dedefaults,SETUPWIN,...
            ['dkitgui(' thstr ',''dedim'','],ET_BGC);
    defw = xlgap3 + de_wh(3) + xrgap3;
    debotbo = ybgap3 + de_wh(4) + ymgap3;
    defdv = [defx;defy;debotbo;1;titleheight;defw];
    defwh = parmwin('dimquery','frwtit',defdv,SETUPWIN,detitle);
        de_dv(1) = defx + xlgap3;
        de_dv(2) = defy + ybgap3;

    uncnames = str2mat('# of Blocks');
    uncdefaults = [nan];
    unc_dv = de_dv;
    unctitle = 'Uncertainty Structure';
    uncfx = yufx + xlgap2;
    uncfy = defy + defwh(4) + ymgap2;
    uncwh = parmwin('dimquery','nwd',unc_dv,uncnames,uncdefaults,SETUPWIN,...
            ['dkparmcb(' thstr ',''uncdim'',1,'],ET_BGC);
    uncfw = xlgap3 + uncwh(3) + xrgap3;
    uncybotbo = ybgapbig3 + uncwh(4) + ymgap3;
    uncfdv = [uncfx;uncfy;uncybotbo;1;titleheight;uncfw];
    uncfwh = parmwin('dimquery','frwtit',uncfdv,SETUPWIN,unctitle);
    uncfdv(2) = uncfy;
    unc_dv(1) = uncfx + xlgap3;
    unc_dv(2) = uncfy + ybgapbig3;

    blktitle = 'Block Structure';
    blkfx = llx + xlgap1;
    blkfy = messy + messh + ybgap1 + ybgap1 + yufwh(4) + ymgap1;
    blkfw = yufwh(3);
    blkybotbo = ybgap2 + defwh(4) + ymgap2 + uncfwh(4) + ytitgap;
    blkfdv = [blkfx;blkfy;blkybotbo;5;20;blkfw];
    blkfwh = parmwin('dimquery','frwtit',blkfdv,SETUPWIN,blktitle);

%    bortitle = 'Signal Dimensions';
    bortitle = 'SIGNAL DIMENSIONS';
    borfx = llx;
    borfy = messy + messh + ybgap1 + 5;
    borfw = xlgap1 + yufwh(3) + xrgap1;
    borybotbo = ybgap1 + yufwh(4) + ymgap1 + blkfwh(4) + ytitgap + ytgap1 - 5;
    borfdv = [borfx;borfy;borybotbo;1;titleheight;borfw];
    borfwh = parmwin('dimquery','frwtit',borfdv,SETUPWIN,bortitle);

    dw = 230;
    systemdv = [llx;borfwh(2)+borfwh(4)+ymgap1;4;4;5;5;40;4;4;100;dw;130;25;5;5];
    cboxnames = str2mat('Open-Loop IC','<Controller>');
    varnames = str2mat('OLIC','CONT');
    mdef = [];
    systemwh = dataent('dimquery',systemdv,cboxnames,varnames,mdef,[],[],[],1,1);
%   NAME STUFF
%    wnamedv = [0 0 4 4 4 4 18 260 3];
    wnamedv = [0 0 4 4 4 4 20 260 3];
    wnamehead = '<Iteration Name>';
    wnamestring = '';
    wnamecb = ['dkitgui(' thstr ',''namecb'')'];

%    sufdv = [0 0 4 4 4 4 18 260 3];
    sufdv = [0 0 4 4 4 4 20 260 3];
    sufhead = '<Iteration Suffix>';
    sufstring = '';
    sufcb = ['dkitgui(' thstr ',''sufcb'')'];

%    omegadv = [0;0;24;3;17;2;3;4;80;10];
    omegadv = [0;0;24;3;20;2;3;4;80;10];
    nametitle = 'Identifiers';
    omegatitle = 'Frequency Range';

    majormidgap = 20;

    omegafx = llx + borfwh(3) + 20;
    omegafy = 0;
        omwh = omframe([],[],'dimquery',omegadv,SETUPWIN,ET_BGC);
    omegafw = xbo2 + omwh(3) + xbo2;
    omegaybotbo = ybotbo2 + omwh(4) + ytopbo2;
    omegafdv = [omegafx;omegafy;omegaybotbo;1;titleheight;omegafw];
    omegafwh = parmwin('dimquery','frwtit',omegafdv,SETUPWIN,omegatitle);

    iternamefx = llx + borfwh(3) + 20;
    iternamefy = 0;
        wnamewh = parmwin('dimquery','longed',wnamedv,wnamehead,wnamestring,SETUPWIN,wnamecb,ET_BGC);
        sufwh = parmwin('dimquery','longed',sufdv,sufhead,sufstring,SETUPWIN,sufcb,ET_BGC);
    infw = xbo2 + wnamewh(3) + xbo2;
    inybotbo = ybotbo2 + wnamewh(4) + ifgap2 + sufwh(4) + ytopbo2;
    inf_dv = [iternamefx;iternamefy;inybotbo;1;titleheight;infw];
    inf_wh = parmwin('dimquery','frwtit',inf_dv,SETUPWIN,nametitle);

    su_width = llx + borfwh(3) + majormidgap + omegafwh(3) + llx;
    dw = dw + inf_wh(1) + inf_wh(3) - messx - systemwh(3);
    su_height =  lly + messh + ybgap1 + borfwh(4) + ymgap1 + systemwh(4);
    systemdv(11) = dw;
    SETUPWIN = figure('visible','off',...
        'Name',[WINDOWPRE 'DK Iteration Setup' wsuff],...
        'menubar','none',...
        'NumberTitle','off',...
        'Color',dgkwin_c,...
        'pointer','watch',...
        'CloseRequestFcn',['dkitgui(' thstr ',''hidesetup'')'],...
        'Position',[20 46 su_width su_height+10],...
        'DoubleBuffer','on', ...
        'DockControls', 'off');
%       SETUP MENUS
    tmp = uimenu(SETUPWIN,'Label','Window');

    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    atmp = uimenu(tmp,'Label','Hide Setup','callback',['dkitgui(' thstr ',''hidesetup'')']);
    btmp = uimenu(tmp,'Label','Iteration','callback',['dkitgui(' thstr ',''showiter'')'],...
        'separator','on');
    ctmp = uimenu(tmp,'Label','Mu/SVD Plot','callback',['dkitgui(' thstr ',''showplot'')']);
    dtmp = uimenu(tmp,'Label','Scalings','callback',['dkitgui(' thstr ',''showscl'')']);
    etmp = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);
    vechandles(handlecnt:handlecnt+4) = [atmp;btmp;ctmp;dtmp;etmp];
    handlecnt = handlecnt + 5;
%       END MENUS

    dw = 0;
    datadv = [0;0;4;4;5;5;40;4;4;94;dw;2;25;5;5];
    dboxnames = str2mat('Uncertainty','Performance','Feedback','Omega');
    dvarnames = str2mat('TMP','EDDIM','YUDIM','TMP');
    dmdef = [];

    datawh = dataent('dimquery',datadv,dboxnames,dvarnames,dmdef,[],[],[],1,1);

    rfy = borfwh(2) + borfwh(4) - datawh(4);
    rfx = borfwh(1) + borfwh(3) + majormidgap;
    rfw = su_width - llx - rfx;
    dw = rfw - datawh(3);
    datadv([1 2 11]) = [rfx rfy dw];

    omegagap = 8;
    omegafy = rfy - omegagap - omegafwh(4);
    omegafdv(2) = omegafy;
        omegadv(1) = omegafx + xbo2;
        omegadv(2) = omegafy + ybotbo2;
    itergap = 6;
    iternamefy = omegafy - itergap - inf_wh(4);
    inf_dv(2) = iternamefy;
        wnamedv(1) = iternamefx + xbo2;
        wnamedv(2) = iternamefy + ybotbo2 + 1;
        sufdv(1) = wnamedv(1);
        sufdv(2) = wnamedv(2) + ifgap2 + wnamewh(4);

    SETUPNORMAX = mkdragtx('create',SETUPWIN);
    set(SETUPNORMAX,'xlim',[0 1],'ylim',[0 1]);

    lx = inf_dv(1);
    ybotbo =  4;
    ytopbo = 4;
    xlbo = 4;
    xrbo = 4;
    th =  20;
    dw = 30;
    hgap = 5;
    vgap = 1;
    nw = inf_wh(3) - xlbo - xrbo - dw - hgap;
    ly = inf_dv(2) - 10 - th - ytopbo - ybotbo;
    dv = [lx;ly;ybotbo;ytopbo;xlbo;xrbo;th;nw;dw;hgap;vgap];

%    figure(SETUPWIN)
%    set(SETUPWIN,'visible','off')

    uncscb = ['dkitgui(' thstr ',''setunc'');'];
    uncecb = ['sguivar(''OLIC'',[],' thstr ');dkitgui(' thstr ',''getolic'');'];
    perfscb = ['dkitgui(' thstr ',''seteddim'',gguivar(''EDDIM'',' thstr '));'];
    perfecb = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Error in Perf'');' ...
                'set(gguivar(''SUMESSAGE'',' thstr '),''string'',''Error in Perf'');'];
    yuscb = ['dkitgui(' thstr ',''setyudim'',gguivar(''YUDIM'',' thstr '));'];
    yuecb = ['set(gguivar(''MESSAGE'',' thstr '),''string'',''Error in Feed'');' ...
                'set(gguivar(''SUMESSAGE'',' thstr '),''string'',''Error in Feed'');'];
    omegascb = ['omframe(' thstr ',gguivar(''OMEGA_HAN'',' thstr '),''custom'');' ...
     'omframe(' thstr ',gguivar(''OMEGA_HAN'',' thstr '),''setcustomstr'',' ...
     'get(gguivar(''EDITHANDLES'',' thstr '),''string''));' ...
     'omframe(' thstr ',gguivar(''OMEGA_HAN'',' thstr '),''mkomega'');'];
    omegaecb = omegascb;
    scb = str2mat(uncscb,perfscb,yuscb,omegascb);
    ecb = str2mat(uncecb,perfecb,yuecb,omegaecb);
    [EXTRALOAD,binlocex] = dataent('create',datadv,dboxnames,dvarnames,dmdef,SETUPNORMAX,...
        scb,ecb,SETUPWIN,'EXTRALOAD');

    name_tit = parmwin('create','frwtit',inf_dv,SETUPWIN,nametitle);
        xx = parmwin('create','longed',wnamedv,wnamehead,wnamestring,SETUPWIN,wnamecb,ET_BGC);
        yy = parmwin('create','longed',sufdv,sufhead,sufstring,SETUPWIN,sufcb,ET_BGC);
        set(name_tit,'userdata',[yy xx]);

    om = parmwin('create','frwtit',omegafdv,SETUPWIN,omegatitle);
        OMEGA_HAN = omframe([],[],'create',omegadv,SETUPWIN,ET_BGC);

    SUMESSAGE = uicontrol('style','text',...
                'backgroundcolor',dgkwin_c,...
                'horizontalalignment','left',...
               'position',[messx messy inf_wh(1)+inf_wh(3)-messx messh]);
    vechandles(handlecnt) = [SUMESSAGE];
    handlecnt = handlecnt + 1;

    borframe = parmwin('create','frwtit',borfdv,SETUPWIN,bortitle);
    set(borframe,'backgroundcolor',[.75 .75 .75]);
    set(get(borframe,'userdata'),'backgroundcolor',[.75 .75 .75]);

    yuframe = parmwin('create','frwtit',yufdv,SETUPWIN,yutitle);
        YUFRAME = parmwin('create','nwd',yu_dv,yunames,yudefaults,SETUPWIN,...
            ['dkparmcb(' thstr ',''yudim'','],ET_BGC);
        YUEDIT = get(YUFRAME,'userdata');

    blkframe = parmwin('create','frwtit',blkfdv,SETUPWIN,blktitle);

    MAIN_BLKF = parmwin('create','frwtit',uncfdv,SETUPWIN,unctitle);
        BLK_HAN = parmwin('create','nwd',unc_dv,uncnames,uncdefaults,SETUPWIN,...
            ['dkparmcb(' thstr ',''uncdim'',1,'],ET_BGC);

    deframe = parmwin('create','frwtit',defdv,SETUPWIN,detitle);
        DEFRAME = parmwin('create','nwd',de_dv,denames,dedefaults,SETUPWIN,...
            ['dkitgui(' thstr ',''dedim'','],ET_BGC);

        EDEDIT = get(DEFRAME,'userdata');


    olicscb = ['dkitgui(' thstr ',''getolic'');'];
    olicecb = ['sguivar(''OLIC'',[],' thstr ');dkitgui(' thstr ',''getolic'');'];
    contscb = ['dkitgui(' thstr ',''getcont'');'];
    contecb = ['sguivar(''CONT'',[],' thstr ');dkitgui(' thstr ',''getcont'');'];
    scb = str2mat(olicscb,contscb);
    ecb = str2mat(olicecb,contecb);
    [OLICCONTLOAD,binlocmain] = dataent('create',systemdv,cboxnames,varnames,mdef,SETUPNORMAX,...
        scb,ecb,SETUPWIN,'OLICCONTLOAD');

%    set(SETUPWIN,'visible','off');

    BINLOC = [binlocex;binlocmain];

    set(SETUPWIN,'Userdata',vechandles(1:handlecnt-1));
    set(ITWIN,'Userdata',vechandles(1:handlecnt-1));

%   6 extra handles
    PLT_WIN = figure('visible','off', 'DockControls', 'off');
    pltcols(PLT_WIN);
%    drawnow
    set(PLT_WIN,'Name',[WINDOWPRE 'DK Iteration Scaling' wsuff],...
        'menubar','none',...
        'pointer','watch',...
        'NumberTitle','off',...
	'CloseRequestFcn',['dkitgui(' thstr ',''hidescl'')'],...
        'Position',[0.50*ss(3) 20 0.45*ss(3) 0.8*ss(4)]);
%        'Position',[420 20 500 780]);
    tmp = uimenu(PLT_WIN,'Label','Window');
    tmp1 = uimenu(tmp,'Label','Hide Scalings',...
        'callback',['dkitgui(' thstr ',''hidescl'')']);
    tmp2 = uimenu(tmp,'Label','Iteration','separator','on',...
        'callback',['dkitgui(' thstr ',''showiter'')']);
    tmp3 = uimenu(tmp,'Label','Setup','enable','off',...
        'callback',['dkitgui(' thstr ',''showsetup'')']);
    SHOWSETUPHAN = [SHOWSETUPHAN;tmp3];
    tmp4 = uimenu(tmp,'Label','Mu/SVD Plot','callback',['dkitgui(' thstr ',''showplot'')']);
    tmp5 = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);

    vskip = 0.08;
    ah = (1-4*vskip)/3;
    aw = 0.8;
%       TOP, norm/mubnds
    bn = axes('Position',[.1 3*vskip+2*ah aw ah],'Fontsize',8);
    title = get(bn,'title');
    set(title,'fontsize',8);
    xx = get(bn,'xlabel');
    set(xx,'fontsize',8);
    yy = get(bn,'ylabel');
    set(yy,'fontsize',8);
%       MIDDLE, rational/fits/data
    rf = axes('Position',[.1 2*vskip+ah aw ah],'Fontsize',8);
    title = get(rf,'title');
    set(title,'fontsize',8);
    yy = get(rf,'ylabel');
    set(yy,'fontsize',8);
%       BOTTOM: sensitivity
    we = axes('Position',[.1 vskip aw ah],'Fontsize',8);
    title = get(we,'title');
    set(title,'fontsize',8);
    xx = get(we,'xlabel');
    set(xx,'fontsize',8);
    yy = get(we,'ylabel');
    set(yy,'fontsize',8);
    FITPLOTS = [rf;bn;we];

%   PARAMETER WINDOW
    if ss(4)<600
        messh = 1;
    else
%        messh = 18;
        messh = 20;
    end

%    hinfdv = [0;0;5;5;5;5;17;160;50;4;4];
%    hnynudv = [0 0 4 4 4 4 18 216 3];
    hinfdv = [0;0;5;5;5;5;20;160;50;4;4];
    hnynudv = [0 0 4 4 4 4 20 216 3];
    nyhead = 'Measurements Utilized:';
    nuhead = 'Controls Utilized:';
    nystring = 'All';
    nustring = 'All';
    nucb = ['dkitgui(' thstr ',''chooseu'');dkuchose'];
    nycb = ['dkitgui(' thstr ',''choosey'');dkychose'];
%    allrbdv = [0;0;5;5;5;5;18;sum(hinfdv([8 9 10]));4];
    allrbdv = [0;0;5;5;5;5;20;sum(hinfdv([8 9 10]));4];

    savenames = str2mat('Controller','Mu Analysis',...
        'Closed-Loop Freq Response','Rational D-Scalings','Open-Loop Interconnection');
    savedefaults = [1;1;0;0;0];
    EXPORTVALUE = savedefaults;
    savetitle = 'Each Iteration: Export...';
    savecallback = ['dkitgui(' thstr ',''savecb'','];

    hinfnames =     str2mat('Gamma Min','Gamma Max',...
        'Bisect Tol','Suboptimal Tol',...
        'Imaginary Tol','Pos Def Tol');
    hinfnames =     str2mat('Gamma Min','Gamma Max',...
        'Suboptimal Tol',...
        'Imaginary Tol','Pos Def Tol');
    HINFPARMNAME = hinfnames;
    HDEFAULTS = [0;100;1;.1;1e-10;1e-6]*[1 1];
    HDEFAULTS = [0;100;1;1e-10;1e-6]*[1 1];
    hinfdefaults = [];
    hinftitle = 'HinfSyn Parameters';
    hinfcallback = ['dkparmcb(' thstr ',''hinfparms'','];
    actualnames = [deblank(hinfnames(1,:)) ' (' agv2str(HDEFAULTS(1,1)) ')'];
    for i=2:size(hinfnames,1)
        actualnames = str2mat(actualnames,...
        [deblank(hinfnames(i,:)) ' (' agv2str(HDEFAULTS(i,1)) ')']);
    end


    ricnames = str2mat('Schur Method','Eigenvalue Method');
    ricdefaults = [1;0];
    rictitle = 'Riccati Solver';
    riccallback = ['dkparmcb(' thstr ',''ricmthd'','];

%    mxodv = [0;0;5;5;5;5;17;160;50;4;4];
    mxodv = [0;0;5;5;5;5;20;160;50;4;4];
    mxonames = 'Max Auto-Order';
    mxocb = ['dkitgui(' thstr ',''reautofit'');dkparmcb(' thstr ',''maxord'','];
    mxodefaults = [5];
    fittitle = 'D-Scale Prefit';

    munames1 = str2mat('Optimal (opt = ''C'')','Fast (opt = ''c'')');
    mudefault1 = [0;1];
    mucallback1 = ['dkparmcb(' thstr ',''mumthd'','];
    munames2 = str2mat('No Lower Bound');
    mudefault2 = [0];
    mutitle = 'Structured Singular Value (Mu)';
    mucallback2 = ['dkparmcb(' thstr ',''nolowerbnd'','];

    ifgap1_1 = 10;
    ymessgap = 4;
    ifgap1_2 = 20;
    ifgapx1 = 12;
    ifgap2 = 9;
    xbo1 = 8;
    xbo2 = 6;
    ybotbo1 = 8;
    ybotbo2 = 6;
    ytopbo1 = 6;
    ytopbo2 = 6;

    PARMWIN = 0;

    messx = xbo1;
    messy = ybotbo1;

    mufx = messx;
    mufy = messy + messh + ymessgap;
        mu1wh = parmwin('dimquery','merb',allrbdv,munames1,mudefault1,PARMWIN,mucallback1);
        mu2wh = parmwin('dimquery','lorb',allrbdv,munames2,mudefault2,PARMWIN,mucallback2);
    mufw = xbo2 + mu1wh(3) + xbo2;
    mufybotbo = ybotbo2 + mu2wh(4) + ifgap2 + mu1wh(4) + ybotbo2;
    mufr_dv = [mufx;mufy;mufybotbo;1;titleheight;mufw];
    mufwh = parmwin('dimquery','frwtit',mufr_dv,PARMWIN,mutitle);
        mu2rb_dv = allrbdv;
        mu2rb_dv(1) = mufx + xbo2;
        mu2rb_dv(2) = mufy + ybotbo2;
        mu1rb_dv = allrbdv;
        mu1rb_dv(1) = mu2rb_dv(1);
        mu1rb_dv(2) = mu2rb_dv(2) + mu2wh(4) + ifgap2;

    hedfx = mufx;
    hedfy = mufy + mufwh(4) + ifgap1_1;
        hnywh = parmwin('dimquery','longed',hnynudv,nyhead,nystring,PARMWIN,nycb,ET_BGC);
        hnuwh = parmwin('dimquery','longed',hnynudv,nuhead,nustring,PARMWIN,nucb,ET_BGC);
        hedwh = parmwin('dimquery','nwd',hinfdv,hinfnames,hinfdefaults,PARMWIN,hinfcallback,ET_BGC);
    hedfw = xbo2 + hedwh(3) + xbo2;
    hedfybotbo = ybotbo2 + hnuwh(4) + ifgap2 + hnywh(4) + ifgap2 + hedwh(4) + ybotbo2;
    hedf_dv = [hedfx;hedfy;hedfybotbo;1;titleheight;hedfw];
    hedfwh = parmwin('dimquery','frwtit',hedf_dv,PARMWIN,hinftitle);
    hedf_dv(2) = hedfy;
        hed_dv = hinfdv;
        hnu_dv = hnynudv;
        hny_dv = hnynudv;
        hnu_dv(1) = hedfx + xbo2;
        hnu_dv(2) = hedfy + ybotbo2;
        hny_dv(1) = hedfx + xbo2;
        hny_dv(2) = hnu_dv(2) + hnuwh(4) + ifgap2;
        hed_dv(1) = hedfx + xbo2;
        hed_dv(2) = hny_dv(2) + hnywh(4) + ifgap2;

    savefx = mufx + ifgapx1 + mufwh(3);
    savefy = mufy;
        savbutwh = parmwin('dimquery','locb',allrbdv,savenames,savedefaults,PARMWIN,savecallback);
    savefw = xbo2 + savbutwh(3) + xbo2;
    savefybotbo = ybotbo2 + savbutwh(4) + ybotbo2;
    savef_dv = [savefx;savefy;savefybotbo;1;titleheight;savefw];
    savefwh = parmwin('dimquery','frwtit',savef_dv,PARMWIN,savetitle);
        savbut_dv = allrbdv;
        savbut_dv(1) = savefx + xbo2;
        savbut_dv(2) = savefy + ybotbo2;

    dffx = savefx;
    dffy = savefy + savefwh(4) + ifgap1_2;
        dfwh = parmwin('dimquery','nwd',mxodv,mxonames,mxodefaults,PARMWIN,mxocb,ET_BGC);
    dffw = xbo2 + dfwh(3) + xbo2;
%    txth = 19;
    txth = 20;
    agap = 1;
    slh = 20;
    ggap = 10;
    dfybotbo = ybotbo2 + txth + agap + slh + agap + txth + ggap + dfwh(4) + ybotbo2;
    dffr_dv = [dffx;dffy;dfybotbo;1;titleheight;dffw];
    dffwh = parmwin('dimquery','frwtit',dffr_dv,PARMWIN,fittitle);
        df_dv = mxodv;
        df_dv(1) = dffx + xbo2;
        df_dv(2) = dffy + ybotbo2 + txth + agap + slh + agap + txth + ggap;

    ricfx = dffx;
    ricfy = dffy + dffwh(4) + ifgap1_2;
        ricwh = parmwin('dimquery','merb',allrbdv,ricnames,ricdefaults,PARMWIN,riccallback);
    ricfw = xbo2 + ricwh(3) + xbo2;
    ricfybotbo = ybotbo2 + ricwh(4) + ybotbo2;
    ricf_dv = [ricfx;ricfy;ricfybotbo;1;titleheight;ricfw];
    ricfwh = parmwin('dimquery','frwtit',ricf_dv,PARMWIN,rictitle);
        ric_dv = allrbdv;
        ric_dv(1) = ricfx + xbo2;
        ric_dv(2) = ricfy + ybotbo2;
    RHS_h = savefwh(4) + dffwh(4) + ricfwh(4);
    maingap = ((hedfy+hedfwh(4)-mufy)-RHS_h)/2;
    dffy = savefy + savefwh(4) + maingap;
    dffr_dv(2) = dffy;
    df_dv(2) = dffy + ybotbo2 + txth + agap + slh + agap + txth + ggap;
    ricfy = dffy + dffwh(4) + maingap;
    ricf_dv(2) = ricfy;
    ric_dv(2) = ricfy + ybotbo2;

    win_w = ricfx+ricfwh(3)+xbo1;
    win_h = ricf_dv(2)+ricfwh(4)+ytopbo1;

    PARMWIN = figure('Name',[WINDOWPRE 'DK Parameters' wsuff],...
        'menubar','none',...
        'NumberTitle','off',...
        'pointer','watch',...
        'color',dgkwin_c,...
        'visible','off',...
	'CloseRequestFcn',['dkitgui(' thstr ',''hideparm'');'],...
        'position',...
        [(ss(3)-win_w)/2-20 (ss(4)-win_h)/2-40 win_w win_h],...
        'DoubleBuffer','on', ...
        'DockControls', 'off');
%       SETUP PARM MENUS
    tmp = uimenu(PARMWIN,'Label','Window');
    vechandles(handlecnt) = tmp;
    handlecnt = handlecnt + 1;
    atmp = uimenu(tmp,'Label','Hide Parameters','enable','on',...
        'callback',['dkitgui(' thstr ',''hideparm'');']);
    btmp = uimenu(tmp,'Label','Iteration','enable','on',...
        'separator','on','callback',['dkitgui(' thstr ',''showiter'');']);
    ctmp = uimenu(tmp,'Label','Setup','enable','off',...
        'callback',['dkitgui(' thstr ',''showsetup'');'],'enable','off');
    SHOWSETUPHAN = [SHOWSETUPHAN;ctmp];
    dtmp = uimenu(tmp,'Label','Mu/SVD Plot','callback',['dkitgui(' thstr ',''showplot'')']);
    etmp = uimenu(tmp,'Label','Scalings','callback',['dkitgui(' thstr ',''showscl'')']);
    vechandles(handlecnt:handlecnt+4) = [atmp;btmp;ctmp;dtmp;etmp];
    handlecnt = handlecnt + 5;
%       END PARM MENUS

    MESS_PARM = uicontrol('style','text',...
                'backgroundcolor',dgkwin_c,...
                'horizontalalignment','left',...
               'position',[xbo1 ybotbo1 win_w-2*xbo1 messh]);
    hinf_tit = parmwin('create','frwtit',hedf_dv,PARMWIN,hinftitle);
        UCHOOSE = parmwin('create','longed',hnu_dv,nuhead,nustring,PARMWIN,nucb,ET_BGC);
        YCHOOSE = parmwin('create','longed',hny_dv,nyhead,nystring,PARMWIN,nycb,ET_BGC);
        ud = get(UCHOOSE,'userdata');
        yd = get(YCHOOSE,'userdata');
        set(ud(2),'enable','off');
        set(yd(2),'enable','off');
        [hf1,than] = parmwin('create','nwd',hed_dv,actualnames,hinfdefaults,PARMWIN,hinfcallback,ET_BGC);
        set(hinf_tit,'userdata',[hf1 YCHOOSE UCHOOSE]);
    ric_tit = parmwin('create','frwtit',ricf_dv,PARMWIN,rictitle);
        rf1 = parmwin('create','merb',ric_dv,ricnames,ricdefaults,PARMWIN,riccallback);
        set(ric_tit,'userdata',rf1);
%   CURRENTLY, WE OFFER NO OPTIONS IN D-FIT
       dfit_tit = parmwin('create','frwtit',dffr_dv,PARMWIN,fittitle);
        uicontrol('style','text','string','Loose','position',...
            [dffx+xbo2 dffy+ybotbo2 40 txth],'horizontalalignment','left');
        uicontrol('style','text','string','Tight','position',...
            [dffx+dffw-xbo2-40 dffy+ybotbo2 40 txth],'horizontalalignment','right');
        PRECSL = uicontrol('style','slider','position',...
            [dffx+xbo2 dffy+ybotbo2+txth+agap dffw-2*xbo2 slh],...
            'value',0.5,...
            'callback',['dkitgui(' thstr ',''reautofit'');']);
        uicontrol('style','text','string','Auto-Fit Tolerance','position',...
            [dffx+1 dffy+ybotbo2+txth+agap+slh+agap dffw-2 txth],...
            'horizontalalignment','center');
        mxodv(1) = dffx+xbo2;
        mxodv(2) = dffy+ybotbo2+txth+agap+slh+agap+txth+ggap;
        [mxohan] = parmwin('create','nwd',mxodv,mxonames,mxodefaults,PARMWIN,mxocb,ET_BGC);
    mu_tit = parmwin('create','frwtit',mufr_dv,PARMWIN,mutitle);
        mf1 = parmwin('create','merb',mu1rb_dv,munames1,mudefault1,PARMWIN,mucallback1);
        mf2 = parmwin('create','lorb',mu2rb_dv,munames2,mudefault2,PARMWIN,mucallback2);
        set(mu_tit,'userdata',[mf1;mf2]);
    savefwh = parmwin('create','frwtit',savef_dv,PARMWIN,savetitle);
    savbutwh = parmwin('create','locb',savbut_dv,savenames,savedefaults,PARMWIN,savecallback);
    PARMWIN_HANS = [hinf_tit;ric_tit;dfit_tit;mu_tit];
    set(PARMWIN,'userdata',get(ITWIN,'userdata'));

%       FREQUENCY RESPONSE WINDOW SETUP
    FR_WIN = figure('Name',[WINDOWPRE 'DK Iteration Frequency Response' wsuff],...
        'visible','off',...
        'pointer','watch',...
        'menubar','none',...
        'numbertitle','off',...
	'CloseRequestFcn',['dkitgui(' thstr ',''hideplot'')'],...
        'Position',[20 20 400 400/1.6], ...
        'DockControls', 'off');
    pltcols(FR_WIN);
    tmp = uimenu(FR_WIN,'Label','Window');
    tmp1 = uimenu(tmp,'Label','Hide Mu/SVD Plot',...
        'callback',['dkitgui(' thstr ',''hideplot'')']);
    tmp2 = uimenu(tmp,'Label','Iteration','separator','on',...
        'callback',['dkitgui(' thstr ',''showiter'')']);
    tmp3 = uimenu(tmp,'Label','Setup','enable','off',...
        'callback',['dkitgui(' thstr ',''showsetup'')']);
    SHOWSETUPHAN = [SHOWSETUPHAN;tmp3];
    tmp4 = uimenu(tmp,'Label','Scalings','callback',['dkitgui(' thstr ',''showscl'')']);
    tmp5 = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);

    ttmp = vechandles(1:handlecnt-1);
    mkours(ttmp,ITWIN,SETUPWIN,PARMWIN,PLT_WIN,FR_WIN);


    PLTCOL = str2mat('--r','-g','-.y');
%   START EVERYTHING
    BUTSTAT = [3;1;1;1;1]; % 5 buttons, all disabled except SETUP
    ISREADY = nan*ones(4,2);
    sguivar('DELTAMOD',0,'AUTORK',AUTORK,'AUTORP',AUTORP,'HINFPARMNAME',HINFPARMNAME,toolhan);
    sguivar('OLICCONTLOAD',OLICCONTLOAD,'EXTRALOAD',EXTRALOAD,'SUMESSAGE',SUMESSAGE,...
        'HDEFAULTS',HDEFAULTS,toolhan);
    sguivar('NAUTOIT',1,'AMENUHANS',AMENUHANS,'MULTISTEP',MULTISTEP,toolhan);
    sguivar('OMEGA_HAN',OMEGA_HAN,'BLK_HAN',BLK_HAN,'MAIN_BLKF',MAIN_BLKF,...
        'YUEDIT',YUEDIT,'STARTED',0,'EDEDIT',EDEDIT,toolhan);
    sguivar('EXPORTVALUE',EXPORTVALUE,'WINDOWPRE',WINDOWPRE,toolhan);
    sguivar('PARMWIN_HANS',PARMWIN_HANS,'UCHOOSE',UCHOOSE,'YCHOOSE',YCHOOSE,'MESS_PARM',MESS_PARM,toolhan);
    sguivar('MESSAGE',MESSAGE,'ET_BGC',ET_BGC,'PLT_WIN',PLT_WIN,toolhan);
    sguivar('MAINPB',MAINPB,'PBSTRS',PBSTRS,'BGC',BGC,'FGC',FGC,'BUTSTAT',BUTSTAT,'EPR',EPR,toolhan);
    sguivar('EPP',EPP,'RICMTHD',RICMTHD,'ITWIN',ITWIN,toolhan);
    sguivar('NBLK',[],'NMEAS',[],'NCNTRL',[],'OLIC',[],toolhan);
    sguivar('BLKSYN',[],'RESTARTHAN',RESTARTHAN,'DKSUM_HAN',DKSUM_HAN,...
        'INTERUPT',0,'MUNOTLOW',0,'MUMTHD',2,toolhan);
    sguivar('INUM',0,'READY',0,'GAMPREDICT',1,'FIT_OPT',1,'PLTCOL',PLTCOL,toolhan);
    sguivar('GLOW',1,'GHIGH',2,'GTOL',3,'GPERCTOL',4,'PRECSL',PRECSL,toolhan);
    sguivar('ISREADY',ISREADY,'SHOWSETUPHAN',SHOWSETUPHAN,'SETUPFLAG',1,toolhan);
    sguivar('OGLINK',[],'MFILENAME','dgkitm','TOOLTYPE','DKIT',toolhan);
    sguivar('FITPLOTS',FITPLOTS,'ULINKNAMES',ULN,'TLINKNAMES',TLN,...
        'AISTOPBUT',[AISTOPBUT],'BINLOC',BINLOC,'VISUAL',1,toolhan);
    sguivar('FR_WIN',FR_WIN,'SETUPWIN',SETUPWIN,'PARMWIN',PARMWIN,...
        'EXPORTVAR',[],'COORDS',COORDS,toolhan);
    sguivar('DEFRAME',DEFRAME,'YUFRAME',YUFRAME,toolhan)
    sguivar('STEPS',0,'CITER',5,'PERCTOL',1.03,'DMAXORD',5,toolhan);
    sguivar('ORIGWINPOS',winpos,'RUNNING',RUNNING,'AXESHAN',AXESHAN,toolhan);

    dk_able([2 3 4 5],[1 1 1 1],toolhan);
    set(MULTISTEP,'enable','off');
    set(AMENUHANS,'enable','off');
%   normalize and Turn everything on
    mknorm(ITWIN);
    mknorm(PARMWIN);
    mknorm(SETUPWIN);
    if (nargout ~= 0)
    	out = ITWIN;
    end
    if 0
        set(ITWIN,'position',[winpos(1:2) .75*winpos(3:4)]);
    end

    set(SETUPWIN,'pointer','arrow','visible','off','handlevis','call')
    set(PLT_WIN,'pointer','arrow','visible','off','handlevis','call')
    set(FR_WIN,'pointer','arrow','visible','off','handlevis','call')
    set(PARMWIN,'pointer','arrow','visible','off','handlevis','call')
    set(ITWIN,'pointer','arrow','visible','on','handlevis','call')
    set(MAINPB(1),'enable','on');

% GJW
    set(ITWIN,'DeleteFcn',...
        ['disp(''Cleaning up in DKITGUI..'');dkitgui(' thstr ',''quit'')']);
    set(MESSAGE,'string','Press SETUP to begin.  See the manual, pages 6-17 to 6-40 for more info.');

 elseif strcmp(in,'reautofit')
    [INUM,REAUTOFIT] = gguivar('INUM','REAUTOFIT',toolhan);
    if INUM>=2
        set(REAUTOFIT,'visible','on')
    end
 elseif strcmp(in,'getolic')
    [ISREADY,STARTED,CITER,OLIC,MESSAGE,SUMESSAGE] = ...
     gguivar('ISREADY','STARTED','CITER','OLIC','MESSAGE','SUMESSAGE',toolhan);
    [mtype,mrows,mcols,mnum] = minfo(OLIC);
    if strcmp(mtype,'syst')
        if STARTED == 1
            if ISREADY(1,1) == mrows & ISREADY(1,2) == mcols;
                rready(toolhan);
                if gguivar('READY',toolhan) == 1
                    if CITER == 0 | CITER == 5
                        dk_able(1,3,toolhan);
                    elseif CITER == 1
                        dk_able([1 2],[2 3],toolhan);
                    elseif CITER >= 2 & CITER <= 4
                        dk_able([1 2],[2 2],toolhan);
                    else
                        dk_able([1:5],ones(1,5),toolhan);
                    end
                end
            else
                set(MESSAGE,'string',...
                    'Incompatible Open_loop IC dimensions - Reload to continue')
                set(SUMESSAGE,'string',...
                    'Incompatible Open_loop IC dimensions - Reload to continue')
                sguivar('READY',0,toolhan);
                dk_able([1:5],ones(1,5),toolhan);
            end
        else
            ISREADY(1,1) = mrows;
            ISREADY(1,2) = mcols;
            sguivar('ISREADY',ISREADY,'ABSORBED',0,toolhan);
            rready(toolhan);
        end
    end
 elseif strcmp(in,'getcont')
    [ISREADY,STARTED,CITER,CONT] = ...
        gguivar('ISREADY','STARTED','CITER','CONT',toolhan);
    [mtype,mrows,mcols,mnum] = minfo(CONT);
    if strcmp(mtype,'syst') | strcmp(mtype,'cons')
        if STARTED == 1
            if ISREADY(2,2) == mrows & ISREADY(2,1) == mcols;
                rready(toolhan);
                if gguivar('READY',toolhan) == 1
                    if CITER == 0
                        dk_able([1 2],[3 2],toolhan);
                    elseif CITER == 1
                        dk_able([1 2],[2 3],toolhan);
                    elseif CITER >= 2 & CITER <= 5
                        dk_able([1 2],[2 2],toolhan);
                    else
                        dk_able([1:5],ones(1,5),toolhan);
                    end
                end
            else
                set(gguivar('SUMESSAGE',toolhan),'string',...
                    'Inconsistent Controller - Redesign, Reload or disable Refresh')
                set(gguivar('MESSAGE',toolhan),'string',...
                    'Inconsistent Controller - Redesign, Reload or disable Refresh')
                sguivar('READY',0,'CITER',5,toolhan);
                dk_able([1:5],[3 1 1 1 1],toolhan);
            end
        else
            [NMEAS,NCNTRL] = gguivar('NMEAS','NCNTRL',toolhan);
            flg = 1;
            if ~isempty(NMEAS)
                if NMEAS ~= mcols
                    set(gguivar('SUMESSAGE',toolhan),'string','Inconsistent Controller Dimensions')
                    flg = 0;
                end
            end
            if ~isempty(NCNTRL)
                if NCNTRL ~= mrows
                    set(gguivar('SUMESSAGE',toolhan),'string','Inconsistent Controller Dimensions')
                    flg = 0;
                end
            end
            sguivar('ISREADY',ISREADY,'ABSORBED',0,toolhan);
            out = rready(toolhan);
            if out==1  & flg == 1
                dk_able(2,2,toolhan);
            end
        end
    else
        if STARTED==1
                set(gguivar('SUMESSAGE',toolhan),'string',...
                    'Inconsistent Controller - Redesign, Reload or disable Refresh')
                set(gguivar('MESSAGE',toolhan),'string',...
                    'Inconsistent Controller - Redesign, Reload or disable Refresh')
                sguivar('READY',0,'CITER',5,toolhan);
                dk_able([1:5],[3 1 1 1 1],toolhan);
        end
    end
 elseif strcmp(in,'nmeas')
    nmeasstr = get(get(gcf,'currentobject'),'String');
    nmeasstr = nmeasstr(find(nmeasstr~=' '));
    tmp = str2double(nmeasstr);
    if tmp > 0 & max(size(tmp)) == 1 & floor(tmp)==ceil(tmp)
        [ISREADY,CONT] = gguivar('ISREADY','CONT',toolhan);
        prlc = 0;
        if ~isempty(CONT) & unum(CONT) ~= tmp
            set(gguivar('SUMESSAGE',toolhan),'string','Inconsistent Preloaded Controller Dimensions')
            prlc = 0;
        elseif ~isempty(CONT) & unum(CONT) == tmp
            prlc = 1;
            set(gguivar('SUMESSAGE',toolhan),'string',' ')
        end
        ISREADY(2,1) = tmp;
        sguivar('NMEAS',tmp,'ISREADY',ISREADY,toolhan);
        out = rready(toolhan,ISREADY);
        if out == 1 & prlc == 0
            dk_able([1;2;3;4;5],[3 1 1 1 1],toolhan);
        elseif out == 1 & prlc == 1
            dk_able([1;2;3;4;5],[3 2 1 1 1],toolhan);
        end
    else
        set(get(gcf,'currentobject'),'String','');
        sguivar('NMEAS',[],toolhan);
    end
 elseif strcmp(in,'ncntrl')
    ncntrlstr = get(get(gcf,'currentobject'),'String');
    ncntrlstr = ncntrlstr(find(ncntrlstr~=' '));
    tmp = str2double(ncntrlstr);
    if tmp > 0 & max(size(tmp)) == 1 & floor(tmp)==ceil(tmp)
        [ISREADY,CONT] = gguivar('ISREADY','CONT',toolhan);
        prlc = 0;
        if ~isempty(CONT) & ynum(CONT) ~= tmp
            set(gguivar('SUMESSAGE',toolhan),'string','Inconsistent Preloaded Controller Dimensions')
            prlc = 0;
        elseif ~isempty(CONT) & ynum(CONT) == tmp
            prlc = 1;
            set(gguivar('SUMESSAGE',toolhan),'string',' ')
        end
        ISREADY(2,2) = tmp;
        sguivar('NCNTRL',tmp,'ISREADY',ISREADY,toolhan);
        out = rready(toolhan);
        if out == 1 & prlc == 0
            dk_able([1;2;3;4;5],[3 1 1 1 1],toolhan);
        elseif out == 1 & prlc == 1
            dk_able([1;2;3;4;5],[3 2 1 1 1],toolhan);
        end
    else
        set(get(gcf,'currentobject'),'String',' ');
        sguivar('NCNTRL',[],toolhan);
    end
 elseif strcmp(in,'dedim')
    if in2==1
        nerrorstr = get(get(gcf,'currentobject'),'String');
        nerrorstr = nerrorstr(find(nerrorstr~=' '));
        tmp = str2double(nerrorstr);
        if tmp > 0 & max(size(tmp)) == 1 & floor(tmp)==ceil(tmp)
            ISREADY = gguivar('ISREADY',toolhan);
            ISREADY(3,1) = tmp;
            sguivar('NERROR',tmp,'ISREADY',ISREADY,toolhan);
            out = rready(toolhan,ISREADY);
            if out == 1
                dk_able([1;2;3;4;5],[3 1 1 1 1],toolhan);
            end
        else
            set(get(gcf,'currentobject'),'String','');
            sguivar('NERROR',[],toolhan);
        end
    elseif in2==2
        ndiststr = get(get(gcf,'currentobject'),'String');
        ndiststr = ndiststr(find(ndiststr~=' '));
        tmp = str2double(ndiststr);
        if tmp > 0 & max(size(tmp)) == 1 & floor(tmp)==ceil(tmp)
            ISREADY = gguivar('ISREADY',toolhan);
            ISREADY(3,2) = tmp;
            sguivar('NDIST',tmp,'ISREADY',ISREADY,toolhan);
            out = rready(toolhan,ISREADY);
            if out == 1
                dk_able([1;2;3;4;5],[3 1 1 1 1],toolhan);
            end
        else
            set(get(gcf,'currentobject'),'String','');
            sguivar('NDIST',[],toolhan);
        end
    else
        disp('Warning: Message not found inside DEDIM')
    end
 elseif strcmp(in,'seteddim')
    in2 = in2(:);
    if length(in2)==2
        if all(in2>0) & all(floor(in2)==ceil(in2))
            [ISREADY,DEFRAME] = gguivar('ISREADY','DEFRAME',toolhan);
            parmwin('setvalues','nwd',DEFRAME,str2mat(num2str(in2(1)),num2str(in2(2))));
            ISREADY(3,:) = in2';
            sguivar('NERROR',in2(1),'NDIST',in2(2),'ISREADY',ISREADY,toolhan);
            out = rready(toolhan,ISREADY);
            if out==1
                dk_able([1;2;3;4;5],[3;1;1;1;1],toolhan);
            end
        else
        end
    else
    end
 elseif strcmp(in,'setyudim')
    in2 = in2(:);
    if length(in2)==2
        if all(in2>0) & all(floor(in2)==ceil(in2))
            [ISREADY,YUFRAME] = gguivar('ISREADY','YUFRAME',toolhan);
            parmwin('setvalues','nwd',YUFRAME,str2mat(num2str(in2(1)),num2str(in2(2))));
            ISREADY(2,:) = in2';
            sguivar('NMEAS',in2(1),'NCNTRL',in2(2),'ISREADY',ISREADY,toolhan);
            out = rready(toolhan,ISREADY);
            if out==1
                dk_able([1;2;3;4;5],[3;1;1;1;1],toolhan);
            end
        else
        end
    else
    end
 elseif strcmp(in,'setunc')
    [TMP,SUMESSAGE] = gguivar('TMP','SUMESSAGE',toolhan);
    [NUNCBLK,dim] = size(TMP);
    if (dim==2 | dim == 3) & ~isstr(TMP)
        dkitgui(toolhan,'setuncdim',0,NUNCBLK);  % table is now created
        BLKTABLE = gguivar('BLKTABLE',toolhan);
        tabed(BLKTABLE,'newintdata',round(TMP(:,1:2)))
        if dim==3
            tabed(BLKTABLE,'newnumdata',abs(TMP(:,3)),[(1:NUNCBLK)' 3*ones(NUNCBLK,1)]);
        end
        tabed(BLKTABLE,'update');
        tabed(BLKTABLE,'setrf');
        dkitgui(toolhan,'blkdone');
    else
        set(SUMESSAGE,'string','Error in Loading Uncertainty Structure');
    end
 elseif strcmp(in,'setuncdim')
    blksynwidth = 2;
    if in2==1   % person typed it
        fpos = in3;
        uncblkstr = get(get(gcf,'currentobject'),'String');
	if isempty(uncblkstr)
		tmp = [];
	else
        	uncblkstr = uncblkstr(find(uncblkstr~=' '));
        	tmp = str2double(uncblkstr);
	end
    else
        BLK_HAN = gguivar('BLK_HAN',toolhan);
        fpos = get(BLK_HAN,'position');
        tmp = in3;
        parmwin('setvalues','nwd',BLK_HAN,int2str(tmp));
    end
    % position of frame is in FPOS, NBLK = tmp
    if tmp > 0 & max(size(tmp)) == 1 & floor(tmp) == ceil(tmp)
        [NUNCBLK,ORIGWINPOS,SETUPWIN] = ...
            gguivar('NUNCBLK','ORIGWINPOS','SETUPWIN',toolhan);
        if ~strcmp(get(SETUPWIN,'units'),'pixels')
            set(SETUPWIN,'units','pixels');
        end
        newwinpos = get(SETUPWIN,'position');
        if ~isempty(NUNCBLK)
            [UNCBLK,UNCBLKFAC,BLKTABLE] = gguivar('UNCBLK','UNCBLKFAC','BLKTABLE',toolhan);
            tabed(BLKTABLE,'delete');
            sguivar('DELTAMOD',1,'BLKTABLE',[],toolhan);
            if tmp>NUNCBLK
                UNCBLK = [UNCBLK;nan*ones(tmp-NUNCBLK,blksynwidth)];
                UNCBLKFAC = [UNCBLKFAC;ones(tmp-NUNCBLK,1)];
            else
                UNCBLK = nan*ones(tmp,blksynwidth);
                UNCBLKFAC = ones(tmp,1);
            end
        else
            UNCBLK = nan*ones(tmp,blksynwidth);
            UNCBLKFAC = ones(tmp,1);
            sguivar('DELTAMOD',0,toolhan);
        end
        ISREADY = gguivar('ISREADY',toolhan);
        ISREADY(4,1) = tmp;
        NUNCBLK = tmp;
        sguivar('ISREADY',ISREADY,'UNCBLK',UNCBLK,...
            'UNCBLKFAC',UNCBLKFAC,'NUNCBLK',NUNCBLK,'NUM_D',NUNCBLK,'NBLK',NUNCBLK+1,toolhan);
        rready(toolhan);

        rowallow = 2;
        titlestring = '';       %       'Block Structure';
        edpos = tabed([],'dimquery',titlestring,[' # ';'Row';'Col';'Fac'],...
                3,rowallow,tmp,0,0,gcf,[],[],[],ORIGWINPOS);
        gap = 0;
        [BLKTABLE] = tabed([],'create',titlestring,[' # ';'Row';'Col';'Fac'],...
          3,rowallow,tmp,...
          newwinpos(3)*(fpos(1)+fpos(3))-edpos(3)+1,...
          newwinpos(4)*fpos(2)-gap,...
          SETUPWIN,gguivar('ET_BGC',toolhan),...
          '',['dkitgui(' thstr ',''blkdone'')'],ORIGWINPOS);
        tabed(BLKTABLE,'normalize');
        facstr = num2str(UNCBLKFAC(1));
        for i=2:NUNCBLK
            facstr = str2mat(facstr,num2str(UNCBLKFAC(i)));
        end
        facindex = [(1:NUNCBLK)' 3*ones(NUNCBLK,1)];
        tabed(BLKTABLE,'newdata',facstr,facindex);
        tabed(BLKTABLE,'update');
        sguivar('BLKTABLE',BLKTABLE,toolhan);
    else
        NUNCBLK = [];
        UNCBLK = [];
        UNCBLKFAC = [];
        set(get(gcf,'currentobject'),'String','');
    end
 elseif strcmp(in,'blkdone')
    [NUNCBLK,BLKTABLE,SUMESSAGE] = gguivar('NUNCBLK','BLKTABLE','SUMESSAGE',toolhan);
    UNCBLK = zeros(NUNCBLK,2);
    UNCBLKFAC = zeros(NUNCBLK,1);
    data = tabed(BLKTABLE,'getnumdata');
    go = 1;
    i = 1;
    while go==1 & i<=NUNCBLK
        val = data(i,1);
        if all(floor(val)==ceil(val)) & val~=0
            UNCBLK(i,1) = val;
        else
            set(SUMESSAGE,'string',...
                ['Error in Uncertainty Block ' int2str(i) ',1']);
            go = 0;
        end
        val = data(i,2);
        if all(floor(val)==ceil(val)) & val>=0
            UNCBLK(i,2) = val;
        else
            set(SUMESSAGE,'string',...
                ['Error in Uncertainty Block ' int2str(i) ',2']);
            go = 0;
        end
        val = data(i,3);
        if val>=0.1 & val<=10
            UNCBLKFAC(i,1) = val;
        else
            set(SUMESSAGE,'string',...
                ['Error in Uncertainty Factor ' int2str(i)]);
            go = 0;
        end
        i = i + 1;
    end
    if go==0
            sguivar('READY',0,toolhan);
    else
        set(SUMESSAGE,'string',''); drawnow;
        sguivar('UNCBLK',UNCBLK,'UNCBLKFAC',UNCBLKFAC,toolhan);
        rready(toolhan);
        [READY,CITER] = gguivar('READY','CITER',toolhan);
        if READY==1 & CITER==4
            dk_able(4,2,toolhan)
            if any(UNCBLK(:,1)<0) | any(UNCBLK(:,2)==0)
                dk_able([5],[1],toolhan);
            else
                dk_able(5,3,toolhan);
                if INUM > 1
                    disp('HOW DID WE GET HERE 1') % XXXX
                    % dk_able(1,2,toolhan);
                end
            end
        elseif READY==1 & CITER==3 & any(UNCBLK(:,1)<0)
            % just ran FRSP, now in the midst of changing some blocks to real
            %   for analysis purposes
            % dk_able(1,1,toolhan); DOESN't appear that we want to execute this
        elseif READY==1 & CITER==3 & all(UNCBLK(:,1)>0) & INUM>1
            disp('HOW DID WE GET HERE 3') % XXXX
            % dk_able(1,2,toolhan);
        end
    end
 elseif strcmp(in,'disableyued')
    [YUEDIT] = gguivar('YUEDIT',toolhan);
    set(YUEDIT,'enable','off');
 elseif strcmp(in,'enableyued')
    [YUEDIT] = gguivar('YUEDIT',toolhan);
    set(YUEDIT,'enable','on');
 elseif strcmp(in,'disableeded')
    [EDEDIT] = gguivar('EDEDIT',toolhan);
    set(EDEDIT,'enable','off');
 elseif strcmp(in,'enableeded')
    [EDEDIT] = gguivar('EDEDIT',toolhan);
    set(EDEDIT,'enable','on');
 elseif strcmp(in,'disableblked')
    [BLK_HAN,BLKTABLE] = gguivar('BLK_HAN','BLKTABLE',toolhan);
    tabed(BLKTABLE,'disablecol',[1 2]);
    bd = get(BLK_HAN,'userdata');
    set(bd(1),'enable','off');
 elseif strcmp(in,'enableblked')
    [BLK_HAN,BLKTABLE] = gguivar('BLK_HAN','BLKTABLE',toolhan);
    tabed(BLKTABLE,'enablecol',[1 2]);
    bd = get(BLK_HAN,'userdata');
    set(bd(1),'enable','on');
 elseif strcmp(in,'choosey')
    co = get(gcf,'currentobject');
    sguivar('YCHOICE_STR',get(co,'string'),toolhan);
 elseif strcmp(in,'chooseu')
    co = get(gcf,'currentobject');
    sguivar('UCHOICE_STR',get(co,'string'),toolhan);
 elseif strcmp(in,'namecb')
    allfigs = get(0,'children');
    co = get(gcf,'currentobject');
    WINDOWNAME = deblank(get(co,'string'));
    sguivar('UDNAME',WINDOWNAME,toolhan);
    if ~isempty(WINDOWNAME)
        WINDOWNAME = [' - ' WINDOWNAME];
    end
    [FR_WIN,ITWIN,SETUPWIN,PARMWIN,PLT_WIN] = ...
        gguivar('FR_WIN','ITWIN','SETUPWIN','PARMWIN','PLT_WIN',toolhan);
    WINDOWPRE = gguivar('WINDOWPRE',toolhan);
    set(PARMWIN,'name',[WINDOWPRE 'DK Iteration Parameters' WINDOWNAME]);
    set(ITWIN,'name',[WINDOWPRE 'DK Iteration' WINDOWNAME]);
    set(SETUPWIN,'name',[WINDOWPRE 'DK Iteration Setup' WINDOWNAME]);
    [mainw,subw] = findmuw(get(0,'chi'));
    dksubs = xpii(subw,ITWIN);
    loc = find(dksubs(:,2)==4);     %   FR_WIN is #4
    if isempty(loc)
        dkitgui(toolhan,'createfrqwin');
    else
        FR_WIN = dksubs(loc,1);
        set(FR_WIN,'name',[WINDOWPRE 'DK Iteration Frequency Response' WINDOWNAME]);
    end
    loc = find(dksubs(:,2)==3);     %   PLT_WIN is #3
    if isempty(loc)
        dkitgui(toolhan,'createpltwin');
    else
        PLT_WIN = dksubs(loc,1);
        set(PLT_WIN,'name',[WINDOWPRE 'DK Iteration Scaling' WINDOWNAME]);
    end
 elseif strcmp(in,'sufcb')
    co = get(gcf,'currentobject');
    val = get(co,'string');
    sp = find(val~=' ');
    if length(sp) < length(val)
        val = val(sp);
        set(co,'string',val);
    end
    sguivar('SUFFIXNAME',val,toolhan);
 elseif strcmp(in,'savecb')
    EXPORTVALUE = gguivar('EXPORTVALUE',toolhan);
    EXPORTVALUE(in2) = ~EXPORTVALUE(in2);
    sguivar('EXPORTVALUE',EXPORTVALUE,toolhan);
 elseif strcmp(in,'showiter')
    ITWIN = gguivar('ITWIN',toolhan);
    figure(ITWIN)
 elseif strcmp(in,'hideiter')
    ITWIN = gguivar('ITWIN',toolhan);
    set(ITWIN,'visible','off')
 elseif strcmp(in,'showsetup1')
    [BUTSTAT,SETUPWIN,MAINPB] = gguivar('BUTSTAT','SETUPWIN','MAINPB',toolhan);
    set(MAINPB(1),'string','Control Design','enable','off',...
    'callback',...
    ['dkitgui(' thstr ',''refreshp'');dkitgui(' thstr ',''hinfsyn'');' ...
    'muexport;dkitgui(' thstr ',''refreshk'');gdataevl']);
    figure(SETUPWIN)
    BUTSTAT(1) = 1;
    sguivar('BUTSTAT',BUTSTAT,'SETUPFLAG',0,toolhan);
    set(gguivar('SHOWSETUPHAN',toolhan),'enable','on');
 elseif strcmp(in,'showsetup')
    [SETUPWIN] = gguivar('SETUPWIN',toolhan);
    figure(SETUPWIN)
 elseif strcmp(in,'hidesetup')
    SETUPWIN = gguivar('SETUPWIN',toolhan);
    set(SETUPWIN,'visible','off')
 elseif strcmp(in,'showplot')
    ITWIN = gguivar('ITWIN',toolhan);
    [mainw,subw] = findmuw(get(0,'chi'));
    dksubs = xpii(subw,ITWIN);
    loc = find(dksubs(:,2)==4);     %   FR_WIN is #4
    if isempty(loc)
        FR_WIN = gguivar('FR_WIN',toolhan);
        dkitgui(toolhan,'createfrqwin');
    else
        FR_WIN = dksubs(loc,1);
    end
    figure(FR_WIN)
 elseif strcmp(in,'hideplot')
    ITWIN = gguivar('ITWIN',toolhan);
    [mainw,subw] = findmuw(get(0,'chi'));
    dksubs = xpii(subw,ITWIN);
    loc = find(dksubs(:,2)==4);     %   FR_WIN is #4
    if isempty(loc)
        dkitgui(toolhan,'createfrqwin');
        FR_WIN = gguivar('FR_WIN',toolhan);
    else
        WINDOWPRE = gguivar('WINDOWPRE',toolhan);
        WINDOWNAME = gguivar('WINDOWNAME',toolhan);
        FR_WIN = dksubs(loc,1);
        set(FR_WIN,'name',...
          [WINDOWPRE 'DK Iteration Frequency Response' WINDOWNAME]);
    end
    set(FR_WIN,'visible','off')
 elseif strcmp(in,'showscl')
    ITWIN = gguivar('ITWIN',toolhan);
    [mainw,subw] = findmuw(get(0,'chi'));
    dksubs = xpii(subw,ITWIN);
    loc = find(dksubs(:,2)==3);     %   PLT_WIN is #3
    if isempty(loc)
        dkitgui(toolhan,'createpltwin');
        PLT_WIN = gguivar('PLT_WIN',toolhan);
    else
        PLT_WIN = dksubs(loc,1);
    end
    figure(PLT_WIN)
 elseif strcmp(in,'hidescl')
    PLT_WIN = gguivar('PLT_WIN',toolhan);
    set(PLT_WIN,'visible','off')
 elseif strcmp(in,'showparm')
    PARMWIN = gguivar('PARMWIN',toolhan);
    figure(PARMWIN)
 elseif strcmp(in,'hideparm')
    PARMWIN = gguivar('PARMWIN',toolhan);
    set(PARMWIN,'visible','off')
 elseif strcmp(in,'acceptlinksetup')
%       in2=nameofvar, in3=handle_of_dkit, in4=callback_handle,in5=gonumeber, in6=on/off,
%       'CONT',handle_of_dkit,handle_of_sim, 'CONTROLLER'_go_number,'on'
    OGLINK = gguivar('OGLINK',in3,toolhan);
    OGLINK = mkmulink(OGLINK,in2,in3,in4,in5,in6);
    sguivar('OGLINK',OGLINK,in3);
 elseif strcmp(in,'acceptlinkdata') % in2=handle_of_dkit, in3=returnstring, in4=data
    eval(['sguivar(''' returnstring ''',in4,in2);']);
 elseif strcmp(in,'restart')
    [ISREADY,BLKSYN,MESSAGE,RESTARTHAN,FR_WIN,PARMWIN_HANS] = ...
        gguivar('ISREADY','BLKSYN','MESSAGE','RESTARTHAN','FR_WIN','PARMWIN_HANS',toolhan);
    set(FR_WIN,'visible','off');
    [nr,nc] = size(ISREADY);
    outputs = ISREADY(1,1);
    inputs = ISREADY(1,2);
    meas = ISREADY(2,1);
    cont = ISREADY(2,2);
    nblk = ISREADY(3,1);
    omflag = ISREADY(3,2);
    set(MESSAGE,'string','Restarting Mu-Synthesis Problem...')
    drawnow
    dk_able([1 2 3 4 5],[3 1 1 1 1],toolhan);
    [OLIC,DKSUM_HAN,UCHOOSE,YCHOOSE,DFITTAB] = ...
                gguivar('OLIC','DKSUM_HAN','UCHOOSE','YCHOOSE','DFITTAB',toolhan);
    [UPDOWN,HPN,AIB] = ...
    gguivar('UPDOWN','HINFPARMNAME','AISTOPBUT',toolhan);
    [GLOW,GHIGH,GTOL,GPERCTOL,HD] =  ...
        gguivar('GLOW','GHIGH','GTOL','GPERCTOL','HDEFAULTS',toolhan);
    if ~isempty(DFITTAB)
        scrolltb('delete',DFITTAB);
        delete(UPDOWN)
        sguivar('DFITTAB',[],toolhan);
    end
    ud = get(UCHOOSE,'userdata');
    yd = get(YCHOOSE,'userdata');
    set(ud(2),'enable','on');
    set(ud(1),'string',['Controls Utilized: (1-' int2str(cont) ')']);
    set(yd(2),'enable','on');
    set(yd(1),'string',['Measurements Utilized: (1-' int2str(meas) ')']);
    sguivar('UCHOICE',1:cont,'YCHOICE',1:meas,toolhan);
    DISPLAY = inf*ones(5,1);
    DISPLAY(1,1) = 1;
    DISPLAY(2,1) = 0;
    sguivar('ABSORBED',1,'SOLIC',OLIC,'DISPLAY',DISPLAY,'CITER',0,toolhan);
    sguivar('DSYSL',eye(outputs-meas),'DSYSR',eye(inputs-cont),'INUM',1,toolhan);
    scrolltb('newdata',DKSUM_HAN,DISPLAY);
    scrolltb('setcnt',DKSUM_HAN,1);
    scrolltb('refill',DKSUM_HAN);
    set(MESSAGE,'string','')
    pv = [GLOW;GHIGH;GTOL;GPERCTOL;EPR;EPP];
    dkitgui(toolhan,'eraseusrhinfp',pv);
    dkitgui(toolhan,'modhinfp',pv,HD(pv,1));
    set(RESTARTHAN,'enable','off');
    sguivar('STARTED',0,toolhan);
    set(AIB,'visible','off')
    dkitgui(toolhan,'enableblked')
    dkitgui(toolhan,'enableyued')
    dkitgui(toolhan,'enableeded')
    dataent('setbenable',gguivar('EXTRALOAD',toolhan),[1;2;3]);
 elseif strcmp(in,'quit')
    allfigs = get(0,'children');
    [FR_WIN,ITWIN,SETUPWIN,PARMWIN,PLT_WIN] = ...
        gguivar('FR_WIN','ITWIN','SETUPWIN','PARMWIN','PLT_WIN',toolhan);
    allfigs = [FR_WIN;ITWIN;SETUPWIN;PARMWIN;PLT_WIN];
    mkdragtx('destroy',allfigs);
    [mainw,subw] = findmuw(get(0,'chi'));
    dksubs = xpii(subw,ITWIN);
    if ~isempty(dksubs)
        delete(dksubs(:,1))
    end
    delete(ITWIN)
 elseif strcmp(in,'setup')  % first attempt to load from command line
    mainfig = dkitgui([],'create');
    olicstring = in2;
    uncblk = in3;
    perfblk = in4;
    yublk = in5;
    omega = in6;
    BLK_HAN = gguivar('BLK_HAN',mainfig);
    eh = get(BLK_HAN,'userdata');
    set(eh(1),'string',int2str(size(uncblk,1)));
    set(get(eh(1),'parent'),'currentobject',eh(1));
    set(0,'currentfigure',get(eh(1),'parent'));
    dkparmcb(toolhan,'uncdim')
 elseif strcmp(in,'autorefk')
    AUTORK = gguivar('AUTORK',toolhan);
    if strcmp(get(AUTORK,'checked'),'on')
        set(AUTORK,'checked','off')
    else
        set(AUTORK,'checked','on');
    end
 elseif strcmp(in,'refreshk')
    [AUTORK,OLICCONTLOAD,STEPS] = ...
		gguivar('AUTORK','OLICCONTLOAD','STEPS',toolhan);
    stdata = get(OLICCONTLOAD,'userdata');
    fh = xpii(stdata,1);
    EDITHANDLES = colbut(fh,'gethan','e',1,2);
    if strcmp(get(AUTORK,'checked'),'on')
        sguivar('EDITHANDLES',EDITHANDLES,'EDITRESULTS','CONT',...
            'RESTOOLHAN',toolhan,toolhan);
        sguivar('SUCCESSCB',['set(gguivar(''MESSAGE'',' thstr '),''string'','' '');dkitgui(' thstr ',''getcont'');'],toolhan);
	if STEPS==0
        	sguivar('ERRORCB',...
		  ['sguivar(''CONT'',[],' thstr ');dkitgui(' ...
		  thstr ',''getcont'');'],toolhan);
	else
        	sguivar('ERRORCB',...
		  ['sguivar(''CONT'',[],' thstr ');dkitgui(' ...
		  thstr ',''getcont'');sguivar(''INTERUPT'',1,' thstr ');'],...
			toolhan);
	end
        set(gguivar('MESSAGE',toolhan),'string','Auto Refreshing K');
        drawnow
    else
        sguivar('EDITHANDLES',[],toolhan);
    end
 elseif strcmp(in,'autorefp')
    AUTORP = gguivar('AUTORP',toolhan);
    if strcmp(get(AUTORP,'checked'),'on')
        set(AUTORP,'checked','off')
    else
        set(AUTORP,'checked','on');
    end
 elseif strcmp(in,'createpltwin')
    [WINDOWPRE,UDNAME,ITWIN] = gguivar('WINDOWPRE','UDNAME','ITWIN',toolhan);
    ss = get(0,'screensize');
    PLT_WIN = figure('menubar','none',...
        'pointer','watch',...
        'NumberTitle','off',...
	'CloseRequestFcn',['dkitgui(' thstr ',''hidescl'')'],...
        'Position',[0.50*ss(3) 20 0.45*ss(3) 0.8*ss(4)], ...
        'DockControls', 'off');
%        'Position',[420 20 500 780]);
    tmp = uimenu(PLT_WIN,'Label','Window');
    set(PLT_WIN,'name',[WINDOWPRE 'DK Iteration Scaling' UDNAME]);
    tmp1 = uimenu(tmp,'Label','Hide Scalings',...
        'callback',['dkitgui(' thstr ',''hidescl'')']);
    tmp2 = uimenu(tmp,'Label','Iteration','separator','on',...
        'callback',['dkitgui(' thstr ',''showiter'')']);
    tmp3 = uimenu(tmp,'Label','Setup','enable','on',...
        'callback',['dkitgui(' thstr ',''showsetup'')']);
    tmp4 = uimenu(tmp,'Label','Mu/SVD Plot','callback',['dkitgui(' thstr ',''showplot'')']);
    tmp5 = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);
    ud = get(ITWIN,'userdata');
    set(PLT_WIN,'userdata',[ud(1:length(ud)-4);abs('SUB')';ITWIN+.03]);
    vskip = 0.08;
    ah = (1-4*vskip)/3;
    aw = 0.8;
%       TOP, norm/mubnds
    bn = axes('Position',[.1 3*vskip+2*ah aw ah],'Fontsize',8);
    title = get(bn,'title');
    set(title,'fontsize',8);
    xx = get(bn,'xlabel');
    set(xx,'fontsize',8);
    yy = get(bn,'ylabel');
    set(yy,'fontsize',8);
%       MIDDLE, rational/fits/data
    rf = axes('Position',[.1 2*vskip+ah aw ah],'Fontsize',8);
    title = get(rf,'title');
    set(title,'fontsize',8);
    yy = get(rf,'ylabel');
    set(yy,'fontsize',8);
%       BOTTOM: sensitivity
    we = axes('Position',[.1 vskip aw ah],'Fontsize',8);
    title = get(we,'title');
    set(title,'fontsize',8);
    xx = get(we,'xlabel');
    set(xx,'fontsize',8);
    yy = get(we,'ylabel');
    set(yy,'fontsize',8);
    FITPLOTS = [rf;bn;we];
    sguivar('FITPLOTS',FITPLOTS,'PLT_WIN',PLT_WIN,toolhan);
    set(PLT_WIN,'handlevis','call');
 elseif strcmp(in,'createfrqwin')
    [WINDOWPRE,UDNAME,ITWIN] = gguivar('WINDOWPRE','UDNAME','ITWIN',toolhan);
    FR_WIN = figure('visible','off',...
        'pointer','watch',...
        'menubar','none',...
        'numbertitle','off',...
	'CloseRequestFcn',['dkitgui(' thstr ',''hideplot'')'],...
        'Position',[20 20 400 400/1.6], ...
        'DockControls', 'off');
    tmp = uimenu(FR_WIN,'Label','Window');
    set(FR_WIN,'name',[WINDOWPRE 'DK Iteration Frequency Response' UDNAME]);
    tmp1 = uimenu(tmp,'Label','Hide Mu/SVD Plot',...
        'callback',['dkitgui(' thstr ',''hideplot'')']);
    tmp2 = uimenu(tmp,'Label','Iteration','separator','on',...
        'callback',['dkitgui(' thstr ',''showiter'')']);
    tmp3 = uimenu(tmp,'Label','Setup','enable','on',...
        'callback',['dkitgui(' thstr ',''showsetup'')']);
    tmp4 = uimenu(tmp,'Label','Scalings','callback',['dkitgui(' thstr ',''showscl'')']);
    tmp5 = uimenu(tmp,'Label','Parameter','callback',['dkitgui(' thstr ',''showparm'')']);
    ud = get(ITWIN,'userdata');
    set(FR_WIN,'userdata',[ud(1:length(ud)-4);abs('SUB')';ITWIN+.04]);
    sguivar('FR_WIN',FR_WIN,toolhan)
    set(FR_WIN,'handlevis','call');
 elseif strcmp(in,'refreshp')
    [AUTORP,OLICCONTLOAD] = gguivar('AUTORP','OLICCONTLOAD',toolhan);
    stdata = get(OLICCONTLOAD,'userdata');
    fh = xpii(stdata,1);
    EDITHANDLES = colbut(fh,'gethan','e',1,1);
    if strcmp(get(AUTORP,'checked'),'on')
        sguivar('EDITHANDLES',EDITHANDLES,toolhan);
        sguivar('EDITRESULTS','OLIC',toolhan);
        sguivar('RESTOOLHAN',toolhan,toolhan);
        sguivar('SUCCESSCB',...
    ['set(gguivar(''MESSAGE'',' thstr '),''string'','' '');dkitgui(' thstr ',''getolic'');'],toolhan);
        sguivar('ERRORCB',['sguivar(''OLIC'',[]);dkitgui(' thstr ',''getolic'');'],toolhan);
        set(gguivar('MESSAGE',toolhan),'string','Auto Refreshing Olic');
        drawnow
    else
        sguivar('EDITHANDLES',[],toolhan);
    end
 elseif strcmp(in,'modhinfp')
    [HDEFAULTS,PARMWIN_HANS,HINFPARMNAME] = ...
       gguivar('HDEFAULTS','PARMWIN_HANS','HINFPARMNAME',toolhan);
    hinfsyn_tit_f = get(PARMWIN_HANS(1,1),'userdata');
    alltxhans = get(hinfsyn_tit_f(1),'userdata');
    %    hstr = get(alltxhans(2,1),'string');
    for i=1:length(in2)
    loc = in2(i);
    val = in3(i);
        set(alltxhans(loc,2),'string',...
        [deblank(HINFPARMNAME(loc,:)) ' (' agv2str(val) ')']);
        HDEFAULTS(loc,2) = val; % 2nd column is what is used.
     end
     sguivar('HDEFAULTS',HDEFAULTS,toolhan);
 elseif strcmp(in,'eraseusrhinfp')
    [PARMWIN_HANS] = gguivar('PARMWIN_HANS',toolhan);
    hinfsyn_tit_f = get(PARMWIN_HANS(1,1),'userdata');
    alltxhans = get(hinfsyn_tit_f(1),'userdata');
    for i=1:length(in2)
    loc = in2(i);
        set(alltxhans(loc,1),'string','');
     end
 else
    disp('Message not found')
 end

% if ~strcmp(in,'create') & ~strcmp(in,'quit')
%    delrunf;
% end

% if ~strcmp(in,'quit')
%    sguivar('CBLOG',cblog);
%    logstring = 'dkitgui(';
%    cnt = 1;
%    xval = xpii(cblog,cnt);
%    while ~isempty(xval)
%        if isstr(xval)
%            logstring = [logstring '''' xval ''','];
%        elseif all(all(floor(xval)==ceil(xval)))
%            logstring = [logstring int2str(xval) ','];
%        else
%            logstring = [logstring num2str(xval) ','];
%        end
%        cnt = cnt + 1;
%        xval = xpii(cblog,cnt);
%    end
%    logstring = [logstring(1:length(logstring)-1) ')'];
% end

% need to differentiate from USER initiated callbacks
%  and automatic callbacks which are generated by the
%  program itself.  Easy way - have all user-generated
%  callbacks have 'user' as last argument.  Also, need
%  to have all necessary info in the callback call.
%
% other problems will also arise when it is radiobuttons
%  or checkboxes, as MATLAB executes automatic 'value' updating
%  and this is not TYPICALLY extracted in the callbacks.
