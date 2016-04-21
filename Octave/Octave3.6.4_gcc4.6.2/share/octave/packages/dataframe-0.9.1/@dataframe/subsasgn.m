function df = subasgn(df, S, RHS)
  %# function df = subasgn(df, S, RHS)
  %# This is the assignement operator for a dataframe object, taking
  %# care of all the housekeeping of meta-info.

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
  %# $Id: subsasgn.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  if (isnull (df))
    error ('dataframe subsasgn: first argument may not be empty');
  endif
  
  switch (S(1).type)
    case '{}'
      error ('Invalid dataframe as cell assignement');
    case '.'
      %# translate the external to internal name
      switch (S(1).subs)
        case "rownames"
          if (~isnull (RHS) && isempty (df._name{1}))
            df._name{1}(1:df._cnt(1), 1) = {''};
            df._over{1}(1, 1:df._cnt(1)) = true;
          endif
          [df._name{1}, df._over{1}] = df_strset \
              (df._name{1}, df._over{1}, S(2:end), RHS);
          return

        case "rowidx"
          if (1 == length(S))
            df._ridx = RHS;
          else
            df._ridx = feval (@subsasgn, df._ridx, S(2:end), RHS);
          endif
          return
          
        case "colnames"
          if (isnull(RHS)) error ("Colnames can't be nulled"); endif
          [df._name{2}, df._over{2}] = df_strset \
              (df._name{2}, df._over{2}, S(2:end), RHS, '_');
          df._name{2} = genvarname (df._name{2});
          return
          
        case "types"
          if (isnull(RHS)) error("Types can't be nulled"); endif
          if (1 == length (S))
            %# perform explicit cast on each column
            df._data = cellfun (@(x) cast (x, RHS), df._data, 
                                "UniformOutput", false);
            df._type(1:end) = RHS;
          else
            if (~strcmp (S(2).type, '()'))
              error ("Invalid internal type sub-access, use () instead");
            endif 
            if (length (S) > 2 || length (S(2).subs) > 1)
              error("Types can only be changed as a whole");
            endif
            if (~isnumeric(S(2).subs{1}))
              [indj, ncol, S(2).subs{1}] = df_name2idx\
                  (df._name{2}, S(2).subs{1}, df._cnt(2), 'column');
            else
              indj = S(2).subs{1}; ncol = length (indj);
            endif
            df._data(indj) = cellfun (@(x) cast (x, RHS), df._data(indj), 
                                      "UniformOutput", false);
            df._type(indj) = {RHS};
          endif
          return
          
        case "source"
          if (length(S) > 1)
            df._src = feval (@subsasgn, df._src, S(2:end), RHS);
          else
            df._src = RHS;
          endif
          return

        case "comment"
          if (length(S) > 1)
            df._cmt = feval (@subsasgn, df._cmt, S(2:end), RHS);
          else
            df._cmt = RHS;
          endif
          return
          
        otherwise
          if (~ischar (S(1).subs))
            error ("Congratulations. I didn't see how to produce this error");
          endif
          %# translate the name to column
          [indc, ncol] = df_name2idx (df._name{2}, S(1).subs, \
                                      df._cnt(2), 'column', true);
          if (isempty(indc))
            %# dynamic allocation
            df = df_pad (df, 2, 1, class (RHS));
            indc = df._cnt(2); ncol = 1;
            df._name{2}(end) = S(1).subs;
            df._name{2} = genvarname(df._name{2});
            df._over{2}(end) = false;
          endif
          
          if (length(S) > 1)
            if (1 == length (S(2).subs)), %# add column reference
              S(2).subs{2} = indc;
            else
              S(2).subs(2:3) = {indc, S(2).subs{2}};
            endif
          else
            %# full assignement
            S(2).type = '()'; S(2).subs = { '', indc, ':' };
            if (ndims (RHS) < 3)
              if (isnull (RHS))
                S(2).subs = {':', indc};
              elseif (1 == size (RHS, 2))
                S(2).subs = { '', indc };
              elseif (1 == ncol && 1 == size (df._data{indc}, 2))
                %# force the padding of the vector to a matrix 
                S(2).subs = {'', indc, [1:size(RHS, 2)]};
              endif
            endif
          endif
          %# do we need to "rotate" RHS ?
          if (1 == ncol && ndims (RHS) < 3 \
                && size (RHS, 2) > 1)
            RHS = reshape (RHS, [size(RHS, 1), 1, size(RHS, 2)]);
          endif
          df = df_matassign (df, S(2), indc, ncol, RHS);
      endswitch
      
    case '()'
      [indr, nrow, S(1).subs{1}] = df_name2idx (df._name{1}, S(1).subs{1}, \
                                                df._cnt(1), 'row');
      if (isempty (indr) && df._cnt(1) > 0)
        %# this is not an initial assignment
        df = df; return;
      endif
      
      if (length (S(1).subs) > 1)
        if (~isempty (S(1).subs{2}))
          [indc, ncol, S(1).subs{2}] = \
              df_name2idx (df._name{2}, S(1).subs{2}, df._cnt(2), 'column');
          %# if (isempty (indc) && df._cnt(2) > 0)
          %# this is not an initial assignment
          %# df = df; return;
        else
          [indc, ncol] = deal ([]);
        endif
      else
        mz = max (cellfun (@length, df._rep));
        [fullindr, fullindc, fullinds] = ind2sub ([df._cnt(1:2) mz], indr);
        indr = unique( fullindr); indc = unique (fullindc); 
        inds = unique (fullinds);
        ncol = length (indc);
        if (any (inds > 1))
          S(1).subs{3} = inds;
        endif
      endif
      
      %# avoid passing ':' as selector on the two first dims
      if (~isnull (RHS))
        S(1).subs{1} = indr; S(1).subs{2} = indc;
      endif

      df = df_matassign (df, S, indc, ncol, RHS);
      
  endswitch
  
  %# disp("end of subasgn"); keyboard
  
endfunction
