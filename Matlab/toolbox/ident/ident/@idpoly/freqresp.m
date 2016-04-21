function [frresp,w,covresp]=freqresp(sys,w)
%FREQRESP Frequency reponse of IDPOLY models.
%
%   H = FREQRESP(M,W) computes the frequency response H of the 
%   IDPOLY model M at the frequencies specified by the vector W.
%   These frequencies should be real and in radians/second.  
% 
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   the output H is a NY-by-NU-by-NW array such that H(:,:,k) gives 
%   the response at the frequency W(k).
%
%   For a SISO model, use SQUEEZE(H) (See HELP SQUEEZE) to obtain a
%   vector of the frequency response.
%
%   [H,W,DH] = FREQRESP(M,W) also returns the frequencies W and the 
%   covariance DH of the response. DH is a 5D-array where 
%   DH(KY,KU,k,:,:)) is the 2-by-2 covariance matrix of the response
%   from input KU to output KY at frequency  W(k). The 1,1 element
%   is the variance of the real part, the 2,2 element the variance
%   of the imaginary part and the 1,2 and 2,1 elements the covariance
%   between the real and imaginary parts. SQUEEZE(DH(KY,KU,k,:,:))
%   gives the covariance matrix of the correspondig response.
%
%   If M is a time series (no input), H is returned as the (power) 
%   spectrum of the outputs; an NY-by-NY-by-NW array. Hence H(:,:,k) 
%   is the spectrum matrix at frequency W(k). The element H(K1,K2,k) is
%   the the cross spectrum between outputs K1 and K2 at frequency W(k).
%   When K1=K2, this is the real-valued power spectrum of output K1. 
%   DH is then the covariance of the spectrum H, so that DH(K1,K1,k) is
%   the variance of the power spectrum out output K1 at frequnecy W(k).
%   No information about the variance of the cross spectra is normally
%   given. (That is, DH(K1,K2,k) = 0 for K1 not equal to K2.)
%
%   If the model M is not a time series, use FREQRESP(m('n')) to obtain
%   the spectrum information of the noise (output disturbance) signals.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.18.4.1 $ $Date: 2004/04/10 23:16:30 $ 

if nargin<1
    disp('Usage: H = FREQRESP(MOD)')
    disp('       [H,W,DH] = FREQRESP(MOD,W)')
    return
end 
T=pvget(sys.idmodel,'Ts');

% *** Set up default values ***

if nargin<2, w=[];end
if isempty(w)
    w = iddefw(sys,'n');
end
w =w(:);
if T>0 & any(w>pi/T+eps*1e4),
    w = w(find(w<=pi/T+eps*1e4));
    warning('Frequencies in w exceeding the Nyquist frequency have been removed.'),
end
P=pvget(sys.idmodel,'CovarianceMatrix'); 


% *** Compute the model polynomials and form the basic
%      matrix of frequencies ***

[a,b,c,d,f]=polydata(sys);
nu=size(b,1);
timeseries = 0;
if nu==0,timeseries = 1; end
nnu=1:nu;
if isempty(P)|ischar(P),
    isP=0;
else 
    isP=1;
