function [frsp,eyefrsp] = mod2frsp(mod,freq,out,in,balflg)

%MOD2FRSP Complex frequency response of a matrix in MPC mod format
%	[frsp,eyefrsp] = mod2frsp(mod,freq,out,in,balflg)
%
%   Complex frequency response of a matrix in MPC mod format, produces
%   a VARYING matrix which contains its frequency response:
%
%    mod     - matrix in MOD format
%    freq    - row vector with lower power of 10, upper power of 10
%              and number of frequency points (0 --> matlab default=50)
%    out     - row vector of which outputs to use in response
%              (it uses all outputs as default or if out == [])
%    in      - row vector of which inputs to use in response
%              (it uses all inputs as default or if in == [])
%    balflg  - if nonzero balances PHI matrix prior to eval, zero (default)
%              value for BALFLG leaves state-space unchanged
%    frsp    - VARYING frequency response matrix
%    eyefrsp - I-FRSP VARYING frequency response matrix if square matrix
%
% See also MPCCL, PLOTFRSP, SMPCCL, SVDFRSP.

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

  t0 = clock;

  if nargin < 2
    disp('usage: [frsp,eyefrsp] = mod2frsp(mod,freq,out,in,balflg)')
    return
  end

  if size(freq) ~= [1 3] | freq(3) < 0
    error('freq should be a row vector of size 3 or no. of points >= 0')
    return
  end

  npts = freq(3);
  if npts == 0
    omega = logspace(freq(1),freq(2)).';
    npts = length(omega);
  else
    omega = logspace(freq(1),freq(2),npts).';
  end

  [phi,gamma,c,d,minfo] = mod2ss(mod);
  T=minfo(1);
  states=minfo(2);
  inputs=sum(minfo(3:5));
  outputs=sum(minfo(6:7));

  if nargin == 2
    in = [1:inputs];
    out = [1:outputs];
    balflg = 0;
  elseif nargin == 3
    in = [1:inputs];
    balflg = 0;
  elseif nargin == 4
    balflg = 0;
  end

  if isempty(out)
    out = [1:outputs];
  end
  if isempty(in)
    in = [1:inputs];
  end

  nin = length(in);
  nout = length(out);
  if nin ~= nout & nargout > 1
    fprintf('I-frsp cannot be calculated unless #inputs=%g be equal #outputs=%g\n', nin, nout);
    eyefrsp = [];
    idnyu = 0;
  else
    idnyu = eye(nout,nin);
  end

  jomega = sqrt(-1) * omega;
  if T ~= 0
    jomega = exp(T*jomega);
  end

  gamma = gamma(:,in);
  c = c(out,:);
  d = d(out,in);

  if balflg ~= 0
    [bal,phi] = balance(phi);
    gamma = bal\gamma;
    c = c*bal;
  end

  [p,hes] = hess(phi);
  hesg = p' * gamma;
  hesc = c * p;

  idn = eye(states);

  frsp = zeros((nout*npts)+1,nin+1);
  if idnyu(1) ~= 0
    eyefrsp = zeros((nout*npts)+1,nin+1);
  end

  ntout = (npts+1)*nout;
  ibeg = 1:nout:ntout;
  iend = ibeg(2:npts+1) - 1;

  time = etime(clock,t0);
  t0 = clock;

  g = (jomega(1) * idn - hes) \ hesg;
  frspi = d + hesc * g;
  frsp(ibeg(1):iend(1),1:nin) = frspi;
  if idnyu(1) ~= 0
    eyefrsp(ibeg(1):iend(1),1:nin) = idnyu - frspi;
  end

  time = time + etime(clock,t0) * npts;
  if npts > 1
    fprintf('over estimated time to perform the frequency response: %g sec\n',time);
  else
    fprintf('elapsed time to perform the frequency response: %g sec\n',time);
  end

  for i=2:npts
    g = (jomega(i) * idn - hes) \ hesg;
    frspi = d + hesc * g;
    frsp(ibeg(i):iend(i),1:nin) = frspi;
    if idnyu(1) ~= 0
      eyefrsp(ibeg(i):iend(i),1:nin) = idnyu - frspi;
    end
  end

  frsp(1:npts,nin+1) = omega;
  frsp((nout*npts)+1,nin+1) = inf;
  frsp((nout*npts)+1,nin) = npts;
  if idnyu(1) ~= 0
    eyefrsp(1:npts,nin+1) = omega;
    eyefrsp((nout*npts)+1,nin+1) = inf;
    eyefrsp((nout*npts)+1,nin) = npts;
  end
%