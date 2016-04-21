## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{ellipse} = } cov2ellipse (@var{K})
## @deftypefnx {Function File} {[@var{ra} @var{rb} @var{theta}] = } cov2ellipse (@var{K})
## @deftypefnx {Function File} {@dots{} = } cov2ellipse (@dots{}, @samp{tol},@var{tol})
## Calculates ellipse parameters from covariance matrix.
##
## @var{K} must be symmetric positive (semi)definite. The optional argument
## @samp{tol} sets the tolerance for the verification of the
## positive-(semi)definiteness of the matrix @var{K} (see @command{isdefinite}).
##
## If only one output argument is supplied a vector defining a ellipse is returned
## as defined in @command{ellipses2d}. Otherwise the angle @var{theta} is given
## in radians.
##
## Run @code{demo cov2ellipse} to see an example.
##
## @seealso{ellipses2d, cov2ellipse, drawEllipse}
## @end deftypefn

function varargout = cov2ellipse (K, varargin);

  parser = inputParser ();
  parser.FunctionName = "cov2ellipse";
  parser = addParamValue (parser,'Tol', 100*eps*norm (K, "fro"), @(x)x>0);
  parser = parse(parser,varargin{:});

  if isdefinite (K,parser.Results.Tol) == -1
    print_usage
  end
  [R S W] = svd (K);
  theta = atan (R(1,1)/R(2,2));
  v     = sort (diag(S), 'ascend')';

  if nargout == 1
    varargout{1} = [0 0 v theta*180/pi];
  elseif nargout == 3
    varargout{1} = v(1);
    varargout{2} = v(2);
    varargout{3} = theta;
  end

endfunction

%!demo
%! K = [2 1; 1 2];
%! L = chol(K,'lower');
%! u = randn(1e3,2)*L';
%!
%! elli = cov2ellipse (K)
%!
%! figure(1)
%! plot(u(:,1),u(:,2),'.r');
%! hold on;
%! drawEllipse(elli,'linewidth',2);
%! hold off
%! axis tight
