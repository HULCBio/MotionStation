function [fr1,w,covff] = freqresp(sys,w)
%FREQRESP Frequency reponse of IDMODEL models.
%
%   H = FREQRESP(M,W) computes the frequency response H of the 
%   IDMODEL model M at the frequencies specified by the vector W.
%   These frequencies should be real and in radians/second. If W is
%   omitted a default choice is made.
% 
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives 
%   the response at the frequency W(k).
%
%   For a SISO model, use SQUEEZE(H) (See HELP SQUEEZE) to obtain a
%   vector of the frequency response.
%
%   [H,W,covH] = FREQRESP(M,W) also returns the frequencies W and the 
%   covariance covH of the response. covH is a 5D-array where 
%   covH(KY,KU,k,:,:)) is the 2-by-2 covariance matrix of the response
%   from input KU to output KY at frequency  W(k). The 1,1 element
%   is the variance of the real part, the 2,2 element the variance
%   of the imaginary part and the 1,2 and 2,1 elements the covariance
%   between the real and imaginary parts. SQUEEZE(covH(KY,KU,k,:,:))
%   gives the covariance matrix of the correspondig response.
%
%   If M is a time series (no input), H is returned as the (power) 
%   spectrum of the outputs; an NY-by-NY-by-NW array. Hence H(:,:,k) 
%   is the spectrum matrix at frequency W(k). The element H(K1,K2,k) is
%   the the cross spectrum between outputs K1 and K2 at frequency W(k).
%   When K1=K2, this is the real-valued power spectrum of output K1. 
%   covH is then the covariance of the spectrum H, so that covH(K1,K1,k) is
%   the variance of the power spectrum out output K1 at frequnecy W(k).
%   No information about the variance of the cross spectra is normally
%   given. (That is, covH(K1,K2,k) = 0 for K1 not equal to K2.)
%
%   If the model M is not a time series, use FREQRESP(m('n')) to obtain
%   the spectrum information of the noise (output disturbance) signals.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/04/10 23:17:24 $

if nargin<2, w=[];end
T=sys.Ts;
if isempty(w)
    w = iddefw(sys,'n');
end
[nrw,ncw]=size(w);if nrw>ncw, w=w.';end
w=w(:);
% Let nargout determine whether to compute sd
[a,b,c,d,k]=ssdata(sys); [nx,nu]=size(b);[ny,nx]=size(c);
if sys.Ts>0&max(w>pi/sys.Ts+eps*1e4)
    w = w(find(w<=pi/sys.Ts+eps*1e4));
    warning('Frequencies in w exceeding the Nyquist frequency have been removed.')
end
try
    Ncap=th.EstimationInfo.DataLength;
    if isempty(Ncap),Ncap=inf;end
catch
    Ncap=inf;
end
nnu=1:nu;
nny=1:ny;
lambda=sys.NoiseVariance;
if nargout>2
    if isa(sys,'idpoly')
        thbbmod = {sys};
    else
        [thbbmod,sys,flag] = idpolget(sys);
        if flag
            try
                assignin('caller',inputname(1),sys)
            catch
            end
        end
    end
end
delays = sys.InputDelay;
if isempty(delays),delays=zeros(nu,1);end
if T>0, delays = T*delays;end

timeseries = 0;
if nu==0
    timeseries = 1;
    lams = sqrtm(lambda);
    b = k*lams;
    d = lams;
    nu = ny;nnu=1:nu;
    delays = zeros(1,nu);
end 
fr1=zeros(ny,nu,length(w));


for ku=nnu
    [ff]=trfsaux(a,b,c(nny,:),d(nny,:),ku,w,T);   
    if delays(ku)~=0
        ff = ff.*(exp(-i*w*delays(ku))*ones(1,length(nny)));
    end
    
    for ky=nny
        fr1(ky,ku,:)=ff(:,ky);
    end
end
if timeseries % then we have the time-series case
    fr=zeros(ny,nu,length(w));
    for ky=nny
        for ku=nnu
            for k=[1:ny]
                fr(ky,ku,:)=fr(ky,ku,:)+fr1(ky,k,:).*conj(fr1(ku,k,:));
            end
        end
    end
    fr1=fr;
    if T>0
        fr1 = fr1*T; 
    end
end

