## Copyright (C) 2008 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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

##-*- texinfo -*-
## @deftypefn{Function File} infoskeleton(@var{prototype}, @var{index_str}, @var{see_also})
## Generate TeXinfo skeleton documentation of @var{prototype}.
##
## Optionally @var{index_str} and @var{see_also} can be specified.
##
## Usage of this function is typically,
## @example
## infoskeleton('[V,Q] = eig( A )','linear algebra','eigs, chol, qr, det')
## @end example
## @seealso{info}
## @end deftypefn

function infoskeleton( prototype , index_str, seealso)

  ## FIXME: add placeholders for math TeX code, examples etc.

  if nargin < 1
    print_usage();
  end

  if nargin < 2
    index_str = "";
  end

  if nargin < 3
    seealso = "";
  end

  ## 
  ## try to parse the function prototype
  ## as:
  ## function retval = fname ( arg1, arg2, etc )"
  ##
  prototype = strtrim( prototype );
  idx = strfind( prototype, "function" );
  if ( !isempty( idx ) )
    prototype(idx:idx+7) = "";
  end

  idx = strfind( prototype, "=" );
  retval = "";
  if( !isempty( idx )   )  
     retval = strtrim ( prototype( 1 : idx(1)-1 ) );
     prototype = prototype ( idx(1) + 1: end );
  end     


  idx = strfind( prototype, "(" );
  fname = prototype;
  if( !isempty( idx )   )  
    fname = strtrim( prototype(1:idx(1)-1) );
    prototype = prototype(idx(1) + 1:end);
  end

  ## next time, use strtok() very easy & simple

  pos = 0; args = {};
  idx =  strfind( prototype , "," );
  if ( !isempty( idx ) )
    prev = [ 0, idx ];
    for pos=1:length( idx )
      args{ pos } = strtrim ( prototype(prev( pos )+1 :idx(pos)-1) );
    end
    prototype = prototype(idx(end) + 1:end);
  end

  idx = strfind( prototype, ")" );
  if ( !isempty( idx ) )
    lvar = strtrim ( prototype(1:idx(1)-1) );
    if ( length( lvar ) > 0 ) 
      args{ pos + 1 } =  lvar;
    end
  end


  ## generate the code
  fprintf("## -*- texinfo -*-\n")
  if ( length( retval ) > 0 )
    fprintf("## @deftypefn{Function File} {@var{%s} = } %s (", ...
            retval,fname );
  else
    fprintf("## @deftypefn{Function File} { } %s (", ...
            fname );
  end

  pos = 0;
  for pos = 1:length(args)-1
    fprintf(" %s,", args{pos} );
  end
  if ( length(args) > 0 )
    fprintf(" %s ) \n", args{pos+1} );
  end
  fprintf("## @cindex %s \n",index_str);
  fprintf("##  The function %s calculates    where",fname );
  pos = 0;
  for pos = 1:length(args)-1
    fprintf(" @var{%s} is ,", args{pos} );
  end
  if ( length(args) > 0 )
    fprintf(" @var{%s} is   .\n", args{pos+1} );
  end
   
  fprintf("## @example\n");
  fprintf("## \n");
  fprintf("## @end example\n");

  fprintf("## @seealso{%s}\n",seealso);
  fprintf("## @end deftypefn\n");
end

%!demo infoskeleton( ' [x,y,z]=infoskeleton(func , z , z9 , jj, fjh, x)  ')
%!demo infoskeleton('[V,Q] = eig( A )','linear algebra','eigs, chol, qr, det')
%!demo infoskeleton( 'function [x,y,z] =  indian_languages ( x)  ')
