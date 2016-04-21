function [ir,r,cl]=cra(z,M,n,fp)
%CRA    Performs correlation analysis to estimate impulse response.
%   IR = CRA(Z)
%
%   Z: The data, entered as an IDDATA object or a matrix 
%      with two columns Z = [y u].
%   IR: The estimated impulse response (IR(1) corresponds to g(0))
%
%   [IR,R,CL] = CRA(Z,M,NA,PLOT) gives access to
%   M: The number of lags for which the functions are computed (def 20)
%   NA: The order of the whitening filter.(Def 10). With NA=0, no prewhite-
%       ning is performed. Then the covariance functions of the original
%       data are obtained.
%   PLOT: PLOT=0 gives no plots. PLOT=1 (Default) gives a plot of IR along
%       with a 99 % confidence region. PLOT=2 gives a plot of all R's.
%
%   Note that in the plot, the response to a normalized pulse input,
%      u(t) = 1/T for 0<t<T, is shown, where T is the sampling interval
%      of the data.
%
%   R: The covariance/correlation information
%      R(:,1) contains the lag indices
%      R(:,2) contains the covariance function of y (poss. prewhitened)
%      R(:,3) contains the covariance function of u (poss. prewhitened)
%      R(:,4) contains the correlation function between (poss prewhitened)
%        u and y (positive lags corresponds to an influence from u to y)
%      CL is the 99 % significance level for the impulse response
%      The plots can be redisplayed by CRA(R);
%
%   See also IMPULSE.

%   L. Ljung 10-2-90,1-9-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:18:55 $

if nargin<1
   disp('Usage: IR = CRA(Z);')
   disp('       IR = CRA(Z,No_OF_LAGS,FILTER_ORDER);')
   return
end
dom = 't';
if isa(z,'frd')|isa(z,'idfrd')
    dom = 'f';
end
if isa(z,'iddata')
     dom = lower(pvget(z,'Domain'));dom = dom(1);
   T = pvget(z,'Ts'); 
   if length(T)>1
       warning('CRA only uses data from the first experiment.')
   end
       T = T{1};
   y = pvget(z,'OutputData'); y = y{1};
   u = pvget(z,'InputData'); u = u{1};
   z = [y u];
else
   T = 1;
end
if dom=='f'
    error('CRA currently does not apply to Frequency Domain data.')
end
[Ncap,nz]=size(z);redisp=0;
if nz==4, if z((Ncap+1)/2,1)==0, redisp=1;end,end
if nz>2 & ~redisp,
   error(sprintf(['This routine is for two data records only.',...
         '\nTo check correlations between more signals, ',...
         '\nuse cra for two signals at a time.']))
end
if redisp, r=z; n=0;fp=2;end

if ~redisp
   if nargin<4, fp=[];end
   if nargin<3, n=[];end
   if nargin<2, M=[];end
   if isempty(fp),fp=1;end
   if isempty(n),n=10;end
   if isempty(M),M=20;end
   if n>=Ncap,n=floor(Ncap/2);disp(['Warning: Cra filter order changed to ',int2str(n)]);end
   if M>=Ncap,M=floor(Ncap/2);disp(['Warning: Cra number of lags changed to ',int2str(M)]);end
   if nz==1, error('For a single signal, use covf instead!'),end
   if n>0
      a=th2poly(ar(z(:,2),n,'fb0'));
      z(:,1)=filter(a,1,z(:,1));
      z(:,2)=filter(a,1,z(:,2));
   end
   %M=M-1;
   if M<=0|round(M)~=M 
       error('The number of lags, M, must be a positive integer.')
   end
   Rcap=covf(z,M+1);
   r(:,1)=[-M:1:M]';
   r(M+1:2*M+1,2:3)=Rcap([1 4],:)';
   r(1:M,2:3)=Rcap([1 4],M+1:-1:2)';
   scir=Rcap(4,1); sccf=sqrt(Rcap(1,1)*Rcap(4,1));
   r(M+1:2*M+1,4)=Rcap(2,:)'/sccf;
   r(1:M,4)=Rcap(3,M+1:-1:2)'/sccf;
   ir=r(M+1:2*M+1,4)*sccf/scir;
   sdreu=2.58*sqrt(r(:,3)'*r(:,2))/scir/sqrt(Ncap)*ones(2*M+1,1);
   cl=sdreu(1);
end
if fp>1 | redisp
   newplot; %clf reset
   subplot(221)
   plot(r(:,1),r(:,2)),
   if n>0,title('Covf for filtered y'),else title('Covf for y'),end
   subplot(222)
   plot(r(:,1),r(:,3)),
   if n>0,title('Covf for prewhitened u'),else title('Covf for u'),end
   subplot(223)
   plot(r(:,1),r(:,4))
   if n>0,title('Correlation from u to y (prewh)'),else title('Correlation from u to y'),end
   
   if ~redisp,
      subplot(224),plot(r(:,1),r(:,4)*sccf/scir/T)
      hold on,plot(r(:,1),sdreu/T,'g-.',r(:,1),-sdreu/T,'g-.'),hold off
      title('Impulse response estimate')
   end
elseif fp==1,
   newplot; %clf reset
   timeax=[0:length(ir)-1];
   stem(timeax,ir/T),line(timeax,cl/T*ones(1,length(ir)),'Linestyle','-.'),
   line(timeax,-cl/T*ones(1,length(ir)),'Linestyle','-.'),
   title('Impulse response estimate'),xlabel('lags')
end
if fp>0
   set(gcf,'NextPlot','replace');
end
