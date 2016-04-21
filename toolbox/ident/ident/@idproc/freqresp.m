function [frresp,w,covresp]=freqresp(sys,w)
%FREQRESP Frequency response of IDPROC models.
%
%   H = FREQRESP(M,W) computes the frequency response H of the 
%   IDPROC model M at the frequencies specified by the vector W.
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

%   L. Ljung 03-16-03
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2003/11/11 15:52:17 $ 


if nargin<2, w=[];end
if isempty(w)
    w = iddefw(sys,'n');
end
w =w(:);
covresp =[];
frresp =[];
OM=ones(1,length(w));
for kom=1:3
    OM=[OM;(i*w').^kom];
end

Kp = pvget(sys,'Kp');
Tp1 = pvget(sys,'Tp1');
Tp2 = pvget(sys,'Tp2');
Tp3 = pvget(sys,'Tp3');
type = i2type(sys);
Tw = pvget(sys,'Tw');
Zeta = pvget(sys,'Zeta');
Tz = pvget(sys,'Tz');
Td = pvget(sys,'Td');
nu = size(type,2);
cov = pvget(sys,'CovarianceMatrix');
for ku = 1:nu
    typek = type{ku};
    kp = Kp.value(ku);
    if any(typek=='U')
        tw = Tw.value(ku);
        zeta = Zeta.value(ku);
    else
        tp1 = Tp1.value(ku);
        tp2 = Tp2.value(ku);
        % tw = sqrt(tp1*tp2);
        % zeta = (tp1+tp2)/2/tw;
    end
    tp3 = Tp3.value(ku);
    tz = Tz.value(ku);
    td = Td.value(ku);
    num = [1 tz]*OM(1:2,:);
    if any(typek=='U')
        den = [1,2*zeta*tw+tp3,tw^2+2*zeta*tw*tp3,tp3*tw^2]*OM;
    else
        den = [1,tp1+tp2+tp3,tp1*tp2+tp2*tp3+tp1*tp3,tp1*tp2*tp3]*OM;
    end
    if any(typek=='I')
        den = den.*(i*w.');
    end
    dgdk = num./den.*exp(-i*w.'*td);
    g = kp*dgdk;
    frresp(1,ku,:)=g;
    dgdtz = kp*OM(2,:)./den;
    if any(typek=='U')
        dgdtw = -g./den.*([0 2*zeta,2*tw+2*zeta*tp3,2*tw*tp3]*OM);
        dgdzeta = -g./den.*([2*tw,2*tw*tp3]*OM([2:3],:));
        dgdtp3 = -g./den.*([0, 1, 2*zeta*tw, tw^2]*OM);
    else
        dgdtp1 = -g./den.*([0 1 tp2+tp3 tp2*tp3]*OM);
        dgdtp2 = -g./den.*([0 1 tp1+tp3 tp1*tp3]*OM);
        dgdtp3 = -g./den.*([0 1 tp2+tp1,tp1*tp2]*OM);
    end
    dgdtd = g.*(-i*w.');
    dgdp = zeros(length(w),0);
    np = 0;
    if strcmp(lower(Kp.status{ku}),'estimate')
        dgdp = [dgdp,dgdk.'];
        np = np+1;
    end
    if strcmp(lower(Tp1.status{ku}),'estimate')
        dgdp = [dgdp,dgdtp1.'];
        np = np+1;
    end
    if strcmp(lower(Tp2.status{ku}),'estimate')
        dgdp = [dgdp,dgdtp2.'];
        np = np+1;
    end
    
    if strcmp(lower(Tw.status{ku}),'estimate')
        dgdp = [dgdp,dgdtw.'];
        np = np+1;
    end
    if strcmp(lower(Zeta.status{ku}),'estimate')
        dgdp = [dgdp,dgdzeta.'];
        np = np+1;
    end
    if strcmp(lower(Tp3.status{ku}),'estimate')
        dgdp = [dgdp,dgdtp3.'];
        np = np+1;
    end
    if strcmp(lower(Td.status{ku}),'estimate')
        dgdp = [dgdp,dgdtd.'];
        np = np+1;
    end
    if strcmp(lower(Tz.status{ku}),'estimate')
        dgdp = [dgdp,dgdtz.'];
        np = np+1;
    end
    if isa(cov,'double')&~isempty(cov)
        P = cov(1:np,1:np);
        cov = cov(np+1:end,np+1:end);
        D4=dgdp*P;
        %
        %   The matrix [C1 C3;conj(C3) C2] is the covariance matrix of [Re GC; Im GC]
        %   according to Gauss' approximation formula
        %
        if size(D4,2)>1
        C1=sum((real(D4).*real(dgdp))')';
        C2=sum((imag(D4).*imag(dgdp))')';
        C3=sum((imag(D4).*real(dgdp))')';
    else
        C1=real(D4).*real(dgdp);
        C2=imag(D4).*imag(dgdp);
        C3=imag(D4).*real(dgdp);
    end
        
        covresp(1,ku,:,1,1)=C1; 
        covresp(1,ku,:,1,2)=C3; 
        covresp(1,ku,:,2,1)=conj(C3); 
        covresp(1,ku,:,2,2)=C2;
    end
end