if nargout>2
    if isempty(thbbmod)
        covff=[];
        return
    end
    if isempty(pvget(thbbmod{1},'CovarianceMatrix'))
        covff=[];
        return
    end
    if ~timeseries
        covff=zeros(ny,nu,length(w),2,2);
        for ky=nny
            thbb=thbbmod{ky};
            [dum,dum,covtemp]=freqresp(thbb(1,1:nu),w);
            covff(ky,:,:,:,:) = covtemp;
        end
    else % if time series
        covff=zeros(ny,nu,length(w));
        for ky=nny
            pp=zeros(length(w),1);psd=pp;
            thbb = thbbmod{ky};
            cov = spsdcal(thbb,w,T);
            covff(ky,ky,:)=cov;
        end
        if T>0, covff=covff*(T^2);end
    end % inf nu>0
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function g = trfsaux(a,b,c,d,iu,w,Tsamp)
%TRFSAUX        Auxiliary function to TRFSS
%
%   [mag,phase] = trfsaux(a,b,c,d,ku,w,T)

%   L. Ljung 10-2-90
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $  $Date: 2004/04/10 23:17:24 $

[no,ns] = size(c);
nw = length(w);

[t,a] = balance(a);
b = t \ b;
c = c * t;
[p,a] = hess(a);
b = p' * b(:,iu);
c = c * p;
d = d(:,iu);
if Tsamp>0 w = exp(Tsamp*w * sqrt(-1)); else w = w * sqrt(-1);end
try
    g = ltifr(a,b,w);
catch
    g = mimofr(a,b,[],[],w(:));
    g = reshape(g,[length(a) prod(size(w))]);
end

g = c * g + diag(d) * ones(no,nw);
g=g.';
%%%%%%%%%%%%%%%%%%%
function [C1]=spsdcal(thbb,w,T)
%SPSDCAL Auxiliary function  
%
%   [cov]=spsdcal(a,b,f,na,nb,nf,nk,GC,OM,P,T)
%   The spectrum is S=T*\sum |b_k/(a*f_k)|^2
%   Cov is the covariance of S
%   D3 = " dGC/dTHETA "
%
[a,b,c,d,f]=polydata(thbb);
na = pvget(thbb,'na');
nb = pvget(thbb,'nb');
nk = pvget(thbb,'nk');
nf = pvget(thbb,'nf');
P = pvget(thbb,'CovarianceMatrix');
nm=max([length(a)+length(f)-1 length(b) length(c) length(d)+length(a)-1]);
i=sqrt(-1);
if T>0,
    OM=exp(-i*[0:nm-1]'*w(:)'*T);
else
    OM=ones(1,length(w));
    for kom=1:nm-1
        OM=[OM;(i*w').^kom];
    end
end


[nu,nbb] = size(b);
[nu,nff]=size(f);
D3=zeros(length(w),na);D3f=[];
for ku = 1:nu
    if nb(ku)>0
        if T>0
             hci = abs((b(ku,:)*OM(1:nbb,:))./((a*OM(1:na+1,:)).*(f(ku,:)*OM(1:nff,:)))).^2;
              D3(:,1:na) = D3(:,1:na) -((hci./(a*OM(1:na+1,:)))'*ones(1,na)).*OM(2:na+1,:)';
             D3 = [D3,((hci./(b(ku,:)*OM(1:nbb,:)))'*...
                    ones(1,nb(ku))).*OM(nk(ku)+1:nk(ku)+nb(ku),:)'];
            D3f=[D3f,((-hci./(f(ku,:)*OM(1:nff,:)))'*ones(1,nf(ku))).*OM(2:nf(ku)+1,:)'];
        else
            hci = abs((b(ku,:)*OM(nbb:-1:1,:))./((a*OM(na+1:-1:1,:)).*(f(ku,:)*OM(nff:-1:1,:)))).^2;
            D3(:,1:na) = D3(:,1:na) -((hci./(a*OM(na+1:-1:1,:)))'*ones(1,na)).*OM(na:-1:1,:)';
            D3 = [D3,((hci./(b(ku,:)*OM(nbb:-1:1,:)))'*ones(1,nb(ku))).*OM(nb(ku):-1:1,:)'];
            D3f = [D3f,((-hci./(f(ku,:)*OM(nff:-1:1,:)))'*ones(1,nf(ku))).*OM(nf(ku):-1:1,:)'];
        end
    end
end
D3=2*[D3,D3f];
D4=D3*P;
C1=sum((real(D4).*real(D3))')';
