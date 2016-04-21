function [idx, nelem, subs, mask] = df_name2idx(names, subs, count, dimname, missingOK=false);

  %# This is a helper routine to translate rownames or columnames into
  %# real index. Input: names, a char array, and subs, a cell array as
  %# produced by subsref and similar. This routine can also detect
  %# ranges, two values separated by ':'. On output, subs is
  %# 'sanitised' from names, and is either a vector, either a single ':'

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
  %# $Id: df_name2idx.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if (isempty (subs))
    %# not caring about rownames ? Avoid generating an error.
    idx = []; nelem = 0; return
  endif

  if (isa (subs, 'char')),
    orig_name = subs;
    if (1 == size (subs, 1))
      if (strcmp(subs, ':')) %# range operator
        idx = 1:count; nelem = count;
        return
      endif
    endif
    subs = cellstr (subs);
  else
    if (~isvector(subs))
      %# yes/no ?
      %# error("Trying to access column as a matrix");
    endif
    switch (class (subs))
      case {"cell"}
        orig_name = char (subs);
      case {"dataframe"}
        orig_name = "elements indexed by a dataframe";
      otherwise
        orig_name = num2str (subs);
    endswitch
  endif

  if (isa (subs, 'cell'))
    subs = subs(:); idx = []; mask = logical (zeros (size (subs, 1), 1));
    %# translate list of variables to list of indices
    for indi = (1:size(subs, 1))
      %# regexp doesn't like empty patterns
      if (isempty (subs{indi})) continue; endif
      %# convert  from standard pattern to regexp pattern
      subs{indi} = regexprep (subs{indi}, '([^\.\\])(\*|\?)', "$1.$2");
      %# quote repetition ops at begining of line, otherwise the regexp
      %# will stall forever/fail
      subs{indi} = regexprep (subs{indi}, \
                              '^([\*\+\?\{\}\|])', "\\$1");
      %# detect | followed by EOL 
      subs{indi} = regexprep (subs{indi}, '([^\\])\|$', "$1\\|");
      if (0 == index (subs{indi}, ':'))
        for indj = (1:min (length (names), count)) %# sanity check
          if (~isempty (regexp (names{indj}, subs{indi})))
            idx = [idx indj]; mask(indi) = true;
          endif
        endfor
      else
        dummy = strsplit (subs{indi}, ':');
        ind_start = 1;
        if (!isempty (dummy{1}))
          ind_start = sscanf (dummy{1}, "%d");
          if (isempty (ind_start))
            ind_start = 1;
            for indj = (1:min(length (names), count)) %# sanity check
              if (~isempty (regexp (names{indj}, subs{indi}))),
                ind_start = indj; break; %# stop at the first match
              endif
            endfor
          endif
        endif
        
        if (isempty (dummy{2}) || strcmp (dummy{2}, 'end'))
          ind_stop = count;
        else
          ind_stop = sscanf(dummy{2}, "%d");
          if (isempty (ind_stop))
            ind_stop = 1;
            for indj = (min (length (names), count):-1:1) %# sanity check
              if (~isempty (regexp (names{indj}, subs{indi})))
                ind_stop = indj; break; %# stop at the last match
              endif
            endfor
          endif
        endif
        idx = [idx ind_start:ind_stop];
      endif
    endfor
    if (isempty (idx) && ~missingOK)
      dummy = sprintf ("Unknown %s name while searching for %s", ...
                       dimname, orig_name);
      error (dummy);
    endif
  elseif (isa (subs, 'logical'))
    idx = 1:length (subs(:)); idx = reshape (idx, size (subs));
    idx(~subs) = []; mask = subs;
  elseif (isa (subs, 'dataframe'))
    idx = subsindex (subs, 1);
  else
    idx = subs;
  endif

  subs = idx;
  nelem = length (idx);
  
endfunction
