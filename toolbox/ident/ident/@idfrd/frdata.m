function [response,freq,Ts,covR] = frdata(sys,flag)
%FRDATA  Quick access to frequency response data for IDFRD objects.
%
%   [RESPONSE,FREQ] = FRDATA(SYS) returns the response data and
%   frequency samples of the identified frequency response data (IDFRD) model SYS.
%
%   For a single model SYS with Ny outputs and Nu inputs, at Nw frequencies,
%   RESPONSE is a Ny-by-Nu-by-Nw array where the (I,J,K) element specifies
%   the response from input J to output I at frequency FREQ(K).  FREQ
%   is a column vector of length Nw which contains the frequency
%   samples of the FRD.
%
%   [RESPONSE,FREQ,TS,covRESP] = FRDATA(SYS) also returns the sample time TS.  Other
%   properties of SYS can be accessed with GET or by direct structure-like 
%   referencing (e.g., SYS.Ts). covRESP is the estimated covariance of the
%   response, see below.
%
%   For a single SISO model SYS, the syntax
%       [RESPONSE,FREQ,TS,covRESP] = FRDATA(SYS,'v')
%   returns the RESPONSE  and covRESP as column vectors rather than as
%   3-dimensional arrays.
%
%   covRESP is a 5D-array with covRESP(KY,KU,k,:,:)) as the 2-by-2 covariance
%   matrix of the response from input KU to output KY at frequency  FREQ(k).
%   The 1,1 element is the variance of the real part, the 2,2 element the variance
%   of the imaginary part and the 1,2 and 2,1 elements the covariance
%   between the real and imaginary parts. SQUEEZE(covH(KY,KU,k,:,:))
%   gives the covariance matrix of the correspondig response.
%
%   If SYS is a time series (no input), RESPONSE is returned as the (power) 
%   spectrum of the outputs; an NY-by-NY-by-NW array. Hence RESPONSE(:,:,k) 
%   is the spectrum matrix at frequency FREQ(k). The element RESPONSE(K1,K2,k) is
%   the cross spectrum between outputs K1 and K2 at frequency FREQ(k).
%   When K1=K2, this is the real-valued power spectrum of output K1. 
%   covRESP is then the covariance of the spectrum RESP, so that covRESP(K1,K1,k) is
%   the variance of the power spectrum out output K1 at frequnecy FREQ(k).
%   No information about the variance of the cross spectra is normally
%   given. (That is, covRESP(K1,K2,k) = 0 for K1 not equal to K2.)
%
%   If the model SYS is not a time series, use FREQRESP(SYS('n')) to obtain
%   the spectrum information of the noise (output disturbance) signals.

%
%   See also IDFRD, GET, IDPROPS, IDFRD/FREQRESP

 %       Copyright 1986-2003 The MathWorks, Inc.
%       $Revision: 1.1.4.1 $   $Date: 2004/04/10 23:16:42 $

[ny,nu] = size(sys);
if nu==0
    response = sys.SpectrumData;
    covR = sys.NoiseCovariance;
else
response = sys.ResponseData;
covR = sys.CovarianceData;
end
freq = sys.Frequency;


% Convenience syntax for SISO case
sizes = size(response);
if nargin>1 & isequal(sizes([1:2,4:end]),[1 1])
   response = response(:);
   covR = covR(:);
end

% Sample time
Ts = sys.Ts;

 
