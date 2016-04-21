% function out = rready(toolhan,ISREADY)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = rready(toolhan,ISREADY)

  out = 0;

  if isempty(toolhan)
    toolhan = gcf;
  end
  if nargin == 1
    ISREADY = gguivar('ISREADY',toolhan);
  end

  if ~any(any(isnan(ISREADY)))
    outputs = ISREADY(1,1);
    inputs = ISREADY(1,2);
    meas = ISREADY(2,1);
    cont = ISREADY(2,2);
    error = ISREADY(3,1);
    dist = ISREADY(3,2);
    nblk = ISREADY(4,1);
    omflag = ISREADY(4,2);
    [UNCBLK,MESSAGE] = gguivar('UNCBLK','MESSAGE',toolhan);
    if nblk == 1
        allblkdim = abs(UNCBLK);
    else
        allblkdim = sum(abs(UNCBLK));
    end
    if (allblkdim(1)+dist+cont~=inputs) | (allblkdim(2)+error+meas~=outputs)
        set(MESSAGE,'string','OLIC/NMEAS/NCNTRL/NERROR/NDIST/UNC_BLOCK Dimension problems...')
        drawnow;
        dk_able([1 2 3 4 5],[1 1 1 1 1 1],toolhan);
        sguivar('READY',0,toolhan);
        out = 0;
    else
        sguivar('READY',1,toolhan);
        out = 1;
        [STARTED,INUM,CITER] = gguivar('STARTED','INUM','CITER',toolhan);
        if STARTED == 0   % just starting
            set(MESSAGE,'string','Mu-Synthesis Problem Specification Complete...')
            set(gguivar('SUMESSAGE',toolhan),'string','Mu-Synthesis Problem Specification Complete...')
            sguivar('DELTAMOD',0,toolhan);
            drawnow
            dk_able([1 2 3 4 5],[3 1 1 1 1],toolhan);
            [OLIC,DKSUM_HAN,UCHOOSE,YCHOOSE,UNCBLKFAC] = ...
                gguivar('OLIC','DKSUM_HAN','UCHOOSE','YCHOOSE','UNCBLKFAC',toolhan);
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
            sguivar('BLKSYN',[UNCBLK;[dist error]],'BLKFAC',[UNCBLKFAC;1],toolhan);
            scrolltb('newdata',DKSUM_HAN,DISPLAY);
            scrolltb('refill',DKSUM_HAN);
        else
            set(MESSAGE,'string','Problem Specification Consistent...')
            if CITER == 5
                dk_able(1,3,toolhan);
            else
                dk_able(CITER+1,3,toolhan);
            end
        end
    end
  else
    sguivar('READY',0,toolhan);
    out = 0;
    if gguivar('SETUPFLAG',toolhan)
        dk_able([1 2 3 4 5],[1 1 1 1 1],toolhan);
    else
        dk_able([1 2 3 4 5],[1 1 1 1 1],toolhan);
    end
  end