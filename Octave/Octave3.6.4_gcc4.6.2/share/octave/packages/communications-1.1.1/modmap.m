## Copyright (C) 2003 David Bateman
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}  {} modmap (@var{method},@var{...})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'ask',@var{m})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'fsk',@var{m},@var{tone})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'msk')
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'psk',@var{m})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'qask',@var{m})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'qask/cir',@var{nsig},@var{amp},@var{phs})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'qask/arb',@var{inphase},@var{quadr})
## @deftypefnx {Function File}  {y = } modmap (@var{x},@var{fd},@var{fs},'qask/arb',@var{map})
##
## Mapping of a digital signal to an analog signal. With no output arguments
## @dfn{modmap} plots the constellation of the mapping. In this case the
## first argument must be the string @var{method} defining one of 'ask',
## 'fsk', 'msk', 'qask', 'qask/cir' or 'qask/arb'. The arguments following 
## the string @var{method} are generally the same as those after the 
## corresponding string in the fucntion call without output arguments.
## The exception is @code{modmap('msk',@var{Fd})}.
##
## With an output argument, @var{y} is the complex mapped analog signal. In
## this case the arguments @var{x}, @var{fd} and @var{fs} are required. The
## variable @var{x} is the digital signal to be mapped, @var{fd} is the
## sampling rate of the of digital signal and the @var{fs} is the sampling
## rate of the analog signal. It is required that @code{@var{fs}/@var{fd}}
## is an integer.
##
## The available mapping of the digital signal are
##
## @table @asis
## @item 'ask'
## Amplitude shift keying
## @item 'fsk'
## Frequency shift keying
## @item 'msk'
## Minimum shift keying
## @item 'psk'
## Phase shift keying
## @item 'qask'
## @itemx 'qsk'
## @itemx 'qam' 
## Quadraure amplitude shift keying
## @end table
##
## In addition the 'qask', 'qsk' and 'qam' method can be modified with the
## flags '/cir' or '/arb'. That is 'qask/cir' and 'qask/arb', etc are valid
## methods and give circular- and arbitrary-qask mappings respectively.
##
## The additional argument @var{m} is the order of the modulation to use.
## @var{m} must be larger than the largest element of @var{x}. The variable
## @var{tone} is the FSK tone to use in the modulation.
##
## For 'qask/cir', the additional arguments are the same as for 
## @dfn{apkconst}, and you are referred to @dfn{apkconst} for the definitions
## of the additional variables.
##
## For 'qask/arb', the additional arguments @var{inphase} and @var{quadr} give
## the in-phase and quadrature components of the mapping, in a similar mapping
## to the outputs of @dfn{qaskenco} with one argument. Similar @var{map}
## represents the in-phase and quadrature components of the mapping as
## the real and imaginary parts of the variable @var{map}.
## @end deftypefn
## @seealso{demodmap,dmodce,amodce,apkconst,qaskenco}

