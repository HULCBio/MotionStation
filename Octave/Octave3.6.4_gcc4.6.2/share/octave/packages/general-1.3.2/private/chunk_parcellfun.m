## Copyright (C) 2010 VZLU Prague, a.s., Czech Republic
## Copyright (C) 2010 Jean-Benoist Leger <jben@jben.info>
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
## @deftypefn{Function File} {} chunk_parcellfun (@dots{:})
## Undocumented internal function.
## @end deftypefn

function varargout = chunk_parcellfun (nproc, chunks_per_proc, func,
  error_handler, verbose_level, varargin)

  args = varargin;
  
  nchunks = chunks_per_proc * nproc;

  ## Compute optimal chunk sizes.
  N = numel (args{1});
  len_chunk = ceil (N/nchunks);
  chunk_sizes = len_chunk (ones(1, nchunks));
  chunk_sizes(1:nchunks*len_chunk - N) -= 1;

  ## Split argument arrays into chunks (thus making arrays of arrays).
  chunked_args = cellfun (@(arg) mat2cell (arg(:), chunk_sizes), args, ...
  "UniformOutput", false);

  ## Attach error handler if present.
  if (! isempty (error_handler))
    chunked_args = [chunked_args, {"ErrorHandler", error_handler}];
  endif

  ## Main call.
  [out_brut{1:nargout}] = parcellfun (nproc, func, chunked_args{:}, ...
  "UniformOutput", false, "VerboseLevel", verbose_level);

  ## Concatenate output args and reshape them to correct size.
  true_size = size (args{1});
  varargout = cellfun (@(arg) reshape (vertcat (arg{:}), true_size), out_brut, "UniformOutput", false);

endfunction

