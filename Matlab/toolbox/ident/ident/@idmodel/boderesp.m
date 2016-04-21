function  [mag,phase,w,sdamp,sdphase] = boderesp(sys,w);
%BODERESP  Computes a model's frequency function,along with its standard deviation
%   [MAG,PHASE,W] = BODERESP(M)   
%
%   where M is a model object (IDMODEL, IDPOLY, IDSS, IDFRD, or IDGREY). 
%   MAG is the magnitude of the response and PHASE is the phase (in degrees).
%   W is the vector of frequencies for which the response is computed. These
%   can be specified by [MAG,PHASE,W] = BODERESP(M,W). The frequency unit is
%   rad/s. Only frequencies up to the Nyquist frequency are considered.
%
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   the MAG and PHASE are NY-by-NU-by-NW array such that MAG(ky,ku,k) gives 
%   the response from input ku to output ky at the frequency W(k).
%
%   If M describes a time series, MAG is returned as its power spectrum and
%   PHASE will be identically zero.
%   Both discrete and continuous time models are handled.
%   
%   To obtain the disturbance (noise) spectrum associated with the outputs
%   of the model M, use BODERESP(M('noise')).  To access a particular
%   input/output response use BODERESP(M(ky,ku)).
%
%   The standard deviations for the magnitude and phase are obtained by
%   [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M).
%   
%   See also IDMODEL/BODE, FFPLOT, IDMODEL/NYQUIST and IDFRD.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.19.4.1 $ $Date: 2004/04/10 23:17:19 $

if nargin<1
   disp('Usage: [Mag,Phase,W] = BODERESP(M)')
   disp('       [Mag,Phase,W,SDMag,SDPhase] = BODERESP(M,FREQUENCIES)')
   return
end
if isnan(sys)
    mag=NaN;phase=NaN;w=NaN;
    sdamp=NaN;sdphase=NaN;
    warning('Model contains NaNs.')
    return
end
nu = size(sys,'nu');
if nu == 0
   timeseries = 1;
else
   timeseries = 0;
end

if nargin<2,w=[];end
if isempty(w)
    w = iddefw(sys,'b');
end
Ts = pvget(sys,'Ts');
if Ts>0
w = w(w<=pi/Ts); % only up to Nyquist
end
if nargout>3&~isa(sys,'idpoly')
   [thbbmod,sys,flag] = idpolget(sys);
   
   if flag
      try
         assignin('caller',inputname(1),sys)
      catch
      end
   end
   if isempty(thbbmod) % To avoid being asked again about calc
      sys=pvset(sys,'CovarianceMatrix','None');
   end
end
if nargout>3
   [GC,w,gccov]=freqresp(sys,w);     
else
   [GC,w] = freqresp(sys,w);
end

mag=abs(GC);
phase = (180/pi)*unwrap(atan2(imag(GC),real(GC)),[],3);
w=w(:);
if nargout<4,return,end
%
%   Now translate these covariances to those of abs(GC) and arg(GC)
%
if timeseries
   sdamp = sqrt(gccov); sdphase = zeros(size(gccov));
else
   if isempty(gccov)
      sdamp=[];sdphase=[];
   else      
      C1=gccov(:,:,:,1,1);C2=gccov(:,:,:,2,2);C3=gccov(:,:,:,1,2);
      sdamp=real(sqrt((real(GC).^2).*C1+2*((real(GC)).*(imag(GC))).*C3...
         +(imag(GC).^2).*C2))./abs(GC);
      sdphase=(180/pi)*sqrt((imag(GC).^2).*C1-2*((real(GC)).*imag(GC)).*C3...
         +(real(GC).^2).*C2)./(abs(GC).^2);
   end
end


