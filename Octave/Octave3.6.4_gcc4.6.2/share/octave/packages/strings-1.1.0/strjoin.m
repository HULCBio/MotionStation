## Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
## @deftypefn {Function File} {@var{rval} =} strjoin (@var{prefixstr}, @var{stringcell})
## @deftypefnx {Function File} {@var{rval} =} strjoin (@var{prefixstr}, @var{varargs})
## Joins the strings in @var{stringcell} with the @var{prefixstr} like the list-join
## function in Python; the second version allows usage with variable number of arguments.
## Note that, if using cell-array as a second argument, only 2 arguments are accepted.
## Also note that, both the arguments are strings or containers of strings (cells).
##
## @example
## @group
##           strjoin(' loves-> ','marie','amy','beth') 
##           ##returns 'marie loves-> amy loves-> beth'
##
##           strjoin('*',@{'Octave','Scilab','Lush','Yorick'@})
##           ##returns 'Octave*Scilab*Lush*Yorick'
## @end group
## @end example
## @seealso {strcmp}
## @end deftypefn

function rval = strjoin (spacer, varargin)
  if (nargin < 2) || (nargin > 2  && iscell(varargin{1}) )
    print_usage();
  end

  if iscell(varargin{1})
    varargin=varargin{1};
  end

  rval="";
  L=length(varargin);
  for idx=1:(L-1)
    rval=strcat(rval,sprintf('%s%s',varargin{idx},spacer));
  end
  rval=strcat(rval,varargin{L});
endfunction

%!assert(strjoin("-","hello"),"hello")
%!assert(strjoin('*',{'Octave','Scilab','Lush','Yorick'}),'Octave*Scilab*Lush*Yorick')
