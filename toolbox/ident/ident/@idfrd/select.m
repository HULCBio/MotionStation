function idf = select(idf1,freqno)
%IDFRD/SELECT Selects IDFRD model at certain frequencies
%
%   IDFM = SELECT(IDF,FREQ_NOS)
%   Returns an IDFRD model IDFM which is equal to the IDFRD model IDF
%   at frequencies W = IDF.frequency(FREQ_NOS).
%
%   Examples: IDFM = SELECT(IDF,5:5:100)
%     Select the response in the 3rd quadrant:
%     rsp = squeeze(IDF.response);
%     IDFM = SELECT(IDF,find(angle(rsp)>-pi & angle(rsp)<-pi/2))

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/10 23:16:51 $

if nargin<2
    disp('Usage: IDFM = SELECT(IDF,FREQ_NOS)')
    if nargout
        idf = [];
    end
    return
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
