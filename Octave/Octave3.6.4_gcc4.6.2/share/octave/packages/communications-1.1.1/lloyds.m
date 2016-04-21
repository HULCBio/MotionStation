## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {[@var{table}, @var{codes}] = } lloyds (@var{sig},@var{init_codes})
## @deftypefnx {Function File} {[@var{table}, @var{codes}] = } lloyds (@var{sig},@var{len})
## @deftypefnx {Function File} {[@var{table}, @var{codes}] = } lloyds (@var{sig},@var{...},@var{tol})
## @deftypefnx {Function File} {[@var{table}, @var{codes}] = } lloyds (@var{sig},@var{...},@var{tol},@var{type})
## @deftypefnx {Function File} {[@var{table}, @var{codes}, @var{dist}] = } lloyds (@var{...})
## @deftypefnx {Function File} {[@var{table}, @var{codes}, @var{dist}, @var{reldist}] = } lloyds (@var{...})
##
## Optimize the quantization table and codes to reduce distortion. This is 
## based on the article by Lloyd
##
##  S. Lloyd @emph{Least squared quantization in PCM}, IEEE Trans Inform 
##  Thoery, Mar 1982, no 2, p129-137
##
## which describes an iterative technique to reduce the quantization error
## by making the intervals of the table such that each interval has the same
## area under the PDF of the training signal @var{sig}. The initial codes to
## try can either be given in the vector @var{init_codes} or as scalar
## @var{len}. In the case of a scalar the initial codes will be an equi-spaced
## vector of length @var{len} between the minimum and maximum value of the 
## training signal.
##
## The stopping criteria of the iterative algorithm is given by
##
## @example
## abs(@var{dist}(n) - @var{dist}(n-1)) < max(@var{tol}, abs(@var{eps}*max(@var{sig}))
## @end example
##
## By default @var{tol} is 1.e-7. The final input argument determines how the
## updated table is created. By default the centroid of the values of the
## training signal that fall within the interval described by @var{codes} 
## are used to update @var{table}. If @var{type} is any other string than
## "centroid", this behaviour is overriden and @var{table} is updated as
## follows.
##
## @example
## @var{table} = (@var{code}(2:length(@var{code})) + @var{code}(1:length(@var{code}-1))) / 2
## @end example
##
## The optimized values are returned as @var{table} and @var{code}. In 
## addition the distortion of the the optimized codes representing the
## training signal is returned as @var{dist}. The relative distortion in
## the final iteration is also returned as @var{reldist}.
##
## @end deftypefn
## @seealso{quantiz}

function [table, code, dist, reldist] = lloyds(sig, init, tol, type)

  if ((nargin < 2) || (nargin > 4))
    usage (" [table, codes, dist, reldist] = lloyds(sig, init [, tol [,type]])");
  endif

  if (min(size(sig)) != 1)
    error ("lloyds: training signal must be a vector");
  endif

  sig = sig(:);
  sigmin = min(sig);
  sigmax = max(sig);

  if (length(init) == 1)
    len = init;
    init = [0:len-1]'/(len-1) * (sigmax - sigmin)  + sigmin;
  elseif (min(size(init))) 
    len = length(init);
  else
    error ("lloyds: unrecognized initial codebook");
  endif
  lcode = length(init);

  if (any(init != sort(init)))
    ## Must be monotonically increasing
    error ("lloyds: Initial codebook must be monotonically increasing");
  endif

  if (nargin < 3)
    tol = 1e-7;
  elseif (isempty(tol))
    tol = 1e-7;
  endif
  stop_criteria = max(eps * abs(sigmax), abs(tol));

  if (nargin < 4)
    type = "centroid";
  elseif (!ischar(type))
    error ("lloyds: expecting string argument for type");
  endif

  ## Setup initial codebook, table and distortion
  code = init(:);
  table = (code(2:lcode) + code(1:lcode-1))/2;
  [indx, ignore, dist] = quantiz(sig, table, code);
  reldist = abs(dist);

  while (reldist > stop_criteria)
    ## The formula of the code at the new iteration is
    ##
    ##  code = Int_{table_{i-1}}^{table_i} x PSD(sig(x)) dx / ..
    ##          Int_{table_{i-1}}^{table_i} PSD(sig(x)) dx
    ##
    ## As sig is a discrete signal, this comes down to counting the number
    ## of times "sig" has values in each interval of the table, and taking
    ## the mean of these values. If no value of the signals in interval, take
    ## the middle of the interval. That is calculate the centroid of the data
    ## of the training signal falling in the interval. We can reuse the index
    ## from the previous call to quantiz to define the values in the interval.
    for i=1:lcode
      psd_in_interval = find(indx == i-1);
      if (!isempty(psd_in_interval))
	code(i) = mean(sig(psd_in_interval));
      elseif (i == 1)
	code(i) = (table(i) + sigmin) / 2; 
      elseif (i == lcode)
	code(i) = (sigmax + table(i-1)) / 2; 
      else
	code(i) = (table(i) + table(i-1)) / 2; 
      endif
    end

    ## Now update the table. There is a problem here, in that I believe
    ## the elements of the new table should be given by b(i)=(c(i+1)+c(i))/2,
    ## but Matlab doesn't seem to do this. Matlab seems to also take the
    ## centroid of the code for the table (this was a real pain to find
    ## why my results and Matlab's disagreed). For this reason, I have a 
    ## default behaviour the same as Matlab, and allow a flag to overide
    ## it to be the behaviour I expect. If any one wants to tell me what
    ## the CORRECT behaviour is, then I'll get rid of of the irrelevant
    ## case below.
    if (strcmp(type,"centroid"))
      for i=1:lcode-1;
	sig_in_code = sig(find(sig >= code(i)));
	sig_in_code = sig_in_code(find(sig_in_code < code(i+1)));
	if (!isempty(sig_in_code))
	  table(i) = mean(sig_in_code);
	else
	  table(i) = (code(i+1) + code(i)) / 2;
	endif
      end
    else
      table = (code(2:lcode) + code(1:lcode-1))/2;
    endif

    ## Update the distortion levels
    reldist = dist;
    [indx, ignore, dist] = quantiz(sig, table, code);
    reldist = abs(reldist - dist);
  endwhile

  if (size(init,1) == 1)
    code = code';
    table = table';
  endif

endfunction
