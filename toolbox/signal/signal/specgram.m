function [yo,fo,to] = specgram(varargin)
%SPECGRAM Spectrogram using a Short-Time Fourier Transform (STFT).
%   B = SPECGRAM(A) calculates the spectrogram for the signal in vector A.
%   SPECGRAM divides the signal into overlapping segments, windows each
%   segment and forms the columns of B with their discrete Fourier
%   transforms.  
%
%   B = SPECGRAM(A,NFFT,Fs) specifies the number of FFT points used to
%   calculate the discrete Fourier transforms.  If NFFT = [] or is not
%   specified the default NFFT = minimum of 256 and the length of A. Fs is
%   the sampling frequency which does not effect the spectrogram but is
%   used for scaling plots.  If Fs=[] or is not specified it defaults to 2
%   Hz.
%
%   B = SPECGRAM(A,NFFT,Fs,WINDOW,NOVERLAP) uses WINDOW to window each
%   overlapping segment and forms the columns of B with their zero-padded,
%   length NFFT discrete Fourier transforms. If you specify a scalar for
%   WINDOW, SPECGRAM uses a Hanning window of length NFFT.  WINDOW must
%   have a length smaller than or equal to NFFT and greater than NOVERLAP.
%   NOVERLAP is the number of samples each segement of A overlaps. The
%   default value of NOVERLAP = length(WINDOW)/2.
%
%   You can use the default value for any parameter by leaving it off or
%   using [] for that parameter, e.g. SPECGRAM(A,[],1000) uses a default
%   NFFT.
%
%   Each column of B contains an estimate of the short-term, time-localized
%   frequency content of the signal A.  Time increases linearly across the
%   columns of B, from left to right.  Frequency increases linearly down
%   the rows, starting at 0.  If A is a length NX complex signal, B is a
%   complex matrix with NFFT rows and 
%        k = fix((NX-NOVERLAP)/(length(WINDOW)-NOVERLAP)) 
%   columns.  If A is real, B still has k columns but the higher frequency
%   components are truncated (because they are redundant); in that case,
%   SPECGRAM returns B with NFFT/2+1 rows for NFFT even and (NFFT+1)/2 rows 
%   for NFFT odd.  
%
%   [B,F,T] = SPECGRAM(...) returns a column of frequencies F and one of
%   times T at which the spectrogram is computed. F has length equal to the
%   number of rows of B, T has length k. 
%
%   B = SPECGRAM(A) produces the spectrogram of the signal A using default
%   settings; the defaults are NFFT = minimum of 256 and the length of A, a
%   Hanning window of length NFFT, and NOVERLAP = length(WINDOW)/2.  
%
%   SPECGRAM(...) with no output arguments plots the absolute value of the 
%   spectrogram in the current figure, using IMAGESC(T,F,20*log10(ABS(B))),
%   where T is created with its starting point shifted by the window length
%   minus the overlap, divided by 2 ((nwind-noverlap)/2). Then AXIS XY, and
%   COLORMAP(JET) are used so the low frequency content of the first
%   portion of the signal is displayed in the lower left corner of the
%   axes.
%
%   SPECGRAM(A,F,Fs,WINDOW) where F is a vector of frequencies in Hz (with
%   2 or more elements) computes the spectrogram at those frequencies using
%   either the chirp z-transform for more than 20 evenly spaced 
%   frequencies or a polyphase decimation filterbank.
%
%   EXAMPLE: Compute the spectrogram of a quadratic chirp.
%
%     t=-2:0.001:2;                % +/-2 secs @ 1kHz sample rate
%     y=chirp(t,100,1,200,'q');    % Start @ 100Hz, cross 200Hz at t=1sec 
%     specgram(y,128,1E3,128,120); % Display the spectrogram
%     title('Quadractic Chip: start at 100Hz and cross 200Hz at t=1sec');
%
%   See also PWELCH, SPECTRUM/WELCH, CPSD, MSCOHERE, TFESTIMATE.

%   Author(s): L. Shure, 1-1-91
%              T. Krauss, 4-2-93, updated
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:19:06 $

error(nargchk(1,5,nargin))
[msg,x,nfft,Fs,window,noverlap]=specgramchk(varargin);
error(msg)
    
