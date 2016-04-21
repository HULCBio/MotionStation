function varargout = phasez(b,a,varargin)
%PHASEZ Digital filter phase response.
%   [PHI,W] = PHASEZ(B,A,N) returns the N-point unwrapped phase response
%   vector PHI and the N-point frequency vector W in radians/sample of
%   the filter:
%               jw               -jw              -jmw 
%        jw  B(e)    b(1) + b(2)e + .... + b(m+1)e
%     H(e) = ---- = ------------------------------------
%               jw               -jw              -jnw
%            A(e)    a(1) + a(2)e + .... + a(n+1)e
%   given numerator and denominator coefficients in vectors B and A. The
%   phase response is evaluated at N points equally spaced around the
%   upper half of the unit circle. If N isn't specified, it defaults to
%   512.
%
%   [PHI,W] = PHASEZ(B,A,N,'whole') uses N points around the whole unit circle.
%
%   PHI = PHASEZ(B,A,W) returns the phase response at frequencies 
%   designated in vector W, in radians/sample (normally between 0 and pi).
%
%   [PHI,F] = PHASEZ(B,A,N,Fs) and [PHI,F] = PHASEZ(B,A,N,'whole',Fs) return 
%   phase vector F (in Hz), where Fs is the sampling frequency (in Hz).
%   
%   PHI = PHASEZ(B,A,F,Fs) returns the phase response at the 
%   frequencies designated in vector F (in Hz), where Fs is the sampling 
%   frequency (in Hz).
%
%   PHASEZ(B,A,...) with no output arguments plots the unwrapped phase of
%   the filter.
%
%   EXAMPLE #1:
%     b=fircls1(54,.3,.02,.008);
%     phasez(b)
%
%   EXAMPLE #2:
%     [b,a] = ellip(10,.5,20,.4);
%     phasez(b,a,512,'whole');
%
%   See also FREQZ, PHASEDELAY, GRPDELAY and FVTOOL.

%   Author(s): V.Pellissier, R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/13 00:18:12 $ 

error(nargchk(1,5,nargin));

if nargin == 1, 
    a = 1; % Assume FIR
end

% Parse inputs
[n_or_w, options] = extract_norw(varargin{:});

    % Add f=0 if not included in the frequency factor
    addpoint = 0;
    if length(n_or_w)>1,
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
    
    % Compute the frequency response (freqz)
    [h, w, s, options] = freqz(b, a, upn_or_w, options{:});
    
    % When h==0, the phase is not defined (introducing NaN's)
    h = modify_fresp(h);
    
    % Unwrap the phase
    phi = unwrap_phase(h,upn_or_w,iswholerange);
    
    % Downsample
    phi = downsample(phi, upfactor);
    w = downsample(w, upfactor);
    
    % Remove additional point
    if addpoint==1,
        phi(end)=[];
        w(end)=[];
    elseif addpoint==-1,
        phi(1)=[];
        w(1)=[];
    end
    
    % Update options
    options.nfft = length(w);
    options.w    = w;
    
if a==1 & length(b)==1,
    % Scalar case
    phi = angle(b)*ones(length(phi),1);
end    

% Parse outputs
switch nargout,
    case 0,
        % Plot when no output arguments are given
        phaseplot(phi,w,s);
    case 1,
        varargout = {phi};
    case 2,
        varargout = {phi,w};
    case 3,
        varargout = {phi,w,s};
    case 4,
        varargout = {phi,w,s,options};
end


%-------------------------------------------------------------------------------
function h = modify_fresp(h)
% When h==0, the phase is not defined (introducing NaN's)

tol = eps^(2/3);
ind = find(abs(h)<=tol);
if ~isempty(ind);
    h(ind)=NaN;
end

%-------------------------------------------------------------------------------
function phi = unwrap_phase(h,w,iswholerange)

if iswholerange,
    phi=unwrap(angle(h));
    
else
    idx = find(w<0);
    if isempty(idx),
        % Range only positive frequencies
        phi=unwrap(angle(h));
    else
        idx = idx(end);
        phi_n=unwrap(angle(h(idx:-1:1)));
        if idx<length(w),
            phi_p=unwrap(angle(h(idx+1:end)));
        else
            phi_p = [];
        end
        phi=[phi_n(end:-1:1);phi_p];
    end
end


%-------------------------------------------------------------------------------
function phaseplot(phi,w,s)

% Cell array of the standard frequency units strings (used for the Xlabels)
frequnitstrs = getfrequnitstrs;
switch lower(s.xunits),
    case 'rad/sample',
        xlab = frequnitstrs{1};
        w    = w./pi; % Scale by pi in the plot
    case 'hz',
        xlab = frequnitstrs{2}; 
    case 'khz',
        xlab = frequnitstrs{3};
    case 'mhz',
        xlab = frequnitstrs{4}; 
    case 'ghz',
        xlab = frequnitstrs{5};
    otherwise
        xlab = s.xunits;
end

plot(w,phi/pi*180);
xlabel(xlab);
ylabel('Phase (degrees)');
grid on;

% [EOF]
