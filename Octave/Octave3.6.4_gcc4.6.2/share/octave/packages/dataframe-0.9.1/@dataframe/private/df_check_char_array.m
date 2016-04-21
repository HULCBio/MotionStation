function resu = df_check_char_array(x, nelem, required)

  %# auxiliary function: pad a char array to some width

  %% Copyright (C) 2009-2012 Pascal Dupuis <Pascal.Dupuis@uclouvain.be>
  %%
  %% This file is part of Octave.
  %%
  %% Octave is free software; you can redistribute it and/or
  %% modify it under the terms of the GNU General Public
  %% License as published by the Free Software Foundation;
  %% either version 2, or (at your option) any later version.
  %%
  %% Octave is distributed in the hope that it will be useful,
  %% but WITHOUT ANY WARRANTY; without even the implied
  %% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  %% PURPOSE.  See the GNU General Public License for more
  %% details.
  %%
  %% You should have received a copy of the GNU General Public
  %% License along with Octave; see the file COPYING.  If not,
  %% write to the Free Software Foundation, 51 Franklin Street -
  %% Fifth Floor, Boston, MA 02110-1301, USA.
  
  %#
  %# $Id: df_check_char_array.m 9585 2012-02-05 15:32:46Z cdemills $
  %#
  
  if 2 == nargin, required = [nelem 1]; endif

  if nelem < required(1),
    error("Too many elements to assign");
  endif

  %# a zero-length element is still considered as a space by char
  if isempty(x), x = ' '; endif 

  if size(x, 1) < max(required(1), nelem)
    %# pad vertically
    dummy = repmat(' ', nelem-size(x, 1), 1);
    resu = char(x, dummy);
  else
    resu = x;
  endif
      
  if size(resu, 2) < required(2),
    %# pad horizontally
    dummy = repmat(' ', nelem, required(2)-size(resu, 2));
    resu = horzcat(resu, dummy);
  endif

endfunction
