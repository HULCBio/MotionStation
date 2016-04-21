% Copyright (C) 2008  Jaroslav Hajek <highegg@gmail.com>
% 
% This file is part of OctaveForge.
% 
% OctaveForge is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
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

% function OLD_FLAG = benchutil_verbose (NEW_FLAG)
% sets or queries the benchmark verbosity flag
%
function flag = benchutil_verbose (setflag)
  persistent verbose;
  if (isempty (verbose))
    verbose = true;
  end
  if (nargin == 0 || nargout == 1)
    flag = verbose;
  end
  if (nargin == 1)
    verbose = setflag;
  end
