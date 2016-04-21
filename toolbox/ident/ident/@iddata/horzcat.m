function dat = horzcat(varargin)
% HORZCAT Horizontal concatenation of IDDATA sets.
%
%   DAT =HORZCAT(DAT1,DAT2,..,DATn) or DAT = [DAT1,DAT2,...,DATn]
%   creates a data set DAT with input and output channels composed 
%   of those in DATk. 
%
%   Default channel names (u1, u2, y1 ,y2 etc) will be changed so
%   that overlaps in names are avioded, and the new channels will
%   be added.
%
%   If DATk contains channels with user specfied names, that are
%   already present in the channels of Datj, j<k, these new channels
%   will be ignored.
%

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $ $Date: 2004/04/10 23:15:52 $

% 
dat=varargin{1}; 
reald = realdata(dat);
N = size(dat,'N');
if ~isa(dat,'iddata')
    error('Each entry in [dat1, dat2, ..] must be an iddata object.')
end

for i=2:nargin
    nu=get(dat,'nu');ny=get(dat,'ny');
    datt=varargin{i};
    if ~isa(datt,'iddata')
        error('Each entry in [dat1, dat2, ..] must be an iddata object.')
        %datt = iddata([],datt);
    end
    if ~strcmp(dat.Domain,datt.Domain)
        error('You cannot concatenate frequency and time domain data.')
    end
    if dat.Domain(1)=='F'
        realdd = realdata(datt);
        Nd = size(datt,'N');
        if realdd~=reald&~all(Nd == N) % to trap a possible misuse
            error(sprintf(['You cannot mix Frequency Domain data that are based on a real time',...
                    '\nsignal with a complex one. If REALDATA(D1)==1 do first D1 = COMPLEX(D1).']))
        end
    end
    y = datt.OutputData; 
    u = datt.InputData; 
    yna = datt.OutputName;
    yun = datt.OutputUnit;
    una = datt.InputName;
    uun = datt.InputUnit;
    yy = dat.OutputData;
    uu = dat.InputData;
    yyna = dat.OutputName;
    yyun = dat.OutputUnit;
    uuna = dat.InputName;
    uuun = dat.InputUnit;
    samp =  pvget(dat,'SamplingInstants');
    sampp = pvget(datt,'SamplingInstants');
    [novy,yna,yov] = defnum2(yyna,'y',yna);
    [novu,una,uov] = defnum2(uuna,'u',una);
    if ~isempty(uov)
        warning(sprintf(['There are overlapping InputNames.\n',...
                'The input channels in the left IDDATA object will be overwritten\n',...
                'by the corresponding channels in the right IDDATA object.']))
    end
    if ~isempty(yov)
        warning(sprintf(['There are overlapping OutputNames.\n',...
                'The output channels in the left IDDATA object will be overwritten\n',...
                'by the corresponding channels in the right IDDATA object.']))
    end
    l1 = length(y); l2 =length(yy);
    if l1~=l2
        error('The two data sets must consist of the same number of experiments.')
    end
    for kk = 1:l1
        if size(yy{kk},1)~= size(y{kk},1)
            error('The data lengths must be the same in each channel.')
        end
        if ~all(samp{kk}==sampp{kk})
            if strcmp(dat.Domain,'Time')
                error('SamplingInstants must coincide for the data sets.')
            else
                error('The Frequency vector must be the same for the data sets.')
            end 
        end
        ynew{kk} = [yy{kk},y{kk}(:,novy)];
        peridnew{kk} = [dat.Period{kk};datt.Period{kk}(novu)];
        if nu == 0&get(datt,'nu')>0
            internew(:,kk) = datt.InterSample(novu,kk);
        elseif get(datt,'nu')==0&nu>0
            internew(:,kk) = dat.InterSample;
        elseif get(datt,'nu')==0&nu==0
            internew(:,kk) = cell(1,0);
        else
            internew(:,kk) = [dat.InterSample(:,kk);datt.InterSample(novu,kk)];
        end
        unew{kk} = [uu{kk},u{kk}(:,novu)];
    end
    dat = pvset(dat,'OutputData',ynew,'InputData',unew,...
        'OutputName',yna,'InputName',una,'InputUnit',[uuun;uun(novu)],...
        'OutputUnit',[yyun;yun(novy)],'Period',peridnew,...
        'InterSample',internew);  
    clear internew
end

