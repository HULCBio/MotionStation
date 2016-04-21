% function dkparmcb(toolhan,in1,in2,in3)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function dkparmcb(toolhan,in1,in2,in3)

    if isempty(toolhan)
	toolhan = gcf;
    end

    if strcmp(in1,'maxord')
        co = get(gcf,'currentobject');
        val = str2double(get(co,'string'));
        if val>=0 & ceil(val)==floor(val) & ~isempty(val)
            set(co,'string',int2str(round(val)));
            sguivar('DMAXORD',val);
        else
            set(co,'string','5');
            sguivar('DMAXORD',5);
        end
    elseif strcmp(in1,'hinfparms')
        % 'Gamma Min','Gamma Max','Bisect Tol','Suboptimal Tol',
        % 'Imaginary Tol (Ham)','Positive Def Tol (Ham)'

    actcol = 2;

        han = get(get(gcf,'currentobject'),'userdata');
        [BUTSTAT,INUM,HDEFAULTS] = ...
        gguivar('BUTSTAT','INUM','HDEFAULTS');

        val = str2double(get(han(in2),'string'));
    if isempty(val)
        val = nan;
    end
            if in2 == 1
                gh = HDEFAULTS(gguivar('GHIGH'),actcol);
                if val < 0 | val>gh | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            elseif in2 == 2
                gl = HDEFAULTS(gguivar('GLOW'),actcol);
                if val<gl | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            elseif in2 == 3
                if val <= 0 | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            elseif in2 == 4
                if val < 0 | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            elseif in2 == 5
                if val <= 0 | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            elseif in2 == 6
                if val <= 0 | isnan(val)
                    set(han(in2),'string',' ');
                    HDEFAULTS(in2,2) = HDEFAULTS(in2,1);
                else
                    set(han(in2),'string',agv2str(val));
            HDEFAULTS(in2,2) = val;
                    if BUTSTAT(1)==1 & INUM>=1
                        dk_able(1,2,toolhan);
                    end
                end
            end
    sguivar('HDEFAULTS',HDEFAULTS);
    elseif strcmp(in1,'nolowerbnd')
        % nu lower bound
        [BUTSTAT] = gguivar('BUTSTAT');
        defaults = [0];
        co = get(gcf,'currentobject');
        val = get(co,'value');
        sguivar('MUNOTLOW',val);
        if BUTSTAT(5) == 3
            dk_able(4,2,toolhan)
        end
    elseif strcmp(in1,'mumthd')
        % fast, optimal
        [BUTSTAT,INUM] = gguivar('BUTSTAT','INUM');
        defaults = [1;0];
        if in2 == 1
            sguivar('MUMTHD',1);
            if BUTSTAT(5)==3
                dk_able(4,2,toolhan);
            end
        elseif in2 == 2
            sguivar('MUMTHD',2);
            if BUTSTAT(5)==3
                dk_able(4,2,toolhan);
            end
        end
    elseif strcmp(in1,'ricmthd')
        % Schur, EIG
        [BUTSTAT,INUM] = gguivar('BUTSTAT','INUM');
        defaults = [1;0];
        if in2 == 1
            sguivar('RICMTHD',2);
            if BUTSTAT(1)==1 & INUM>=1
                dk_able(1,2,toolhan);
            end
        elseif in2 == 2
            sguivar('RICMTHD',1);
            if BUTSTAT(1)==1 & INUM>=1
                dk_able(1,2,toolhan);
            end
        end
    elseif strcmp(in1,'yudim')
        if in2==1
            dkitgui(toolhan,'nmeas');
        elseif in2==2
            dkitgui(toolhan,'ncntrl');
        end
    elseif strcmp(in1,'uncdim')
        MAIN_BLKF = gguivar('BLK_HAN');
        fpos = get(MAIN_BLKF,'position');
        dkitgui(toolhan,'setuncdim',1,fpos);
    end
