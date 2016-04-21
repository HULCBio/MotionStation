function varargout = welch(x,esttype,varargin)
%WELCH Welch spectral estimation method.
%   [Pxx,F] = WELCH(X,WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,ESTTYPE)
%   [Pxx,F] = WELCH({X},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'psd')
%   [Pxx,F] = WELCH({X},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'ms')
%   [Pxy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'cpsd')
%   [Txy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'tfe')
%   [Cxy,F] = WELCH({X,Y},WINDOW,NOVERLAP,NFFT,Fs,SPECTRUMTYPE,'mscohere')
%
%   Inputs:
%      see "help pwelch" for complete description of all input arguments.
%      ESTTYPE - is a string specifying the type of estimate to return, the
%                choices are: psd, cpsd, tfe, and mscohere.
%
%   Outputs:
%      Depends on the input string ESTTYPE:
%      Pxx - Power Spectral Density (PSD) estimate, or
%      MS  - Mean-square spectrum, or
%      Pxy - Cross Power Spectral Density (CPSD) estimate, or
%      Txy - Transfer Function Estimate (TFE), or
%      Cxy - Magnitude Squared Coherence.
%      F   - frequency vector, in Hz if Fs is specified, otherwise it has
%            units of rad/sample

%   Author(s): P. Pacheco
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:18:54 $ 

%   References:
%     [1] Petre Stoica and Randolph Moses, Introduction To Spectral
%         Analysis, Prentice-Hall, 1997, pg. 15
%     [2] Monson Hayes, Statistical Digital Signal Processing and 
%         Modeling, John Wiley & Sons, 1996.

error(nargchk(2,8,nargin));
error(nargoutchk(0,3,nargout));

% Parse input arguments.
[x,M,isreal_x,y,Ly,win,winName,winParam,noverlap,opts,msg] = ...
                                      parse_inputs(x,esttype,varargin{:});
error(msg);

% Obtain the necessary information to segment x and y.
[L,noverlap,win,msg] = segment_info(M,win,noverlap);
error(msg);

% Parse optional args nfft, fs, and spectrumType. 
[options,msg] = welch_options(isreal_x,L,opts{:});
error(msg);

% Compute the number of segments
k = (M-noverlap)./(L-noverlap);

% Uncomment the following line to produce a warning each time the data
% segmentation does not produce an integer number of segements.
%if fix(k) ~= k),
%   warning('The number of segments is not an integer, truncating data.');
%end

k = fix(k);

% Compute the periodogram power spectrum of each segment and average always
% compute the whole power spectrum, we force Fs = 1 to get a PS not a PSD.
Sxx = zeros(options.nfft,1); % Initialize
LminusOverlap = L-noverlap;
xStart = 1:LminusOverlap:k*LminusOverlap;
xEnd   = xStart+L-1;
switch esttype,
    case {'ms','psd'},
        for i = 1:k,
            Sxx  = Sxx + computeperiodogram(x(xStart(i):xEnd(i)),win,...
                                                options.nfft,esttype);
        end
        
    case 'cpsd',
        for i = 1:k,
            Sxx  = Sxx + computeperiodogram({x(xStart(i):xEnd(i)),...
                     y(xStart(i):xEnd(i))},win,options.nfft,esttype);
        end
        
    case 'tfe'
        Sxy = zeros(options.nfft,1); % Initialize
        for i = 1:k,
            Sxx  = Sxx + computeperiodogram(x(xStart(i):xEnd(i)),...
                     win,options.nfft,esttype);
            Sxy  = Sxy + computeperiodogram({x(xStart(i):xEnd(i)),...
                     y(xStart(i):xEnd(i))},win,options.nfft,esttype);
        end

    case 'mscohere'
        % Note: (Sxy1+Sxy2)/(Sxx1+Sxx2) != (Sxy1/Sxy2) + (Sxx1/Sxx2)
        % ie, we can't push the computation of Cxy into computeperiodogram.
        Sxy = zeros(options.nfft,1); % Initialize
        Syy = zeros(options.nfft,1); % Initialize
        for i = 1:k,
            Sxx  = Sxx + computeperiodogram(x(xStart(i):xEnd(i)),...
                      win,options.nfft,esttype);
            Syy  = Syy + computeperiodogram(y(xStart(i):xEnd(i)),...
                      win,options.nfft,esttype);
            Sxy  = Sxy + computeperiodogram({x(xStart(i):xEnd(i)),...
                      y(xStart(i):xEnd(i))},win,options.nfft,esttype);
        end
