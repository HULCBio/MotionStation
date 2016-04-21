function plot(varargin)
%IDDATA/PLOT Plots input - output data.
%   PLOT(DATA)    
%
%   DATA is the input - output data  as an IDDATA object.
%   Axis information is taken from the object.
%
%   To plot a subselection of the data use subreferencing:
%
%   PLOT(DATA(201:300))  or  PLOT(DATA(201:300,Outputs,Inputs))
%   like  PLOT(DATA(201,'Altitude',{'Angle_of_attack','Speed'}))
%   or PLOT(DATA(:,[3 4],[3:7])
%
%   Several data sets can be compared by
%   PLOT(dat1,dat2,...,datN)
%   Colors, linestyles and markers can be specified by PlotStyle 
%   PLOT(dat1,'PlotStyle1',dat2,'PlotStyle2',....,datN,'PlotStyleN')
%   PlotStyle takes values like 'b', 'b+:', etc. See HELP PLOT.
%
%   The signals are plotted so that each plot contains the signals 
%   that have the same InputNames and OutputNames and (for multi-
%   experiment data) the same ExperimentName. Press RETURN to advance
%   from one plot to the next. Typing CTRL-C will abort the plotting
%   in an orderly fashion.
%
%   For data sets with inputs and outputs, the plot is split so that each
%   input/output combination is shown separately. For data sets with no
%   inputs or no outputs the signals are shown separately.
%
%   The input signal is plotted as a linearly interploted curve or as a
%   staircase plot according to the Property 'InterSample' (foh or zoh).

%   L. Ljung 87-7-8, 93-9-25
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $ $Date: 2004/04/10 23:16:05 $

if nargin < 1
    disp('Usage: PLOT(DATA)')
    return
end
[z,zname,PlotStyle,erm] = sysdatde(varargin{:});
    if ~isempty(erm)
        error(erm)
    end
if isempty(z)
    disp('Empty data set. No plot.')
    return
end
[ynared,unared,yind,uind,exnared,exind] = idnamede(z);
% tsind are the sets that are pure time series
% usind ate the data sets that have no outputs
tsind =[];
usind =[];
for ks = 1:length(z)
    [N,ny,nu] = size(z{ks});
    if nu==0
        tsind = [tsind,ks];
    end
    if ny == 0
        usind = [usind,ks];
    end
end

cols=get(gca,'colororder'); 
if sum(cols(1,:))>1.5  
    colord=['y','m','c','r','g','w','b']; % Dark background
else
    colord=['b','g','r','c','m','y','k']; % Light background
end
newplot
clearflag = 0;
for kexp= 1:length(exnared)
    for yna = 1:length(ynared)
        for una = 1:length(unared)
            plotted = 0;
            for ks = 1:length(z)
                if yind(ks,yna)&uind(ks,una)&exind(ks,kexp)
                    plotted = 1;
                    if clearflag
                        try
                            pause
                        catch
                            hold off
                            set(gcf,'NextPlot','replace');
                            return
                        end
                        clf
                        clearflag = 0;
                    end
                    zk = z{ks};
                    dom = zk.Domain;
                     if ~isreal(zk)
                            zk = abs(zk);
                        end
                    if strcmp(lower(dom),'frequency')
                        tscase = 0;
                       
                    else
                        tscase = 1;
                    end
                    
                    y = zk.OutputData{exind(ks,kexp)}(:,yind(ks,yna));
                    u = zk.InputData{exind(ks,kexp)}(:,uind(ks,una));                                
                    if isempty(PlotStyle{ks})
                        PStyle=[colord(mod(ks-1,7)+1),'-'];
                    else
                        PStyle=PlotStyle{ks};
                    end
                    int=pvget(zk,'SamplingInstants');int = int{exind(ks,kexp)};
                    if length(exnared)>1
                        exptext = [zk.ExperimentName{exind(ks,kexp)},': '];
                    else
                        exptext = [];
                    end                                             
                    subplot(2,1,1)
                    
                    plot(int,y,PStyle)
                    hold on
                    if tscase
                        xlabel(zk.TimeUnit)
                    else
                        un = zk.Tstart;
                        if iscell(un),un=un{kexp};end
                        xlabel(un)
                    end
                    
                    ylabel(zk.OutputUnit{yind(ks,yna)})
                    title([exptext,zk.OutputName{yind(ks,yna)}])
                    
                    subplot(2,1,2) 
                    %hold on
                    ints = zk.InterSample;ints=ints{kexp};
                    if lower(ints(1))=='z'&tscase
                        PC='PC'; 
                    else
                        PC='LI';
                    end
                    if PC~='PC',
                        plot(int,u,PStyle)%(:,ku)),
                    else
                        stairs(int,u,PStyle)
                    end
                    hold on
                    ax = axis; 
                    xn1 = min(ax(1),int(1));
                    xn2 = max(ax(2),int(end));
                    y1=min(u);y1=y1-0.1*abs(y1);y1 = min(y1,ax(3));
                    y2=max(u);y2=y2+0.1*abs(y2);y2 = max(y2,ax(4));
                    if y1==y2, y1=-1;y2=1;end 
                    axis([xn1 xn2 y1 y2]);% To look better for binary data
                    title(zk.InputName{uind(ks,una)})  
                    if tscase
                        xlabel(zk.TimeUnit)
                    else
                        un = zk.Tstart;
                        if iscell(un),un=un{kexp};end
                        xlabel(un)
                    end
                    
                    ylabel(zk.InputUnit{uind(ks,una)}) 
                    
                end %if yind
            end % for systems
            if plotted
                clearflag = 1;
            end  
        end % for nu
    end % for ny
    
    % Now deal with the data sets that are time series
    for yna = 1:length(ynared)
        for ks = tsind 
            if yind(ks,yna)&exind(ks,kexp)
                plotted = 1;
                 
                if clearflag
                    try
                        pause
                    catch
                        hold off
                        set(gcf,'NextPlot','replace');
                        return
                    end
                    clf
                    clearflag = 0;
                end
                zk = z{ks}; 
                dom = zk.Domain;
                  if ~isreal(zk)
                            zk = abs(zk);
                        end
                if strcmp(lower(dom),'frequency')
                        tscase = 0;
                    else
                        tscase = 1;
                    end
                y = zk.OutputData{exind(ks,kexp)}(:,yind(ks,yna));
                if isempty(PlotStyle{ks})
                    PStyle=[colord(mod(ks-1,7)+1),'-'];
                else
                    PStyle=PlotStyle{ks};
                end
                int=pvget(zk,'SamplingInstants');int = int{exind(ks,kexp)};
                T=zk.Ts; T=T{exind(ks,kexp)}; 
                if length(exnared)>1
                    exptext = [zk.ExperimentName{exind(ks,kexp)},': '];
                else
                    exptext = [];
                end                                             
                subplot(1,1,1)
                %	if ~tscase, y = abs(y);end
                plot(int,y,PStyle)
                hold on
                if tscase
                    xlabel(zk.TimeUnit)
                else
                    un = zk.Tstart;
                    if iscell(un),un=un{kexp};end
                    xlabel(un)
                end
                
                ylabel(zk.OutputUnit{yind(ks,yna)})
                title([exptext,zk.OutputName{yind(ks,yna)}])
            end % plot
        end % for sys
        if plotted
            clearflag = 1;
        end  
        
    end % for ky
    % Now the data sets that have no output
    for una = 1:length(unared) 
        for ks = usind
            if uind(ks,una)&exind(ks,kexp)
                plotted = 1;
                if clearflag
                    try
                        pause
                    catch
                        hold off
                        set(gcf,'NextPlot','replace');
                        return
                    end
                    clf
                    clearflag = 0;
                end
                zk = z{ks}; 
                dom = zk.Domain;
                 if ~isreal(zk)
                            zk = abs(zk);
                        end
                  if strcmp(lower(dom),'frequency')
                        tscase = 0;
                    else
                        tscase = 1;
                    end
                u = zk.InputData{exind(ks,kexp)}(:,uind(ks,una));                                
                if isempty(PlotStyle{ks})
                    PStyle=[colord(mod(ks-1,7)+1),'-'];
                else
                    PStyle=PlotStyle{ks};
                end
                
                int=pvget(zk,'SamplingInstants');int = int{exind(ks,kexp)};
                ints = zk.InterSample;ints=ints{kexp};
                %	if ~tscase, u = abs(u);end
                if lower(ints(1))=='z'&tscase
                    PC='PC'; 
                else
                    PC='LI';
                end
                if PC~='PC',
                    plot(int,u,PStyle)
                else
                    stairs(int,u,PStyle)
                end
                hold on
                ax = axis; 
                xn1 = min(ax(1),int(1));
                xn2 = max(ax(2),int(end));
                y1=min(u);y1=y1-0.1*abs(y1);y1 = min(y1,ax(3));
                y2=max(u);y2=y2+0.1*abs(y2);y2 = max(y2,ax(4));
                if y1==y2, y1=-1;y2=1;end 
                axis([xn1 xn2 y1 y2]); % To look better for binary data
                if length(exnared)>1
                    exptext = [zk.ExperimentName{exind(ks,kexp)},': '];
                else
                    exptext = [];
                end               
                title([exptext,zk.InputName{uind(ks,una)}]) 
                if tscase
                    xlabel(zk.TimeUnit)
                else
                    un = zk.Tstart;
                    if iscell(un),un=un{kexp};end
                    xlabel(un)
                end
                ylabel(zk.InputUnit{uind(ks,una)})            
            end % if plot
        end % for sys
        if plotted
            clearflag = 1;
        end   
    end % for una
