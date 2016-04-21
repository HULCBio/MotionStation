function sysd = c2d(sys,Ts,method,w)
%C2D  Conversion of continuous-time models to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD) converts the continuous-time LTI 
%   model SYSC to a discrete-time model SYSD with sample time Ts.  
%   The string METHOD selects the discretization method among the 
%   following:
%      'zoh'       Zero-order hold on the inputs
%      'foh'       Linear interpolation of inputs (triangle appx.)
%      'imp'       Impulse-invariant discretization
%      'tustin'    Bilinear (Tustin) approximation
%      'prewarp'   Tustin approximation with frequency prewarping.  
%                  The critical frequency Wc (in rad/sec) is specified
%                  as fourth input by 
%                     SYSD = C2D(SYSC,Ts,'prewarp',Wc)
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   For state-space models,
%      [SYSD,G] = C2D(SYSC,Ts,METHOD)
%   also returns a matrix G that maps continuous initial conditions
%   into discrete initial conditions.  Specifically, if x0,u0 are
%   initial states and inputs for SYSC, then equivalent initial
%   conditions for SYSD are given by
%      xd[0] = G * [x0;u0],     ud[0] = u0 .
%
%   See also D2C, D2D, LTIMODELS.

%	Clay M. Thompson  7-19-90, A. Potvin 12-5-95
%       P. Gahinet  7-18-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.33 $  $Date: 2002/04/10 06:13:12 $


ni = nargin;
no = nargout;
tolint = 1e4*eps;  % tolerance for fractional delays

% Error handling
error(nargchk(2,4,ni))
if ~isa(Ts,'double') | length(Ts)~=1 | Ts<=0,
    error('Second input argument TS must be a positive scalar')
elseif ni==2,  
    method = 'zoh';  
elseif ~ischar(method) | length(method)==0,
    error('METHOD must be a nonempty string.')
elseif isempty(findstr(lower(method(1)),'mzftpi'))
    error(sprintf('Unknown discretization method "%s".',method'))
end
method = lower(method);

% Extract data
[Zero,Pole,Gain,ts] = zpkdata(sys);
if ts~=0,  
    error('System is already discrete. Use D2D to resample.'),
end
sizes = size(Gain);
ny = sizes(1);
nu = sizes(2);

% Handle various methods
sysd = sys;
switch method(1)
case 'm'
    % Matched pole-zero: extract ZPK data
    if ~isequal([ny nu],[1 1]),
        error('Matched pole-zero method only applicable to SISO systems.')
    end
    
    % Entry-by-entry discretization
    for i=1:prod(sizes(3:end)),
        z = Zero{i};   p = Pole{i};
        RealFlag = isreal(Gain(i)) & isconjugate(z) & isconjugate(p);
        
        % Zero/pole r mapped to exp(r*Ts)
        zd = exp(z*Ts);
        pd = exp(p*Ts);
        
        % Guard against overflow
        if ~all(isfinite(zd)) | ~all(isfinite(pd))
            error('Overflow in C2D conversion with matched pole/zero method.')
        end
        
        % Map zeros at infinity to z=-1 except one (see Franklin-Powell, 3a. on p.61)
        zd = [zd; -ones(length(pd)-length(zd)-1,1)];
        
        % Match D.C. gain or gain at s=1/Ts for systems with integrator
        % RE: s = sm -> z = exp(Ts*sm)
        sm = 0;
        while any(abs([z;p]-sm)<sqrt(eps)),
            sm = sm + 0.1/Ts;
        end
        zm = exp(sm*Ts);
        dcc = Gain(i)*prod(sm-z)/prod(sm-p);
        kd = dcc*prod(zm-pd)/prod(zm-zd);
        if RealFlag
            kd = real(kd);
        end
        
        % Require that gain be real
        sysd.z{i} = zd;
        sysd.p{i} = pd;
        sysd.k(i) = kd;
    end
    
    % Update LTI properties
    sysd.lti = c2d(sys.lti,Ts,tolint);
    
case {'t' 'p'},
    % Tustin approximation
    if method(1)=='t',
        c = 2/Ts;
    elseif ni<4,
        error('The critical frequency must be specified when using prewarp method.')
    else
        c = w/tan(w*Ts/2);
    end
    
    % Loop over all SISO entries
    for i=1:prod(sizes),
        z = Zero{i};   
        p = Pole{i};   
        k = Gain(i);
        lpmz = length(p) - length(z);
        RealFlag = isreal(k) & isconjugate(z) & isconjugate(p);
        
        % Each factor (s-rj) is transformed to
        %           (2/T - rj) z - (2/T + rj)
        %           -------------------------
        %                     z + 1
        % Handle zeros first:
        cmz = c - z;   % 2/T-z
        cpz = c + z;   % 2/T+z
        ix = (cmz==0);
        % Zeros s.t. 2/T-zj~=0 mapped to (2/T+zj)/(2/T-zj), other contribute to gain
        z = cpz(~ix,:) ./ cmz(~ix,:); 
        k = k * prod(-cpz(ix,:)) * prod(cmz(~ix,:));
        
        % Then handle poles:
        cmp = c - p;   % 2/T-p
        cpp = c + p;   % 2/T+p
        ix = (cmp==0);
        % Poles s.t. 2/T-pj~=0 mapped to (2/T+pj)/(2/T-pj), other contribute to gain
        p = cpp(~ix,:) ./ cmp(~ix,:); 
        k = k / prod(-cpp(ix,:)) / prod(cmp(~ix,:));
        if RealFlag
            k = real(k);
        end
        
        % (z+1) factors may contribute additional poles or zeros
        z = [z ; -ones(lpmz,1)];
        p = [p ; -ones(-lpmz,1)];
        
        sysd.z{i} = z;
        sysd.p{i} = p;
        sysd.k(i) = k;
    end
    
    % Update LTI properties
    sysd.lti = c2d(sys.lti,Ts,tolint);
    
otherwise
    % ZOH or FOH
    % Extract delay data, derive discrete input and output delays and 
    % absorb fractional input and output delays into I/O delay matrix.
    Tdin = pvget(sys.lti,'InputDelay');
    Tdout = pvget(sys.lti,'OutputDelay');
    Tdio = pvget(sys.lti,'ioDelay');
    did = floor(Tdin/Ts+tolint);  % Discrete input delays
    dod = floor(Tdout/Ts+tolint); % Discrete output delays
    fid = max(0,Tdin-Ts*did);     % Fractional input delays
    fod = max(0,Tdout-Ts*dod);    % Fractional output delays
    Tdio = Tdio + repmat(fid',[sizes(1) 1]) + repmat(fod,[1 sizes(2)]);
    if ndims(Tdio)<length(sizes),
        Tdio = repmat(Tdio,[1 1 sizes(3:end)]);
    end
    
    % Entry-by-entry conversion
    h = zpk(0);
    diod = zeros(size(Tdio));
    for i=1:prod(sizes),
        % Form SISO model H = TF(NUM{I},DEN{I})
        h.z = Zero(i);
        h.p = Pole(i);
        h.k = Gain(i);
        h.lti = pvset(h.lti,'InputDelay',Tdio(i));
        hd = zpk(c2d(ss(h),Ts,method));
        sysd.z(i) = hd.z;
        sysd.p(i) = hd.p;
        sysd.k(i) = hd.k;
        diod(i) = totaldelay(hd.lti);  % discrete I/O delay
    end
    
    % Update LTI properties
    sysd.lti = c2d(sys.lti,Ts,did,dod,diod);  
    
end


% Set variable to z
sysd.Variable = 'z';

