% function [out1,out2] = gdataent(message,in1,in2,in3,in4,in5,in6,in7,in8)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out1,out2] = gdataent(message,in1,in2,in3,in4,in5,in6,in7,in8)


if isempty(in1)
    in1 = gguivar('TEMP');
end


if strcmp(message,'create') | strcmp(message,'dimquery')
%   DATA

    % 'instruction'
    dimvec = in1;
    cboxnames = in2;
    varnames = in3; % names for SGUIVAR
    mdefault = in4;
    normax = in5;
    refreshcb = in6;
    errorcb = in7;
    fig = in8;

    et_bgc = [1 1 1];

    lx = dimvec(1);
    ly = dimvec(2);
    ytopbo = dimvec(3);
    ybotbo = dimvec(4);
    binlbo = dimvec(5);
    binrbo = dimvec(6);
    binw = dimvec(7);
    xlbo = dimvec(8);
    xrbo = dimvec(9);
    nw = dimvec(10);
    dw = dimvec(11);
    mw = dimvec(12);
    th = dimvec(13);
    vgap = dimvec(14);
    hgap = dimvec(15);
    fdimvec = [lx+binlbo+binw+binrbo;ly;ybotbo;ytopbo;xlbo;xrbo;th;nw;dw;hgap;vgap;mw];
    if strcmp(message,'create')
        fh = parmwin('create','cbwetwnet',fdimvec,cboxnames,[],...
            fig,'',et_bgc,'callbackscript',mdefault);
        hans = get(fh,'userdata');  % N x 3
        ethan = hans(:,2);


        % Make BINS
        binloc = [];
        figpos = get(fig,'position');
        win_w = figpos(3);
        win_h = figpos(4);
        binx = [lx;lx;lx+binw;lx+binw];
        biny = [ly+ybotbo+th;ly+ybotbo;ly+ybotbo;ly+ybotbo+th];
        nbinx = binx/win_w;
        nbiny = biny/win_h;
        nbinyoff = (vgap+th)/win_h;
        axes(normax);
        nvar = size(cboxnames,1);
        for i=1:nvar
            binloc = [[fig nbinx(1) nbiny(2) nbinx(3)-nbinx(1) nbiny(1)-nbiny(2) ethan(nvar-i+1)];binloc];
            line(nbinx,nbiny,'color',[0 0 0])
            nbiny = nbiny + nbinyoff;
        end
        set(normax,'xlim',[0 1],'ylim',[0 1]);
        out1 = hans(1,3);   % this becomes the main handle
        stdata = [];
        stdata = ipii(stdata,fh,1);
        stdata = ipii(stdata,varnames,2);
        stdata = ipii(stdata,refreshcb,3);
        stdata = ipii(stdata,errorcb,4);
        set(out1,'userdata',stdata);
        out2 = binloc;
    else
        fh = parmwin('dimquery','cbwetwnet',fdimvec,cboxnames,[],...
            fig,'',et_bgc,'callbackscript',mdefault);
        out1 = [lx ly fh(3)+binlbo+binw+binrbo fh(4)];
    end
elseif strcmp(message,'setet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    for i=1:length(in2)
        set(hans(in2(i),2),'string',deblank(in3(i,:)));
    end
elseif strcmp(message,'getet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    outdata = get(hans(in2(1),2),'string');
    if strcmp(in2,'all')
        in2 = 1:size(hans,1);
    end
    for i=2:length(in2)
        outdata = str2mat(outdata,get(hans(in2(i),2),'string'))
    end
    out1 = outdata;
elseif strcmp(message,'setnet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    for i=1:length(in2)
        set(hans(in2(i),3),'string',deblank(in3(i,:)));
    end
elseif strcmp(message,'getnet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    outdata = get(hans(in2(1),3),'string');
    if strcmp(in2,'all')
        in2 = 1:size(hans,1);
    end
    for i=2:length(in2)
        outdata = str2mat(outdata,get(hans(in2(i),3),'string'));
    end
    out1 = outdata;
elseif strcmp(message,'setbstat')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    for i=1:length(in2)
        set(hans(in2(i),1),'value',in3(i));
    end
elseif strcmp(message,'getbstat')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    outdata = [];
    if strcmp(in2,'all')
        in2 = 1:size(hans,1);
    end
    for i=1:length(in2)
        outdata = [outdata;get(hans(in2(i),1),'value')];
    end
    out1 = outdata;
elseif strcmp(message,'refresh')    % checks status,loads appropriate VARIABLES
                                    %   for call to gdataevl
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');

    butstat = gdataent('getbstat',mainh,'all');
    bindex  = find(butstat==1);
    EDITHANDLES = hans(bindex,2);
    varnames = xpii(stdata,2);
    EDITRESULTS = varnames(bindex,:);
    RESTOOLHAN = gcf*ones(length(bindex),1);
    scb = xpii(stdata,3);
    if isempty(scb)
        SUCCESSCB = [];
    else
        SUCCESSCB = scb(bindex,:);
    end
    ecb = xpii(stdata,4);
    if isempty(ecb)
        ERROCB = [];
    else
        ERRORCB = ecb(bindex,:);
    end
    sguivar('EDITHANDLES',EDITHANDLES,'EDITRESULTS',EDITRESULTS,...
        'RESTOOLHAN',RESTOOLHAN,'SUCCESSCB',SUCCESSCB,'ERRORCB',ERRORCB);
elseif strcmp(message,'refreshminfo')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');

    butstat = gdataent('getbstat',mainh,'all');
    bindex  = find(butstat==1);
    minfotab = gguivar('MINFOTAB');
    for i=1:length(bindex)
        if ~isnan(minfotab(i,1))
            if minfotab(i,1) == 1   % constant
                str = ['C: r' int2str(minfotab(i,2)) ',  c' int2str(minfotab(i,3))];
            elseif minfotab(i,1) == 2   % empty
                str = ['Empty'];
            elseif minfotab(i,1) == 3   % system
                str = ['S: y' int2str(minfotab(i,2)) ',  u' int2str(minfotab(i,3)) ',  x'...
                            int2str(minfotab(i,4))];
            elseif minfotab(i,1) == 4   % varying
                str = ['V: r' int2str(minfotab(i,2)) ',  c' int2str(minfotab(i,3)) ',  #'...
                            int2str(minfotab(i,4))];
            end
        else
            str = 'Error in eval';
        end
        if i==1
            allstr = str;
        else
            allstr = str2mat(allstr,str);
        end
    end
    gdataent('setnet',mainh,bindex,allstr)
elseif strcmp(message,'setall')
else
    disp('Message not found')
end

