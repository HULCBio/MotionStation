function zpplot(varargin)
%ZPPLOT Plots zeros and poles.
%
%   ZPPLOT(M) 
%   
%   where M is an IDMODEL object, like IDPOLY, IDSS, IDARX or
%   IDGREY.
%   To plot the zeros and poles for several models use
%   ZPPLOT(M1,M2,...,Mn)
%   To select the color associated with each model use
%   ZPPLOT(M1,'b',M2,'m',M3,'r')
%
%   To also display confidence regions, corresponding to SD
%   standard deviations, use ZPPLOT(M1,..Mn,'SD',SD). Here SD is a
%   positive real scalar.
%
%   The zeros and poles  are plotted with 'o' denoting zeros and 'x' poles.
%   Poles and zeros associated with the same input/output pair,
%   but different models are always plotted in the same diagram. 
%
%   To consider specific input/output channels, use ZPPLOT(M(ky,ku)).
%   To include also the transfer functions from the noise sources,
%   use ZPPLOT(noisecnv(M)), and for noise sources only ZPPLOT(M('noise')).
%
%   When M contains information about several different input/output channels
%   these will be sorted according to the channel names. Default is that
%   each input/output channel is plotted separately in a split plot.
%   With ZPPLOT(M1,...Mn,'mode',MODE) some alternatives are given:
%   MODE = 'sub' (The default value) splits the screen into several plots.
%   MODE = 'same' gives all plots in the same diagram. Use 'ENTER' to advance.
%   MODE = 'sep' erases the previous plot before the next channel pair is
%   treated.
%
%   ZPPLOT(M1,..Mn,..,'axis',AXIS) gives access to the axis scaling:
%   AXIS = [x1 x2 y1 y2] fixes the axes scaling. AXIS = x is the same as
%   AXIS = [-m m -m m]. Default is autoscaling.
% 
 

%   L. Ljung 10-1-86, revised 7-3-87,8-27-94
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.16.4.1 $ $Date: 2004/04/10 23:17:51 $

if nargin<1
    disp('Usage: ZPPLOT(M)')
    disp('       ZPPLOT(M,''sd'',sd,''mode'',mode,''axis'',axis)')
    disp('       ZPPLOT(M1,M2,..,Mn)')
    return
end
for kn=1:nargin
    ina{kn}=inputname(kn);
end
[sys,sysname,PlotStyle,sd,mode,ax] = vardecod(varargin{:},ina);
[ynared,unared,yind,uind] = idnamede(sys);
smode = any(strcmp(mode,{'sam','sep'}));
for ks = 1:length(sys)
    if sd>0
        %[thbbmod,sys1,flag] = idpolget(sys{ks});
        [z,p,k,dz,dp] = zpkdata(sys{ks});
        if isempty(dp)
           warning(['No confidence regions for model ',sysname{ks}])
       end
        Dz{ks} = dz; Dp{ks} = dp;
    else
        [z,p,k] = zpkdata(sys{ks});
    end
    Z{ks} = z; P{ks} = p; Ts(ks) = pvget(sys{ks},'Ts');
end
if any(Ts>0)& any(Ts==0)
    warning(sprintf(['The list of model contain both continuous and discrete ones.\n',...
            'Be careful with the interpretation of the plot.']))
end
cols=get(gca,'colororder');

if sum(cols(1,:))>1.5  
    colord=['y','m','c','r','g','w','b']; % Dark background
    eccol = 'w';
else
    colord=['b','g','r','c','m','y','k']; % Light background
    eccol ='k';
end
om=2*pi*[0:100]/100;
w=exp(om*sqrt(-1));
lny = length(ynared);
lnu = length(unared);
for yna = 1:lny
    for una = 1:lnu
        if strcmp(mode,'sub')
            subplot(lny,lnu,(yna-1)*lnu+una)
        else
            subplot(1,1,1)
        end
         if any(Ts>0)
            plot(w,eccol)
            hold on
        end
        if any(Ts==0)
            plot([-100 100],[0 0],[eccol,':'],[0 0],[-100 100],[eccol,':']);
        end
        axis('square')
        axis(axis)
        hold on
        if any(Ts>0),md = 1;else md = 0;end
        for ks = 1:length(sys)
            if isempty(PlotStyle{ks})
                PStyle=colord(mod(ks-1,7)+1);
            else
                PStyle=PlotStyle{ks}(1);
            end
            if yind(ks,yna)&uind(ks,una)  
                p = P{ks}{yind(ks,yna),uind(ks,una)};
                md = max([md;abs(p)]);
                for kp=1:length(p)
                    plot(real(p(kp)),imag(p(kp)),['x',PStyle])
                    if sd
                        try
                        dp = Dp{ks}{yind(ks,yna),uind(ks,una)};
                        zpsdpl(p(kp),dp(:,:,kp),sd,w,[':',PStyle],['-',PStyle])
                    end
                    end
                end
                z = Z{ks}{yind(ks,yna),uind(ks,una)};
                md = max([md;abs(z)]);
                
                for kp=1:length(z)
                    plot(real(z(kp)),imag(z(kp)),['o',PStyle])
                    if sd
                        try
                        dz = Dz{ks}{yind(ks,yna),uind(ks,una)};
                        zpsdpl(z(kp),dz(:,:,kp),sd,w,['-.',PStyle],['-',PStyle])
                    end
                    end
                end
            end
        end
         if yna==1|smode
            title(['From ',unared{una}])
        end
        if una ==1|smode
            ylabel(['To ',ynared{yna}])
        end
        
        if ~isempty(ax)
            md = ax;
        end
        if length(md)==1
            m(1)=-md;m(2)=md;m(3)=-md;m(4)=md;
        else
            m = md;
        end
        axis(m)
        if ~strcmp(mode,'sam'),set(gca,'NextPlot','Replace'),end
        if smode
            pause
            if strcmp(mode,'sep')
                hold off
            end
        end
    end
