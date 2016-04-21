function zec = complex(ze)
% COMPLEX Makes an IDDATA object flag complex data
%
%   DATC = COMPLEX(DATA) 
%
%   For time domain data, DATC will contain inputs and outputs that are
%   complex data (but with zero imaginary part if originally real).
%
%   For frequency domain data, negative frequencies with complex conjugated
%   data values are appended.

% $Revision: 1.4.4.2 $ $Date: 2004/04/10 23:15:43 $
%   Copyright 1986-2004 The MathWorks, Inc.

dom = lower(pvget(ze,'Domain'));
dom = dom(1);
[N,ny,nu,Nexp] = size(ze);
zec = ze;
if dom=='t'
    for kexp = 1:Nexp
        if isreal(zec.OutputData{kexp})
        zec.OutputData{kexp}=complex(ze.OutputData{kexp});
        end
        if isreal(zec.InputData{kexp})
        zec.InputData{kexp}=complex(ze.InputData{kexp});
        end
    end
else
    %if realdata(ze)
        for kexp = 1:Nexp
            fre = ze.SamplingInstants{kexp};
            if all(fre>=0)
            if fre(1)==0
                sist = 2;
            else
                sist = 1;
            end
            if round(N(kexp)/2)==N(kexp)/2
                just = 0;
            else
                just = 1;
            end
            zec.SamplingInstants{kexp} = [-fre(end-just:-1:sist); fre];
            zec.OutputData{kexp} = [conj(ze.OutputData{kexp}(end-just:-1:sist,:));ze.OutputData{kexp}];
            zec.InputData{kexp} = [conj(ze.InputData{kexp}(end-just:-1:sist,:));ze.InputData{kexp}];
        end
    end
end
