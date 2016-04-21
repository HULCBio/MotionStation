function resu = subsref(df, S)
  %# function resu = subsref(df, S)
  %# This function returns a subpart of a dataframe. It is invoked when
  %# calling df.field, df(value), or df{value}. In case of fields,
  %# returns either the content of the container with the same name,
  %# either the column with the same name, priority being given to the
  %# container. In case of range, selection may occur on name or order
  %# (not rowidx for rows). If the result is homogenous, it is
  %# downclassed. In case an extra field is given, is it used to
  %# determine the class of the return value. F.i., 
  %# df(1, 2, 'dataframe') 
  %# does not return a scalar but a dataframe, keeping all the meta-information

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
  %# $Id: subsref.m 9585 2012-02-05 15:32:46Z cdemills $
  %#
  
  %# what kind of object should we return ?
  asked_output_type = ''; asked_output_format = [];

  if (strcmp (S(1).type, '.')) %# struct access
    indi = strmatch (S(1).subs, 'as');
    if (~isempty (indi)) 
      if (length (S) < 2 || ~strcmp (S(2).type, '.'))
        error ("The output format qualifier 'as' must be followed by a type");
      endif
      asked_output_type = "array";
      asked_output_format = S(2).subs; S = S(3:end);
    else
      indi = strmatch(S(1).subs, 'array');
      if (~isempty (indi)) 
        asked_output_type = "array";    
        S = S(2:end);
      else
        indi = strmatch (S(1).subs, char ('df', class (df)));
        if (~isempty (indi))
          %# requiring a dataframe
          if (1 == indi) %# 'df' = short for 'dataframe'
            asked_output_type = 'dataframe';
          else
            asked_output_type =  S(1).subs;
          endif
          S = S(2:end);
          if (isempty (S) && strcmp (asked_output_type, class (df)))
            resu = df; return; 
          endif
        else
          indi = strmatch(S(1).subs, 'cell');
          if (~isempty (indi))
            asked_output_type =  S(1).subs;
            S = S(2:end);
          else
            %# access as a pseudo-struct
            resu = struct(df); %# avoid recursive calls  
            if (1 == strfind(S(1).subs, '_')) %# its an internal field name
              %# FIXME: this should only be called from class members and friends
              %# FIXME -- in case many columns are asked, horzcat them
              resu = horzcat (feval (@subsref, resu, S));
            else
              %# direct access through the exact column name
              indi = strmatch(S(1).subs, resu._name{2}, "exact");
              if (~isempty (indi))
                resu = df._data{indi}; %# extract colum;
                if (strcmp (df._type{indi}, 'char') \
                    && 1 == size (df._data{indi}, 2))
                  resu = char (resu)
                endif 
                if (length (S) > 1)
                  dummy = S(2:end); S = S(1);
                  switch dummy(1).type
                    case '()'
                      if (isa(dummy(1).subs{1}, "char"))
                        [indr, nrow, dummy(1).subs{1}] = \
                            df_name2idx(df._name{1}, dummy(1).subs{1}, df._cnt(1), 'row');
                      endif
                      resu = feval(@subsref, resu, dummy);
                    otherwise
                      error ("Invalid column access");
                  endswitch
                endif
              else %# access of an attribute
                dummy = S(2:end); S = S(1);
                postop = ''; further_deref = false;
                %# translate the external to internal name
                switch S(1).subs
                  case "rownames"
                    S(1).subs = "_name";
                    S(2).type = "{}"; S(2).subs{1}= 1;
                    postop = @(x) char (x); 
                  case "colnames"
                    S(1).subs = "_name";
                    S(2).type = "{}"; S(2).subs{1}= 2;
                    postop = @(x) char (x); further_deref = true;
                  case "rowcnt"
                    S(1).subs = "_cnt";
                    S(2).type = "()"; S(2).subs{1}= 1;
                  case "colcnt"
                    S(1).subs = "_cnt";
                    S(2).type = "()"; S(2).subs{1}= 2;
                  case "rowidx"
                    S(1).subs = "_ridx"; further_deref = true;
                  case "types"  %# this one should be accessed as a matrix
                    S(1).subs = "_type"; further_deref = true;
                  case "source"
                    S(1).subs = "_src";
                    further_deref = true;
                  case "comment"
                    S(1).subs = "_cmt";
                    further_deref = true;
                  case "new"
                    if (isempty (dummy))
                      resu = dataframe([]);
                    else
                      if (!strcmp (dummy(1).type, "()"))
                        error ("Bogus constructor call");
                      endif
                      resu = dataframe(dummy(1).subs{:});
                    endif
                    if (length (dummy) > 1)
                      resu = subsref(resu, dummy(2:end));
                    endif
                    return;
                  otherwise
                    error ("Unknown column name: %s", S(1).subs);
                endswitch
                if (!isempty (dummy))
                  if ~further_deref,
                    error ("Invalid sub-dereferencing");
                  endif
                  if (isa(dummy(1).subs{1}, "char"))
                    [indc, ncol, dummy(1).subs{1}] = \
                        df_name2idx(df._name{2}, dummy(1).subs{1}, \
                                    df._cnt(2), 'column');
                    if (isempty (indc)) 
                      %# should be already catched  inside df_name2idx
                      error ("Unknown column name: %s",  dummy(1).subs{1});
                    endif
                  endif
                  if (!strcmp (dummy(1).type, '()'))
                    error ("Invalid internal field name sub-access, use () instead");
                  endif
                endif
                %# workaround around bug 30921, fixed in hg changeset 10937
                %# if !isempty (dummy)
                S = [S dummy];
                %# endif
                resu = feval(@subsref, resu, S);
                if (!isempty (postop))
                  resu = postop(resu);
                endif
              endif
            endif
            return
          endif
        endif
      endif
    endif
  endif
  
  %# disp('line 103 '); keyboard

  IsFirst = true;
  while 1, %# avoid recursive calls on dataframe sub-accesses
  
    %# a priori, performs whole accesses
    nrow = df._cnt(1); indr = 1:nrow; 
    ncol = df._cnt(2); indc = 1:ncol; 
    %# linear indexes
    [fullindr, fullindc, fullinds, onedimidx] = deal([]);

    %# iterate over S, sort out strange constructs as x()()(1:10, 1:4)
    while length (S) > 0,
      if (strcmp (S(1).type, '{}'))
        if (!IsFirst || !isempty (asked_output_format))
          error ("Illegal dataframe dereferencing");
        endif
        [asked_output_type, asked_output_format] = deal('cell');
      elseif (!strcmp (S(1).type, '()'))
        %# disp(S); keyboard
        error ("Illegal dataframe dereferencing");
      endif
      if (isempty (S(1).subs)) %# process calls like x()
        if (isempty (asked_output_type))
          asked_output_type = class (df);
        endif
        if (length (S) <= 1) 
          if (strcmp (asked_output_type, class (df)))
            %# whole access without conversion
            resu = df; return; 
          endif
          break; %# no dimension specified -- select all, the
          %# asked_output_type was set in a previous iteration
        else
          %# avoid recursive calls
          S = S(2:end); 
          IsFirst = false; continue;
        endif      
      endif
      %# generic access
      if (isempty (S(1).subs{1}))
        error ('subsref: first dimension empty ???');
      endif
      if (length (S(1).subs) > 1)
        if (isempty (S(1).subs{2}))
          error ('subsref: second dimension empty ???');
        endif
        [indr, nrow, S(1).subs{1}] = \
            df_name2idx(df._name{1}, S(1).subs{1}, df._cnt(1), 'row');      
        if (!isa(indr, 'char') && max (indr) > df._cnt(1))
          error ("Accessing dataframe past end of lines");
        endif
        [indc, ncol, S(1).subs{2}] = \
            df_name2idx(df._name{2}, S(1).subs{2}, df._cnt(2), 'column');
        if (max (indc) > df._cnt(2))
          %# is it a two index access of a 3D structure ?
          if (length (df._cnt) > 2)
            [fullindc, fullinds] = ind2sub (df._cnt(2:3), indc);
            if (fullindc <= df._cnt(2))
              indc = fullindc; inds = fullinds; 
            endif
          endif
          %# retest
          if (max (indc) > df._cnt(2))
            error ("Accessing dataframe past end of columns");
          endif
        endif
      else
        %# one single dim -- probably something like df(:), df(A), ...
        fullindr = 1; onedimidx = S(1).subs{1};
        switch class (S(1).subs{1})
          case {'char'} %# one dimensional access, disallow it if not ':' 
            if (strcmp (S(1).subs{1}, ':'))
              fullindr = []; fullindc = []; asked_output_type = "array"; 
            else
              error (["Accessing through single dimension and name " \
                      S(1).subs{1} " not allowed\n-- use variable(:, 'name') instead"]);
            endif
          case {'logical'}
            S(1).subs{1} = find(S(1).subs{1});
          case {'dataframe'}
            S(1).subs{1} = subsindex(S(1).subs{1}, 1);
        endswitch

        if (isempty (S(1).subs{1})) 
          resu = df_colmeta(df);
          return; 
        endif

        if (!isempty (fullindr))
          %# convert linear index to subscripts
          if (length (df._cnt) <= 2)
            [fullindr, fullindc] = ind2sub (df._cnt, S(1).subs{1});
            fullinds = ones (size (fullindr));
          else
            dummy = max (cellfun(@length, df._rep));
            [fullindr, fullindc, fullinds] = ind2sub\
                ([df._cnt dummy], S(1).subs{1});
          endif 
          
          indr = unique (fullindr); nrow = length (indr);
          %# determine on which columns we'll iterate
          indc = unique (fullindc)(:).'; ncol = length (indc);
          if (!isempty (asked_output_type) && ncol > 1)
            %# verify that the extracted values form a square matrix
            dummy = zeros(indr(end), indc(end));
            for indi = (1:ncol)
              indj = find (fullindc == indc(indi));
              dummy(fullindr(indj), indc(indi)) = 1;
            endfor
            dummy = dummy(indr(1):indr(end), indc(1):indc(end));
            if (any (any (dummy!= 1)))
              error ("Vector-like selection is not rectangular for the asked output type");
            else
              fullindr = []; fullindc = [];
            endif
          endif 
        endif
      endif
      %# at this point, S is either empty, either contains further dereferencing
      break;
    endwhile
    
    %# we're ready to extract data
    %# disp('line 211 '); keyboard
    
    if (isempty (asked_output_type))
      output_type = class (df); %# force df output
    else
      if (!strcmp (asked_output_type, "array") \
          || !isempty (asked_output_format))
        %# override the class of the return value
        output_type = asked_output_type;
      else
        %# can the data be merged ?
        output_type = df._data{indc(1)}(1);
        dummy = isnumeric(df._data{indc(1)}); 
        for indi = (2:ncol)
          dummy = dummy & isnumeric (df._data{indc(indi)});
          if (~strcmp (class (output_type), df._type{indc(indi)}))
            if (dummy) 
              %# let downclassing occur
              output_type = horzcat (output_type, df._data{indc(indi)}(1));
              continue; 
            endif
            %# unmixable args -- falls back to type of parent container 
            error ("Selected columns %s not compatible with cat() -- use 'cell' as output format", mat2str (indc));
            %# dead code -- suppress previous line for switching automagically the output format to df
            output_type = class (df); 
            break;
          endif
        endfor
        asked_output_format = class (output_type);
        output_type = "array";
      endif
    endif
    
    if (any(strcmp ({output_type, asked_output_type}, class (df))))
      if (!isempty (S) && (1 == length (S(1).subs)))
        %# is the selection index vector-like ?
        if ((isnumeric(S(1).subs{1}) && isvector(S(1).subs{1}) &&
             df._cnt(1) > 1) && isempty (asked_output_type))
          %# in the case of vector input, favor array output
          [asked_output_type, output_type] = deal("array");
        endif
      endif
    endif
      
    indt = {}; %# in case we have to mix matrix of different width
    if (!isempty (fullinds))
      inds = unique (fullinds); nseq = length (inds);
      indt(1, 1:df._cnt(2)) = inds;
    else      
      inds = 1; indt(1, 1:df._cnt(2)) = inds; nseq = 1;
      if (isempty (S) || all(cellfun('isclass', S(1).subs, 'char')))
        inds = ':'; indt(1, 1:df._cnt(2)) = inds;
        nseq = max (cellfun(@length, df._rep(indc)));
      else
        if (length (S(1).subs) > 1) %# access-as-matrix
          if (length (S(1).subs) > 2)
            inds = S(1).subs{3};
            if (isa(inds, 'char'))
              nseq = max (cellfun(@length, df._rep(indc)));
              indt(1, 1:df._cnt(2)) = inds;
            else
              %# generate a specific index for each column
              nseq = length (inds);
              dummy = cellfun(@length, df._rep(indc));
              indt(1, 1:df._cnt(2)) = inds;
              indt(1==dummy) = 1; 
            endif
          endif
        endif
      endif
    endif

    if (strcmp (output_type, class (df)))
      %# disp('line 295 '); keyboard
      %# export the result as a dataframe
      resu = dataframe ([]);
      resu._cnt(1) = nrow; resu._cnt(2) = ncol;
      if (isempty (fullindr))
        for indi = (1:ncol)
          resu._data{indi} =  df._data{indc(indi)}\
              (indr, df._rep{indc(indi)}(indt{indc(indi)})); 
          resu._rep{indi} =  1:size (resu._data{indi}, 2);
          resu._name{2}(indi, 1) = df._name{2}(indc(indi));
          resu._over{2}(1, indi) = df._over{2}(indc(indi));
          resu._type{indi} = df._type{indc(indi)};
        endfor
        if (!isempty (df._ridx) && size (df._ridx, 2) >= inds)
          resu._ridx = df._ridx(indr, inds);
        endif 
        if (length (df._name{1}) >= max (indr))
          resu._name{1}(1:nrow, 1) = df._name{1}(indr);
          resu._over{1}(1, 1:nrow) = df._over{1}(indr);
        endif
      else
        dummy = df_whole(df);
        dummy = dummy(onedimidx);
        for indi = (1:resu._cnt(2))
          indc = unique (fullindc(:, indi));
          if (1 == length (indc))
            resu._name{2}(indi)= df._name{2}(indc);
            resu._over{2}(indi)= df._over{2}(indc);
            unfolded = df._data{indc}(:, df._rep{indc});
            indj =  sub2ind (size (unfolded), fullindr(:, indi), \
                            fullinds(:, indi));
            resu._data{indi} = unfolded(indj);
            resu._type{indi} = df._type{indc};
            resu._rep{indi} = 1:size (resu._data{indi}, 2);  
          else
            resu._name{2}(indi)= ["X" num2str(indi)];
            resu._over{2}(indi)= true;
            resu._data{indi} = squeeze(dummy(:, indi, :));
            resu._type{indi} = class (dummy(1, indi, 1));
            resu._rep{indi} = 1:size (resu._data{indi}, 2);  
          endif
        endfor
        if (1 ==  size (df._ridx, 2))
          resu._ridx = repmat (df._ridx, [1 ncol 1]);
        else
          resu._ridx = df._ridx;
        endif
        if (!isempty (resu._ridx))
          if (size (resu._ridx, 2) > 1)
            resu._ridx = resu._ridx(indr, indc);
          else
            resu._ridx = resu._ridx(indr);
          endif
        endif
      endif
      %# to be verified :       keyboard
      resu._src = df._src;
      resu._cmt = df._cmt;
      resu = df_thirddim(resu);
      if (length (S) > 1) %# perform further access, if required
        df = resu;
        S = S(2:end);   %# avoid recursive calls
        continue;       %# restart the loop around line 150
      endif
      return;
      
    elseif (strcmp (output_type, 'cell'))
      %# export the result as a cell array
      if (isempty (asked_output_format))
        resu = cell (2+nrow, 2+ncol); resu(1:end, 1:2) = {''};
        resu(2, 3:end) = df._type(indc);                        %column type
        row_offs = 2; col_offs = 2;
        for indi = (1:ncol)
          resu{1, 2+indi} = df._name{2}{indc(indi)};            % column name
        endfor
        resu(3:end, 1) =  mat2cell (df._ridx(indr), ones (nrow, 1), 1);
        if (length (df._name{1}) >= max (indr))
          resu(3:end, 2) = df._name{1}{indr};
        endif           
      else
        resu = cell (nrow, ncol);
        row_offs = 0; col_offs = 0;
      endif
      for indi = (1:ncol)
        switch df._type{indc(indi)}                             % cell content
          case {'char' }
            %# dummy = cellstr(df._data{indc(indi)}(indr, :));
            dummy = df._data{indc(indi)}(indr, :);
            resu(1+row_offs:end, indi+col_offs) = dummy;
          otherwise
            dummy = df._data{indc(indi)}(indr, :);
            resu(1+row_offs:end, indi+col_offs) = \
                mat2cell (dummy, ones (nrow, 1), size (dummy, 2));
        endswitch
      endfor

      %# did we arrive here by x.cell ?
      if (0 == length (S)) return; endif
      
      %# perform the selection on the content, keeping the header
      if (length (S) > 1) %# perform further access, if required
        if (~strcmp (S(2).type, '()'))
          error ("Illegal dataframe-as-cell sub-dereferencing");
        endif
        if (!isempty (asked_output_format))
          resu = feval(@subsref, resu, S(2:end));
        else    
          if (length (S(2).subs) != 1)
            %# normal, two-dimensionnal access apply the selection on the
            %# zone containing the data
            dummy = S;
            if (!isempty (dummy(2).subs))
              dummy(2).subs{2} = ':';
            endif
            resuf = cat (2, \
                         %# reselect indexes
                         feval (@subsref, resu(3:end, 1),
                                dummy(2:end)), \
                         %# reselect rownames
                         feval (@subsref, resu(3:end, 2),
                                dummy(2:end)), \
                         %# extract - reorder - whatever
                         feval (@subsref, resu(3:end, 3:end), S(2:end))
                         \
                         );
            dummy = S;
            if (!isempty (dummy(2).subs))
              dummy(2).subs{1} =  [1 2];
            endif
            resuf =  cat(1, \
                         %# reselect column names and types
                         [cell(2, 2) feval(@subsref, resu(1:2,
                                                          3:end), \
                                           dummy(2:end))], \
                         resuf \
                         );
            resuf(1:2, 1:2) = {''}; resu = resuf;
          else
            %# one dimensionnal access of the whole 2D cell array -- you
            %# asked it, you got it
            resu = feval(@subsref, resu(:), S(2:end));
            if (!isa(S(2).subs{1}, 'char') \
                  && size (S(2).subs{1}, 2) > 1)
              resu = resu.';
            endif
          endif
        endif
      elseif (1 == length (S(1).subs))
        resu = resu(:);
        if (!isa(S(1).subs{1}, 'char') \
              && size (S(1).subs{1}, 2) > 1)
          resu = resu.';
        endif
      endif
      return; %# no more iteration required
  
    else
      %# export the result as a vector/matrix. Rules:
      %# * x(:, :, :) returns a 3D matrix 
      %# * x(:, n:m, :) returns a 3D matrix 
      %# * x(:, :) returns a horzcat of the third dimension 
      %# * x(:, n:m) select only the first sequence 
      %# * x(:) returns a vertcat of the columns of x(:, :)
      %# disp('line 403 '); keyboard
      if (isempty (S) || isempty (S(1).subs) || \
          length (S(1).subs) > 1 || \
          (isnumeric(S(1).subs{1}) && !isvector(S(1).subs{1}))) 
        %# access-as-matrix
        df = struct(df);        %# remove the magic, avoid recursive calls 
        if (isempty (fullindr)) %# two index access
          if (~isempty (asked_output_format)) %# force a conversion
            if (strmatch(asked_output_format, 'cell'))
              extractfunc = @(x) mat2cell\
                  (df._data{indc(x)}(indr, df._rep{indc(x)}(inds)), \
                   ones (nrow, 1));
            else
              extractfunc = @(x) cast ( df._data{indc(x)}\
                                       (indr, df._rep{indc(x)}(inds)),\
                                       asked_output_format);
            endif
          else %# let the usual downclassing occur
            extractfunc = @(x) df._data{indc(x)}(indr, df._rep{indc(x)}(inds));
          endif 
          try
            if (nseq > 1)
              dummy = reshape (extractfunc (1), nrow, 1, []); 
              if (size (dummy, 3) < nseq)
                dummy = repmat (dummy, [1 1 nseq]);
              endif
            else
              dummy = extractfunc (1);
            endif
          catch
            error ("Column %d format (%s) can't be converted to %s", \
                   indc(1), df._type{indc(1)}, asked_output_format);
          end_try_catch
          if (ncol > 1)
            %# dynamic allocation with the final type
            resu = repmat (dummy, [1 ncol]);
            for indi = (2:ncol)
              try
                if (nseq > 1)
                  dummy = reshape (extractfunc (indi), nrow, 1, []);
                  if (size (dummy, 3) < nseq)
                    dummy = repmat (dummy, [1 1 nseq]);
                  endif
                else
                  dummy = extractfunc (indi);
                endif
              catch
                error ("Column %d format (%s) can't be converted to %s", \
                       indc(indi), df._type{indc(indi)}, asked_output_format);
              end_try_catch
              resu(:, indi, :) = dummy;
            endfor
          else
            if (strcmp (df._type{indc(1)}, 'char'))
              resu = char (dummy);
            else
              resu = dummy;
            endif
          endif
          if (!isempty (S) && 2 == length (S(1).subs) \
              && all(cellfun('isclass', S(1).subs, 'char')))
            resu = reshape (resu, nrow, ncol*nseq);
          endif
        else %# one index access
          %# disp('line 557'); keyboard
          if (~isempty (asked_output_format)) %# force a conversion
            if (strmatch (asked_output_format, 'cell'))
              extractfunc = @(x, y) mat2cell (df._data{x}(:, df._rep{x}(y)), \
                                              ones (length (y), 1));
            else
              extractfunc = @(x, y) cast (df._data{x}(:, df._rep{x})(y), \
                                          asked_output_format);      
            endif
          else %# let the usual downclassing occur
            extractfunc = @(x, y) df._data{x}(:, df._rep{x})(y);
          endif
          try
            resu = zeros(0, class (sum (cellfun (@(x) zeros (1, class (x(1))),\
                                                 df._data(indc)))));
            for indi = (indc)
              dummy = find (indi == fullindc);   %# linear global index
              %# linear index for this matrix
              idx = sub2ind (size (df._data{indi}), fullindr(dummy), \
                             fullinds(dummy));
              resu(dummy) = extractfunc (indi, idx);
            endfor
          catch
            disp (lasterr); 
            error ("Column %d format (%s) can't be converted to %s", \
                   indi, df._type{indi}, asked_output_format);
          end_try_catch
          resu = reshape (resu, size (onedimidx));
        endif
      else %# access-as-vector
        %# disp('line 548 '); keyboard
        if (!isempty (fullindr))
          switch df._type{indc(1)}
            case {'char'}
              resu = df._data{indc(1)}(fullindr(1), \
                                       df._rep{indc(1)}(fullinds(1)));
              for indi = (2:length (fullindr))
                resu = char (resu, df._data{indc(indi)}\
                             (fullindr(indi), df._rep{indc(indi)}(fullinds(indi))));
              endfor
            otherwise
              if (isempty (asked_output_format))
                resu = df._data{fullindc(1)}\
                    (fullindr(1), df._rep{fullindc(1)}(fullinds(1)));
              else      %# this type will propagate with subsequent cat
                resu = cast (df._data{fullindc(1)}\
                             (fullindr(1), df._rep{fullindc(1)}(fullinds(1))),\
                             asked_output_format);
              endif
              for indi = (2:length (fullindr))
                resu = cat(1, resu, df._data{fullindc(indi)}\
                           (fullindr(indi), \
                            df._rep{fullindc(indi)}(fullinds(indi))));
              endfor
          endswitch
        else %# using the (:) operator
          resu = df_whole(df)(:);
        endif
        if (!isa(S(1).subs{1}, 'char') \
              && size (S(1).subs{1}, 2) > 1)
          resu = resu.';
        endif
      endif
      if (length (S) > 1) %# perform further access, if required
         %# disp('line 442 '); keyboard
        resu = feval(@subsref, resu, S(2:end));
      endif
    endif
    return; %# no more iteration required
  endwhile

  %# disp("line 343 !?!"); %# keyboard
  return  
  
endfunction
