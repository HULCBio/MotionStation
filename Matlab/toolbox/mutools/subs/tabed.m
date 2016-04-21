%function [mainh,evhan,allhan,pbhan] = tabed(in,titlename,colnames,...
%        ecols,maxnumrows,nrows,ulcx,ulcy,winhan,et_bgc,cbfunc)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.9.2.3 $

function [out1,out2,out3,out4] = tabed(toolhan,message,in1,in2,in3,in4,in5,in6,...
    in7,in8,in9,in10,in11,in12)

 if isempty(toolhan)
    co = get(gcf,'currentobject');
    if ~isempty(co)
        toolhan = get(co,'userdata'); % incorrect with slider, but that gets done
    end
 end

 if strcmp(message,'create')
    titlename = in1;
    colnames = in2;
    ecols = in3;
    maxnumrows = in4;
    nrows = in5;
    ulcx = in6;
    ulcy = in7;
    winhan = in8;
    et_bgc = in9;
    cbfunc = in10;
    filledcb = in11;
    if ~strcmp(get(winhan,'units'),'pixels')
        set(winhan,'units','pixels');
    end
    newwinpos = get(winhan,'position');
    origwinpos = in12;
    wf = newwinpos(3)/origwinpos(3);
    hf = newwinpos(4)/origwinpos(4);
    [numnames,dum] = size(colnames);
    tgap = 4*hf;
    ngap = 2*hf;
    bw = 35*wf;
    iw = 25*wf;
    pbw = 23*wf;
    pbh = 35*hf;
    th = 1*hf;
    nh = 17*hf;
    bh = 19*hf;
    boxgap = 6*wf;
    boygap = 6*hf;
    bxgap = 4*wf;
    bygap = 3*hf;
    igap = 8*wf;
    rxgap = 6*wf;
    bocolor = [.0 0.5 0.5];

    if nrows > maxnumrows
        tw = iw + igap + ecols*bw + (ecols-1)*bxgap + rxgap + pbw;
        figw = 2*boxgap + tw;
        figh = 2*boygap + maxnumrows*bh + (maxnumrows-1)*bygap + ...
            ngap + nh + tgap + th;
        xstart = ulcx;
        ystart = ulcy - figh;
        mainh = uicontrol(winhan,...
            'Style','frame',...
            'Position',[xstart ystart figw figh]);
        evhan = mainh;
        xloc = ulcx + boxgap;
        yloc = ulcy - boygap - th;
    if th>0
            tithan = uicontrol(winhan,...
                'Style','text',...
                'String',titlename,...
                'Position',[xloc yloc tw th]);
            evhan = [evhan tithan];
    end
        xstart = ulcx + boxgap;
        ystart = ulcy - boygap - th - tgap - nh;
        xloc = xstart;
        yloc = ystart;
        for k=1:numnames
            nw = bw;
            mgap = bxgap;
            if k==1
                nw = iw;
                mgap = igap;
            end
            tmp = uicontrol(winhan,...
                'Style','text',...
                'String',deblank(colnames(k,:)),...
                'Position',[xloc yloc nw nh]);
            evhan = [evhan tmp];
            xloc = xloc + nw + mgap;
        end

        xstart = ulcx + boxgap;
        ystart = ulcy - boygap - th - tgap - nh - ngap - bh;

        allhan = zeros(maxnumrows,1+ecols);
        xloc = xstart;
        colhan = [];
        yloc = ystart;
        for k=1:maxnumrows
            view = uicontrol(winhan,...
                'Style','text',...
                'String',int2str(k),...
                'Position',[xloc yloc iw bh]);
            evhan = [evhan view];
            colhan = [colhan;view];
            yloc = yloc - bh - bygap;
        end
        allhan(:,1) = colhan;
        xloc = xstart + iw + igap;
        for j=1:ecols
            colhan = [];
            yloc = ystart;
            for k=1:maxnumrows
                cb = mdxpii(cbfunc,1,k,j);
                view = uicontrol(winhan,...
                    'Style','edit',...
                    'backgroundcolor',et_bgc,...
                    'Userdata',mainh,...
                    'String','',...
                    'Callback',['tabed([],''edit'',' int2str(k) ',' int2str(j) ');' cb],...
                    'HorizontalAlignment','right',...
                    'Position',[xloc yloc bw bh]);
                evhan = [evhan view];
                set(view,'HorizontalAlignment','center');
                colhan = [colhan;view];
                yloc = yloc - bh - bygap;
            end
            xloc = xloc + bw + bxgap;
            allhan(:,j+1) = colhan;
        end
        ystart = ulcy - figh + boygap;
        xstart = ulcx + boxgap + iw + igap + ecols*bw +...
            (ecols-1)*bxgap + rxgap;

        xloc = xstart;
        yloc = ystart;
        sht = ulcy - boygap - th - tgap - nh - ngap - yloc;
        pos = [xloc yloc pbw sht];
        slh = ourslid(0,'create',pos,[nrows;maxnumrows;1],'tabed([],''slidermotion'');',mainh);
        evhan = [evhan slh];
    else
        slh = [];
        tw = iw + igap + ecols*bw + (ecols-1)*bxgap;
        figw = 2*boxgap + tw;
        figh = 2*boygap + nrows*bh + (nrows-1)*bygap + ...
            ngap + nh + tgap + th;


        xstart = ulcx;
        ystart = ulcy - figh;

        % get(mainh,'Userdata') has all of the important data in PIM
        mainh = uicontrol(winhan,...
            'Style','frame',...
            'Position',[xstart ystart figw figh]);
        evhan = mainh;

        xloc = ulcx + boxgap;
        yloc = ulcy - boygap - th;
    if th>0
            tithan = uicontrol(winhan,...
                'Style','text',...
                'String',titlename,...
                'Position',[xloc yloc tw th]);
            evhan = [evhan tithan];
    end

        xstart = ulcx + boxgap;
        ystart = ulcy - boygap - th - tgap - nh;

        xloc = xstart;
        yloc = ystart;
        for k=1:numnames
            nw = bw;
            mgap = bxgap;
            if k==1
                nw = iw;
                mgap = igap;
            end
            tmp = uicontrol(winhan,...
                'Style','text',...
                'String',deblank(colnames(k,:)),...
                'Position',[xloc yloc nw nh]);
            evhan = [evhan tmp];
            xloc = xloc + nw + mgap;
        end

        xstart = ulcx + boxgap;
        ystart = ulcy - boygap - th - tgap - nh - ngap - bh;

        allhan = zeros(nrows,1+ecols);
        xloc = xstart;
        colhan = [];
        yloc = ystart;
        for k=1:nrows
            view = uicontrol(winhan,...
                'Style','text',...
                'String',int2str(k),...
                'Position',[xloc yloc iw bh]);
            evhan = [evhan view];
            colhan = [colhan;view];
            yloc = yloc - bh - bygap;
        end
        allhan(:,1) = colhan;
        xloc = xstart + iw + igap;
        for j=1:ecols
            colhan = [];
            yloc = ystart;
            for k=1:nrows
                cb = mdxpii(cbfunc,1,k,j);
                view = uicontrol(winhan,...
                    'Style','edit',...
                    'backgroundcolor',et_bgc,...
                    'Userdata',mainh,...
                    'String','',...
                    'Callback',['tabed([],''edit'',' int2str(k) ',' int2str(j) ');' cb],...
                    'HorizontalAlignment','right',...
                    'Position',[xloc yloc bw bh]);
                evhan = [evhan view];
                set(view,'HorizontalAlignment','center');
                colhan = [colhan;view];
                yloc = yloc - bh - bygap;
            end
            xloc = xloc + bw + bxgap;
            allhan(:,j+1) = colhan;
        end
    end
    runfilled = 1;
    stdata = [];
    stdata = ipii(stdata,[],1); % PIM_1 is the matrix data
    stdata = ipii(stdata,allhan,2); % PIM_2 is the matrix of handles for boxes that scroll
    stdata = ipii(stdata,[1],3);      % PIM_3=[scroll_cnt]
    stdata = ipii(stdata,slh,4);
    stdata = ipii(stdata,[nrows ecols],5);
    stdata = ipii(stdata,nan*ones(nrows,ecols),6);
    stdata = ipii(stdata,filledcb,7);
    stdata = ipii(stdata,evhan,8);
    stdata = ipii(stdata,runfilled,9);
