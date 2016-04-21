function df = df_matassign(df, S, indc, ncol, RHS)
  %# auxiliary function: assign the dataframe as if it was a matrix

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
  %# $Id: df_matassign.m 9615 2012-02-10 15:22:57Z cdemills $
  %#

  if (isnull (RHS))
    if (1 == ncol)
      if (sum (~strcmp (S.subs, ':')) > 2)
        error("A null assignment can only have one non-colon index.");
      endif
    elseif (sum (~strcmp (S.subs, ':')) > 1)
      error("A null assignment can only have one non-colon index.");
    endif
    
    if (strcmp (S.subs(1), ':'))  %# removing column/matrix
      RHS = S; RHS.subs(2) = [];
      for indi = (indc)
        unfolded  = df._data{indi}(:, df._rep{indi});
        unfolded  = feval (@subsasgn, unfolded, RHS, []);
        df._data{indi} = unfolded;
        if (~isempty (unfolded))
          df._rep(indi) = 1:size (unfolded, 2);
        endif
      endfor
      %# remove empty elements
      indi = cellfun ('isempty', df._data);
      if (any (indi)) %# nothing left, remove this column
        df._cnt(2) = df._cnt(2) - sum (indi);
        indi = ~indi; %# vector of kept data
        df._name{2} = df._name{2}(indi);
        df._over{2} = df._over{2}(indi);
        df._type = df._type(indi);
        df._data = df._data(indi);
        df._rep = df._rep(indi);
      endif
      if (size (df._ridx, 3) > 1)
        df._ridx(:, indc, :) = [];
      endif
    elseif (strcmp (S.subs(2), ':'))  %# removing rows
      indr = S.subs{1}; 
      if (~isempty (df._name{1}))
        df._name{1}(indr, :) = []; 
        df._over{1}(indr) = []; 
      endif     
      df._ridx(indr, :, :) = [];
      %# to remove a line, iterate on each column
      df._data = cellfun (@(x) feval(@subsasgn, x, S, []), \
                         df._data, "UniformOutPut", false);
      if (isa (indr, 'char'))
         df._cnt(1) = 0;
       else
         df._cnt(1) = df._cnt(1) - length (indr);
       endif
    endif
    df = df_thirddim (df);
    return;
  endif

  indc_was_set = ~isempty (indc);
  if (~indc_was_set) %# initial dataframe was empty
    ncol = size (RHS, 2); indc = 1:ncol;
  endif
  
  indr = S.subs{1, 1}; 
  indr_was_set = ~isempty (indr); 
  %# initial dataframe was empty ?
  if (~indr_was_set || strcmp (indr, ':'))
    if (iscell (RHS))
      nrow = max (sum (cellfun ('size', RHS, 1)));
    else
      if (isvector (RHS))
        if (0 == df._cnt(1))
          nrow = size (RHS, 1); 
        else
          nrow = df._cnt(1);  %# limit to df numbner of rows
        endif 
      else
        %# deduce limit from RHS 
        nrow = size (RHS, 1);
      endif
    endif
    indr = 1:nrow;
  elseif (~isempty (indr)) 
    if (~isnumeric (indr))
      %# translate row names to row index
      [indr, nrow] = df_name2idx (df._name{1}, indr, df._cnt(1), 'row');
      S.subs{1, 1} = indr;
    else
      nrow = length (indr);
    endif
  endif
  if (length (S.subs) > 2)
    inds = S.subs{1, 3};
  else
    inds = [];
  endif

  rname = cell(0, 0); rname_width = max (1, size (df._name{2}, 2)); 
  ridx = []; cname = rname; ctype = rname;

  if (iscell (RHS))
    if ((length (indc) == df._cnt(2) && size (RHS, 2) >=  df._cnt(2)) \
        || 0 == df._cnt(2) || isempty (S.subs{1}) || isempty (S.subs{2}))
      %# providing too much information -- remove extra content
      if (size (RHS, 1) > 1)
        %# at this stage, verify that the first line doesn't contain
        %# chars only; use them for column names
        dummy = cellfun ('class', \
                         RHS(1, ~cellfun ('isempty', RHS(1, :))), \
                         'UniformOutput', false);
        dummy = strcmp (dummy, 'char');
        if (all (dummy))
          if (length (df._over{2}) >= max (indc) \
                && ~all (df._over{2}(indc)) && ~isempty (S.subs{2}))
            warning("Trying to overwrite colum names");
          endif

          cname = RHS(1, :).'; RHS = RHS(2:end, :);            
          if (~indr_was_set) 
            nrow = nrow - 1; indr = 1:nrow;
          else
            %# we know indr, there is no reason that RHS(:, 1) contains
            %# row names.
            if (isempty (S.subs{2}))
              %# extract columns position from columns names 
              [indc, ncol,  S.subs{2}, dummy] = ...
                  df_name2idx (df._name{2}, cname, df._cnt(2), 'column');
              if (length (dummy) ~= sum (dummy))
                warning ("Not all RHS column names used");
                cname = cname(dummy); RHS = RHS(:, dummy);
              endif
            endif
          endif
        endif
        %# at this stage, verify that the first line doesn't contain
        %# chars only; use them for column types
        dummy = cellfun ('class', \
                        RHS(1, ~cellfun ('isempty', RHS(1, :))), \
                        'UniformOutput', false);
        dummy = strcmp (dummy, 'char');
        if (all (dummy))
          if (length (df._over{2}) >= max (indc) \
                && ~all (df._over{2}(indc)))
            warning ("Trying to overwrite colum names");
          endif
                                         
          ctype = RHS(1, :); RHS = RHS(2:end, :);
          if (~indr_was_set)
            nrow = nrow - 1; indr = 1:nrow;
          endif
        endif
      endif
      
      %# more elements than df width -- try to use the first two as
      %# row index and/or row name
      if (size (RHS, 1) > 1)
        dummy = all (cellfun ('isnumeric', \
                            RHS(~cellfun ('isempty', RHS(:, 1)), 1)));
      else
        dummy =  isnumeric(RHS{1, 1});
      endif
      dummy = dummy && (~isempty (cname) && size (cname{1}, 2) < 1);
      if (dummy)
        ridx = cell2mat (RHS(:, 1)); 
        %# can it be converted to a list of unique numbers ?
        if (length (unique (ridx)) == length (ridx))
          ridx = RHS(:, 1); RHS = RHS(:, 2:end);
          if (length (df._name{2}) == df._cnt(2) + ncol)
            %# columns name were pre-filled with too much values
            df._name{2}(end) = [];
            df._over{2}(end) = [];
            if (size (RHS, 2) < ncol) 
              ncol = size (RHS, 2); indc = 1:ncol;
            endif
          elseif (~indc_was_set) 
            ncol = ncol - 1;  indc = 1:ncol; 
          endif 
          if (~isempty (cname)) cname = cname(2:end); endif
          if (~isempty (ctype)) ctype = ctype(2:end); endif
        else
          ridx = [];
        endif
      endif

      if (size (RHS, 2) >  df._cnt(2))
        %# verify the the first row doesn't contain chars only, use them
        %# for row names
        dummy = cellfun ('class', \
                        RHS(~cellfun ('isempty', RHS(:, 1)), 1), \
                        'UniformOutput', false);
        dummy = strcmp (dummy, 'char') \
            && (~isempty (cname) && size (cname{1}, 2) < 1);
        if (all (dummy)) 
          if (length (df._over{1}) >= max (indr) \
                && ~all (df._over{1}(indr)))
            warning("Trying to overwrite row names");
          else
            rname = RHS(:, 1); 
          endif
          rname_width = max ([1; cellfun('size', rname, 2)]); 
          RHS = RHS(:, 2:end); 
          if (length (df._name{2}) == df._cnt(2) + ncol)
            %# columns name were pre-filled with too much values
            df._name{2}(end) = [];
            df._over{2}(end) = [];
            if (size (RHS, 2) < ncol) 
              ncol = size (RHS, 2); indc = 1:ncol;
            endif
          elseif (~indc_was_set) 
            ncol = ncol - 1;  indc = 1:ncol; 
          endif
          if (~isempty (cname)) cname = cname(2:end); endif
          if (~isempty (ctype)) ctype = ctype(2:end); endif
        endif
      endif
    endif
  endif

  %# perform row resizing if columns are already filled
  if (~isempty (indr) && isnumeric(indr))
    if (max (indr) > df._cnt(1) && size (df._data, 2) == df._cnt(2))
      df = df_pad (df, 1, max (indr)-df._cnt(1), rname_width);
    endif
  endif
  
  if (iscell(RHS)) %# we must pad on a column-by-column basis
    %# verify that each cell contains a non-empty vector, and that sizes
    %# are compatible
    %# dummy = cellfun ('size', RHS(:), 2);
    %# if any (dummy < 1),
    %#   error("cells content may not be empty");
    %# endif
    
    %# dummy = cellfun ('size', RHS, 1);
    %# if any (dummy < 1),
    %#   error("cells content may not be empty");
    %# endif
    %# if any (diff(dummy) > 0),
    %#   error("cells content with unequal length");
    %# endif
    %# if 1 < size (RHS, 1) && any (dummy > 1),
    %#   error("cells may only contain scalar");
    %# endif

    if (size(RHS, 2) > indc)
      keyboard
    endif

    %# the real assignement
    if (1 == size (RHS, 1)) %# each cell contains one vector
      fillfunc = @(x) RHS{x};
      idxOK = logical(indr);
    else %# use cell2mat to pad on a column-by-column basis
      fillfunc = @(x) cell2mat (RHS(:, x));
    endif

    indj = 1;
    for indi = (1:ncol)
      if (indc(indi) > df._cnt(2))
        %# perform dynamic resizing one-by-one, to get type right
        if (isempty (ctype) || length (ctype) < indc(indi))
          df = df_pad(df, 2, indc(indi)-df._cnt(2), class(RHS{1, indj}));
        else
          df = df_pad(df, 2, indc(indi)-df._cnt(2), ctype{indj});
        endif
      endif
      if (nrow == df._cnt(1))
        %# whole assignement
        try 
          if (size (RHS, 1) <= 1)
            switch df._type{indc(indi)}
              case {'char' } %# use a cell array to hold strings
                dummy = RHS(:, indj);
              case {'double' }
                dummy = fillfunc (indj);
              otherwise
                dummy = cast(fillfunc (indj), df._type{indc(indi)});
            endswitch
          else
            %# keeps indexes in sync as cell elements may be empty
            idxOK = ~cellfun ('isempty', RHS(:, indj));
            %# intialise dummy so that it can receive "anything"
            dummy = [];
            switch (df._type{indc(indi)})
              case {'char' } %# use a cell array to hold strings
                dummy = RHS(:, indj);
              case {'double' }
                dummy(idxOK, :) = fillfunc (indj); dummy(~idxOK, :) = NA;
              otherwise
                dummy(idxOK, :) = fillfunc (indj); dummy(~idxOK, :) = NA;
                dummy = cast(dummy, df._type{indc(indi)});
            endswitch
          endif
        catch
          dummy = \
              sprintf ("Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s", \
                       indj, df._type{indc(indi)}, length (indr), disp (RHS(:, indj)));
          error (dummy);
        end_try_catch
        if (size (dummy, 1) < df._cnt(1))
          dummy(end+1:df._cnt(1), :) = NA;
        endif
      else
        %# partial assignement -- extract actual data and update
        dummy = df._data{indc(indi)}; 
        try     
          switch (df._type{indc(indi)})
            case {'char' } %# use a cell array to hold strings
              dummy(indr, 1) = RHS(:, indj);
            case {'double' }
              dummy(indr, :) = fillfunc (indj);
            otherwise
              dummy(indr, :) = cast(fillfunc (indj), df._type{indc(indi)});
          endswitch
        catch
          dummy = \
              sprintf ("Assignement failed for colum %d, of type %s and length %d,\nwith new content\n%s", \
                       indj, df._type{indc(indi)}, length (indr), disp(RHS(:, indj)));
          error (dummy);
        end_try_catch
      endif
      df._data{indc(indi)} = dummy; df._rep{indc(indi)} = 1:size (dummy, 2); 
      indj = indj + 1;
    endfor
    
  else 
    %# RHS is either a numeric, either a df
    if (any (indc > min (size (df._data, 2), df._cnt(2))))
      df = df_pad(df, 2, max (indc-min (size (df._data, 2), df._cnt(2))),\
                   class(RHS));
    endif
    if (~isempty (inds) && isnumeric(inds) && any (inds > 1))
      for indi = (1:length (indc))
        if (max (inds) > length (df._rep{indc(indi)}))
          df = df_pad(df, 3, max (inds)-length (df._rep{indc(indi)}), \
                      indc(indi));
        endif
      endfor
    endif

    if (isa (RHS, 'dataframe'))
      %# block-copy index
      S.subs(2) = 1;
      if (any (~isna(RHS._ridx)))
        df._ridx = feval(@subsasgn,  df._ridx, S,  RHS._ridx);
      endif
      %# skip second dim and copy data
      S.subs(2) = []; Sorig = S; 
      for indi = (1:length (indc))
        [df, S] = df_cow(df, S, indc(indi));
        if (strcmp (df._type(indc(indi)), RHS._type(indi)))
          try
            df._data{indc(indi)} = feval(@subsasgn, df._data{indc(indi)}, S, \
                                         RHS._data{indi}(:, RHS._rep{indi}));
          catch
            disp(lasterr()); disp('line 516 ???'); keyboard
          end_try_catch
        else
          df._data{indc(indi)} = feval(@subsasgn, df._data{indc(indi)}, S, \
                                       cast(RHS._data{indi}(:, RHS._rep{indi}),\
                                            df._type(indc(indi))));
        endif
        S = Sorig;
      endfor
      if (~isempty (RHS._name{1}))
        df._name{1}(indr) = genvarname(RHS._name{1}(indr));
        df._over{1}(indr) = RHS._over{1}(indr);
      endif
      if (~isempty (RHS._src))
        if (~any (strcmp (cellstr(df._src), cellstr(RHS._src))))
          df._src = vertcat(df._src, RHS._src);
        endif
      endif
      if (~isempty (RHS._cmt))
        if (~any (strcmp (cellstr(df._cmt), cellstr(RHS._cmt))))
          df._cmt = vertcat(df._cmt, RHS._cmt);
        endif
      endif

    else
      %# RHS is homogenous, pad at once
      if (isvector (RHS)) %# scalar - vector
        if (isempty (S.subs))
          fillfunc = @(x, y) RHS;
        else 
          %# ignore 'column' dimension -- force colum vectors -- use a
          %# third dim just in case
          if (isempty (S.subs{1})) S.subs{1} = ':'; endif 
          S.subs(2) = []; 
          if (length (S.subs) < 2) 
            S.subs{2} = 1; 
          endif 
          if (length (indc) > 1 && length (RHS) > 1)
            %# set a row from a vector
            fillfunc = @(x, S, y) feval (@subsasgn, x, S, RHS(y));
          else   
            fillfunc = @(x, S, y) feval (@subsasgn, x, S, RHS);
          endif
        endif
        Sorig = S; 
        for indi = (1:length (indc))
          try
            [df, S] = df_cow(df, S, indc(indi));
            df._data{indc(indi)} = fillfunc (df._data{indc(indi)}, S, indi);
            S = Sorig;
          catch
            disp(lasterr)
            disp('line 470 '); keyboard
          end_try_catch
          # catch
          #   if ndims(df._data{indc(indi)}) > 2,
          #     %# upstream forgot to give the third dim
          #     dummy = S; dummy.subs(3) = 1;
          #     df._data{indc(indi)} = fillfunc(df._data{indc(indi)}, \
          #                                   dummy, indi);
          #   else
          #     rethrow(lasterr());
          #   endif
          # end_try_catch
        endfor
      else %# 2D - 3D matrix
        S.subs(2) = []; %# ignore 'column' dimension
        if (isempty (S.subs{1}))
          S.subs{1} = indr;
        endif
        %# rotate slices in dim 1-3 to slices in dim 1-2
        fillfunc = @(x, S, y) feval(@subsasgn, x, S, squeeze(RHS(:, y, :)));
        Sorig = S; 
        for indi = (1:length (indc))
          [df, S] = df_cow(df, S, indc(indi));
          df._data{indc(indi)} = fillfunc (df._data{indc(indi)}, S, indi);
          S = Sorig;
        endfor
      endif
      if (indi < size (RHS, 2) && ~isa (RHS, 'char'))
        warning (' not all columns of RHS used');
      endif
    endif
  endif

  %# delayed row padding -- column padding occured before
  if (~isempty (indr) && isnumeric (indr))
    if (max (indr) > df._cnt(1) && size (df._data, 2) < df._cnt(2))
      df = df_pad(df, 1, max (indr)-df._cnt(1), rname_width);
    endif
  endif

  %# adjust ridx and rnames, if required
  if (~isempty (ridx))
    dummy = df._ridx;
    if (1 == size (RHS, 1))
      dummy(indr) = ridx{1};
    else
      dummy(indr) = vertcat(ridx{indr});
    endif
    if (length (unique (dummy)) ~= length (dummy)) %# || \
          %# any (diff(dummy) <= 0),
      error("row indexes are not unique or not ordered");
    endif
    df._ridx = dummy;
  endif
  
  if (~isempty (rname) && (length (df._over{1}) < max (indr) || \
        all (df._over{1}(indr))))
    df._name{1}(indr, 1) = genvarname(rname);
    df._over{1}(1, indr) = false;
  endif
  if (~isempty (cname) && (length (df._over{2}) < max (indc) || \
        all (df._over{2}(indc))))
    try
      df._name{2}(indc, 1) = genvarname (cname);
    catch
      disp('line 472 '); keyboard
    end_try_catch
    df._over{2}(1, indc) = false;
  endif
  
  df = df_thirddim (df);
  
endfunction
