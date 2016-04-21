function varargout = zerophase(b,a, varargin) 
%ZEROPHASE Zero-phase response of a real filter. 
%   [Hr,W] = ZEROPHASE(B,A)returns the zero-phase response Hr and 
%   the frequency vector W (in rad/sample) at which Hr is computed.  
%   The zero-phase response is evaluated a 512 equally spaced points  
%   on the upper half of the unit circle. 
% 
%   The zero-phase response, Hr(w), is related to the frequency 
%   response, H(w) by 
%                                       jPhiz(w) 
%                          H(w) = Hr(w)e 
% 
%   Note that the zero-phase response is always real, but it is not 
%   equivalent to the magnitude response. In particular, the former 
%   can be negative whereas the latter cannot. 
% 
%   [Hr,W] = ZEROPHASE(B,A, NFFT) uses NFFT frequency points on the  
%   upper half of the unit circle when computing the zero-phase 
%   response. 
% 
%   [Hr,W] = ZEROPHASE(B,A,NFFT,'whole') uses NFFT frequency points 
%   around the whole unit circle. 
% 
%   [Hr,W] = ZEROPHASE(B,A,W) returns the zero-phase response at frequencies  
%   designated in vector W, in radians/sample (normally between 0 and pi). 
% 
%   [Hr,F] = ZEROPHASE(...,Fs) use the sampling frequency 
%   Fs, in Hz, to determine the frequency vector F (in Hz) at which 
%   Hr is computed. 
% 
%   [Hr,W,Phi] = ZEROPHASE(...) returns the continuous phase Phi. Note that 
%   this quantity is not equivalent to the phase response of the filter when the 
%   zero-phase response is negative. 
% 
%   ZEROPHASE(...) with no output arguments, plots the zero-phase 
%   response versus frequency. 
% 
%   EXAMPLE #1: 
%     b=fircls1(54,.3,.02,.008); 
%     zerophase(b) 
% 
%   EXAMPLE #2: 
%     [b,a] = ellip(10,.5,20,.4); 
%     zerophase(b,a,512,'whole') 
% 
%   See also FREQZ, INVFREQZ, PHASEZ, FREQS, PHASEDELAY, GRPDELAY and FVTOOL. 

%   Author(s): V.Pellissier and R. Losada 
%   Copyright 1988-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/11/21 15:46:51 $  

% Error checking 
error(nargchk(1,5,nargin)); 

% Boolean flag indicating if the Filter Design Toolbox is installed. 
if qfiltexists & nargin > 1, 
    warning(generatemsgid('syntaxChanged'),'The syntax of the zerophase function has changed.'); 
end 

if nargin==1, a=1;end 
if ~isreal(b) | ~isreal(a), 
    error('zerophase not defined for complex filters.'); 
end 

errStr = 'iirfilter'; 
% Linear-phase FIR filter 
if a==1, 
    [Hz,wz,phiz,s,options,errStr] = exactzerophase(b, varargin{:}); 
end 

