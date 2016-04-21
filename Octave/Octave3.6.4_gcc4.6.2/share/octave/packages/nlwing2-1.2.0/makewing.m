% Copyright (C) 2008  VZLU Prague, a.s., Czech Republic
% 
% Author: Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of NLWing2.
% 
% NLWing2 is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this software; see the file COPYING.  If not, see
% <http://www.gnu.org/licenses/>.
% 

% -*- texinfo -*-
% @deftypefn{Function File} {wing =} makewing (acs, pols, ref, panels)
% Creates the wing structure necessary for further computations. 
% @var{acs} is an N-by-5 array specifying the spanwise geometry description.
% each row contains @code{[zac xac yac chord twist]}
% pols is a struct array describing the spanwise wing section data
% distribution. @code{pols(i).z} is the spanwise coordinate, @code{pols(i).cl}
% is the lift coefficient on local angle of attack dependence, etc. 
% @var{ref} contains the reference quantities.
% @var{panels} specifies either an approximate number of panels,
% or directly the z-coordinates of panel vertices. In the latter case, 
% @var{panels}(1) and @var{panels}(end) should match @var{acs}(1,1) and
% @var{acs}(end,1), respectively.
% @end deftypefn
function wing = makewing (ac, pols, ref, np = 80, zac = [])

  ozac = ac(:,1);

  if (isempty (zac))
    % distribute points
    if (ref.sym)
      zmx = ozac(end);
      fi = linspace (0, pi/2, np+1).';
      zac = zmx * sin (fi);
    else
      zmxl = ozac(1); zmxu = ozac(end);
      fi = linspace (0, pi/2, np/2+1)';
      zac = [zmxl * sin(fi(end:-1:2)); zmxu * sin(fi)];
    endif
  endif

  wing.zac = zac;
  aci = interp1 (ozac, ac(:,2:5), zac, "pchip");
  wing.xac = aci(:,1);
  wing.yac = aci(:,2);
  wing.cac = aci(:,3);

  m2 = @(v) (v(1:end-1)+v(2:end))/2;
  wing.zc = zc = m2 (zac);
  wing.ch = m2 (aci(:,3));
  wing.twc = pi/180 * m2 (aci(:,4));

  zpol = [pols.z];
  if (! issorted (zpol))
    [zpol, isrt] = sort (zpol);
    pols = pols(isrt);
  endif

  % set jj so that zc(jj(i)-1) <= zpol(i) < zc(jj(i)) 
  % which, in turn, means 
  % zpol(i) < zc(jj(i)) <= zc(jj(i+1)-1) <= zpol(i+1)
  jj = lookup (zc, zpol) + 1;
  % correct boundary values (to include all of zc)
  jj(1) = 1;
  jj(end) = length (zc) + 1;

  wing.pidx = jj;
  wing.pol = pols;
  wing.np = np;

  wing.a0 = zeros (np, 1);
  wing.amax = zeros (np, 1);
  wing.clmax = zeros (np, 1);
  wing.cf = zeros (np, 1);

  % FIXME: 3.3.50+ will handle discontinuous interpolation.
  for i=1:length (jj)-1
    jl = jj(i); ju = jj(i+1)-1;
    if (jl <= ju)
      lcf = (zc(jl:ju) - zpol(i)) / (zpol(i+1) - zpol(i));
      wing.cf(jl:ju) = lcf;
      wing.a0(jl:ju) = (1-lcf) * pols(i).a0 + lcf * pols(i+1).a0 + wing.twc(jl:ju);
      wing.amax(jl:ju) = (1-lcf) * pols(i).amax + lcf * pols(i+1).amax + wing.twc(jl:ju);
      wing.clmax(jl:ju) = (1-lcf) * pols(i).clmax + lcf * pols(i+1).clmax;
    endif
  endfor

  for [val,key] = ref
    wing.(key) = val;
  endfor
  dS = wing.ch .* diff (wing.zac);
  if (! isfield (wing, 'sym'))
    wing.sym = true;
  endif
  if (! isfield (wing, 'area'))
    area = wing.area = sum (dS);
    if (wing.sym)
      wing.area *= 2;
    endif
  else
    area = wing.area / 2;
  endif
  if (! isfield (wing, 'cmac'))
    wing.cmac = sum (dS .* wing.ch) / area;
  endif
  if (! isfield (wing, 'span'))
    wing.span = wing.zac(end) - wing.zac(1);
    if (wing.sym)
      wing.span *= 2;
    endif
  endif
  xac = wing.xac; xac = (xac(1:end-1) + xac(2:end))/2;
  yac = wing.yac; yac = (yac(1:end-1) + yac(2:end))/2;
  if (! isfield (wing, 'xmac'))
    wing.xmac = dot (dS, xac) / area;
    wing.ymac = dot (dS, yac) / area;
  endif
  dxmac = xac - wing.xmac;
  dymac = yac - wing.ymac;
  wing.rmac = hypot (dymac, dxmac);
  wing.amac = atan2 (dymac, dxmac);
endfunction
