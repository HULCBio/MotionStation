function [z,kzz] = zfcheck(z,m)
%ZFCHECK Removes zero frequency from Frequency Domain Data if model
%contains an integration
%
%   Internal function
%   z data, m model, kzz removed freqnumbers (cell array)

%	L. Ljung 03-08-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1.4.1 $  $Date: 2004/04/10 23:20:34 $

zfflag = 0;
kzz = cell(1,size(z,'Ne'));
if strcmp(pvget(z,'Domain'),'Frequency')
    fre = pvget(z,'SamplingInstants');
    for kexp = 1:length(fre)
        if any(fre{kexp}==0)
            zfflag = 1;
        end
    end
end
if zfflag
    was = warning;
    warning off
    fr = freqresp(m,0);
    warning(was)
    if any(isinf(fr))|any(isnan(fr))
        warning(sprintf(['Frequency zero has been removed from the data set',...
                '\nsince the model contains an integration.']))
        [z,kzz] = rmzero(z);
    end
end