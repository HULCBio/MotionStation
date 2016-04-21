## Copyright (C) 2006,2007,2008,2009,2010,2012  Carlo de Falco, Massimiliano Culpo
##
## This file is part of:
##     MSH - Meshing Software Package for Octave
##
##  MSH is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  MSH is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with MSH; If not, see <http://www.gnu.org/licenses/>.
##
##  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>
##  author: Massimiliano Culpo <culpo _AT_ users.sourceforge.net>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{mesh}]} = @
## msh2m_gmsh(@var{geometry},@var{option},@var{value},...)
## @deftypefnx {Function File}{[@var{mesh}, @var{gmsh_out}]} = msh2m_gmsh(...) 
##
## Construct an unstructured triangular 2D mesh making use of the free
## software gmsh.
##
## The compulsory argument @var{geometry} is the basename of the
## @code{*.geo} file to be meshed. 
##
## The optional arguments @var{option} and @var{value} identify
## respectively a gmsh option and its value. For more information
## regarding the possible option to pass, refer to gmsh manual or gmsh
## site @url{http://www.geuz.org/gmsh/}. 
##
## The returned value @var{mesh} is a PDE-tool like mesh structure.
## If the function is called with two outputs @var{gmsh_out} is the verbose output
## of the gmsh subprocess.
##
## @seealso{msh2m_structured_mesh, msh3m_gmsh, msh2m_mesh_along_spline}
## @end deftypefn

function [mesh, gmsh_output] = msh2m_gmsh (geometry, varargin)

  ## Check input
  if !mod(nargin,2) # Number of input parameters
    error("msh2m_gmsh: wrong number of input parameters.");
  endif
  ## FIXME: add input type check?

  ## Build mesh
  noptions  = (nargin - 1) / 2; # Number of passed options
  
  ## Construct system command string
  verbose   = 1;
  optstring = "";
  for ii = 1:noptions
    option    = varargin{2*(ii)-1};
    value     = varargin{2*ii};
    ## Check for verbose option
    if strcmp(option,"v")
      verbose = value;
    endif
    if !ischar(value)
      value = num2str(value);
    endif
    optstring = [optstring," -",option," ",value];
  endfor

  ## Invoke gmsh
  if (verbose)
    printf("\n");
    printf("Generating mesh...\n");
  endif

  msh_name = strcat (tmpnam (), ".msh");
  fclose (fopen (msh_name, "w"));

  [status, gmsh_output] = system (["gmsh -format msh -2 -o " msh_name optstring " " geometry ".geo 2>&1 "]);
  if (status)
    error ("msh2m_gmsh: the gmesh subprocess exited abnormally");
  endif

  fname = tmpnam ();
  fclose (fopen (strcat (fname, "_e.txt"), "w"));
  e_filename =  canonicalize_file_name (strcat (fname, "_e.txt"));

  fclose (fopen (strcat (fname, "_p.txt"), "w"));
  p_filename =  canonicalize_file_name (strcat (fname, "_p.txt"));

  fclose (fopen (strcat (fname, "_t.txt"), "w"));
  t_filename =  canonicalize_file_name (strcat (fname, "_t.txt"));
  
  ## Build structure fields
  if (verbose)
    printf("Processing gmsh data...\n");
  endif
  ## Points
  com_p   = sprintf ("awk '/\\$Nodes/,/\\$EndNodes/ {print $2, $3 > ""%s""}' ", p_filename);
  ## Side edges
  com_e   = sprintf ("awk '/\\$Elements/,/\\$EndElements/ {n=3+$3; if ($2 == ""1"") print $(n+1), $(n+2), $5 > ""%s""}' ", e_filename);
  ## Triangles
  com_t   = sprintf ("awk '/\\$Elements/,/\\$EndElements/ {n=3+$3; if ($2 == ""2"") print $(n+1), $(n+2), $(n+3), $5 > ""%s""}' ", t_filename);

  command = [com_p, msh_name, ";"];
  command = [command, com_e, msh_name, ";"];
  command = [command, com_t, msh_name];
  
  system (command);

  ## Create PDE-tool like structure
  if (verbose)
    printf("Creating PDE-tool like mesh...\n");
  endif
  p   = load(p_filename)'; # Mesh-points
  tmp = load(e_filename)'; # Mesh surface-edges
  be  = zeros(7,columns(tmp));
  be([1,2,5],:) = tmp;
  t   = load(t_filename)'; # Mesh tetrahedra

  ## Remove hanging nodes
  if (verbose)
    printf("Check for hanging nodes...\n");
  endif
  nnodes = columns(p);
  in_msh = intersect( 1:nnodes , t(1:3,:) );
  if length(in_msh) != nnodes
    new_num(in_msh) = [1:length(in_msh)];
    t(1:3,:)        = new_num(t(1:3,:));
    be(1:2,:)       = new_num(be(1:2,:));
    p               = p(:,in_msh);
  endif

  ## Set region numbers in edge structure
  if (verbose)
    printf("Setting region number in edge structure...\n");
  endif
  mesh          = struct("p",p,"t",t,"e",be);
  tmp           = msh2m_topological_properties (mesh, "boundary");
  mesh.e(6,:)   = t(4,tmp(1,:));
  jj            = find (sum(tmp>0)==4);
  mesh.e(7,jj)  = t(4,tmp(3,jj)); 
  
  ## Delete temporary files
  if (verbose)
    printf("Deleting temporary files...\n");
  endif
  unlink (p_filename);
  unlink (e_filename);
  unlink (t_filename);
  unlink (msh_name);

