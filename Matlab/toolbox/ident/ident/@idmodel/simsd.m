function [yout,ysdout] = simsd(th,u,n,noise,ky)
%SIMSD Illustrates the uncertainty in simulated model responses.
%   SIMSD(Model,U)
%
%   U is an IDDATA object or a column vector (matrix) containing the input(s).
%   Model is any IDMODEL object (IDPOLY, IDARX, IDSS, IDGREY or IDPROC). 
%   10 random models are created, consistent with the covariance informa-
%   tion in Model, and the responses of each of these models to U are plotted
%   in the same diagram.
%
%   The number 10 can be changed to N by SIMSD(Model,U,N).
%
%   With SIMSD(Model,U,N,'noise',KY), additive noise (e) is added to the
%   simulation in accordance with the noise model of Model.
%   KY denotes the output numbers to be plotted (default all).
%   
%   When called with output arguments
%   [Y,YSD] = SIMSD(Model,U)
%   no plots are created, but Y is returned as a cell array of the
%   simulated outputs and YSD is the estimated standard deviation of the 
%   outputs. If U is an IDDATA object, so are Y and YSD, otherwise they are 
%   returned as vectors (matrices). In the IDDATA case plot(Y{:}) will thus
%   plot all the responses.
%
%   SIMSD and SIM have similar syntaxes. Note that SIMSD computes the
%   standard deviation by Monte Carlo simulation, while SIM uses
%   differential approximations ('Gauss approximation formula.') They may
%   give different results.
%
%   See also IDMODEL/SIM.

%   L.Ljung 7-8-87
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $ $Date: 2004/04/10 23:17:41 $

if nargin < 2
    disp('Usage: SIMSD(MODEL,INPUT)')
    disp('       SIMSD(MODEL,INPUT,No_of_Sim,ADD_NOISE,OUTPUTS)')
    disp('       ADD_NOISE one of ''no_noise'', ''noise''.')
    return
end
if isa(u,'idmodel')
    th1 = u;
    u = th;
    th = th1;
end
[ny,nu] = size(th);
if nargin<5,ky=[];end
if nargin <4,noise=[];end
if length(noise)<3,noise=[];end
if nargin<3,n=[];end,
if isempty(ky),ky=1:ny;end
if isempty(noise),noise='nonoise';end
if isempty(n),n=10;end
iddataflag = 1;
Tsamp = pvget(th,'Ts');
if ~isa(u,'iddata')
    iddataflag = 0;
    if Tsamp==0
        error(sprintf(['For a continuous time system the input must be an iddata object.'...
                '\nUse U = IDDATA([],U,Tsamp).']))
    else
        u = iddata([],u,Tsamp);
    end
end
[N,dum,nud]=size(u);
if nu~=nud, 
    error('The input matrix U does not have the correct number of columns!'),
    return,
end
P = pvget(th,'CovarianceMatrix');
if strcmp(P,'None')
    disp('No covariance information given in the model.')
    d = length(pvget(th,'ParameterVector'));
    P=zeros(d,d);
end
if size(P)==0; 
    d = length(pvget(th,'ParameterVector'));
    P = zeros(d,d);
    try
        ut = pvget(th,'Utility');
        th1 = ut.Pmodel;
    catch
        th1 = [];
        warning('No covariance information given in the model.')
    end
    if ~isempty(th1)
        try
            P = pvget(th1,'CovarianceMatrix');
            th = th1;
        catch
            warning('No covariance information given in the model.')
        end
    end
end

par = pvget(th,'ParameterVector');
lam = pvget(th,'NoiseVariance');
d = length(par);
if norm(P)>0
    P=chol(P+1e4*eps*eye(size(P)));
end
tsd = pvget(u,'Ts');
tsd = tsd{1};
u1  = u;
yna = pvget(th,'OutputName');
k = 1;
while k<=n
    if k > 1
        th1 = parset(th,par+P'*randn(d,1));
    else
        th1 = th;
    end
    if noise(3)=='i',
        e = iddata([],randn(N,ny),tsd);
        u1=[u e];
    end %corr 9007
     try
        y{k}=sim(u1,th1);
        k=k+1;
    end
end
if nargout&n>1 %then compute ysd
    y0 = pvget(y{1},'OutputData');
    sd = zeros(size(y0{1}));
    for k = 2:n
        y1 = pvget(y{k},'OutputData');
        sd = sd + (y1{1}-y0{1}).^2;
    end
    if iddataflag
    ysdout = y{1};
    ysdout = pvset(ysdout,'OutputData',{sqrt(sd/(n-1))});
    yout = y;
else
    ysdout = sqrt(sd/(n-1));
    for k=1:n
        yout(k)=pvget(y{k},'OutputData');
    end
end
     
else % then plot
    for kk = ky
        yh = pvget(y{1},'OutputData');
        tim = pvget(y{1},'SamplingInstants');
        tim = tim{1};
        yh = yh{1};
        yh=yh(:,kk);
        ndu=length(yh);y1=max(yh);y2=min(yh);
        y12=y1-y2;y1=y1+0.2*y12;y2=y2-0.2*y12;
        subplot(length(ky),1,kk)
        plot(tim,yh,'k')
        axis([tim(1) tim(end) y2 y1]);hold on;
        title(['Output ',yna{kk}])
        
        for k=2:n
            yh=pvget(y{k},'OutputData');
            yh = yh{1};
            y1=max([y1;yh(:,kk)]);y2=min([y2;yh(:,kk)]);
            plot(tim,yh(:,kk))
        end
        axis([tim(1) tim(end) y2 y1]);
        hold off
    end
end
    set(gcf,'NextPlot','replace');