end
na=sys.na;nb=sys.nb;nc=sys.nc;nd=sys.nd;
nf=sys.nf;nk=sys.nk;nnd=na+sum(nb)+nc+nd+sum(nf);
nm=max([length(a)+length(f)-1 length(b) length(c) length(d)+length(a)-1]);
i=sqrt(-1);
if T>0,OM=exp(-i*[0:nm-1]'*w'*T);end
if T<=0,
    OM=ones(1,length(w));
    for kom=1:nm-1
        OM=[OM;(i*w').^kom];
    end
end

% *** Compute the transfer function(s) GC=B/AF ***
frresp=zeros(1,nu,length(w)); 

sc=1;kf=0;ks=0;nrc=length(w)+1;
if ~timeseries
    covresp=zeros(1,nu,length(w),2,2);
    delays = pvget(sys,'InputDelay');
    if isempty(delays),delays=zeros(nu,1);end
    if T>0, delays = delays*T;end
    for k=nnu
        gn=conv(a,f(k,:));
        if T>0
            indb=1:length(b(k,:));indg=1:length(gn);
        else 
            indb=length(b(k,:)):-1:1; indg=length(gn):-1:1;
        end
        GC=(b(k,:)*OM(indb,:))./(gn*OM(indg,:));
        if delays(k)>0
            GC = GC.*exp(-i*w'*delays(k));
        end
        frresp(1,k,:)=GC;
        ll=[1:na,na+ks+1:na+ks+nb(k),na+sum(nb)+nc+nd+kf+1:na+sum(nb)+nc+nd+kf+nf(k)];
        ks=ks+nb(k);kf=kf+nf(k); 
        if nargout >2
            if isP,
                P1=P(ll,ll);
                if nb(k)==0
                    C1=zeros(length(OM),1);C2=C1;C3=C1;  
                else
                    [C1,C2,C3]=ffsdcal(a,b(k,1:nb(k)+nk(k)),f(k,1:nf(k)+1),na,...
                        nb(k),nf(k),nk(k),GC,OM,P1,T); 
                end
                covresp(1,k,:,1,1)=C1; 
                covresp(1,k,:,1,2)=C3; 
                covresp(1,k,:,2,1)=conj(C3); 
                covresp(1,k,:,2,2)=C2; 
            end
        end
    end % if nargout
else % timeseries
    % Now for the spectrum
    covresp =[];
    covresp = zeros(1,1,length(w));
    hn=conv(a,d);
    if T>0,
        indc=1:length(c);
        indh=1:length(hn);
    else   
        indc=length(c):-1:1; 
        indh=length(hn):-1:1;
    end
    H=(c*OM(indc,:))./(hn*OM(indh,:));
    lam = pvget(sys.idmodel,'NoiseVariance');
    if T == 0
        Tmod = 1;
    else
        Tmod = T;
    end
    frresp(1,1,:)=(abs(H).^2)'*lam*Tmod;
    %
    % *** Compute the standard deviation of the spectrum ***
    if isP & nargout>2,
        try
            idm = sys.idmodel;
            ei = pvget(idm,'EstimationInfo');
            Ncap=ei.DataLength;
            if isempty(Ncap),Ncap=inf;end
        catch
            Ncap=inf;
        end
        if ~isempty(Ncap)
            ll=[1:na,na+sum(nb)+1:na+sum(nb)+nc+nd];
            P1=P(ll,ll);
            [C1,C2,C3,varamp]=ffsdcal(a,c,d,na,nc,nd,1,H,OM,P1,T);
            var(1,1,:)=varamp;
            covresp(1,1,:) = (2/Ncap)*frresp.^2 + lam^2*Tmod^2*var;
            % assuming e to be normal so that Var lam = 2*lam^2/N
            
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [C1,C2,C3,varamp]=ffsdcal(a,b,f,na,nb,nf,nk,GC,OM,P,T)
%FFSDCAL Auxiliary function  
%
%   [C1,C2,C3,varamp]=ffsdcal(a,b,f,na,nb,nf,nk,GC,OM,P,T)
%   [C1  C2]
%   [C2' C3]    is the covariance matrix of (b/af)
%
%   varamp is the variance of |a/bf|^2
%   D3 = " dGC/dTHETA "
%
if T>0,
    D3=[((-GC./(a*OM(1:na+1,:)))'*ones(1,na)).*OM(2:na+1,:)',...
            ((GC./(b*OM(1:length(b),:)))'*ones(1,nb)).*OM(nk+1:nk+nb,:)',...
            ((-GC./(f*OM(1:nf+1,:)))'*ones(1,nf)).*OM(2:nf+1,:)'];
else
    D3=[((-GC./(a*OM(na+1:-1:1,:)))'*ones(1,na)).*OM(na:-1:1,:)',...
            ((GC./(b*OM(length(b):-1:1,:)))'*ones(1,nb)).*OM(nb:-1:1,:)',...
            ((-GC./(f*OM(nf+1:-1:1,:)))'*ones(1,nf)).*OM(nf:-1:1,:)'];
end


D4=D3*P;
%
%   The matrix [C1 C3;conj(C3) C2] is the covariance matrix of [Re GC; Im GC]
%   according to Gauss' approximation formula
%
C1=sum((real(D4).*real(D3))')';
C2=sum((imag(D4).*imag(D3))')';
C3=sum((imag(D4).*real(D3))')';
%
%   Now translate these covariances to those of abs(GC) and arg(GC)
if nargout>3
    varamp = 4*((real(GC').^2).*C1+2*((real(GC')).*(imag(GC'))).*C3...
        +(imag(GC').^2).*C2);
end
