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
## @deftypefn {Function File}  {} qaskenco (@var{m})
## @deftypefnx {Function File} {} qaskenco (@var{msg},@var{m})
## @deftypefnx {Function File} {@var{y} = } qaskenco (@var{...})
## @deftypefnx {Function File} {[@var{inphase}, @var{quadr}] =} qaskenco (@var{...})
##
## Map a digital signal using a square QASK constellation. The argument
## @var{m} must be a positive integer power of 2. With two input arguments
## the variable @var{msg} represents the message to be encoded. The values
## of @var{msg} must be between 0 and @code{@var{m}-1}. In all cases
## @code{qaskenco(@var{M})} is equivalent to @code{qaskenco(1:@var{m},@var{m})}
##
## Three types of outputs can be created depending on the number of output 
## arguments. That is
##
## @table @asis
## @item No output arguments
## In this case @dfn{qaskenco} plots the constellation. Only the
## points in @var{msg} are plotted, which in the case of a single input
## argument is all constellation points.
## @item A single output argument
## The returned variable is a complex variable representing the in-phase 
## and quadrature components of the mapped  message @var{msg}. With, a 
## single input argument this effectively gives the mapping from symbols
## to constellation points
## @item Two output arguments
## This is the same as two ouput arguments, expect that the in-phase
## and quadrature components are returned explicitly. That is
##
## @example
## octave> c = qaskenco(msg, m);
## octave> [a, b] = qaskenco(msg, m);
## octave> all(c == a + 1i*b)
## ans = 1
## @end example
## @end table
##
## If @code{sqrt(@var{m})} is an integer, then @dfn{qaskenco} uses a Gray
## mapping. Otherwise, an attempt is made to create a nearly square mapping 
## with a minimum Hamming distance between adjacent constellation points.
## @end deftypefn
## @seealso{qaskdeco}

## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified for new gnuplot interface (octave > 2.9.0)

function [a, b] = qaskenco(msg, M)

  if (nargin == 1)
    M = msg;
  elseif (nargin == 2)
    if ((min(msg(:)) < 0) || (max(msg(:)) > M-1))
      error ("qaskenco: message invalid");
    endif
  else
    error ("qaskenco: incorrect number of arguments");
  endif

  if (!isscalar(M) || (M != ceil(M)) || (M < 2))
    error ("qaskenco: order of modulation must be a positive integer greater than 2");
  endif

  if (log2(M) != ceil(log2(M)))
    error ("qaskenco: the order must be a power of two");
  endif
  
  if (M == 2)
    inphase = [-1,  1];
    quadr =   [ 0,  0];
  elseif (M == 4)
    inphase = [-1, -1,  1,  1];
    quadr =   [-1,  1, -1,  1];
  elseif (M == 8)
    inphase = [-1, -1,  1,  1, -3, -3,  3,  3];
    quadr =   [-1,  1, -1,  1, -1,  1, -1,  1];
  else
    NC =2^floor(log2(sqrt(M)));
    MM = NC * NC;
    Gray = [0, 1];
    for i=2:ceil(log2(NC))
      Gray = [Gray 2^(i-1) + fliplr(Gray)];
    end
    Gray = fliplr(de2bi(shift(Gray,length(Gray)/2 - 1)));
    Gray2 = zeros(MM,log2(MM));
    Gray2(:,1:2:log2(MM)) = repmat(Gray,NC,1);
    for i=1:NC
      Gray2(i:NC:MM,2:2:log2(MM)) = Gray;
    end
    layout = reshape(bi2de(fliplr(Gray2)),NC,NC);

    if (MM != M)
      ## Not sure this is the best that can be done for these mappings. If 
      ## anyone wants to improve this, go ahead, but do it in qaskdeco too.
      OFF = sqrt(M/32);
      NR = NC + 2*OFF;
      layout2 = NaN * ones(NR);
      layout2(1+OFF:OFF+NC,1+OFF:OFF+NC) = layout;
      
      layout2(1:OFF,1+OFF:OFF+NC) = MM + layout(OFF:-1:1,:);
      layout2(NR-OFF+1:NR,1+OFF:OFF+NC) = MM + layout(NC:-1:NC-OFF+1,:);

      layout2(1+2*OFF:NC,1:OFF) = MM + layout(OFF+1:NC-OFF,OFF:-1:1);
      layout2(1+2*OFF:NC,NR-OFF+1:NR) = MM + ...
	  layout(OFF+1:NC-OFF,NC:-1:NC-OFF+1);

      layout2(1+OFF:2*OFF,1:OFF) = MM + ...
	  layout(NC/2:-1:NC/2-OFF+1,NC/2:-1:OFF+1);
      layout2(NC+1:OFF+NC,1:OFF) = MM + ...
	  layout(NC-OFF:-1:NC/2+1,NC/2:-1:OFF+1);

      layout2(1+OFF:2*OFF,NR-OFF+1:NR) = MM + ...
	  layout(NC/2:-1:NC/2-OFF+1,NC-OFF:-1:NC/2+1);
      layout2(NC+1:OFF+NC,NR-OFF+1:NR) = MM + ...
	  layout(NC-OFF:-1:NC/2+1,NC-OFF:-1:NC/2+1);
      NC = NR;
      layout = layout2;
    endif

    inphase = repmat([0:NC-1]*2 - NC + 1,1,NC);
    for i=1:NC
      quadr(i:NC:NC*NC) = [0:NC-1]*2 - NC + 1;
    end
    [dummy, indx] = sort(layout(:));
    indx = indx(1:M);			## Get rid of remaining NaN's
    inphase = inphase(indx);
    quadr = quadr(indx);
  endif

  if (nargin == 2)
    inphase = inphase(msg+1);
    quadr = quadr(msg+1);
    ## Fix up indexing if using column vector
    if (size(msg,2) == 1)
      inphase = inphase';
      quadr = quadr';
    endif
  endif

  if (nargout == 0)
    inphase = inphase(:);
    quadr = quadr(:);
    plot (inphase, quadr, "r+");
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
  elseif (nargout == 1)
    a = inphase + 1i * quadr;
  else
    a = inphase;
    b = quadr;
  endif

endfunction