if ~isempty(errStr), 
     
    % Parse inputs 
    [n_or_w, options] = extract_norw(varargin{:}); 
     
    % Add f=0 if not included in the frequency factor 
    if length(n_or_w)>1, 
        addpoint = 0; 
        idx = find(n_or_w>=0); 
        if isempty(idx), 
            % Only negative frequencies 
            addpoint = 1; 
            n_or_w = [n_or_w,0]; 
        else 
            idx = find(n_or_w<=0); 
            if isempty(idx), 
                % Only positive frequencies 
                addpoint = -1; 
                n_or_w = [0,n_or_w]; 
            end 
        end 
    end 

    % Define the new N-point frequency vector where the frequency response is evaluated 
    [upn_or_w, upfactor, iswholerange] = getinterpfrequencies(n_or_w, varargin{:}); 
     
    % Compute the phase response (phasez) on the desired range 
    phi = compute_phase(b, a, upn_or_w, options); 
     
    % Estimate the sign of H on the desired range 
    [Hsign, isfirstsegmentpositive,periodicity,flip] = estimateHsign(b, ... 
        a, phi, iswholerange, upn_or_w); 
     
    % Compute the frequency response (freqz) 
    [h, wz, s, options] = compute_fresp(b, a, upn_or_w, options); 
     
    % Zero-phase response 
    if length(n_or_w)>1, 
        if addpoint==1, 
            isoriginpositive= (Hsign(end) == 1); 
        elseif addpoint==-1, 
            isoriginpositive= (Hsign(1) == 1); 
        else 
            idx = find(upn_or_w>=0); 
            isoriginpositive = (Hsign(idx(1)) == 1); 
        end 
        % Vector specified (not nfft) 
        if isfirstsegmentpositive*isoriginpositive~=1, 
            Hsign = -Hsign; 
        end 
    end 
    Hz = Hsign.*abs(h(:)); 
     
    % Continous phase 
    phiz = compute_continuousphase(Hsign, phi, isfirstsegmentpositive); 
     
    % Downsample to retrieve the number of points specified by the user 
    A = downsample([Hz(:), phiz(:), wz(:)], upfactor); 
    Hz   = A(:,1); 
    phiz = A(:,2); 
    wz   = A(:,3); 
     
    % Remove additional point 
    if length(n_or_w)>1, 
        if addpoint==1, 
            Hz(end) =[]; 
            phiz(end)=[]; 
            wz(end)=[]; 
        elseif addpoint==-1, 
            Hz(1) =[]; 
            phiz(1)=[]; 
            wz(1)=[]; 
        end 
    end 
     
    % Update options 
    options.periodicity = periodicity; 
    options.flip = flip; 
    options.nfft = length(wz); 
    options.w    = wz; 
     
end 

% Parse outputs 
switch nargout, 
case 0, 
    zerophaseplot(Hz,wz,s); 
case 1, 
    varargout = {Hz}; 
case 2, 
    varargout = {Hz,wz}; 
case 3, 
    varargout = {Hz,wz,phiz}; 
case 4, 
    varargout = {Hz,wz,phiz,options}; 
end 


%-------------------------------------------------------------------------------------------- 
function [Hz,Wz,Phi,S, options,errStr] = exactzerophase(b, varargin) 
% Compute the zerophase from the frequency response. 
% References: A. Antoniou, DIGITAL FILTERS, Analysis, Design, and 
%             Applications. 2nd Ed., Mc Graw-Hill, N.Y., 1993, 
%             Chapter 15. 

Hz = []; 
Wz = []; 
Phi = []; 
S = []; 
options = []; 
errStr = ''; 

if ~signalpolyutils('islinphase',b,1), 
    errStr = 'The filter must have linear phase.'; 
    return 
end 

% Get the number of leading zeros. 
nzeros=min(find(b~=0))-1; 

% Remove trailing zeros 
b = b(1:max(find(b~=0))); 

% Get the FIR type and filter order 
if length(b) == 1, 
  filtertype = 1; 
  N = 0; 
else 
  N = length(b) - 1; % Filter order. 
   
  if strcmpi('symmetric',signalpolyutils('symmetrytest',b,1)), 
    % Symmetric coefficients 
    issymflag = 1; 
  else 
    % We already know it is linear phase, must be antisymmetric coefficients 
    issymflag = 0; 
  end 
   
  filtertype = determinetype(N,issymflag); 
end 

% Compute the frequency response (freqz) 
try 
    [H Wz S options] = freqz(b,1,varargin{:}); 
    % Compute the frequency vector W 
    W = computeFreqv(Wz,S); 
catch 
    errStr = lasterr; 
    return 
end 

% Compute the phase component Phi = P - Nw/2 
% P = 0 for Type 1 and 2 FIR filters. 
% P = pi/2 for Type 3 and 4 FIR filters. 

flip = 0; 
switch filtertype 
case {1,2} 
    P=0; 
    periodicity = 2; 
    if filtertype==2, 
        periodicity = 4; 
    end 
case {3,4} 
    P=pi/2; 
    periodicity = 2; 
    if filtertype==4, 
        periodicity = 4; 
        flip = 1; 
    end 
end 
options.periodicity = periodicity; 
options.flip = flip; 
Phi=P-W*((N+nzeros)/2); % Phase component 

% The zerophase response : Hzero = exp(-J*Phi)*H(w) 

