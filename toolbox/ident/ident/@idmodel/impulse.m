function [you,tou,ysdou] = impulse(varargin)
%IMPULSE  Impulse response of IDMODELs and direct estimation from IDDATA sets.
%
%   IMPULSE(MOD) plots the impulse response of the IDMODEL model MOD (either 
%   IDPOLY, IDARX, IDSS or IDGREY).  
%
%   IMPULSE(DAT) estimates and plots the impulse response from the data set 
%   DAT given as an IDDATA object. This does not apply to time series data.
%   To study subchannels, use IR = IMPULSE(DAT); IMPULSE(IR(INPUTS,OUTPUTS)).
%
%   For multi-input models, independent impulse commands are applied to each 
%   input channel.   
%
%   IMPULSE(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations as a region around zero. Any response
%   outside this region is thus "significant". Add the argument
%   'FILL' after the models to show  the confidence region(s) as a
%   band instead: IMPULSE(M,'sd',3,'fill').
%
%   IMPULSE uses a stem plot by default. To change that into a regular plot
%   add the argument 'PLOT' after the models: IMPULSE(M,'plot'). In
%   this case, the uncertainty region is shown as a strip around
%   the response.
%
%   The time span of the plot is determined by the argument T: IMPULSE(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For an
%   impulse response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0). 
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input impulse occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.
% 
%   NOTE: The pulse is normalized w.r.t. the sampling interval T so that
%   u(t) = 1/T for 0<t<T and zero otherwise.
%
%   IMPULSE(MOD1,MOD2,..,DAT1,..,T) plots the impulse responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot. 
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in  
%      IMPULSE(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = IMPULSE(MOD) 
%   returns the output response Y and the time vector T used for 
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the impulse response of the 
%   j-th input channel. YSD contains the standard deviations of Y.
%   
%   For a DATA input MOD = IMPULSE(DAT),  returns the model of the 
%   impulse response, as an IDARX object. This can of course be plotted
%   using IMPULSE(MOD).
%
%   The calculation of the impulse response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the 
%   property/value pair  IMPULSE( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/IMPULSE and IDDATA/IMPULSE are adjusted to the use with
%   identification tasks. If you have the CONTROL SYSTEMS TOOLBOX and want
%   to access the LTI/IMPULSE, use VIEW(MOD1,...,'impulse').

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $  $Date: 2004/04/10 23:17:28 $

if nargin<1
    disp('Usage: IMPULSE(Data/Model)')
    disp('       [Y,T,YSD,YMOD] = IMPULSE(Data/Model,T).')  
    return
end
% First fix case with output:
% ...

NA = 10; sd = 0; stempl = 1;
varargin = low(varargin);
fillnr = find(strcmp(varargin,'fill'));
if ~isempty(fillnr)
    fillsd = 1;
    varargin(fillnr)=[];
else 
    fillsd =0;
end
fillnr = find(strcmp(varargin,'plot'));
if ~isempty(fillnr)
    stempl = 0;
    varargin(fillnr)=[];
else 
    stempl =1;
end

kpf = find(strcmp(varargin,'pw'));
if length(kpf)>1
    error('You entered argument ''PW'' more than once.');
end
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
        varargin = varargin([1:kpf-1,kpf+2:end]);
    end
    
end
kpf = find(strcmp(varargin,'sd'));
if length(kpf)>1
    error('You entered argument ''SD'' more than once.');
end
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
elseif length(T)>2
    T = [min(T),max(T)];
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
        error('IMPULSE with output arguments can handle only one model/data set.')
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
                            sd1 = sd;
                        end
                    end
                    
                    if stempl
                        stem(t,y,PStyle),hold on
                    else
                        plot(t,y,PStyle);hold on
                    end
                    
                    if sd1
                        if stempl
                            yy = zeros(size(ysd));
                        else
                            yy = y;
                        end
                        
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
        defax = axis;
        axis([min(defax(1),T(1)) max(defax(2),T(2)) defax(3:4)]);
        % The above is to give the desired plot span even for any IMPRES.
        
        if yna==1
            title(['From ',unared{una}]);
        end
        if una ==1
            ylabel(['To ',ynared{yna}]);
        end
        
    end
end

set(gcf,'NextPlot','replace');

%%いいいいいいいいいいいいいいいいいいいいいいいい
function [y,t,ysd,sys1,flag] = impres(sys1,T,sd,Tsdemand)
flag = 0;
[ny,nu] = size(sys1);
Ts  = sys1.Ts;
T1 = min(0,min(T)); 
T2 = max(T);
if Ts==0
    if ~isempty(Tsdemand)
        Ts = Tsdemand;
    else
        [dum,Ts] = iddeft(sys1,T2);
    end
    Tss = 0;
else
    Tss = Ts;
end

if isaimp(sys1)
    ut = pvget(sys1,'Utility');
    B = ut.impulse.B;
    dB = ut.impulse.dB;
    Tsd = pvget(sys1,'Ts');
    time = ut.impulse.time;
    actime = find(time>=T1&time<=T2);
    Ndata = length(actime);
    y  = zeros(Ndata,ny,nu);ysd = zeros(Ndata,ny,nu); 
    t = time(actime);
    for kk = 1:nu
        y(:,:,kk)=squeeze(B(:,kk,actime)).'/Tsd;  
        ysd(:,:,kk)=squeeze(dB(:,kk,actime)).'/Tsd;
    end
    
else
    Tstart = floor(T1/Ts); 
    if Tstart*Ts+10*eps<T1, Tstart=Tstart+1;end
    Ndata = ceil((T2-T1)/Ts-10*eps)+1;
    uu = iddata([],zeros(Ndata,nu),Ts);
    uu = pvset(uu,'Tstart',Tstart*Ts,...
        'InputName',pvget(sys1,'InputName')); % This is to assure that 0 is a sampling point
    zer = find(get(uu,'SamplingInstants')==0);
    y  = zeros(Ndata,ny,nu);ysd = zeros(Ndata,ny,nu); 
    if sd&(isa(sys1,'idmodel')&~isa(sys1,'idpoly')) % test isimp
        [thbbmod,sys1,flag] = idpolget(sys1);
    end
    if ~sys1.Ts % continuous time model
        if sd >0
            disp('No confidence interval for continuous time model')
        end
        sys1 = idss(sys1);
        B = pvget(sys1,'B');
        sys1 = c2d(sys1,Ts);
        nxd = size(sys1,'nx');
        nxc = size(B,1);
        if nxd>nxc;
            B = [B;zeros(nxd-nxc,size(B,2))];
        end
        inpd = pvget(sys1,'InputDelay');
    end
    
    for ku = 1:nu
        u1 = uu;
        if Tss==0
            init = B(:,ku); 
            sd1 = 0;
        else
            sd1 =sd;
            init ='z';
            u1.u(zer,ku)=1/Ts;
        end
        if sd1
            [y1,ysd1] = sim(u1,sys1);
            
            if ~isempty(ysd1)
                ysd2 = pvget(ysd1,'OutputData');
                ysd(1:length(ysd2{1}),:,ku)=ysd2{1};
            else
                ysd =[];
            end
            y2 = pvget(y1,'OutputData');
            y(1:length(y2{1}),:,ku) = y2{1}; 
        else
            y1 = sim(u1,sys1,init); 
            y2 = pvget(y1,'OutputData'); y2 = y2{1};
            Nc = size(u1,'N');
            if Tss
                y(1:length(y2),:,ku) = y2;
            else
                y(1:Nc,:,ku) = zeros(Nc,ny);
                y(zer+inpd(ku):Nc,:,ku) = y2(1:Nc-zer+1-inpd(ku),:);
            end
        end
    end  
    t=pvget(y1,'SamplingInstants');t = t{1};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arg = low(arg)
for kk=1:length(arg)
    if ischar(arg{kk})
        arg{kk}=lower(arg{kk});
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 