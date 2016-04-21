function resu = display(df)

  %# function resu = display(df)
  %# Tries to produce a nicely formatted output of a dataframe.

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
  %# $Id: display.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

  %# generate header name
  dummy = inputname (1);
  if (isempty(dummy))
    dummy = "ans";
  endif

  if (2 == length (df._cnt))
    head = sprintf ("%s = dataframe with %d rows and %d columns", \
                    dummy, df._cnt);
  else
    head = sprintf ("%s = dataframe with %d rows and %d columns on %d pages", \
                    dummy, df._cnt);
  endif

  if (!isempty (df._src))
    for indi = (1:size (df._src, 1))
      head = strvcat\
          (head, [repmat("Src: ", size (df._src{indi, 1}, 1), 1)\
                  df._src{indi, 1}]);
    endfor
  endif

  if (!isempty (df._cmt))
    for indi = (1:size(df._cmt, 1))
      head = strvcat\
          (head, [repmat("Comment: ", size (df._cmt{indi, 1}, 1), 1)\
                  df._cmt{indi, 1}]);
    endfor
  endif
  
  if (all (df._cnt > 0))  %# stop for empty df
    dummy=[]; vspace = repmat (' ', df._cnt(1), 1);
    indi = 1; %# the real, unfolded index
    %# loop over columns where the corresponding _data really exists
    for indc = (1:min (df._cnt(2), size (df._data, 2))) 
      %# emit column names and type
      if (1 == length (df._rep{indc}))
        dummy{1, 2+indi} = deblank (disp (df._name{2}{indc}));
        dummy{2, 2+indi} = deblank (df._type{indc});
      else
        %# append a dot and the third-dimension index to column name
        tmp_str = [deblank(disp (df._name{2}{indc})) "."];
        tmp_str = arrayfun (@(x) horzcat (tmp_str, num2str(x)), ...
                            (1:length (df._rep{indc})), 'UniformOutput', false); 
        dummy{1, 2+indi} = tmp_str{1};
        dummy{2, 2+indi} = deblank (df._type{indc});
        for indk = (2:length (tmp_str))
          dummy{1, 1+indi+indk} = tmp_str{indk};
          dummy{2, 1+indi+indk} = dummy{2, 2+indi};
        endfor
      endif
      %# "print" each column
      switch df._type{indc}
        case {'char'}
          indk = 1; while (indk <= size (df._data{indc}, 2))
            tmp_str = df._data{indc}(:, indk); %#get the whole column
            indj = cellfun ('isprint', tmp_str, 'UniformOutput', false); 
            indj = ~cellfun ('all', indj);
            for indr = (1:length(indj))
              if (indj(indr)),
                if (isna (tmp_str{indr})),
                  tmp_str{indr} = "NA";
                else
                  if (~ischar (tmp_str{indr}))
                    tmp_str{indr} = char (tmp_str{indr});
                  endif
                  tmp_str{indr} = undo_string_escapes (tmp_str{indr});
                endif
              endif
            endfor
            %# keep the whole thing, and add a vertical space
            dummy{3, 2+indi} = disp (char (tmp_str));
            dummy{3, 2+indi} = horzcat...
                (vspace, char (regexp (dummy{3, 2+indi}, '.*', ...
                                       'match', 'dotexceptnewline')));
            indi = indi + 1; indk = indk + 1;
          endwhile
        otherwise
          %# keep only one horizontal space per line
          unfolded = df._data{indc}(:, df._rep{indc});
          indk = 1; while (indk <= size (unfolded, 2))
            dummy{3, 2+indi} = disp (unfolded(:, indk));
            tmp_str = char (regexp (dummy{3, 2+indi}, \
                                    '[-+]?[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?(\s??[-+]\s??[0-9]*\.?[0-9]+([eE][-+]?[0-9]+)?i)?', \
                                    'match', 'dotexceptnewline'));
            tmp_str = horzcat...
                (vspace, char (regexp (dummy{3, 2+indi}, '\S.*', ...
                                       'match', 'dotexceptnewline')));
            dummy{3, 2+indi} = tmp_str;
            indi = indi + 1; indk = indk + 1;
          endwhile
      endswitch
    endfor

    %# put everything together
    vspace = [' '; ' '; vspace];
    %# second line content
    resu = []; 
    if (!isempty (df._ridx))
      for (ind1 = 1:size (df._ridx, 2))
        if ((1 == size(df._ridx, 3)) && \
              (any (!isna (df._ridx(1:df._cnt(1), ind1)))))
          dummy{2, 1} = [sprintf("_%d", ind1) ; "Nr"];
          dummy{3, 1} = disp (df._ridx(1:df._cnt(1), ind1)); 
          indi = regexp (dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
          if (isempty (resu))
            resu = strjust (char (dummy{2, 1}, indi), 'right');
          else
            resu = horzcat(resu, vspace, strjust (char (dummy{2, 1}, indi), \
                                                  'right'), vspace);
          endif
        else 
          for ind2 = (1:size (df._ridx, 3))
            if (any (!isna (df._ridx(1:df._cnt(1), ind1, ind2)))),
              dummy{2, 1} = [sprintf("_%d.%d", ind1, ind2) ; "Nr"];
              dummy{3, 1} = disp (df._ridx(1:df._cnt(1), ind1, ind2)); 
              indi = regexp (dummy{3, 1}, '\b.*\b', 'match', 'dotexceptnewline');
              if (isempty (resu)) 
                resu = strjust (char (dummy{2, 1}, indi), 'right');
              else
                resu = horzcat (resu, vspace, strjust (char(dummy{2, 1}, indi), \
                                                       'right'), vspace);
              endif
            endif
          endfor
        endif
      endfor
    endif

    %# emit row names
    if (isempty (df._name{1})),
      dummy{2, 2} = []; dummy{3, 2} = [];
    else
      dummy{2, 2} = [" ";" "];
      dummy{3, 2} = df._name{1};
    endif
    
    %# insert a vertical space
    if (!isempty(dummy{3, 2}))
      indi = ~cellfun ('isempty', dummy{3, 2});
      if (any (indi))
        try
          resu = horzcat (resu, vspace, strjust (char(dummy{2, 2}, dummy{3, 2}),\
                                                 'right'));
        catch
          disp ('line 172 '); keyboard
        end_try_catch
      endif
    endif
    
    %# emit each colum
    for indi = (1:size (dummy, 2) - 2)
      %# was max(df._cnt(2:end)),
      try
        %# avoid this column touching the previous one
        if (any (cellfun ('size', dummy(1:2, 2+indi), 2) >= \
                 size (dummy{3, 2+indi}, 2)))
          resu = horzcat (resu, vspace);
        endif
        resu = horzcat (resu, strjust (char (dummy{:, 2+indi}), 'right'));
      catch
        tmp_str = sprintf ("Emitting %d lines, expecting %d", ...
                           size (dummy{3, 2+indi}, 1), df._cnt(1));
        keyboard
        error (tmp_str);
      end_try_catch
    endfor
  else
    resu = '';
  endif
  
  resu = char (head, resu); disp (resu)

endfunction
