## Copyright (C) 2004 Patrick Labbe
## Copyright (C) 2004 Laurent Mazet <mazet@crm.mot.com>
## Copyright (C) 2005 Larry Doolittle <ldoolitt@recycle.lbl.gov>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{nb} =} dxfwrite (@var{filename}, @var{pl}, @dots{})
##
## Write @var{filename} as a DXF file. Polyline @var{pl} must be defined as
## matrix of 1, 2 or 3 columns respectively for x, y and z coordinates. The
## number of polyline (@var{nb}) or 0 is returned.
## @end deftypefn

function [nb] = dxfwrite (filename, varargin)
  
  ## Check file name
  sn = split(filename, ".");
  if !strcmp(tolower(deblank(sn(end,:))), "dxf")
    filename = [filename, ".dxf"];
  endif

  ## Check arguments
  nb = 0;
  if nargin <= 1
    usage("dxfwrite = (filename, pl, ...)");
    return;
  endif
  
  ## Open file
  fid = fopen (filename, "wt");
  if fid <= 0
    error("error opening file \"%s\"\n", filename);
  endif

  ## Format string
  FMT = sprintf("%%.%dg", save_precision);

  ## Header declarations
  fprintf (fid, ["0\nSECTION\n", "2\nHEADER\n"]);
  ## DXF version
  fprintf (fid, ["9\n$ACADVER\n", "1\nAC1009\n"]); ## AutoCAD R11
  ## End of headers
  fprintf (fid, "0\nENDSEC\n");

  ## Table declarations
  fprintf (fid, ["0\nSECTION\n", "2\nTABLES\n"]);

  ## Line type declarations
  fprintf (fid, ["0\nTABLE\n", "2\nLTYPE\n"]);
  ## Number of line types
  fprintf (fid, "70\n1\n");
  ## New line type
  fprintf (fid, "0\nLTYPE\n");
  ## Line type name
  fprintf (fid, "2\nCONTINUOUS\n");
  ## Standard flags
  fprintf (fid, "70\n0\n"); ## Optimal for AutoCAD
  ## Descriptive text for linetype
  fprintf (fid, "3\nContinuous line\n");
  ## Alignment code
  fprintf (fid, "72\n65\n"); ## the ASCII code for A
  ## Number of linetype elements
  fprintf (fid, "73\n0\n"); 
  ## Total pattern length
  fprintf (fid, "40\n0\n");
  ## Pattern definition
  ## ???
  ## End of line types
  fprintf (fid, "0\nENDTAB\n");

  ## Layers declarations
  fprintf (fid, ["0\nTABLE\n", "2\nLAYER\n"]);
  ## Number of layers
  fprintf (fid, "70\n%d\n", nargin-1);

  nb = 0;
  for i=1:nargin-1
    nb++;
    ## New layer
    fprintf (fid, "0\nLAYER\n");
    ## Layer name
    fprintf (fid, "2\nCurve%d\n", nb);
    ## Standard flags
    fprintf (fid, "70\n0\n"); ## Optimal for AutoCAD
    ## Line type
    fprintf (fid, "6\nCONTINUOUS\n");
    ## Color number
    fprintf (fid, "62\n%d\n", nb);
  endfor
  ## End of layers
  fprintf (fid, "0\nENDTAB\n");

  ## End of tables
  fprintf (fid, "0\nENDSEC\n");

  ## Entity declarations
  fprintf (fid, ["0\nSECTION\n", "2\nENTITIES\n"]);
  
  nb = 0;
  for i=1:nargin-1
    tmp_pl = varargin{1+nb++};
    
    ## Check curve dimension (1, 2 or 3)
    if columns(tmp_pl) <= 3
      pl = zeros(rows(tmp_pl), 3);
      pl(:, 1:columns(tmp_pl)) = tmp_pl;
    else
      warning ("%dth entry skipped (more than 3 dimensions)", nb);
      continue;
    endif

    ## Check if the curve is closed
    closed = false;
    if pl(1, :) == pl(rows(pl), :)
      closed = true;
      pl = pl([1:rows(pl)-1], :);
    endif

    ## New polyline
    fprintf (fid, "0\nPOLYLINE\n");

    ## Layer name
    fprintf (fid, "8\nCurve%d\n", nb);
    ## Line type name
    fprintf (fid, "6\nCONTINUOUS\n");
    ## Color number???
    fprintf (fid, "66\n%d\n", nb);
    ## Standard flags
    fprintf (fid, "70\n%d\n", closed);

    ## Layer specification
    layspec = sprintf("8\nCurve%d\n", nb);

    ## List of vertex
    fprintf(fid, ["0\nVERTEX\n", layspec, \
                  "10\n",FMT,"\n", "20\n",FMT,"\n", "30\n",FMT,"\n"], pl.');

    ## End of polyline
    fprintf(fid, "0\nSEQEND\n");
    
  endfor
  
  ## End of entities
  fprintf(fid, "0\nENDSEC\n");
  
  ## End of file
  fprintf(fid, "0\nEOF\n");
  
  ## Close file
  fclose(fid);
  
endfunction