end
Sxx = Sxx./k; % Average the sum of the periodograms

if any(strcmpi(esttype,{'tfe','mscohere'})),
   Sxy = Sxy./k; % Average the sum of the periodograms

   if strcmpi(esttype,'mscohere'),
       Syy = Syy./k; % Average the sum of the periodograms
   end
end

% Generate the frequency vector in [rad/sample] at which Sxx was computed
% If Fs is not empty, w will be converted to Hz in computepsd below
w = psdfreqvec(options.nfft);

% Compute the one-sided or two-sided PSD [Power/freq]. Also compute the
% corresponding half or whole power spectrum [Power], the frequency at
% which the psd is computed and the corresponding frequency units
[Pxx,w,units] = computepsd(Sxx,w,options.range,options.nfft,options.Fs,esttype);

if any(strcmpi(esttype,{'tfe','mscohere'})),
    % Cross PSD.  The frequency vector and xunits are not used. 
    [Pxy,f,xunits] = computepsd(Sxy,w,options.range,options.nfft,options.Fs,esttype);

    % Transfer function estimate.
    if strcmpi(esttype,'tfe'),
        Pxx = Pxy ./ Pxx; % Txy
    end

    % Magnitude Square Coherence estimate.
    if strcmpi(esttype,'mscohere'),
        % Auto PSD for 2nd input vector. The freq vector & xunits are not
        % used.
        [Pyy,f,xunits] = computepsd(Syy,w,options.range,options.nfft,options.Fs,esttype);
        Pxx = (abs(Pxy).^2)./(Pxx.*Pyy); % Cxy
    end
end

if nargout==0 
    w = {w};
    if strcmpi(units,'Hz'), w = {w{:},'Fs',options.Fs};  end
    % Create a spectrum object to store in the Data object's metadata.
    percOverlap = (noverlap/L)*100;
    hspec = spectrum.welch({winName,winParam},L,percOverlap);

    if any(strcmpi(esttype,{'tfe','mscohere'})),
        if strcmpi(options.range,'onesided'), range='half'; else range='whole'; end
        htfe = dspdata.freqz(abs(Pxx),w{:},'SpectrumRange',range);
        htfe.Metadata.setsourcespectrum(hspec);
        plot(htfe);

    else
        % abs of Pxx is necessary in case Pxx=CSD which is complex.
        hpsd = dspdata.psd(abs(Pxx),w{:},'SpectrumType',options.range);
        hpsd.Metadata.setsourcespectrum(hspec);
        plot(hpsd);
    end
else
    varargout = {Pxx,w}; % Pxx=PSD, MEANSQUARE, CPSD, or TFE
end

%-----------------------------------------------------------------------------------------------
function [x,Lx,isreal_x,y,Ly,win,winName,winParam,noverlap,opts,msg] = ...
                                          parse_inputs(x,esttype,varargin)
% Parse the inputs to the welch function.

% Assign defaults in case of early return.
isreal_x = 1;
y        = [];
Ly       = 0;
is2sig   = false;
win      = [];
winName  = 'User Defined';
winParam = '';
noverlap = [];
opts     = {};
msg      = '';

% Determine if one or two signal vectors was specified.
Lx = length(x);
if iscell(x),
    if Lx > 1, % Cell array.
        y = x{2};
        is2sig = true;
    end
    x = x{1};
    Lx = length(x);
else
    if ~any(strcmpi(esttype,{'psd','ms'})),
        msg.identifier = generatemsgid('invalidSignalVectors');
        msg.message= 'You must specify a cell array with two signal vectors to estimate either the cross power spectral density or the transfer function.';
        return;
    end
