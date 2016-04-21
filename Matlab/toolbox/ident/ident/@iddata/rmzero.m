function [data,kzz] = rmzero(data)
%RMZERO Removes zero frequency from Frequency Domain Data

%	L. Ljung 03-08-10
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:20 $

kzz =cell(1,size(data,'Ne'));
if strcmp(data.Domain,'Time')
    return
end
fre = pvget(data,'SamplingInstants');
for kexp = 1:length(fre);
    kz = find(fre{kexp}==0);
    kzz{kexp} = kz;
    if ~isempty(kz)
        data.SamplingInstants{kexp}(kz)=[];
        data.InputData{kexp}(kz,:)=[];
        data.OutputData{kexp}(kz,:)=[];
    end
end