end 
hold off 
set(gcf,'NextPlot','replace');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sys,sysname,PlotStyle,sd,mode,ax] = vardecod(varargin)
ina = varargin{end};
varargin=varargin(1:end-1);
nsys = 0;      % counts LTI systems
nstr = 0;      % counts plot style strings 
nw = 0;
sd = 0;
del =[];
mode = [];
ax = [];
for kk= 1:length(varargin)
    if ischar(varargin{kk})&length(varargin{kk})>1&...
            strcmp(lower(varargin{kk}(1:2)),'sd')
        if kk==length(varargin)
            error('The argument ''sd'' must be followed by a postive number.')
        end
        del = [kk,kk+1];
        sd = varargin{kk+1};
        if ~(isa(sd,'double')&length(sd)==1&sd>=0)
            error('The argument ''sd'' must be followed by a postive number.')
        end
    elseif ischar(varargin{kk})&length(varargin{kk})>1&...
            strcmp(lower(varargin{kk}(1:2)),'mo')
        if kk==length(varargin)
            error(['The argument ''mode'' must be followed by ''sep'',',...
                    '''same'', or ''sub'''])
        end
        del = [del,kk,kk+1];
        mode = lower(varargin{kk+1});
        if ~(length(mode)>2&any(strcmp(mode(1:3),{'sep','sam','sub'}))) 
           error(['The argument ''mode'' must be followed by ''sep'',',...
                    '''same'', or ''sub'''])
        end
        mode = mode(1:3);
    elseif ischar(varargin{kk})&length(varargin{kk})>1&...
            strcmp(lower(varargin{kk}(1:2)),'ax')
        if kk==length(varargin)
            error(['The argument ''axis'' must be followed by a ',...
                    'postive number or a 4-vector of numbers.'])
        end
        del = [del,kk,kk+1];
        ax = varargin{kk+1};
        if ~(isa(ax,'double')&(length(sd)==1|length(sd)==4))
            error(['The argument ''axis'' must be followed by a ',...
                    'postive number or a 4-vector of numbers.'])
        end
    end
end
varargin(del)=[];
lastsyst = 0;
lastplot = 0;
modflag = 0;
ni = length(varargin);
PlotStyle=[];
for jj=1:ni
    argj = varargin{jj};
    if isa(argj,'idfrd')|isa(argj,'frd')
        error('Zpplot cannot accept freqency function data (IDFRD or FRD).')
    end
    if isa(argj,'lti'),argj=idss(argj);end
    if isa(argj,'idmodel')
        if ~isempty(argj)
            nsys = nsys+1;   
            [ny,nu]=size(argj);
            if nu==0,
                 argj = argj(:,'bothx9');
            end
             sys{nsys} = argj;
            sysname{nsys} = ina{jj};lastsyst=jj;
            modflag=1;
        end
    elseif isa(argj,'char')&modflag&...
            ~((length(argj)>2)&any(strcmp(lower(argj),{'sub','sep','sam'})))
        nstr = nstr+1;   
        PlotStyle{nsys} = argj; lastplot=jj;
        modflag = 0;
    else
        break
    end
end
PlotStyle=[PlotStyle,cell(1,nsys-length(PlotStyle))];

kk=1;
startarg = max(lastsyst,lastplot);
if ni>startarg
    for jj=startarg+1:ni
        newarg{kk}= varargin{jj};kk=kk+1;
    end
else
    newarg={};
end
for kj = 1:length(newarg)
    if ischar(newarg{kj})
        mode = newarg{kj};
    end
    if isa(newarg{kj},'double')
        if length(newarg{kj})==1
            sd = newarg{kj};
        elseif length(newarg{kj})==4
            ax = newarg{kj};
        end
    end
end


if isempty(mode),mode='sub';end
mode=mode(1:3);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zpsdpl(z,dz,sd,w,mark1,mark2)
%ZPSDPL Plots standard deviations in zero-pole plots.
%
%   zpsdpl(zepo,sd,w,iz,mark1,mark2)
%
%   This is a help function to zpplot.

%   L.Ljung 7-2-87

if imag(z)==0
    rp=real(z+sd*sqrt(dz(1,1))*[-1 1]);
    [mr,nr] = size(rp);
    plot(rp,zeros(mr,nr),mark1)
else  
    [V,D]=eig(dz); z1=real(w)*sd*sqrt(D(1,1));
    z2=imag(w)*sd*sqrt(D(2,2)); X=V*[z1;z2];
    if imag(z)<0,X(2,:)=-X(2,:);end
    
    X=[X(1,:)+real(z);X(2,:)+imag(z)];
    plot(X(1,:),X(2,:),mark2)
end
