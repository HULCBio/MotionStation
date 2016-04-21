## Copyright (C) 2010 VZLU Prague, a.s., Czech Republic
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
## @deftypefn{Function File} {} parcellfun_opts (args)
## Undocumented internal function.
## @end deftypefn

function [nargs, uniform_output, error_handler, ...
  verbose_level, chunks_per_proc, vectorized] = parcellfun_opts (args)

  uniform_output = true;
  error_handler = [];
  verbose_level = 1; # default to normal output level
  chunks_per_proc = 0; # 0 means than size of chunk is 1
  vectorized = false;

  nargs = length (args);

  ## parse options
  while (nargs > 1)
    opt = args{nargs-1};
    if (! ischar (opt))
      break;
    else
      opt = tolower (opt);
      val = args{nargs};
    endif
    switch (opt)
    case "uniformoutput"
      uniform_output = logical (val);
      if (! isscalar (uniform_output))
        error ("parcellfun: UniformOutput must be a logical scalar");
      endif
    case "errorhandler"
      error_handler = val;
      if (! isa (error_handler, "function_handle"))
        error ("parcellfun: ErrorHandler must be a function handle");
      endif
    case "verboselevel"
      verbose_level = val;
      if (! isscalar (verbose_level))
        error ("parcellfun: VerboseLevel must be a numeric scalar");
      endif
    case "chunksperproc"
      chunks_per_proc = round (val);
      if (! isscalar (chunks_per_proc) || chunks_per_proc <= 0)
        error ("parcellfun: ChunksPerProc must be a positive scalar");
      endif
    case "vectorized"
      vectorized = logical (val);
      if (! isscalar (vectorized))
        error ("parcellfun: Vectorized must be a logical scalar");
      endif
    otherwise
      break;
    endswitch
    nargs -= 2;
  endwhile

  if (vectorized && chunks_per_proc <= 0)
    error ("parcellfun: the ""Vectorized"" option requires also ""ChunksPerProc""");
  endif

endfunction
