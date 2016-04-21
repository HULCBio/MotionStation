function [e,r]=resid(z,th,M,maxsize)
%RESID  Computes and tests the residuals associated with a model.
%   Calling RESID with a NON-IDMODEL argument is OBSOLETE.
%   See HELP IDMODEL/RESID instead.
 
%   L. Ljung 10-1-86,1-25-92
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.2 $ $Date: 2001/04/06 14:21:38 $

% The only reason for keeping this old version is to honor the old
% syntax [e,r] = resid(dat,m); resid(r) for redisplaying the plot.

if nargin < 1
   disp('Usage: RESID(DATA,MODEL)')
   disp('       E = RESID(DATA,MODEL,No_OF_LAGS,MAXSIZE)')
   return
end


% ** Set up the default values **
newplot;
[N,nz]=size(z);
maxsdef=idmsize(N);

if nargin<4, maxsize=maxsdef;end
if nargin<3, M=25;end
if maxsize<0,maxsize=maxsdef;end,if M<0, M=25;end
if nargin==1,[nz2,M1]=size(z);nz=sqrt(nz2);M=M1-2;N=z(1,M1-1);
ny=z(1,M1);nu=nz-ny;r=z(:,1:M);end
if nargin>1,
[N,nz]=size(z); nu=th(1,3);ny=nz-nu;
% *** Compute the residuals and the covariance functions ***

e=pe(z,th);

if nz>1, e1=[e z(:,ny+1:nz)];else e1=e;end
r=covf(e1,M,maxsize);
end
nr=0:M-1;plotind=0;
for ky=1:ny
ind=ky+(ky-1)*nz;
% ** Confidence interval for the autocovariance function **
sdre=2.58*(r(ind,1))/sqrt(N)*ones(M,1);
if nz==1,spin=111;else spin=210+plotind+1;end,subplot(spin)
plot(nr,r(ind,:)'/r(ind,1),nr,[ sdre -sdre]/r(ind,1),':r')
title(['Correlation function of residuals. Output # ',int2str(ky)])
xlabel('lag')
plotind=rem(plotind+1,2);
if plotind==0,pause,newplot;end
end


nr=-M+1:M-1;
% *** Compute confidence lines for the cross-covariance functions **
for ky=1:ny
for ku=1:nu
ind1=ky+(ny+ku-1)*nz;ind2=ny+ku+(ky-1)*nz;indy=ky+(ky-1)*nz;
indu=(ny+ku)+(ny+ku-1)*nz;
   %corr 891007
   sdreu=2.58*sqrt(r(indy,1)*r(indu,1)+2*(r(indy,2:M)*r(indu,2:M)'))/sqrt(N)*ones(2*M-1,1); % corr 890927
   spin=210+plotind+1;subplot(spin)
   plot(nr,[r(ind1,M:-1:1) r(ind2,2:M) ]'/(sqrt(r(indy,1)*r(indu,1))),...
        nr,[ sdreu -sdreu]/(sqrt(r(indy,1)*r(indu,1))),':r' )

   title(['Cross corr. function between input ' int2str(ku)...
         ' and residuals from output ',int2str(ky)])
   xlabel('lag')
   plotind=rem(plotind+1,2);if ky+ku<nz & plotind==0,pause,newplot;end
end,end
r(1,M+1:M+2)=[N,ny];
set(gcf,'NextPlot','replace');

