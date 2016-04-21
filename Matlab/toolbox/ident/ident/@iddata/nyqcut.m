function datamod = nyqcut(data)
%NYQCUT Cuts way data above the Nyquist frequency


%   L. Ljung 03-06-05
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/06/05 19:32:46 $

datamod = data;
dom = data.Domain; dom = lower(dom(1));
if dom=='f'
    fre = data.SamplingInstants;
    y = data.OutputData;
    u = data.InputData;
    un = data.Tstart;
    Ts = data.Ts;
    for kexp = 1:length(un)
        if strcmp(lower(un{kexp}),'hz')
            picorr = 2*pi;
        else
            picorr = 1;
        end
        frek = fre{kexp};
        if Ts{kexp} > 0 & any(frek>pi/picorr/Ts{kexp}+1e4*eps)
            warning('Frequency points above the Nyquist frequency have been removed')
            freno = find(frek<=pi/picorr/Ts{kexp}+1e4*eps);
            fre{kexp} = frek(freno);
            y{kexp} = y{kexp}(freno,:);
            u{kexp} = u{kexp}(freno,:);
        end
    end
    datamod.SamplingInstants = fre;
    datamod.OutputData = y;
    datamod.InputData = u;
end
