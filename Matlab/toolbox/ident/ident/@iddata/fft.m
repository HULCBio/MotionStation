function datf = fft(dat,n,comp)
%IDDATA/FFT Compute FFT of time domain  IDDATA signals.
%
%   DATF = FFT(DAT) 
%   converts the time domain IDDATA signal DAT to the
%   frequency domain data DATF using FFT and sorting the data wrt
%   frequencies.
%   
%   This routine requires equally sampled time domain data, and
%   returns a frequency domain IDDATA object with frequencies from
%   0 to the Nyquist frequency.
%
%   DATF = FFT(DAT,N)
%   uses an N-point FFT (padding the data set with zeros if the data record
%   is shorter than N and truncating it otherwise) to return an IDDATA object
%   with N/2 or (N+1)/2 freqencies equally distributed between 0 and the
%   Nyquist frequency. If DAT contains several experiments, N is a row vector
%   of length = number of experiments. If N is given as an integer, all
%   experiments use the same N.
%   
%   Default N = size(DAT,'N').
%
%   Note that the FFTs are scaled by dividing by sqrt(size(DAT,'N')) in order to
%   retain the noise level in the signals.
%
%   If DAT contains real-valued data, DATF only returns frequency domain
%   data for non-negative frequencies, otherwise both negative and positive
%   frequencies are included. To include negative frequencies also for
%   real-valued data, enter DATF = FFT(DAT,N,'compl');
%
%   See also IFFT.  
  
  
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $ $Date: 2004/04/10 23:15:50 $  

if isempty(dat)
    datf = dat;
    datf.Domain = 'Frequency';
    return
end

if nargin == 3
    negfr = 1;
else
    negfr = 0;
end
if nargin<2
    n =[];
end
if isempty(n)
    n = size(dat,'N');
end
Ne = size(dat,'Ne');
if length(n)~=Ne
    if length(n)==1
        n = n*ones(1,Ne);
    else
        error('N must either be an integer or a row vector of integers of length = # of experiments.')
    end
end
if strcmp(lower(dat.Domain),'frequency')
    error('This data is frequency domain. Use IFFT to convert to time domain.')
end
y = dat.OutputData;
u = dat.InputData;
ts = dat.Ts;
for kexp = 1:length(ts)
if isempty(ts{kexp})
	error('FFT requires equally sampled data.')
end
end
ss = dat.TimeUnit;
if isempty(ss), ss= 'sec';end

for kexp = 1:length(y)
    N = n(kexp);
    if floor(N)~=N|N<=0
        error('N must be positive integer(s).')
    end
    Ndat = size(y{kexp},1);
    Ts = ts{kexp};
    if isreal(dat)&~negfr
        if fix(N/2)==N/2
            n1 = N/2+1;
            freq{kexp} = [0:N/2]'/Ts*2*pi/N;
        else
            n1 = (N+1)/2;
            freq{kexp} = [0:(N-1)/2]'/Ts*2*pi/N;
        end
    else
        if fix(N/2)==N/2
            nlp = N/2+1;
            nln = N/2+2:N;
            freq{kexp} = [[-N/2+1:-1],[0:N/2]]'/Ts*2*pi/N;
        else
            nlp = (N+1)/2;
            nln = [(N+1)/2+1:N];
            freq{kexp} = [[-(N+1)/2+1:-1],[0:(N-1)/2]]'/Ts*2*pi/N;
            
        end
    end
    
    Y1 = fft(y{kexp},N)/sqrt(min(N)); % think if it is N or Ndat!
    U1 = fft(u{kexp},N)/sqrt(min(N));
    if length(y{kexp})==1|length(u{kexp})==1; % This is to handle the special case of length 1 data
        Y1=Y1.';
        U1=U1.';
        if isempty(Y1), Y1 = zeros(size(U1,1),0);end
        if isempty(U1), U1 = zeros(size(Y1,1),0);end
    end
    
    if isreal(dat)&~negfr
        Y{kexp}= Y1(1:n1,:); U{kexp}= U1(1:n1,:);
    else
        if fix(N/2)==N/2
            Y{kexp} = Y1([[N/2+2:N],1+[0:N/2]],:);
            U{kexp}=U1([[N/2+2:N],1+[0:N/2]],:);
        else
            Y{kexp} = Y1([[(N+1)/2+1:N],1+[0:(N-1)/2]],:);
            U{kexp}=U1([[(N+1)/2+1:N],1+[0:(N-1)/2]],:);
        end
    end
    unit{kexp} = ['rad/s'];
end
datf = dat;
datf.InputData = U;
datf.OutputData = Y;
datf.SamplingInstants = freq;
datf.Domain = 'Frequency';
datf.Tstart = unit;


