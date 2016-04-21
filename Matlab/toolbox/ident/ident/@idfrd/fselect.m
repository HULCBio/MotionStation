function idf = fselect(idf1,freqno,fmax)
%IDFRD/FSELECT Selects IDFRD model at certain frequencies
%
%   IDFM = FSELECT(IDF,INDEX) 
%
%   Returns an IDFRD model IDFM which is equal to the IDFRD model IDF
%   at frequencies F = IDF.frequency(INDEX).
%  
%   IDFM = FSELECT(IDF,FMin,FMax) 
%  
%   Returns IDFM with frequencies between FMin and FMax.
%
%   Examples: IDFM = FSELECT(IDF,5:5:100).
%
%     Select the response in the 3rd quadrant:
%     ph = angle(squeeze(IDF.response));
%     IDFM = FSELECT(IDF,find(ph > -pi & ph < -pi/2))
%
%     IDFM = FSELECT(IDF,0.1, 0.4)  
%     selects responses at frequencies between 0.l and 0.4 (measured in
%     the unit IDF.units.)

% Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2004/04/10 23:16:44 $

if nargin<2
    disp('Usage: IDFM = FSELECT(IDF,FREQ_NOS)')
    if nargout
        idf = [];
    end
    return
end
w = idf1.Frequency;
if nargin==3
    fmin = freqno;
    
    if fmax<=fmin
        error('The second value of the frequency range must be larger than the first one.')
    end
    freqno = find(w<fmax&w>fmin);
end
idf = idf1;
idf.Frequency = idf.Frequency(freqno);
if ~isempty(idf.ResponseData)
    idf.ResponseData = idf.ResponseData(:,:,freqno);
end
if ~isempty(idf.SpectrumData)
    idf.SpectrumData = idf.SpectrumData(:,:,freqno);
end
if ~isempty(idf.CovarianceData)
    idf.CovarianceData = idf.CovarianceData(:,:,freqno,:,:);
end
try
    idf.NoiseCovariance = idf.NoiseCovariance(:,:,freqno);
end
