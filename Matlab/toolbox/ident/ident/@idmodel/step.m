function [you,tou,ysdou] = step(varargin)
%STEP  Step response of IDMODELs and direct estimation from IDDATA sets.
%
%   STEP(MOD) plots the step response of the IDMODEL model MOD (either 
%   IDPOLY, IDARX, IDSS or IDGREY).  
%
%   STEP(DAT) estimates and plots the step response from the data set 
%   DAT given as an IDDATA object.
%
%   For multi-input models, independent step commands are applied to each 
%   input channel.  
%
%   STEP(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations. Add the argument 'FILL' after the models to show 
%   the confidence region(s) as a band instead: STEP(M,'sd',3,'fill').
%
%   To obtain a stem plot rather than a regular plot, add the argument 'STEM'
%   after the models: STEP(M,'stem').
%
%   The time span of the plot is determined by the argument T: STEP(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For a
%   step response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0). 
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input step occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.
%
%   STEP(MOD1,MOD2,..,DAT1,..,T) plots the step responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot. 
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in  
%      STEP(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = STEP(MOD) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the step response of the 
%   j-th input channel. YSD contains the standard deviations of Y.
%   
%   For a DATA input MOD = STEP(DAT),  returns the model of the 
%   step response, as an IDARX object. This can of course be plotted
%   using STEP(MOD).
%
%   The calculation of the step response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the 
%   property/value pair  STEP( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/STEP and IDDATA/STEP are adjusted to the use with
%   identification tasks. If you have the CONTROL SYSTEMS TOOLBOX and want
%   to access the LTI/STEP, use VIEW(MOD1,....,'step').  

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.22.4.1 $  $Date: 2004/04/10 23:17:45 $

if nargin<1
    disp('Usage: STEP(Data/Model)')
    disp('       [Y,T,YSD,YMOD] = STEP(Data/Model,T).')  
    return
end
NA = 10; sd = 0; stempl = 0;
varargin = low(varargin);
fillnr = find(strcmp(varargin,'fill'));
if ~isempty(fillnr)
    fillsd = 1;
    varargin(fillnr)=[];
else 
    fillsd =0;
end
fillnr = find(strcmp(varargin,'stem'));
if ~isempty(fillnr)
    stempl = 1;
    varargin(fillnr)=[];
else 
    stempl =0;
end
kpf = find(strcmp(varargin,'pw'));
if ~isempty(kpf)
    if kpf == length(varargin)
        error('The argument ''PW'' must be followed by an integer.')
    end
    NA = varargin{kpf+1};
    if ~isa(NA,'double')
        error('The argument ''PW'' must be followed by an integer.')
    end
    if length(varargin)<kpf+2
        varargin = varargin(1:kpf-1);
    else
        varargin = varargin(1:kpf-1,kpf+2:end);
    end
    
end
kpf = find(strcmp(varargin,'sd'));
if ~isempty(kpf)
    if kpf == length(varargin)
        error('The argument ''SD'' must be followed by a postive real number.')
    end
    sd = varargin{kpf+1};
    if ~isa(sd,'double')
        error('The argument ''SD'' must be followed by a postive real number.')
    elseif sd<0
        error('The argument ''SD'' must be followed by a postive real number.')
        
    end
    if length(varargin)<kpf+2
        varargin = varargin(1:kpf-1);
    else
        varargin = varargin([1:kpf-1,kpf+2:end]);
    end
    
end

[sys,sysname,PlotStyle,T,Tdata,Tsdemand] = sysirdec(NA,varargin{:});
if isempty(sys),if nargout,you=NaN;tou=NaN;ysdou=NaN;end,return,end
if length(T)==1
    T =[-T/4 T];
end

if isempty(T)
    if ~isempty(Tdata)
        T = [min(Tdata),max(Tdata)];
    else%if exist('lti')
        for ksys = 1:length(sys);
            Tf(ksys) = iddeft(sys{ksys});
        end
        Tf = max(Tf);
        T = [-Tf/4,Tf];
    end
end
for ks = 1:length(sys)
    if size(sys{ks},'nu')==0  %% For time series look at response from e
        sys{ks} = noisecnv(sys{ks});
    end
end

if nargout
    if length(sys)>1
        error('STEP with output arguments can handle only one model/data set.')
    end
    sys1 = sys{1};
    [you,tou,ysdou,sys1,flag] = impres(sys1,T,sd,Tsdemand);
    if flag
        try
            assignin('caller',sysname{ks},sys1)
        catch
        end
    end
    return
end

[ynared,unared,yind,uind] = idnamede(sys);
cols=get(gca,'colororder');
if sum(cols(1,:))>1.5  
    colord=['y','m','c','r','g','w','b']; % Dark background
else
    colord=['b','g','r','c','m','y','k']; % Light background
end
for ks = 1:length(sys)
    sys1 = sys{ks};
    [y,t,ysd,sys1,flag] = impres(sys1,T,sd,Tsdemand);
    Y{ks}=y;YSD{ks}=ysd;Tsa{ks}=t;
end

NY = length(ynared);
NU = length(unared);
for yna = 1:length(ynared)
    for una = 1:length(unared)
        subplot(NY,NU,(yna-1)*NU+una)
        for ks = 1:length(sys)
            if isempty(PlotStyle{ks})
                PStyle=[colord(mod(ks-1,7)+1),'-'];
            else
                PStyle=PlotStyle{ks};
            end
            if uind(ks,una)             
                if yind(ks,yna)&uind(ks,una)
                    t = Tsa{ks};
                    y = Y{ks}(1:length(t),yind(ks,yna),uind(ks,una));
                    sd1 = 0;
                    if sd
                        if isempty(YSD{ks})
                            sd1 = 0;
                        else
                            ysd = YSD{ks}(1:length(t),yind(ks,yna),uind(ks,una));
                            if ~isreal(ysd)
                                warning('Standard deviations unreliable.')
                                ysd = zeros(size(ysd));
                            end
                            sd1 = sd;
                        end
                    end
                    
                    if stempl
                        stem(t,y,PStyle),hold on
                    else
                        plot(t,y,PStyle);hold on
                    end
                    
                    if sd1
                        yy = y;                  
                        if fillsd
                            if length(sys) ==1
                                fillcol ='y';
                            else
                                fillcol = PStyle(1);
                            end
                            t = t(:);
                            xax=[t;t(end:-1:1)];
                            ysd = ysd(:);
                            yax=[yy+sd*ysd;yy(end:-1:1)-sd*ysd(end:-1:1)];
                            
                            fill(xax,yax,fillcol)
                            if stempl
                                stem(t,y,PStyle),hold on
                            else
                                plot(t,y,PStyle);hold on
                            end                        
                        else
                            plot(t,yy+sd*ysd,[PStyle(1),'-.']),hold on
                            plot(t,yy-ysd*sd,[PStyle(1),'-.']),hold on
                        end
                    end
                end
            end
        end % sys
        hold off
        if yna==1
            title(['From ',unared{una}]);
        end
        if una ==1
            ylabel(['To ',ynared{yna}]);
        end
    end
end

set(gcf,'NextPlot','replace');

%%¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
function [y,t,ysd,sys1,flag] = impres(sys1,T,sd,Tsdemand)
flag = 0;
[ny,nu]=size(sys1);
Ts  = sys1.Ts;
T1 = min(0,min(T)); T2 = max(T);
if Ts==0
    if ~isempty(Tsdemand)
        Ts = Tsdemand;
    else
        [dum,Ts] = iddeft(sys1,T2);
    end
    Tss=0;
else
    Tss = Ts;
end

if isaimp(sys1)
    ut = pvget(sys1,'Utility');
    B = ut.impulse.B;
    dBstep = ut.impulse.dBstep;
    time = ut.impulse.time;
    actime = find(time>=T1&time<=T2);
    Ndata = length(actime);
    y  = zeros(Ndata,ny,nu);ysd = zeros(Ndata,ny,nu); 
    t = time(actime);
    zer = find(t==0);
    int = [zer:Ndata]; 
    for kk = 1:nu
        y(:,:,kk)=squeeze(B(:,kk,actime))';  
        for ky = 1:ny
            y(int,ky,kk)=cumsum(y(int,ky,kk));%
        end 
        ysd(:,:,kk)=squeeze(dBstep(:,kk,actime))';
    end
else
    Tstart = floor(T1/Ts); 
    if Tstart*Ts<T1, Tstart=Tstart+1;end
    Ndata = ceil((T2-T1)/Ts-10*eps)+1;
    %inpd = pvget(sys1,'InputDelay');
    %Ndata = Ndata+max(inpd);
    
    uu = iddata([],zeros(Ndata,nu),Ts);
    uu = pvset(uu,'Tstart',Tstart*Ts,...
        'InputName',pvget(sys1,'InputName')); % This is to assure that 0 is a sampling point
    zer = find(get(uu,'SamplingInstants')==0);
    int = zer:Ndata;
    y  = zeros(Ndata,ny,nu);ysd = zeros(Ndata,ny,nu); %skilj på sd
    if sd&(isa(sys1,'idmodel')&~isa(sys1,'idpoly')) % test isimp
        [thbbmod,sys1,flag] = idpolget(sys1);
    end
    for ku = 1:nu
        u1 = uu;
        u1.u(int,ku)=ones(size(int));
        if sd
            ssd = 0;
            if isa(sys1,'idproc')
                typ = i2type(sys1);
                if isempty(sys1.CovarianceMatrix)
                    ssd = 0;
                else
                    ssd = any(cat(2,typ{:})=='D');
                end
            end
            if ssd % take the uncertainty by Monte Carlo
                [y1,ysd1] = simsd(u1,sys1,30);
                y1 = y1{1};
            else
                [y1,ysd1] = sim(u1,sys1,'z'); 
            end
            if ~isempty(ysd1)
                ysd2 = pvget(ysd1,'OutputData');
                ysd(1:length(ysd2{1}),:,ku)=ysd2{1};
            else
                ysd =[];
            end
        else
            y1 = sim(u1,sys1,'z'); 
        end
        y2 = pvget(y1,'OutputData');
        y(1:length(y2{1}),:,ku) = y2{1};
    end  
    t=pvget(y1,'SamplingInstants');t = t{1};
    
end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arg = low(arg)
for kk=1:length(arg)
    if ischar(arg{kk})
        arg{kk}=lower(arg{kk});
    end
end

 