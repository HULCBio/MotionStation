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
% @deftypefn{Function File} {[ac, pn, ref]} = loadwing (filename)
% Loads the basic wing geometry from file @var{filename}.
% The geometry should be described in the file as follows:
% @verbatim
% mchord <reference mean aerodynamic chord>
% area <reference wing area>
% mcenter <reference mean aerodynamic center>
% 
% centers
% <z1>  <x1>  <y1>  <c1>  <tw1>
%              :
% <zN>  <xN>  <yN>  <cN>  <twN>
% 
% polars
% <polar file name 1>
% <polar file name 2>
% 
% @end verbatim
% 
% xK, yK, zK are coordinates of the K-th point on the mean center line,
% cK is the corresponding chord length and twK the twist.
% 
% @end deftypefn

function [ac, pol, ref] = loadwing (filename)
f = fopen (filename, "rt");
if (f < 0)
  error ("loadwing: cannot open %s", filename)
endif

unwind_protect

  ac = [];
  pol = [];
  ref.sym = true;

  mode = 0;

  while (! feof (f))
    line = strtrim (fgets (f));
    % skip empty lines
    if (length (line) == 0) 
      continue;
    elseif (strcmp (line, "centers"))
      mode = 1;
    elseif (strcmp (line, "polars"))
      mode = 2;
    elseif (strmatch ('nonsymmetric', line))
      mode = 0;
      ref.sym = false;
    elseif (strmatch ('area', line))
      mode = 0;
      ref.area = sscanf (line(5:end), ' %f', 'C');
    elseif (strmatch ('mchord', line))
      mode = 0;
      ref.cmac = sscanf (line(8:end), ' %f', 'C');
    elseif (strmatch ('mcenter', line))
      mode = 0;
      [xmac, ymac] = sscanf (line(8:end), ' %f %f', 'C');
      ref.xmac = xmac;
      if (isempty (ymac))
	ref.ymac = 0;
      else
	ref.ymac = ymac;
      endif
    elseif (mode == 1)
      [z,x,y,c,a] = sscanf (line, '%f %f %f %f %f', 'C');
      if (isempty (a))
	a = 0;
      endif
      ac(end+1,:) = [z,x,y,c,a];
    elseif (mode == 2)
      i = length (pol) + 1;
      [pol(i).z, pol(i).names] = sscanf (line, '%f %s', 'C');
    endif
  endwhile

unwind_protect_cleanup
  fclose(f);
end_unwind_protect

if (ref.sym)
  if (ac(1,1) < 0 || ac(end,1) < 0)
    ac(:,1) = -ac(:,1);
  endif
  if (ac(1,1) < 0 || ac(end,1) < 0)
    warning ("loadwing: invalid symmetric wing");
  endif
  if (ac(1,1) > ac(end,1))
    ac = ac(end:-1:1,:);
  endif
endif

endfunction
