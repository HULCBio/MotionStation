
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function [out1,out2] = dataent(message,in1,in2,in3,in4,in5,in6,in7,in8,in9)


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
    % name of this tool's handle as stored in calling program
    guiname = in9;

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
    fdimvec = [lx+binlbo+binw+binrbo;ly;ybotbo;ytopbo;xlbo;xrbo;th;hgap;vgap];
    nvar = size(cboxnames,1);
    if strcmp(message,'create')
        tmp1 = ['dataent(''refresh'',gguivar(''' guiname ''''];
        tmp2 = ['gdataevl;dataent(''refreshminfo'',gguivar(''' guiname ''''];
        cbs = [tmp1 '),1);' tmp2 '),1);'];
        for i=2:nvar
            cbss = [tmp1 '),' int2str(i) ');' tmp2 '),' int2str(i) ');'];
            cbs = str2mat(cbs,cbss);
        end
        ecbs = setstr(ones(nvar,1)*' ');
        [fh,than] = colbut(fig,'create',fdimvec,'pet',[nw dw mw],nvar,[1 1 1]);
        colbut(fh,'setcb','p',1,'all',cbs);
        colbut(fh,'setstr','p',1,'all',cboxnames);
        ethan = colbut(fh,'gethan','e',1,1:nvar);

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
        if gca ~= normax	% try to keep visible off
            axes(normax);
	end
        for i=1:nvar
            binloc = [[fig nbinx(1) nbiny(2) nbinx(3)-nbinx(1) nbiny(1)-nbiny(2) ethan(nvar-i+1)];binloc];
            line(nbinx,nbiny,'color',[0 0 0])
            nbiny = nbiny + nbinyoff;
        end
        set(normax,'xlim',[0 1],'ylim',[0 1]);
        out1 = than(1,1);   % this becomes the main handle
        stdata = [];
        stdata = ipii(stdata,fh,1);
        stdata = ipii(stdata,varnames,2);
        stdata = ipii(stdata,refreshcb,3);
        stdata = ipii(stdata,errorcb,4);
        set(out1,'userdata',stdata);
        out2 = binloc;
    else
        xywh = colbut(fig,'dimquery',fdimvec,'pet',[nw dw mw],nvar,[1 1 1]);
        out1 = [lx ly xywh(3)+binlbo+binw+binrbo xywh(4)];
    end
elseif strcmp(message,'setet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    colbut(pwh,'setstr','e',1,in2,in3);
elseif strcmp(message,'getet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    out1 = colbut(pwh,'getstr','e',1,in2);
elseif strcmp(message,'setnet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    colbut(pwh,'setstr','t',1,in2,in3);
elseif strcmp(message,'getnet')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    out1 = colbut(pwh,'getstr','t',1,in2);
elseif strcmp(message,'setbstat')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    hans = get(pwh,'userdata');
    for i=1:length(in2)
        set(hans(in2(i),1),'value',in3(i));
    end
elseif strcmp(message,'setbenable')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    colbut(pwh,'enable','p',1,in2);
elseif strcmp(message,'setbdisable')
    mainh = in1;
    stdata = get(mainh,'userdata');
    pwh = xpii(stdata,1);
    colbut(pwh,'disable','p',1,in2);
%elseif strcmp(message,'getbstat')
%    mainh = in1;
%    stdata = get(mainh,'userdata');
%    pwh = xpii(stdata,1);
%    hans = get(pwh,'userdata');
%    outdata = [];
%    if strcmp(in2,'all')
%        in2 = 1:size(hans,1);
%    end
%    for i=1:length(in2)
%        outdata = [outdata;get(hans(in2(i),1),'value')];
%    end
%    out1 = outdata;
elseif strcmp(message,'refresh')    % checks status,loads appropriate VARIABLES
                                    %   for call to gdataevl
    bindex = in2;
    mainh = in1;
    stdata = get(mainh,'userdata'); % within this tool
    pwh = xpii(stdata,1);
    EDITHANDLES = colbut(pwh,'gethan','e',1,bindex);
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
    bindex = in2;
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
            elseif minfotab(i,1) == 5   % Packed
                str = ['P: r' int2str(minfotab(i,2)) ',  c' int2str(minfotab(i,3)) ',  items '...
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
    dataent('setnet',mainh,bindex,allstr)
elseif strcmp(message,'setall')
else
    disp('Message not found')
end