## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File} {[@var{m}] =} amdemod (@var{s}, @var{fc}, @var{fs})
## Compute the amplitude demodulation of the signal @var{s} with a carrier 
## frequency of @var{fc} and a sample frequency of @var{fs}.
## @seealso{ammod}
## @end deftypefn

function [m] = amdemod(s,fc,fs)
  if(nargin ~= 3)
	  usage("m = amdemod(s,fc,fs)");
  end
  t = 0:1./fs:(length(s)-1)./fs;
  e = s.*cos(2.*pi.*fc.*t);
  [b a] = butter(5,fc.*2./fs);
  m = filtfilt(b,a,e).*2;
