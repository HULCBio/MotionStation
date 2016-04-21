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
## @deftypefn {Function File} {@var{K} = } ellipse2cov (@var{elli})
## @deftypefnx {Function File} {@var{K} = } ellipse2cov (@var{ra}, @var{rb})
## @deftypefnx {Function File} {@var{K} = } ellipse2cov (@dots{}, @var{theta})
## Calculates covariance matrix from ellipse.
##
## If only one input is given, @var{elli} must define an ellipse as described in
## @command{ellipses2d}.
## If two inputs are given, @var{ra} and @var{rb} define the half-lenght of the
## axes.
## If a third input is given, @var{theta} must be the angle of rotation of the
## ellipse in radians, and in counter-clockwise direction.
##
## The output @var{K} contains the covariance matrix define by the ellipse.
##
## Run @code{demo ellipse2cov} to see an example.
##
## @seealso{ellipses2d, cov2ellipse, drawEllipse}
## @end deftypefn

function K = ellipse2cov (elli, varargin);

  ra    = 1;
  rb    = 1;
  theta = 0;
  switch numel (varargin)
    case 0
    ## ellipse format
      if numel (elli) != 5
        print_usage ();
      end
      ra    = elli(1,3);
      rb    = elli(1,4);
      theta = elli(1,5)*pi/180;

    case 2
    ## ra,rb
      if numel (elli) != 1
        print_usage ();
      end
      ra = elli;
      rb = varargin{1};

    case 3
    ## ra,rb, theta
      if numel (elli) != 1
        print_usage ();
      end
      ra    = elli;
      rb    = varargin{1};
      theta = varargin{2};

    otherwise
      print_usage ();
  end

  T = createRotation (theta)(1:2,1:2);
  K = T*diag([ra rb])*T';

endfunction

%!demo
%! elli = [0 0 1 3 -45];
%!
%! # Create 2D normal random variables with covarinace defined by elli.
%! K = ellipse2cov (elli)
%! L = chol(K,'lower');
%! u = randn(1e3,2)*L';
%!
%! Kn = cov (u)
%!
%! figure(1)
%! plot(u(:,1),u(:,2),'.r');
%! hold on;
%! drawEllipse(elli,'linewidth',2);
%! hold off
%! axis tight
