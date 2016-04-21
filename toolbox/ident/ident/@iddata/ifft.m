function datf = ifft(dat)
%IDDATA/IFFT Compute IFFT of frequency domain  IDDATA signals.
%
%   DATI = IFFT(DAT) converts the frequency domain IDDATA signal to the
%   time domain data using IFFT and sorting the data wrt
%   frequencies.
%   
%   This routine requires that the frequency domain data are
%   defined for equally spaced frequency points, stretching from
%   frequency 0 to  the Nyquist frequency. More exactly:
%   DAT.Frequency = [0:df:F], where df = 2*pi/(N*DAT.Ts) and 
%   F =  pi/DAT.Ts if N is odd and F = pi/DAT.Ts * (1- 1/N) if N
%   is even. Here N is the number of frequencies.  
%
%   See also FFT.  

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $ $Date: 2004/04/10 23:15:57 $ 

if strcmp(lower(dat.Domain),'time')
    error('This data is time domain. Use FFT to convert to frequency domain.')
end
if isempty(dat)
    datf = dat;
    datf.Domain = 'Time';
    return
end
dat = chgunits(dat,'rad/s');
datf = dat;
y = dat.OutputData;
u = dat.InputData;
fre = dat.SamplingInstants;
ts = dat.Ts;
ermsg = sprintf(['IFFT can be applied only if the frequencies are equally spaced,'...
        '\nranging from 0 to the Nyquist frequency. See HELP IDDATA/IFFT.']);
for kexp = 1:length(y)
    N = size(y{kexp},1);
    if N>1
        fre1 = fre{kexp};
        Ts = ts{kexp};
        
        %TEST if IFFT can be applied: first and last frequency, and equal step
        noifft = 0;
        
        df = diff(fre1);
        ddf = diff(df);
        fnr = max(abs(fre1));
        % 1. Equal frequncy sampling:
        if max(abs(ddf))/fnr>0.0001
            error(ermsg);
        end
        N = length(fre1);
        % 2. frequency zero must be included:
        n0 = find(abs(fre1)<df(1)/1000);
        if isempty(n0)
            error(ermsg)
        end
        % Any negative frequencies must be matched by the same positive ones:
        
        kt = find(fre1<0);
        if ~isempty(kt)
            compl = 1;
            if norm(fre1(n0+[kt(end):-1:kt(1)])+fre1(kt))>fnr/10000;
                error(ersmg)
            end
        else
            compl = 0;
        end
        % compute the length of the original sequence:
        if compl
            No = N;
        else
            if (abs(fre1(end)-pi/Ts)<0.0001*fnr)
                No = 2*N-2;
            elseif  (abs(fre1(end)-pi/Ts*(1-1/(2*N-1)))<0.0001*fnr)
                No = 2*N-1;
            else
                error(ermsg)
            end  
        end
        if ~compl %Real time domain data 
            if  fix(No/2)==No/2 
                Y{kexp} = real(ifft([y{kexp};conj(y{kexp}(end-1:-1:2,:))]));
                U{kexp} = real(ifft([u{kexp};conj(u{kexp}(end-1:-1:2,:))]));
            else
                Y{kexp} = real(ifft([y{kexp};conj(y{kexp}(end:-1:2,:))]));
                U{kexp} = real(ifft([u{kexp};conj(u{kexp}(end:-1:2,:))]));	
            end
        else
            Y{kexp} = ifft([y{kexp}(n0:end,:);y{kexp}(1:n0-1,:)]);
            U{kexp} = ifft([u{kexp}(n0:end,:);u{kexp}(1:n0-1,:)]);
            if realdata(dat)
                Y{kexp}=real(Y{kexp});
                U{kexp}=real(U{kexp});
            end
        end
        datf.SamplingInstants{kexp}= []; 
        datf.Tstart{kexp} = [];
        sqN = sqrt(size(Y{kexp},1));
        Y{kexp} = sqN*Y{kexp}; 
        U{kexp} = sqN*U{kexp};
    else % N=1
        Y{kexp} = y{kexp}; U{kexp}= u{kexp};
         datf.Tstart{kexp} = [];
    end
end
datf.InputData = U;
datf.OutputData = Y;
datf.Domain = 'Time';