%    for i=1:size(allhan,1)
%        set(allhan(i,4),'string','1');
%    end
    set(mainh,'Userdata',stdata);    % Userdata of large Background is PIM
    out1 = mainh;

  elseif strcmp(message,'dimquery')
    titlename = in1;
    colnames = in2;
    ecols = in3;
    maxnumrows = in4;
    nrows = in5;
    ulcx = in6;
    ulcy = in7;
    winhan = in8;
    if ~strcmp(get(winhan,'units'),'pixels')
        set(winhan,'units','pixels');
    end
    newwinpos = get(winhan,'position');
    origwinpos = in12;
    wf = newwinpos(3)/origwinpos(3);
    hf = newwinpos(4)/origwinpos(4);
    [numnames,dum] = size(colnames);
    tgap = 4*hf;
    ngap = 2*hf;
    bw = 35*wf;
    iw = 25*wf;
    pbw = 23*wf;
    pbh = 35*hf;
    th = 1*hf;
    nh = 17*hf;
    bh = 19*hf;
    boxgap = 6*wf;
    boygap = 6*hf;
    bxgap = 4*wf;
    bygap = 3*hf;
    igap = 8*wf;
    rxgap = 6*wf;
    bocolor = [.0 0.5 0.5];

    if nrows > maxnumrows
        tw = iw + igap + ecols*bw + (ecols-1)*bxgap + rxgap + pbw;
        figw = 2*boxgap + tw;
        figh = 2*boygap + maxnumrows*bh + (maxnumrows-1)*bygap + ...
            ngap + nh + tgap + th;
    else
        tw = iw + igap + ecols*bw + (ecols-1)*bxgap;
        figw = 2*boxgap + tw;
        figh = 2*boygap + nrows*bh + (nrows-1)*bygap + ...
            ngap + nh + tgap + th;
    end
    out1 = [ulcx ulcy figw figh];
  elseif strcmp(message,'slidermotion')
    slidhan = get(gcf,'currentobject');
    allinfo = get(slidhan,'userdata');
    ourval  = allinfo(4);
    toolhan = allinfo(5);   % master of slider is in 5th entry
    stdata = get(toolhan,'Userdata');
    set(toolhan,'Userdata',ipii(stdata,ourval,3));
    tabed(toolhan,'update');
  elseif strcmp(message,'update')
    stdata = get(toolhan,'Userdata');
    mdata = xpii(stdata,1);
    nrnc = xpii(stdata,5);
    ehands = xpii(stdata,2);
    numerows = size(ehands,1);
    scrcnt = xpii(stdata,3);
    for i=1:min([numerows nrnc(1)])
        set(ehands(i,1),'String',int2str(scrcnt+i-1))
        for j=1:nrnc(2)
            set(ehands(i,j+1),'String',xpii(mdata,scrcnt+i-1+(j-1)*nrnc(1)));
        end
    end