endfunction

%!test
%! fid = fopen("circle.geo","w");
%! fprintf(fid,"Point(1) = {0, 0, 0, 1};\n");
%! fprintf(fid,"Point(2) = {1, 0, 0, 1};\n");
%! fprintf(fid,"Point(3) = {-1, 0, 0, 1};\n");
%! fprintf(fid,"Circle(1) = {3, 1, 2};\n");
%! fprintf(fid,"Circle(2) = {2, 1, 3};\n");
%! fprintf(fid,"Line Loop(4) = {2, 1};\n");
%! fprintf(fid,"Plane Surface(4) = {4};");
%! fclose(fid);
%! mesh = msh2m_gmsh("circle","v",0);
%! system("rm circle.geo");
%! nnodest = length(unique(mesh.t));
%! nnodesp = columns(mesh.p);
%! assert(nnodest,nnodesp);

%!demo
%! name = [tmpnam ".geo"];
%! fid = fopen (name, "w");
%! fputs (fid, "Point(1) = {0, 0, 0, .1};\n");
%! fputs (fid, "Point(2) = {1, 0, 0, .1};\n");
%! fputs (fid, "Point(3) = {1, 0.5, 0, .1};\n");
%! fputs (fid, "Point(4) = {1, 1, 0, .1};\n");
%! fputs (fid, "Point(5) = {0, 1, 0, .1};\n");
%! fputs (fid, "Point(6) = {0, 0.5, 0, .1};\n");
%! fputs (fid, "Line(1) = {1, 2};\n");
%! fputs (fid, "Line(2) = {2, 3};\n");
%! fputs (fid, "Line(3) = {3, 4};\n");
%! fputs (fid, "Line(4) = {4, 5};\n");
%! fputs (fid, "Line(5) = {5, 6};\n");
%! fputs (fid, "Line(6) = {6, 1};\n");
%! fputs (fid, "Point(7) = {0.2, 0.6, 0};\n");
%! fputs (fid, "Point(8) = {0.5, 0.4, 0};\n");
%! fputs (fid, "Point(9) = {0.7, 0.6, 0};\n");
%! fputs (fid, "BSpline(7) = {6, 7, 8, 9, 3};\n");
%! fputs (fid, "Line Loop(8) = {6, 1, 2, -7};\n");
%! fputs (fid, "Plane Surface(9) = {8};\n");
%! fputs (fid, "Line Loop(10) = {7, 3, 4, 5};\n");
%! fputs (fid, "Plane Surface(11) = {10};\n");
%! fclose (fid);
%! mesh = msh2m_gmsh (canonicalize_file_name (name)(1:end-4), "clscale", ".5");
%! trimesh (mesh.t(1:3,:)', mesh.p(1,:)', mesh.p(2,:)');
%! unlink (canonicalize_file_name (name));