end

x = x(:);
isreal_x = isreal(x);

% Parse 2nd input signal vector.
if is2sig,
    y = y(:);
    isreal_x = isreal(y) && isreal_x;
    Ly = length(y);
    if Ly ~= Lx,
        msg.identifier = generatemsgid('invalidSignalVectors');
        msg.message = 'The length of the two input vectors must be equal to calculate the cross spectral density.';
        return;
    end
end

% Parse window and overlap, and cache remaining inputs.
lenargin = length(varargin);
if lenargin >= 1,
    win = varargin{1};
    if lenargin >= 2,
        noverlap = varargin{2};

        % Cache optional args nfft, fs, and spectrumType.
        if lenargin >= 3,  opts = varargin(3:end); end
    end
end

if isempty(win) | isscalar(win), 
    winName = 'hamming'; 
    winParam = 'symmetric';
end

%-----------------------------------------------------------------------------------------------
function [L,noverlap,win,msg] = segment_info(M,win,noverlap)
%SEGMENT_INFO   Determine the information necessary to segment the input data.         
%
%   Inputs:
%      M        - An integer containing the length of the data to be segmented
%      WIN      - A scalar or vector containing the length of the window or the window respectively                 
%                 (Note that the length of the window determines the length of the segments)
%      NOVERLAP - An integer containing the number of samples to overlap (may be empty)
%
%   Outputs:
%      L        - An integer containing the length of the segments
%      NOVERLAP - An integer containing the number of samples to overlap
%      WIN      - A vector containing the window to be applied to each section
%      MSG      - A string containing possible error messages
%
%
%   The key to this function is the following equation:
%
%      K = (M-NOVERLAP)/(L-NOVERLAP)
%
%   where
%
%      K        - Number of segments
%      M        - Length of the input data X
%      NOVERLAP - Desired overlap
%      L        - Length of the segments
%   
%   The segmentation of X is based on the fact that we always know M and two of the set
%   {K,NOVERLAP,L}, hence determining the unknown quantity is trivial from the above
%   formula.

% Initialize outputs
L = [];
msg = '';

% Check that noverlap is a scalar
if any(size(noverlap) > 1),
    msg.identifier = generatemsgid('invalidNoverlap');
    msg.message = 'You must specify an integer number of samples to overlap.';
    return
end

if isempty(win),
   % Use 8 sections, determine their length
   if isempty(noverlap),
      % Use 50% overlap
      L = fix(M./4.5);
      noverlap = fix(0.5.*L);
   else
      L = fix((M+7.*noverlap)./8);
   end
   % Use a default window
   win = hamming(L);
else
   % Determine the window and its length (equal to the length of the segments)
   if ~any(size(win) <= 1) | ischar(win),
       msg.identifier = generatemsgid('invalidWindow');
       msg.message = 'The WINDOW argument must be a vector or a scalar.';
       return
   elseif length(win) > 1,
       % WIN is a vector
       L = length(win);
   elseif length(win) == 1,
       L = win;
       win = hamming(win);
   end
   if isempty(noverlap),
      % Use 50% overlap
      noverlap = fix(0.5.*L);
   end
end

% Do some argument validation
if L > M,
    msg.identifier = generatemsgid('invalidSegmentLength'); 
    msg.message = 'The length of the segments cannot be greater than the length of the input signal.';
    return
end

if noverlap >= L,
    msg.identifier = generatemsgid('invalidNoverlap');
    msg.message = 'The number of samples to overlap must be less than the length of the segments.';
    return
end

%------------------------------------------------------------------------------
function [options,msg] = welch_options(isreal_x,N,varargin)
%WELCH_OPTIONS   Parse the optional inputs to the PWELCH function.
%   WELCH_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
   
% Generate defaults 
options.nfft = max(256,2^nextpow2(N));
options.Fs = []; % Work in rad/sample
if isreal_x,
   options.range = 'onesided';
else
   options.range = 'twosided';
end
msg = '';


[options,msg] = psdoptions(isreal_x,options,varargin{:});

% [EOF]
