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
## @deftypefn {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'ask',@var{m})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'fsk',@var{m},@var{tone})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'msk')
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'psk',@var{m})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'qask',@var{m})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'qask/cir',@var{nsig},@var{amp},@var{phs})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'qask/arb',@var{inphase},@var{quadr})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},@var{fd},@var{fs},'qask/arb',@var{map})
## @deftypefnx {Function File}  {z = } demodmap (@var{y},[@var{fd}, @var{off}],@var{...})
##
## Demapping of an analog signal to a digital signal. The function 
## @dfn{demodmap} must have at least three input arguments and one
## output argument. Argument @var{y} is a complex variable representing
## the analog signal to be demapped. The variables @var{fd} and @var{fs} are
## the sampling rate of the of digital signal and the sampling rate of the
## analog signal respectively. It is required that @code{@var{fs}/@var{fd}}
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
## methods and give circular- and arbitrary-qask mappings respectively. Also
## the method 'fsk' and 'msk' can be modified with the flag '/max', in
## which case @var{y} is assumed to be a matrix with @var{m} columns,
## representing the symbol correlations.
##
## The variable @var{m} is the order of the modulation to use. By default
## this is 2, and in general should be specified.
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
## @seealso{modmap,ddemodce,ademodce,apkconst,qaskenco}

function z = demodmap (y, fd, fs, varargin)

  if (nargin < 3)
    error ("demodmap: too few arguments");
  endif

  if (!isscalar(fs) || !isreal(fs) || !isreal(fd) ||(fs <= 0) || (fd <= 0))
    error ("demodmap: sampling rates must be positive real values");
  endif
  if (abs(fs/fd - floor(fs/fd)) > eps)
    error ("demodmap: the sample rate Fs must be an integer multiple of Fd");
  endif

  if (!isscalar(fd))
    if (isequal(size(fd),[1,2]))
      off = fd(2);
      fd = fd(1);
    else
      error ("demodmap: sampling rate Fd must be a scalar or two-element row-vector");
    endif
  else
    off = 0;
  endif

  if (nargin > 3)
    method = varargin{1};
    if (!ischar(method) || (!strcmp(method,"ask") && ...
	                          isempty(findstr(method,"msk")) && isempty(findstr(method,"fsk")) && ...
	                          isempty(findstr(method,"samp")) && !strcmp(method,"psk") && ...
	                          !strcmp(method,"qask") && !strcmp(method,"qam") && ...
	                          !strcmp(method,"qsk") && !strcmp(method,"qask/cir") && ...
	                          !strcmp(method,"qam/cir") && !strcmp(method,"qsk/cir") && ...
	                          !strcmp(method,"qask/arb") && !strcmp(method,"qam/arb") && ...
	                          !strcmp(method,"qsk/arb")))
      error ("modmap: unknown mapping method");
    endif
  else
    method = "sample";
  endif

  if (!isreal(off) || (off < 0) || (off != floor(off)) || ...
      (off >= fs/fd))
    error ("demodmap: offset must be an integer in the range [0, Fs/Fd)");
  endif
  if (off == 0)
    off = round(fs/fd);
  endif

  if (min(size(y)) == 1)
    y = y(off:round(fs/fd):length(y));
  else
    y = y(off:round(fs/fd):size(y,1),:);
  endif

  if (strcmp(method,"ask") || !isempty(findstr(method,"fsk")) || ...
      strcmp(method,"psk") || strcmp(method,"qask") || ...
      strcmp(method,"qam") || strcmp(method,"qsk"))
    if (nargin > 4)
      M = varargin{2};
    else
      M = 2;
    endif
    if (!isempty(findstr(method,"fsk")) && (nargin > 5))
      error ("demodmap: too many arguments");
    endif
  endif

  z = [];
  if (!isempty(findstr(method,"fsk")) || !isempty(findstr(method,"msk")))
    if (findstr(method,"msk"))
      if (nargin > 4)
	      error ("demodmap: too many arguments");
      endif
      M = 2;
      tone = fd/2;
    else
      if (nargin > 5)
	      tone = varargin{3};
      else
	      tone = fd;
      endif
      if (nargin > 6)
	      error ("demodmap: too many arguments");
      endif
    endif

    if (findstr(method,"/max"))
      if (size(y,2) != M)
	      error ("demodmap: when using correlation must have M columns");
      endif
      ## We have an M-column maximum from which with pick index of the maximum
      ## value in each row as the decoded value
      [a, b] = max(y');
      z = (b - 1)';
    else
      c = [0:M-1]*tone;
    endif
  elseif (strcmp(method,"ask"))
    if (floor(M/2) == M/2)
      c = [ -2*([M/2:-1:1]-0.5)/(M-1),  2*([1:M/2]-0.5)/(M-1)];
    else
      c = [ -2*([floor(M/2):-1:1])/(M-1),  0, 2*([1:floor(M/2)])/(M-1)];
    endif
  elseif (strcmp(method,"psk"))
    c = apkconst(M,[],[]);
  elseif (!isempty(findstr(method,"qask")) || ...
	        !isempty(findstr(method,"qsk")) || ... 
	        !isempty(findstr(method,"qam")))
    if (findstr(method,"/cir"))
      nsig = 2;
      amp = [];
      phs = [];
      if (nargin > 4)
	      nsig = varargin{2};
	      if (!isvector(nsig))
	        error ("modmap: invalid number of constellation point in qask/cir");
	      endif
      endif
      if (nargin > 5)
	      amp = varargin{3};
      endif
      if (nargin > 6)
	      phs = varargin{4};
      endif
      c = apkconst(nsig,amp,phs);
      M = length(c);
    elseif (findstr(method,"/arb"))
      if (nargin == 4)
	      c = qaskenco(2);
      elseif (nargin == 5)
	      c = varargin{2}; 
      elseif (nargin == 6)
	      inphase = varargin{2}; 
	      quadr = varargin{3};
	      c = inphase + 1i*quadr;
      elseif (nargin > 6)
	      error ("demodmap: too many arguments");
      endif
      M = length(c);
    else
      ## Could do "c = qaskenco(M)", but qaskdeco's speed is not dependent
      ## on M, while speed of code below is O(M).
      z = qaskdeco(y,M);
    endif
  endif

  ## Have we decoded yet? If not have a mapping that we can use.
  if (isempty(z))
    c = c(:);
    z = zeros(size(y));
    if (size(y,1) == 1)
      [a, b] = min(abs(repmat(y(:).',M,1) - repmat(c,1,size(y,2))));
      z = b - 1;
    elseif (size(y,1) == 1)
      [a, b] = min(abs(repmat(y(:),M,1) - repmat(c,1,size(y,1))));
      z = (b - 1).';
    else
      for i=1:size(y,1)
	      [a, b] = min(abs(repmat(y(i,:),M,1) - repmat(c,1,size(y,2))));
	      z(i,:) = b - 1;
      end
    endif
  endif

endfunction


