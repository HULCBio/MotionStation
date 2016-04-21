## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
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
## @deftypefn {Function File} {@var{fileStr} =} data2geo (@var{data}, @var{lc})
## @deftypefnx {Function File} {@var{fileStr} =} data2geo (@dots{}, @var{param}, @var{value})
## Uses data to build a file compatible with Gmsh.
##
## @var{data} is assumed to describe a polygon in @code{polygon2d} format.
## The argument @var{lc} specifies the edge size.
##
## The optional parameters can be 'output' followed with a string specifying a file
## to write, and 'spherical' followed by a real number @var{r} indicating that the
##  polygon describes a spherical surface of radious @var{r}.
##
## @seealso{polygon2d, @@svg/path2polygon}
## @end deftypefn

function strFile = data2geo(data,lc,varargin)

    nl = @()sprintf('\n');

    ## Parse options
    filegiven = [];
    spherical = [];
    if nargin > 2
      filegiven = find(cellfun(@(x)strcmpi(x,'output'),varargin));
      spherical = find(cellfun(@(x)strcmpi(x,'spherical'),varargin));
    end

    [n dim] = size(data);
    if dim == 2
        data(:,3) = zeros(n,1);
    end

    header = ' // File created with Octave';
    strFile = [];
    strFile = [strFile header nl()];

    # Points
    strFile = [strFile '// Points' nl()];

    for i=1:n
        strFile = [strFile pointGeo(i,data(i,:),lc)];
    end

    # Lines
    strFile = [strFile '// Lines' nl()];
    for i=1:n-1
        strFile = [strFile lineGeo(i,i,i+1)];
    end
    strFile = [strFile lineGeo(n,n,1)];

    # Loop
    strFile = [strFile lineLoopGeo(n+1,n,1:n)];

    # Surface
    if spherical
        sphr = varargin{spherical+1};
        if dim ==2
            sphr(1,3) = 0;
        end
        strFile = [strFile pointGeo(n+1,sphr,lc)];
        strFile = [strFile ruledSurfGeo(n+3,1,n+1,n+1)];
    else
        strFile = [strFile planeSurfGeo(n+2,1,n+1)];
    end

    if filegiven
        outfile = varargin{filegiven+1};
        fid = fopen(outfile,'w');
        fprintf(fid,'%s',strFile);
        fclose(fid);
        disp(['DATA2GEO: Geometry file saved to ' outfile])
    end
endfunction

%!demo
%! points  = [0 0 0; 0.1 0 0; 0.1 .3 0; 0 0.3 0];
%! strFile = data2geo(points,0.009);
%! disp(strFile)

%!demo
%! dc = svg('drawing6.svg');
%! ids = dc.pathid();
%! P = dc.path2polygon(ids{1},12)(1:end-1,:);
%! P = bsxfun(@minus, P, centroid(P));
%! P = simplifypolygon(P,'tol',5e-1);
%! filename = tmpnam ();
%! meshsize = sqrt(mean(sumsq(diff(P,1,1),2)))/2;
%! data2geo (P, meshsize, 'output', [filename '.geo']);
%!
%! pkg load msh fpl
%! T = msh2m_gmsh(filename);
%! pdemesh(T.p,T.e,T.t)
%!
%! # --------------------------------------------------------------------------
%! # We load the drawing6.svg file into Octave and transform it into a polygon.
%! # Then we create a temporary file where the .geo mesh will be written.
%! # If the packages msh and fpl are available, a mesh is created from the .geo
%! # file.
