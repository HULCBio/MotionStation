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
## msh3m_gmsh(@var{geometry},@var{option},@var{value},...) 
## @deftypefnx {Function File}{[@var{mesh}, @var{gmsh_out}]} = msh3m_gmsh(...) 
##
## Construct an unstructured tetrahedral 3D mesh making use of the free
## software gmsh.
##
## The required argument @var{geometry} is the basename of the
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
## @seealso{msh3m_structured_mesh, msh2m_gmsh, msh2m_mesh_along_spline}
## @end deftypefn

function [mesh, gmsh_output] = msh3m_gmsh (geometry, varargin)

  ## Check input
  ## Number of input
  if !mod(nargin,2)
    warning("WRONG NUMBER OF INPUT.");
    print_usage;
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

  ## Generate mesh using Gmsh
  if (verbose)
    printf("\n");
    printf("Generating mesh...\n");
  endif

  msh_name = strcat (tmpnam (), ".msh");
  fclose (fopen (msh_name, "w"));

  [status, gmsh_output] = system (["gmsh -format msh -3 -o " msh_name optstring " " geometry ".geo 2>&1"]);
  if (status)
    error ("msh3m_gmsh: the gmesh subprocess exited abnormally");
  endif

  if (verbose)
    printf("Processing gmsh data...\n");
  endif

  fname = tmpnam ();
  fclose (fopen (strcat (fname, "_e.txt"), "w"));
  e_filename =  canonicalize_file_name (strcat (fname, "_e.txt"));

  fclose (fopen (strcat (fname, "_p.txt"), "w"));
  p_filename =  canonicalize_file_name (strcat (fname, "_p.txt"));

  fclose (fopen (strcat (fname, "_t.txt"), "w"));
  t_filename =  canonicalize_file_name (strcat (fname, "_t.txt"));

  fclose (fopen (strcat (fname, "_s.txt"), "w"));
  s_filename =  canonicalize_file_name (strcat (fname, "_s.txt"));

  ## Points
  com_p   = sprintf ("awk '/\\$Nodes/,/\\$EndNodes/ {print $2, $3, $4 > ""%s""}' ", p_filename);
  ## Surface edges
  com_e   = sprintf ("awk '/\\$Elements/,/\\$EndElements/ {n=3+$3; if ($2 == ""2"") print $(n+1), $(n+2), $(n+3), $5 > ""%s""}' ", e_filename);
  ## Tetrahedra
  com_t   = sprintf ("awk '/\\$Elements/,/\\$EndElements/ {n=3+$3; if ($2 == ""4"") print $(n+1), $(n+2), $(n+3), $(n+4), $5 > ""%s""}' ", t_filename);
  ## Side edges
  com_s   = sprintf ("awk '/\\$Elements/,/\\$EndElements/ {n=3+$3; if ($2 == ""1"") print $(n+2), $(n+2), $5 > ""%s""}' ", s_filename);

  command = [com_p, msh_name, ";"];
  command = [command, com_e, msh_name, ";"];
  command = [command, com_t, msh_name, ";"];
  command = [command, com_s, msh_name];
  
  system (command);

  ## Create PDE-tool like structure
  if (verbose)
    printf("Creating PDE-tool like mesh...\n");
  endif
  ## Mesh-points
  p   = load(p_filename)';
  ## Mesh side-edges
  s   = load(s_filename)';
  ## Mesh surface-edges
  tmp = load(e_filename)';
  be  = zeros(10,columns(tmp));
  be([1,2,3,10],:) = tmp;
  ## Mesh tetrahedra
  t   = load(t_filename)';


  ## Remove hanging nodes
  if (verbose)
    printf("Check for hanging nodes...\n");
  endif
  nnodes = columns(p);
  in_msh = intersect( 1:nnodes , t(1:4,:) );
  if length(in_msh) != nnodes
    new_num(in_msh) = [1:length(in_msh)];
    t(1:4,:)        = new_num(t(1:4,:));
    be(1:3,:)       = new_num(be(1:3,:));
    p               = p(:,in_msh);
  endif

  mesh = struct("p",p,"s",s,"e",be,"t",t);
  
  if (verbose)
    printf("Deleting temporary files...\n");
  endif
  unlink (p_filename);
  unlink (e_filename);
  unlink (t_filename);
  unlink (s_filename);
  unlink (msh_name);

endfunction