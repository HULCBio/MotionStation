function  [mag,phase,w,sdamp,sdphase] = boderesp(sys,wdes);
%IDFRD/BODERESP  Computes a model's frequency function,along with its standard deviation
%   [MAG,PHASE,W] = BODERESP(G)   
%
%   where G is an IDFRD model object. 
%   MAG is the magnitude of the response and PHASE is the phase (in degrees).
%   The response is computed for the frequencies in G.Frequency. These are
%   returned in the vector W. The frequency unit is always rad/s, regardless of 
%   G.UNITS.
%
%   If M has NY outputs and NU inputs, and W contains NW frequencies, 
%   the MAG and PHASE are NY-by-NU-by-NW array such that MAG(ky,ku,k) gives 
%   the response frominput ku to output ky at the frequency W(k).
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
%   [MAG,PHASE,W] = BODERESP(M,WDES) returns the values in the frequency span from
%   Min(WDES) to Max(WDES).


%   
%   See also BODE, FFPLOT, NYQUIST and IDFRD.

%   L. Ljung 7-7-87,1-25-92
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2004/04/10 23:16:39 $

if nargin<1
   disp('Usage: [Mag,Phase,W] = BODERESP(M)')
   disp('       [Mag,Phase,W,SDMag,SDPhase] = BODERESP(M,FREQUENCIES)')
   return
end
if nargin<2
    wdes = [];
end
if nargin==2&~isempty(wdes)
   warning('Frequencies cannot be specified for IDFRD models.'),
end
%ut = sys.Utility;
% if isfield(ut,'bodeidx')
%     idx = ut.bodeidx;
% else
%     idx = [];
% end
% if ~isempty(idx)
%     sys = select(sys,idx);
% end

[GC,w,gccov]=freqresp(sys,wdes);
[ny,nu]=size(sys);
mag=abs(GC);
if nu == 0
   phase = zeros(size(mag));
else
   phase = (180/pi)*unwrap(atan2(imag(GC),real(GC)),[],3);
end


%
%   Now translate these covariances to those of abs(GC) and arg(GC)
%
if isempty(gccov)
   sdamp=[];sdphase=[];
else
   if nu == 0
      sdamp = sqrt(gccov);sdphase = zeros(size(sdamp));
   else 
      C1=gccov(:,:,:,1,1);C2=gccov(:,:,:,2,2);C3=gccov(:,:,:,1,2);
      sdamp=sqrt((real(GC).^2).*C1+2*((real(GC)).*(imag(GC))).*C3...
         +(imag(GC).^2).*C2)./abs(GC);
      sdphase=(180/pi)*sqrt((imag(GC).^2).*C1-2*((real(GC)).*imag(GC)).*C3...
         +(real(GC).^2).*C2)./(abs(GC).^2);
   end
end