function y = modmap(varargin)

  method = "sample";
  if (nargout == 0)
    if (nargin < 1)
      error ("modmap: too few arguments");
    endif
    method = varargin{1};
    optarg = 1;
    M = 2;
    fd = 1;
    fs = 1;
  elseif (nargout == 1)
    if (nargin < 3)
      error ("modmap: too few arguments");
    endif
    x = varargin{1};
    fd = varargin{2};
    fs = varargin{3};
    if (nargin > 3)
      method = varargin{4};
    endif
    M = max(2,2^ceil(log2(max(x(:)) + 1)));
    optarg = 4;

    if (!isscalar(fs) || !isscalar(fd) || !isreal(fs) || !isreal(fd) || ...
	(fs <= 0) || (fd <= 0))
      error ("modmap: sampling rates must be positive real values");
    endif
    if (abs(fs/fd - floor(fs/fd)) > eps)
      error ("modmap: the sample rate Fs must be an integer multiple of Fd");
    endif

    nn = round(fs/fd);
    if (min(size(x)) == 1)
      n = length(x);
      yy = zeros(n,1);
      if (size(x,1) == 1)
	yy = yy';
      end
      for i=1:nn
	yy(i:nn:nn*n) = x;
      end
    else
      n = size(x,1);
      yy = zeros(n*nn,size(x,2));
      for i=1:nn
	yy(i:nn:nn*n,:) = x;
      end
    endif
    x = yy;
  else
    error ("modmap: too many output arguments");
  endif

  if (!ischar(method))
    error ("modmap: mapping method to use must be a string");
  endif

  if (isempty(findstr(method,"/arb")) && isempty(findstr(method,"/cir")))
    if (nargin > optarg)
      M = varargin{optarg+1};
      if (!isscalar(M) || !isreal(M) || (M < 0) || (M != floor(M)))
	error ("modmap: modulation order must be a real positive integer");
      endif
    endif
    if ((nargout != 0) && (M < max(x(:)) + 1))
      error ("modmap: illegal symbol in data for modulation order");
    endif
  endif

  if (strcmp(method,"ask"))
    if (nargin > optarg + 1)
      error ("modmap: too many arguments");
    endif

    if (nargout == 0)
      if (floor(M/2) == M/2)
	apkconst(2*ones(1,M/2),2*([1:M/2]-0.5)/(M-1));
      else
	apkconst([1,2*ones(1,floor(M/2))],2*([0:floor(M/2)])/(M-1));
      endif
    else
      if (floor(M/2) == M/2)
	c = [ -2*([M/2:-1:1]-0.5)/(M-1),  2*([1:M/2]-0.5)/(M-1)];
      else
	c = [ -2*([floor(M/2):-1:1])/(M-1),  0, 2*([1:floor(M/2)])/(M-1)];
      endif
      y = c(x+1);
      if (size(x,2) == 1)
	y = y';
      endif
    endif
  elseif (strcmp(method,"psk"))
    if (nargin > optarg + 1)
      error ("modmap: too many arguments");
    endif
    if (nargout == 0)
      apkconst(M,"n");
    else
      c = apkconst(M);
      y = c(x+1);
      if (size(x,2) == 1)
	y = y';
      endif
    endif
  elseif (strcmp(method,"msk"))

    if (nargout == 0)
      if (nargin > optarg)
	fd = varargin{optarg+1};
	if (!isscalar(fd))
	  error ("modmap: the sampling rate must be a scalar");
	endif
      endif
      if (nargin > optarg + 1)
	error ("modmap: too many arguments");
      endif

      ## This is an ugly plot, with little info. But hey!!!
      try stem ([0, fd], [2, 1]);
      catch
	error ("modmap: can not find stem-plot function");
      end
      title("MSK constellation");
      xlabel("Frequency (Hz)");
      ylabel("");
      axis([-fd, 2*fd, 0, 2]);
    else
      if (nargin > optarg)
	error ("modmap: too many arguments");
      endif
      tone = fd/2;
      y = tone * x;
    endif
  elseif (strcmp(method,"fsk"))
    if (nargin > optarg + 1)
      tone = varargin{optarg+2};
      if (!isscalar(tone))
	error ("modmap: the FSK tone must be a scalar");
      endif
    else
      tone = fd;
    endif
    if (nargin > optarg + 2)
      error ("modmap: too many arguments");
    endif

    if (nargout == 0)
      ## This is an ugly plot, with little info. But hey!!!
      try stem ([0:tone:(M-1)*tone], [2, ones(1,M-1)]);
      catch
	error ("modmap: can not find stem-plot function");
      end
      title("FSK constellation");
      xlabel("Frequency (Hz)");
      ylabel("");
      axis([-tone, M*tone, 0, 2]);
    else
      y = tone * x;
    endif
  elseif ((strcmp(method,"qask")) || (strcmp(method,"qsk")) || ...
	  (strcmp(method,"qam")))
    if (nargin > optarg + 1)
      error ("modmap: too many arguments");
    endif
    if (nargout == 0)
      qaskenco(M);
    else
      y = qaskenco(x, M);
    endif
  elseif ((strcmp(method,"qask/cir")) || (strcmp(method,"qsk/cir")) || ...
	  (strcmp(method,"qam/cir")))
    nsig = M;
    amp = [];
    phs = [];
    if (nargin > optarg)
      nsig = varargin{optarg+1};
      if (!isvector(nsig) || (sum(nsig) < M))
	error ("modmap: insufficient number of constellation point in qask/cir");
      endif
    endif
    if (nargin > optarg + 1)
      amp = varargin{optarg+2};
    endif
    if (nargin > optarg + 2)
      phs = varargin{optarg+3};
    endif
    if (nargout == 0)
      apkconst(nsig,amp,phs,"n");
    else
      c = apkconst(nsig,amp,phs);
      y = c(x+1);
      if (size(x,2) == 1)
	y = y';
      endif
    endif
  elseif ((strcmp(method,"qask/arb")) || (strcmp(method,"qsk/arb")) || ...
	  (strcmp(method,"qam/arb")))
    if (nargin == optarg)
      [inphase, quadr] = qaskenco(M);
    elseif (nargin == optarg+1)
      c = varargin{optarg+1}; 
      inphase = real(c);
      quadr = imag(c);
    elseif (nargin == optarg+2)
      inphase = varargin{optarg+1}; 
      quadr = varargin{optarg+2};
    else
      error ("modmap: incorrectly defined mapping in 'qask/arb'");
    endif
    if (!isreal(inphase) || !isreal(quadr) || !isvector(inphase) || ...
	!isvector(quadr) || !all(isfinite(inphase)) || ... 
	!all(isfinite(quadr)) ||(length(inphase) < M))
      error ("modmap: invalid arbitrary qask mapping");
    endif
    
    if (nargout == 0)
      inphase = inphase(:);
      quadr = quadr(:);
      plot (inphase, quadr, "+r");
      title("QASK Constellation");
      xlabel("In-phase");
      ylabel("Quadrature");
      axis([min(inphase)-1, max(inphase)+1, min(quadr)-1, max(quadr)+1]);
      xd = 0.02 * max(inphase);
      if (nargin == 2)
	msg = msg(:);
	for i=1:length(inphase)
	  text(inphase(i)+xd,quadr(i),num2str(msg(i)));
	end
      else
	for i=1:length(inphase)
	  text(inphase(i)+xd,quadr(i),num2str(i-1));
	end
      endif
      refresh;
    else
      y = inphase(x+1) + 1i * quadr(x+1);
      if (size(x,2) == 1)
	y = y';
      endif
    endif
  elseif (strcmp(method,"sample"))
    if (nargout == 0)
      error ("modmap: no constellation for resampling");
    endif
    ## Just for resampling !!! So don't need anything else here
    y = x;
  else
    error ("modmap: unknown mapping method");
  endif

endfunction