ejnw=exp(-j*Phi); % exponential multiplying factor 
Hz=real(H.*ejnw); % zerophase response, disregard the round off imaginary part. 


%------------------------------------------------------------------------------------ 
function filtertype = determinetype(N,issymflag) 

if issymflag, 
    % Type 1 or type 2 
    if rem(N,2), 
        % Odd order 
        filtertype = 2; 
    else 
        % Even order 
        filtertype = 1; 
    end 
     
else 
    % Type 3 or type 4 
    if rem(N,2), 
        % Odd order 
        filtertype = 4; 
    else 
        % Even order 
        filtertype = 3; 
    end 
end 


%--------------------------------------------------------------------------------------------- 
function W = computeFreqv(Wz,S) 
% Compute the frequency vector W which will be used in the phase component. 

% If Fs was not specified return W = Wz 
if isempty(S.Fs) 
    W = Wz; 
else 
    W = 2*pi*Wz/S.Fs; 
end 


%-------------------------------------------------------------------------------------------- 
function phi = compute_phase(b, a, upn_or_w, options) 
% Compute the phase response (phasez) on the desired range 

phi = phasez(b, a, upn_or_w, options{:}); 


%--------------------------------------------------------------------------------------------- 
function [Hsign, isfirstsegmentpositive, periodicity, flip] = estimateHsign(b, ... 
    a, phi, iswholerange, upn_or_w) 

%-------------------------------------------------------------------------- 
% Estimate the sign of H on the [0 Fs/2) range 
%-------------------------------------------------------------------------- 

% Detect the discontinuities of the phase on [0 Fs/2) 
N = length(phi); 
if iswholerange, 
    N = N/2; 
end 
phasejumps = findphasejumps(phi(1:N)); 

% Determine the sign of the first point 
ii = 1; 
while isnan(phi(ii)), 
    ii=ii+1; 
end 
if ii==1, 
    H0 = dividenowarn(sum(b),sum(a)); 
    isfirstsegmentpositive = sign(H0)/2+.5; % first point positive=1 , negative or null=0 
else, 
    isfirstsegmentpositive = sign(phi(ii))/2+.5; 
end 

% Determine the length of each segment where the sign is constant 
signlength = diff(phasejumps); % Phase jump = Sign change 

% Build the sign by concatenating segments of 1 and -1 alternatively 
Hsign = []; 
for ii=1:length(signlength), 
    Hsign = [Hsign; (-1)^(ii+isfirstsegmentpositive)*ones(signlength(ii),1)]; 
end 

%-------------------------------------------------------------------------- 
% Extend the estimation of the sign of H on the full range [0 Fs) if needed 
%-------------------------------------------------------------------------- 
periodicity = []; 
flip = 0; 
if iswholerange, 
    % Determine the symetries of the zerophase 
    [sym_0, sym_pi, periodicity, flip] = findsym(phi, upn_or_w); 
    if sym_0 & sym_pi, 
        % Symmetry vs 0 and pi 
        Hsign = [Hsign(:);Hsign(end:-1:1)]; 
    elseif sym_0, 
        % Symmetry vs 0 and anti-symmetry vs pi 
        Hsign = [Hsign(:);-Hsign(end:-1:1)]; 
    elseif sym_pi, 
        % Anti-symmetry vs 0 and symmetry vs pi 
        Hsign = [Hsign(:);Hsign(end:-1:1)]; 
    else 
        % Anti-symmetry vs 0 and anti-symmetry vs pi 
        Hsign = [Hsign(:);-Hsign(end:-1:1)]; 
    end 
end 


%-------------------------------------------------------------------------------------------- 
function phasejumps = findphasejumps(Phi) 

% First source of jumps: gaps greter than pi*170/180 
phasejumps1 = gaps(Phi); 

% Second source of jumps: NaNs 
phasejumps2 = findnans(Phi); 

% Union of all phase jumps 
phasejumps = union(phasejumps1, phasejumps2); 


%-------------------------------------------------------------------------------------------- 
function phasejumps = gaps(Phi) 

% Detect the jumps greater than pi*170/180 (non-linearities) 
phasejumps = find(abs(diff(Phi))>pi*170/180); 