elseif strcmp(message,'edit')
    rowcnt = in1;
    colcnt = in2;
    eh = get(gcf,'currentobject');
    es = get(eh,'string');
    stdata = get(toolhan,'Userdata');
    strdata = xpii(stdata,1);
    cnt = xpii(stdata,3);
    nrnc = xpii(stdata,5);
    filled = xpii(stdata,6);
    runfilled = xpii(stdata,9);
    if ~isempty(deblank(es))
        filled(cnt+rowcnt-1,colcnt) = 1;
    else
        filled(cnt+rowcnt-1,colcnt) = nan;
        es = '';
    end
    strdata = ipii(strdata,es,cnt+rowcnt-1+(colcnt-1)*nrnc(1));
    stdata = ipii(stdata,strdata,1);
    stdata = ipii(stdata,filled,6);
    set(toolhan,'userdata',stdata);
    if all(all(filled==1)) & runfilled == 1
        eval(xpii(stdata,7));
    end
elseif strcmp(message,'newnumdata')
    numdata = in1;
    index = in2;
    stdata = get(toolhan,'Userdata');
    mdata = xpii(stdata,1);
    filled = xpii(stdata,6);
    nrnc = xpii(stdata,5);
    ehands = xpii(stdata,2);
    numerows = size(ehands,1);
    scrcnt = xpii(stdata,3);
    for k=1:size(index,1)
    i = index(k,1);
    j = index(k,2);
    mdata = ipii(mdata,agv2str(numdata(k),2),i+(j-1)*nrnc(1));
    filled(i,j) = 1;
    end
    stdata = ipii(stdata,mdata,1);
    stdata = ipii(stdata,filled,6);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'newdata')
    strdata = in1;
    index = in2;
    stdata = get(toolhan,'Userdata');
    mdata = xpii(stdata,1);
    filled = xpii(stdata,6);
    nrnc = xpii(stdata,5);
    ehands = xpii(stdata,2);
    numerows = size(ehands,1);
    scrcnt = xpii(stdata,3);

    for k=1:size(index,1)
    i = index(k,1);
    j = index(k,2);
    mdata = ipii(mdata,deblank(strdata(k,:)),i+(j-1)*nrnc(1));
    filled(i,j) = 1;
    end
    stdata = ipii(stdata,mdata,1);
    stdata = ipii(stdata,filled,6);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'newintdata')
    intmat = in1;
    stdata = get(toolhan,'Userdata');
    mdata = xpii(stdata,1);
    nrnc = xpii(stdata,5);
    filled = xpii(stdata,6);
    for i=1:size(intmat,1)
    for j=1:size(intmat,2)
        mdata = ipii(mdata,int2str(intmat(i,j)),i+(j-1)*nrnc(1));
        filled(i,j) = 1;
    end
    end
    stdata = ipii(stdata,mdata,1);
    stdata = ipii(stdata,filled,6);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'getnumdata')
    stdata = get(toolhan,'Userdata');
    mdata = xpii(stdata,1);
    nrnc = xpii(stdata,5);
    filled = xpii(stdata,6);
    out1 = nan*ones(nrnc(1),nrnc(2));
    fillflg = 0;
    for i=1:nrnc(1)
    for j=1:nrnc(2)
        val = str2double(xpii(mdata,i+(j-1)*nrnc(1)));
        if ~isempty(val) & max(size(val))==1
            out1(i,j) = val;
        else
            filled(i,j) = nan;
            fillflg = 1;
        end
    end
    end
    if fillflg == 1
        stdata = ipii(stdata,filled,6);
        set(toolhan,'userdata',stdata);
    end
elseif strcmp(message,'disablecol')
    stdata = get(toolhan,'userdata');
    han = xpii(stdata,2);
    set(han(:,in1+1),'enable','off');
elseif strcmp(message,'enablecol')
    stdata = get(toolhan,'userdata');
    han = xpii(stdata,2);
    set(han(:,in1+1),'enable','on');
elseif strcmp(message,'setrf')
    stdata = get(toolhan,'userdata');
    stdata = ipii(stdata,1,9);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'unsetrf')
    stdata = get(toolhan,'userdata');
    stdata = ipii(stdata,0,9);
    set(toolhan,'userdata',stdata);
elseif strcmp(message,'delete')
    stdata = get(toolhan,'userdata');
    han = xpii(stdata,8);
    delete(han);
elseif strcmp(message,'normalize')
    stdata = get(toolhan,'userdata');
    han = xpii(stdata,8);
    set(han,'units','normalized');
else
    disp('Warning: Message not found')
end
