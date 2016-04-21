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
## @deftypefn {Function File} {@var{msg} =} qaskdeco (@var{c},@var{m})
## @deftypefnx {Function File} {@var{msg} =} qaskdeco (@var{inphase},@var{quadr},@var{m})
## @deftypefnx {Function File} {@var{msg} =} qaskdeco (@var{...},@var{mnmx})
##
## Demaps an analog signal using a square QASK constellation. The input signal
## maybe either a complex variable @var{c}, or as two real variables 
## @var{inphase} and @var{quadr} representing the in-phase and quadrature 
## components of the signal.
##
## The argument @var{m} must be a positive integer power of 2. By deafult the
## same constellation as created in @dfn{qaskenco} is used by @dfn{qaskdeco}.
## If is possible to change the values of the minimum and maximum of the
## in-phase and quadrature components of the constellation to account for
## linear changes in the signal values in the received signal. The variable
## @var{mnmx} is a 2-by-2 matrix of the following form
##
## @multitable @columnfractions 0.125 0.05 0.25 0.05 0.25 0.05
## @item @tab | @tab min in-phase   @tab , @tab max in-phase   @tab |
## @item @tab | @tab min quadrature @tab , @tab max quadrature @tab |
## @end multitable
## 
## If @code{sqrt(@var{m})} is an integer, then @dfn{qaskenco} uses a Gray
## mapping. Otherwise, an attempt is made to create a nearly square mapping 
## with a minimum Hamming distance between adjacent constellation points.
## @end deftypefn
## @seealso{qaskenco}

function a = qaskdeco(varargin)

  have_mnmx = 0;
  if (nargin == 2)
    c = varargin{1};
    inphase = real(c);
    quadr = imag(c);
    M = varargin{2};
  elseif (nargin == 3)
    if (all(size(varargin{3}) == [2 2]))
      c = varargin{1};
      inphase = real(c);
      quadr = imag(c);
      M = varargin{2};
      mnmx = varargin{3};
      have_mnmx = 1;
    else
      inphase = varargin{1};
      quadr = varargin{2};
      M = varargin{3};
    endif
  elseif (nargin == 4)
    inphase = varargin{1};
    quadr = varargin{2};
    M = varargin{3};
    mnmx = varargin{4};
    have_mnmx = 1;
  else
    error ("qaskdeco: incorrect number of arguments");
  endif

  if (iscomplex(inphase) || iscomplex(quadr))
    error ("qaskdeco: error in in-phase and/or quadrature components");
  endif

  if (!isscalar(M) || (M != ceil(M)) || (M < 2))
    error ("qaskdeco: order of modulation must be a positive integer greater than 2");
  endif

  if (log2(M) != ceil(log2(M)))
    error ("qaskdeco: the order must be a power of two");
  endif

  if (have_mnmx)
    if (any(size(mnmx) != [2 2]))
      error ("qaskdeco: error in max/min constellation values");
    endif
  else
    if ((M == 2) || (M == 4))
      mnmx = [-1, 1; -1, 1];
    elseif (M == 8)
      mnmx = [-3, 3; -1, 1];
    elseif (sqrt(M) == floor(sqrt(M)))
      NC = 2^floor(log2(sqrt(M)));
      mnmx = [-NC+1, NC-1; -NC+1, NC-1];
    else
      NC = 2^floor(log2(sqrt(M))) + 2*sqrt(M/32);
      mnmx = [-NC+1, NC-1; -NC+1, NC-1];
    endif     
  endif

  if (M == 2)
    layout = [0, 1]';
  elseif (M == 4)
    layout = [0, 1; 2, 3];
  elseif (M == 8)
    layout = [4, 5; 0, 1; 2, 3; 6, 7];
  else
    NC =2^floor(log2(sqrt(M)));
    MM = NC * NC;
    Gray = [0 1];
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
      ## anyone wants to improve this, go ahead, but do it in qaskenco too.
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
      layout = layout2;
    endif
  endif

  ix = 1 + (inphase - mnmx(1,1))/(mnmx(1,2)-mnmx(1,1))*(size(layout,1)-1);
  qx = 1 + (quadr - mnmx(2,1))/(mnmx(2,2)-mnmx(2,1))*(size(layout,2)-1);

  try    wfi = warning("off", "Octave:fortran-indexing");
  catch  wfi = 0;
  end

  unwind_protect
    a = layout(size(layout,1)*(max(min(round(qx),size(layout,2)),1)-1) + ...
	       max(min(round(ix),size(layout,1)),1));
    ## XXX FIXME XXX Why is this necessary??
    if ((M == 2) &&(size(inphase,1) == 1))
      a = a';
    endif

    if (any(isnan(a(:))))
      ## We have a non-square constellation, with some invalid points.
      ## Map to nearest valid constellation points...
      indx = find(isnan(a(:)));
      ix = ix(indx);
      qx = qx(indx);
      ang = atan2(quadr(indx),inphase(indx));

      qx(find(ang > 3*pi/4)) = NR-OFF;
      ix(find((ang <= 3*pi/4) & (ang > pi/2))) = OFF+1;
      ix(find((ang <= pi/2) & (ang > pi/4))) = NR - OFF;
      qx(find((ang <= pi/4) & (ang > 0))) = NR - OFF;
      qx(find((ang <= 0) & (ang > -pi/4))) = OFF+1;
      ix(find((ang <= -pi/4) & (ang > -pi/2))) = NR - OFF;
      ix(find((ang <= -pi/2) & (ang > -3*pi/4))) = OFF+1;
      qx(find(ang <= -3*pi/4)) = OFF+1;

      a(indx) = layout(size(layout,1)*(max(min(round(qx), ...
		size(layout,2)),1)-1) + max(min(round(ix),size(layout,1)),1));
    endif
  unwind_protect_cleanup
    warning (wfi);
  end_unwind_protect

endfunction

%!function dec = __fntestqask1__ (msg, m)
%! [inp, qudr] = qaskenco (msg, m);
%! dec = qaskdeco (inp, qudr, m);

%!function __fntestqask2__ (m, dims)
%! msg = floor( rand(dims) * m);
%! assert (__fntestqask1__ (msg, m), msg);

%!test __fntestqask2__ (2, [100,100])
%!test __fntestqask2__ (4, [100,100])
%!test __fntestqask2__ (8, [100,100])
%!test __fntestqask2__ (16, [100,100])
%!test __fntestqask2__ (32, [100,100])
%!test __fntestqask2__ (64, [100,100])

%!test __fntestqask2__ (2, [100,100,3])
%!test __fntestqask2__ (4, [100,100,3])
%!test __fntestqask2__ (8, [100,100,3])
%!test __fntestqask2__ (16, [100,100,3])
%!test __fntestqask2__ (32, [100,100,3])
%!test __fntestqask2__ (64, [100,100,3])