nx = length(x);
nwind = length(window);
if nx < nwind    % zero-pad x if it has length less than the window length
    x(nwind)=0;  nx=nwind;
end
x = x(:); % make a column vector for ease later
window = window(:); % be consistent with data set

ncol = fix((nx-noverlap)/(nwind-noverlap));
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
if length(x)<(nwind+colindex(ncol)-1)
    x(nwind+colindex(ncol)-1) = 0;   % zero-pad x
end

if length(nfft)>1
    df = diff(nfft);
    evenly_spaced = all(abs(df-df(1))/Fs<1e-12);  % evenly spaced flag (boolean)
    use_chirp = evenly_spaced & (length(nfft)>20);
else
    evenly_spaced = 1;
    use_chirp = 0;
end

if (length(nfft)==1) | use_chirp
    y = zeros(nwind,ncol);

    % put x into columns of y with the proper offset
    % should be able to do this with fancy indexing!
    y(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

    % Apply the window to the array of offset signal segments.
    y = window(:,ones(1,ncol)).*y;

    if ~use_chirp     % USE FFT
        % now fft y which does the columns
        y = fft(y,nfft);
        if ~any(any(imag(x)))    % x purely real
            if rem(nfft,2),    % nfft odd
                select = 1:(nfft+1)/2;
            else
                select = 1:nfft/2+1;
            end
            y = y(select,:);
        else
            select = 1:nfft;
        end
        f = (select - 1)'*Fs/nfft;
    else % USE CHIRP Z TRANSFORM
        f = nfft(:);
        f1 = f(1);
        f2 = f(end);
        m = length(f);
        w = exp(-j*2*pi*(f2-f1)/(m*Fs));
        a = exp(j*2*pi*f1/Fs);
        y = czt(y,m,w,a);
    end
else  % evaluate DFT on given set of frequencies
    f = nfft(:);
    q = nwind - noverlap;
    extras = floor(nwind/q);
    x = [zeros(q-rem(nwind,q)+1,1); x];
    % create windowed DTFT matrix (filter bank)
    D = window(:,ones(1,length(f))).*exp((-j*2*pi/Fs*((nwind-1):-1:0)).'*f'); 
    y = upfirdn(x,D,1,q).';
    y(:,[1:extras+1 end-extras+1:end]) = []; 
end

t = (colindex-1)'/Fs;

% take abs, and use image to display results
if nargout == 0
    newplot;
    if length(t)==1
        imagesc([0 1/f(2)],f,20*log10(abs(y)+eps));axis xy; colormap(jet)
    else
        t = ((colindex-1)+((nwind-noverlap)/2)')/Fs; % Shift time vector by half window length.
        imagesc(t,f,20*log10(abs(y)+eps));axis xy; colormap(jet)
    end
    xlabel('Time')
    ylabel('Frequency')
elseif nargout == 1,
    yo = y;
elseif nargout == 2,
    yo = y;
    fo = f;
elseif nargout == 3,
    yo = y;
    fo = f;
    to = t;
end

function [msg,x,nfft,Fs,window,noverlap] = specgramchk(P)
%SPECGRAMCHK Helper function for SPECGRAM.
%   SPECGRAMCHK(P) takes the cell array P and uses each cell as 
%   an input argument.  Assumes P has between 1 and 5 elements.

msg = [];

x = P{1}; 
if (length(P) > 1) & ~isempty(P{2})
    nfft = P{2};
else
    nfft = min(length(x),256);
end
if (length(P) > 2) & ~isempty(P{3})
    Fs = P{3};
else
    Fs = 2;
end
if length(P) > 3 & ~isempty(P{4})
    window = P{4}; 
else
    if length(nfft) == 1
        window = hanning(nfft);
    else
        msg = 'You must specify a window function.';
    end
end
if length(window) == 1, window = hanning(window); end
if (length(P) > 4) & ~isempty(P{5})
    noverlap = P{5};
else
    noverlap = ceil(length(window)/2);
end

% NOW do error checking
if (length(nfft)==1) & (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (length(nfft)==1) & (nfft ~= abs(round(nfft)))
    msg = 'Requires positive integer values for NFFT.';
end
if (noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer value for NOVERLAP.';
end
if min(size(x))~=1,
    msg = 'Requires vector (either row or column) input.';
end