% First and last points = non-linearities 
phasejumps = [0; phasejumps; length(Phi)]; 

% Add 1 because of diff 
phasejumps = phasejumps+1; 



%-------------------------------------------------------------------------------------------- 
function phasejumps = findnans(Phi) 

% Find NaNs  
nans=find(isnan(Phi)); 

if isempty(nans), 
    phasejumps = []; 
else 
    % First NaN 
    firstnan = nans(1); 
    nans(1) = []; 
     
    % Keep the first of consecutive NaNs 
    index = find(isnan(Phi(nans-1))); 
    nans(index) = []; 
    phasejumps = [firstnan;nans(:)]; 
end 

%-------------------------------------------------------------------------------------------- 
function [sym_0, sym_pi, periodicity, flip] = findsym(phi, upn_or_w) 

% Determination of the symmetry vs 0 
sym_0 = issymmetric(phi, 0); 

% Determination of the symmetry vs pi 
if length(upn_or_w)==1, 
    % Nfft 
    npi = upn_or_w/2; 
end 
sym_pi = issymmetric(phi, npi); 

flip = 0; 
if sym_0 & sym_pi, 
    % Symmetry vs 0 and pi 
    periodicity = 2; 
elseif sym_0, 
    % Symmetry vs 0 and anti-symmetry vs pi 
    periodicity = 4; 
elseif sym_pi, 
    % Anti-symmetry vs 0 and symmetry vs pi 
    periodicity = 2; 
else 
    % Anti-symmetry vs 0 and anti-symmetry vs pi 
    periodicity = 4; 
    flip = 1; 
end 


%-------------------------------------------------------------------------------------------- 
function sym_val = issymmetric(phi, val) 
% Determination of the symmetry vs val 

phitol=pi/10; 
i = val+1; 
while isnan(phi(i)), 
    i=i+1; 
end 

if i==val+1, 
    sym_val=1; % symmetry vs val 
else 
    % Principal component of the phase (between -pi and pi) 
    princomp = rem(phi(i),pi); 
    if abs(princomp)>pi/2-phitol & abs(princomp)<pi/2+phitol, 
        % Jump of pi in the vicinity of val 
        sym_val=0; % antisymmetry vs val 
    else 
        sym_val=1; % symmetry vs val 
    end 
end 


%-------------------------------------------------------------------------------------------- 
function [h, wz, s, options] = compute_fresp(b, a, upn_or_w, options) 

[h, wz, s, options] = freqz(b, a, upn_or_w, options{:}); 


%----------------------------------------------------------------------------------------------- 
function phiz = compute_continuousphase(Hsign, phi, isfirstsegmentpositive) 

% Compensate the phase (-pi on each discontinuity section) 
aux = [0; diff((Hsign-1)/2)]; 
compensate = cumsum(abs(aux)); 
phiz = phi(:)-compensate*pi; 

% Add an offset to the phase if the first segment is negative 
% The first point of Phiz must be -pi and pi 
if ~isfirstsegmentpositive, 
    if phiz(1)>=0, 
        phiz=phiz-pi; 
    else 
        phiz=phiz+pi; 
    end 
end 


%----------------------------------------------------------------------------------------------- 
function zerophaseplot(Hz,Wz,S) 

% Determine the correct frequency label. 
if isempty(S.Fs), 
    xlbl = 'Normalized Frequency (\times \pi rad/sample)'; 
    Wz = Wz./pi; 
else 
    xlbl = 'Frequency (Hz)'; 
end 

ylbl = 'Amplitude'; 

% Plot the zero-phase response 
h_plot = plot(Wz,Hz); 

% Set axis limit to last frequency value and turn grid on 
h_axis = get(h_plot,'parent'); 
set(h_axis,'xlim',[Wz(1),Wz(end)],'xgrid','on','ygrid','on'); 

% Set x-label 
h_xlbl = get(h_axis,'xlabel'); 
set(h_xlbl,'string',xlbl); 

% Set y-label 
h_ylbl = get(h_axis,'ylabel'); 
set(h_ylbl,'string',ylbl); 

% Set title 
h_title = get(h_axis,'title'); 
set(h_title,'string','Zero-phase response'); 

% [EOF] 
