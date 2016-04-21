function idsimsd(u,th,n,noise,ky)
%IDSIMSD Illustrates the uncertainty in simulated model responses.
%   IDSIMSD(U,Model)
%
%   U is an IDDATA object or a column vector (matrix) containing the input(s).
%   Model is a model given any any IDMODEL object (IDPOLY, IDARX, IDSS or IDGREY). 
%   10 random models are created, consistent with the covariance informa-
%   tion in Model, and the responses of each of these models to U are plotted
%   in the same diagram.
%
%   The number 10 can be changed to N by IDSIMSD(U,Model,N).
%
%   With IDSIMSD(U,Model,N,'noise',KY), additive noise (e) is added to the
%   simulation in accordance with the noise model of Model.
%   KY denotes the output numbers to be plotted (default all).
%
%   See also IDSIM.

%   L.Ljung 7-8-87
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2001/04/06 14:22:30 $

if nargin < 2
   disp('Usage: IDSIMSD(INPUT,MODEL)')
   disp('       IDISMSD(INPUT,MODEL,ADD_NOISE,OUTPUTS)')
   disp('       ADD_NOISE one of ''no_noise'', ''noise''.')
   return
end

ny = size(th,'ny');
if nargin<5,ky=[];end
if nargin <4,noise=[];end
if nargin<3,n=[];end,
if isempty(ky),ky=1:ny;end
if isempty(noise),noise='nonoise';end
if isempty(n),n=10;end
nu = size(th,'nu');
Tsamp = pvget(th,'Ts');

%[Nc,d]=getncap(th);
if isa(u,'iddata')
   u = pvget(u,'InputData');u=u{1};
   end
[N,nz]=size(u);
if nu~=nz, 
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
   try
      ut = pvget(th,'Utility');
      th = ut.Pmodel;
      P = pvget(th,'CovarianceMatrix');
   catch
      disp('No covariance information given in the model.')
      d = length(pvget(th,'ParameterVector'));
      P=zeros(d,d);
   end
end
par = pvget(th,'ParameterVector');
lam = pvget(th,'NoiseVariance');
d = length(par);
 if norm(P)>0
   P=chol(P);
end

u1=u;
yna = pvget(th,'OutputName');
for kk=ky
   if noise(3)=='i', 
      u1=[u randn(N,ny)];
   end %corr 9007
   yh=idsim(u1,th);yh=yh(:,kk);
   ndu=length(yh);y1=max(yh);y2=min(yh);
   y12=y1-y2;y1=y1+0.2*y12;y2=y2-0.2*y12;
   subplot(length(ky),1,kk)
   plot([1:ndu]*Tsamp,yh),axis([Tsamp ndu*Tsamp y2 y1]);hold on;
      title(['Output ',yna{kk}])
   u1=u;
   for k=1:n-1
      th1 = parset(th,par+P*randn(d,1));
      if noise(3)=='i', 
         u1=[u randn(N,ny)];
      end
      yh=idsim(u1,th1);
      plot([1:ndu]*Tsamp,yh(:,kk))
   end
   hold off
   %if kk<ky(length(ky)),pause,end
end
set(gcf,'NextPlot','replace');
