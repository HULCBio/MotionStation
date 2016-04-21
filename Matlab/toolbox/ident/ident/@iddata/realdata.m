function ind = realdata(data)
%REALDATA flags if an iddata object corresponds to a real time domain data
%
%   REALDATA(DATA) returns 1 if DATA is a real time domain data set, and
%   0 otherwise
%
%   For time domain data this is the same as ISREAL.
%   For frequency domain data real time domain data means that no data
%   values for negative frequencies are specified.
%
%   See also IDDATA/ISREAL and IDDATA/COMPLEX

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:16:18 $


ind = 0;
dom = data.Domain;
if lower(dom(1))=='t';
    ind = isreal(data);
else
    [N,ny,nu,Nexp]=size(data);
    
     fre = data.SamplingInstants;
    for kexp = 1:Nexp
        if round(N(kexp)/2) == N(kexp)/2
            mitt = N(kexp)/2;
            even = 1;
        else
            mitt = (N(kexp)+1)/2;
            even = 0;
        end
        if all(fre{kexp}>=0)
            ind = 1;
        else
            if norm(conj(data.OutputData{kexp}(1:mitt-1,:))-...
                    data.OutputData{kexp}(end-even:-1:mitt+1,:))<10000*eps&...
                   norm(conj(data.InputData{kexp}(1:mitt-1,:))-...
                    data.InputData{kexp}(end-even:-1:mitt+1,:))<10000*eps 
                ind = 1;
            end
        end
    end
end