end % exp
hold off
set(gcf,'NextPlot','replace');

function [sys,sysname,PlotStyle,erm] = sysdatde(varargin)
%SYSARDEC  xxx

%   Copyright 1986-2000 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $ $Date: 2004/04/10 23:16:05 $

erm = [];
ni = nargin;
no = nargout;
newarg=[];inpn=[];
% Parse input list

%inputname = inpn;
nsys = 0;       % counts Iddata data sets
nstr = 0;      % counts plot style strings 

sys = cell(1,ni);
sysname = cell(1,ni);
PlotStyle = cell(1,ni);

lastsyst=0;lastplot=0;
un = []; % keeping track of Freq units.
dom = []; %keepingtrack of domains
for j=1:ni,
    argj = varargin{j};
    if isa(argj,'iddata') 
        if ~isempty(argj)
            nsys = nsys+1;   
            sys{nsys} = argj;
            sysname{nsys} = inputname(j);
            lastsyst=j;
            if isempty(dom)
                dom = lower(argj.Domain(1));
            else
                if dom~=lower(argj.Domain(1));
                    error('You cannot mix Frequency and Time Domain data in the same plot.');
                end
            end
            if dom=='F'
                if isempty(un)
                    un = argj.Tstart;
                    un = un{1};
                else
                    if ~strcmp(un,argj.Tstart)
                        warning(['All frequency units converted to ',un])
                        sys{nsys} = chgunits(sys{nsys},un);
                    end
                end
            end
        end
    elseif isa(argj,'char')&j>1&isa(varargin{j-1},'iddata') 
        nstr = nstr+1;   
        PlotStyle{nsys} = argj; lastplot=j;
        
    end
end
if lastplot==lastsyst+1,lastsyst=lastsyst+1;end
kk=1;
sys = sys(1:nsys);
sysname = sysname(1:nsys);
PlotStyle = PlotStyle(1:nsys);
