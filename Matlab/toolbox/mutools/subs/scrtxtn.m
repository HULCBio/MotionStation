% function [out1,out2,out3] = ...
%         scrtxtn(message,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.10.2.3 $

function [out1,out2,out3] = ...
        scrtxtn(message,in1,in2,in3,in4,in5,in6,in7,in8,in9,in10,in11,in12)


if strcmp(message,'create')
    fig = in1;
    apos = in2;
    xlim = in3;
    nh = in4(1);
    numnames = in4(2);
    if length(in4)==2
        slidw = 20;
    else
        slidw = in4(3);
    end
    coltypemask = in5;
    colpos = in6;
    colalign = in7;
    colpt = in8;
    colstrings = in9;
    coltitles = in10;
    totalcols = length(colpos);
    totalrows = numnames;
    fontsize = in11;
    if nargin <= 12   % no GONUM
        gonum = zeros(totalrows,totalcols);
    else
        gonum = in12;
    end
    if gcf ~= fig	% try to keep visible off..
        fprintf(1,'GCF is %i but fig is %i.\n',gcf,fig);
        figure(fig);
    end
    wpos = get(in1,'position');
    axhan = axes('position',apos,'xlim',in3,'ylim',[-nh*numnames 0],'box','on',...
        'xticklabel',[],'yticklabel',[],'xtick',[],'ytick',[],'xcolor',[0 0 0],...
        'ycolor',[0 0 0],'color',[64/85 64/85 64/85],...
        'BusyAction','queue','Interruptible','off','defaulttextinterpreter','none');
    SLIDHAN = uicontrol('style','slider',...
            'value',1,...
            'userdata',axhan,...
            'enable','off',...
            'position',[wpos(3)*(apos(1)+apos(3)) wpos(4)*apos(2) slidw wpos(4)*apos(4)],...
            'callback','scrtxtn(''slideraction'');');
    txhans = zeros(totalrows,totalcols);
    exhan = [];
    allhan = [axhan;SLIDHAN];
    for j=1:totalcols
        if strcmp(coltypemask(1,j),'d')
            for i=1:numnames
                txhans(i,j) = mkdragic('create',get(axhan,'parent'),...
                    ' ',[colpos(j) -i*nh+0.5*nh],gonum(i,j),axhan); % xxxcheck gonum
                set(txhans(i,j),'fontsize',fontsize,...
                    'BusyAction','queue','Interruptible','off');
            end
        else
            for i=1:numnames
                txhans(i,j) = text(colpos(j),-i*nh+0.5*nh,' ',...
                    'horizontalalignment',colalign(j));
                set(txhans(i,j),'fontsize',fontsize,'color',[0 0 0],...
                    'BusyAction','queue','Interruptible','off');
                exhan = [exhan;txhans(i,j)];
            end
        end
        tmp = text(colpos(j),.5*nh,deblank(coltitles(j,:)),...
            'horizontalalignment',colalign(j),'fontsize',8,'color',[0 0 0]);
        allhan = [allhan;tmp];
        exhan = [exhan;tmp];
    end
    out2 = exhan;
    stdata = [];
    lastval = 1;
    activerows = 0;
    cnt = 1;
    stdata = ipii(stdata,[SLIDHAN;lastval;nh;numnames;activerows;cnt],1);
    stdata = ipii(stdata,coltypemask,2);
    stdata = ipii(stdata,colpt,3);
    stdata = ipii(stdata,txhans,4);
    stdata = ipii(stdata,[],5);
    stdata = ipii(stdata,[],6);
    stdata = ipii(stdata,colstrings,7);
    stdata = ipii(stdata,allhan,8);
    set(axhan,'userdata',stdata);
    out1 = axhan;
elseif strcmp(message,'delete')
    axhan = in1;
    stdata = get(axhan,'userdata');
    txhans = xpii(stdata,4);
    ohans = xpii(stdata,8);
    delete(txhans);
    delete(ohans(2:length(ohans)));
    delete(ohans(1))
elseif strcmp(message,'changefont')
    axhan = in1;
    stdata = get(axhan,'userdata');
    txhans = xpii(stdata,4);
    set(txhans,'fontsize',in2);
elseif strcmp(message,'changedata')
    axhan = in1;
    stdata = get(axhan,'userdata');
    alldims = xpii(stdata,1);
    numnames = alldims(4);
    slidhan = alldims(1);
    mdata = in2;
    gonum = in3;
    nrows = size(mdata,1);
    alldims(5) = nrows;
    if nrows>numnames
        set(slidhan,'enable','on');
        val = get(slidhan,'value');
        cnt = round((numnames-nrows)*val + (nrows-numnames+1));
        val = (cnt-nrows+numnames-1)/(numnames-nrows);
        set(slidhan,'value',val);
        alldims(6) = cnt;
    else
        set(slidhan,'enable','off');
        alldims(6) = 1;
    end
    stdata = ipii(stdata,alldims,1);
    stdata = ipii(stdata,mdata,5);
    stdata = ipii(stdata,gonum,6);
    set(axhan,'userdata',stdata);
elseif strcmp(message,'slideraction')
    slidhan = get(gcf,'currentobject');
    axhan = get(slidhan,'userdata');
    fig = get(axhan,'parent');
    stdata = get(axhan,'userdata');
    alldims = xpii(stdata,1);
    coltypemask = xpii(stdata,2);
    colpt = xpii(stdata,3);
    txhans = xpii(stdata,4);
    mdata = xpii(stdata,5);
    gonum = xpii(stdata,6);
    colstrings = xpii(stdata,7);
    slidhan = alldims(1);
    lastval = alldims(2);
    nh = alldims(3);
    numnames = alldims(4);
    nrows = alldims(5);
    cnt = alldims(6);
    val = get(slidhan,'value');
    refill = 1;
    [clo,index] = min(abs([val-lastval-.1 val-lastval-.01 val-lastval+.1 val-lastval+.01 val-lastval]));
%                           1 set up         1 line up       1 screen down   line down    same
    if index(1) == 1 & abs(clo(1)) < 2e-3
        ncnt = max([cnt-(numnames-1) 1]);    % page up
    elseif index(1) == 2 & abs(clo(1)) < 2e-3
        ncnt = max([cnt-1 1]);   % line up
    elseif index(1) == 3 & abs(clo(1)) < 2e-3
        ncnt = min([cnt+(numnames-1) nrows-numnames+1]);   % page down
    elseif index(1) == 4 & abs(clo(1)) < 2e-3
        ncnt = min([cnt+1 nrows-numnames+1]);    % line down
    elseif index(1) == 5 & abs(clo(1)) < 2e-3
        % disp('same');
        ncnt = cnt;
    else
        % disp('General Move')
        ncnt = round((numnames-nrows)*val + (nrows-numnames+1));
    end
    val = (ncnt-nrows+numnames-1)/(numnames-nrows);
    if val < 0  % disaster fixer
        val = 0;
        ncnt = nrows-numnames+1;
    elseif val>1
        val = 1;
        ncnt = 1;
    end
    set(slidhan,'value',val);
    alldims(2) = val;
    alldims(6) = ncnt;
    stdata = ipii(stdata,alldims,1);
    set(axhan,'userdata',stdata);
%    ud = ipii(ud,fig,2);	% removes warning about uninitialized var GJW 09/06/96
    ud = ipii([],fig,2);
    numcols = size(txhans,2);
    if ncnt~=cnt    % don't redraw unless it moved
      for j=1:numcols
        if strcmp(coltypemask(1,j),'d') % dragable
            if strcmp(coltypemask(2,j),'s')
                for i=1:numnames
                    thestring = deblank(setstr(mdata(ncnt+i-1,colpt(1,j):colpt(2,j))));
                    ud = ipii(ud,thestring,1);
                    ud = ipii(ud,gonum(i),3);
                    set(txhans(i,j),'string',thestring,'userdata',ud);
                end
            elseif strcmp(coltypemask(2,j),'i')
                for i=1:numnames
                    thestring = int2str(mdata(ncnt+i-1,colpt(1,j):colpt(2,j)));
                    ud = ipii(ud,thestring,1);
                    ud = ipii(ud,gonum(i),3);
                    set(txhans(i,j),'string',thestring,'userdata',ud);
                end
            elseif strcmp(coltypemask(2,j),'p')
                for i=1:numnames
                    thestring = deblank(colstrings(mdata(ncnt+i-1,colpt(1,j):colpt(2,j)),:));
                    ud = ipii(ud,thestring,1);
                    ud = ipii(ud,gonum(i),3);
                    set(txhans(i,j),'string',thestring,'userdata',ud);
                end
            end
        else
            if strcmp(coltypemask(2,j),'s')
                for i=1:numnames
                    thestring = deblank(setstr(mdata(ncnt+i-1,colpt(1,j):colpt(2,j))));
                    set(txhans(i,j),'string',thestring);
                end
            elseif strcmp(coltypemask(2,j),'i')
                for i=1:numnames
                    thestring = int2str(mdata(ncnt+i-1,colpt(1,j):colpt(2,j)));
                    set(txhans(i,j),'string',thestring);
                end
            elseif strcmp(coltypemask(2,j),'p')
                for i=1:numnames
                    thestring = deblank(colstrings(mdata(ncnt+i-1,colpt(1,j):colpt(2,j)),:));
                    set(txhans(i,j),'string',thestring);
                end
            end
        end
      end
    end
elseif strcmp(message,'draw')
    axhan = in1;
    fig = get(axhan,'parent');
    stdata = get(axhan,'userdata');
    alldims = xpii(stdata,1);
    coltypemask = xpii(stdata,2);
    colpt = xpii(stdata,3);
    txhans = xpii(stdata,4);
    mdata = xpii(stdata,5);
    gonum = xpii(stdata,6);
    colstrings = xpii(stdata,7);
    slidhan = alldims(1);
    lastval = alldims(2);
    nh = alldims(3);
    numnames = alldims(4);
    nrows = alldims(5);
    cnt = alldims(6);
    val = get(slidhan,'value');
    refill = 1;
%    ud = ipii(ud,fig,2);	% removes warning about uninitialized var GJW 09/06/96
    ud = ipii([],fig,2);
    numcols = size(txhans,2);

    if isempty(mdata)
        for j=1:numcols
            for i=1:numnames
                set(txhans(i,j),'string','','visible','off');
            end
        end
    else
    for j=1:numcols
        if strcmp(coltypemask(1,j),'d') % dragable
            if strcmp(coltypemask(2,j),'s')
                for i=1:min([numnames nrows])
                        thestring = deblank(setstr(mdata(cnt+i-1,colpt(1,j):colpt(2,j))));
                        ud = ipii(ud,thestring,1);
                        ud = ipii(ud,gonum(i),3);
                        set(txhans(i,j),'string',thestring,'userdata',ud,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            elseif strcmp(coltypemask(2,j),'i')
                for i=1:min([numnames nrows])
                    thestring = int2str(mdata(cnt+i-1,colpt(1,j):colpt(2,j)));
                    ud = ipii(ud,thestring,1);
                    ud = ipii(ud,gonum(i),3);
                    set(txhans(i,j),'string',thestring,'userdata',ud,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            elseif strcmp(coltypemask(2,j),'p')
                for i=1:min([numnames nrows])
                    thestring = deblank(colstrings(mdata(cnt+i-1,colpt(1,j):colpt(2,j)),:));
                    ud = ipii(ud,thestring,1);
                    ud = ipii(ud,gonum(i),3);
                    set(txhans(i,j),'string',thestring,'userdata',ud,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            end
        else
            if strcmp(coltypemask(2,j),'s')
                for i=1:min([numnames nrows])
                    thestring = deblank(setstr(mdata(cnt+i-1,colpt(1,j):colpt(2,j))));
                    set(txhans(i,j),'string',thestring,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            elseif strcmp(coltypemask(2,j),'i')
                for i=1:min([numnames nrows])
                    thestring = int2str(mdata(cnt+i-1,colpt(1,j):colpt(2,j)));
                    set(txhans(i,j),'string',thestring,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            elseif strcmp(coltypemask(2,j),'p')
                for i=1:min([numnames nrows])
                    thestring = deblank(colstrings(mdata(cnt+i-1,colpt(1,j):colpt(2,j)),:));
                    set(txhans(i,j),'string',thestring,'visible','on');
                end
                for i=min([numnames nrows])+1:numnames
                        set(txhans(i,j),'visible','off');
                end
            end
        end
    end
    end
    if nrows <= numnames
        alldims(6) = 1;
        stdata = ipii(stdata,alldims,1);
        set(axhan,'userdata',stdata);
    end
elseif strcmp(message,'deleteallcols')
    delete(get(in1,'children'));
else
    disp('Warning: Message Not Found')
end
