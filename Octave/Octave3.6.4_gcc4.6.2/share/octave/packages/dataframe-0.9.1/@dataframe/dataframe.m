function df = dataframe(x = [], varargin)
  
  %# -*- texinfo -*-
  %#  @deftypefn {Function File} @var{df} = dataframe(@var{x = []}, ...)
  %# This is the default constructor for a dataframe object, which is
  %# similar to R 'data.frame'. It's a way to group tabular data, then
  %# accessing them either as matrix or by column name.
  %# Input argument x may be: @itemize
  %# @item a dataframe => use @var{varargin} to pad it with suplemental
  %# columns
  %# @item a matrix => create column names from input name; each column
  %# is used as an entry
  %# @item a cell matrix => try to infer column names from the first row,
  %#   and row indexes and names from the two first columns;
  %# @item a file name => import data into a dataframe;
  %# @item a matrix of char => initialise colnames from them.
  %# @item a two-element cell: use the first as column as column to
  %# append to,  and the second as initialiser for the column(s)
  %# @end itemize
  %# If called with an empty value, or with the default argument, it
  %# returns an empty dataframe which can be further populated by
  %# assignement, cat, ... If called without any argument, it should
  %# return a dataframe from the whole workspace. 
  %# @*Variable input arguments are first parsed as pairs (options, values).
  %# Recognised options are: @itemize
  %# @item rownames : take the values as initialiser for row names
  %# @item colnames : take the values as initialiser for column names
  %# @item seeked : a (kept) field value which triggers start of processing.
  %# @item trigger : a (unkept) field value which triggers start of processing.
  %# Each preceeding line is silently skipped. Default: none
  %# @item unquot: a logical switch telling wheter or not strings should
  %# be unquoted before storage, default = true;
  %# @item sep: the elements separator, default '\t,'
  %# @end itemize
  %# The remaining data are concatenated (right-appended) to the existing ones.
  %# @end deftypefn

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
  %# $Id: dataframe.m 9585 2012-02-05 15:32:46Z cdemills $
  %#

if (0 == nargin)
  disp ('FIXME -- should create a dataframe from the whole workspace')
  df = dataframe ([]);
  return
endif

if (isempty (x) && 1 == nargin)
  %# default constructor: initialise the fields in the right order
  df._cnt = [0 0];
  df._name = {cell(0, 1), cell(1, 0)}; %# rows - cols 
  df._over = cell (1, 2);
  df._ridx = [];  
  df._data = cell (0, 0);
  df._rep = cell (0, 0);   %# a repetition index
  df._type = cell (0, 0);  %# the type of each column
  df._src = cell (0, 0);
  df._cmt = cell (0, 0);   %# to put comments
  df = class (df, 'dataframe');
  return
endif

if (isa (x, 'dataframe'))
  df = x;
elseif (isa (x, 'struct'))
  df = class (x, 'dataframe'); return
else
  df = dataframe ([]); %# get the right fields
endif

%# default values
seeked = []; trigger =[]; unquot = true; sep = "\t,"; cmt_lines = [];
locales = "C";

if (length(varargin) > 0)
  indi = 1;
  %# loop over possible arguments
  while (indi <= size (varargin, 2))
    if (isa (varargin{indi}, 'char'))
      switch(varargin{indi})
        case 'rownames'
          switch class (varargin{indi+1})
            case {'cell'}
              df._name{1} = varargin{indi+1};
            case {'char'}
              df._name{1} = cellstr (varargin{indi+1});
            otherwise
              df._name{1} = cellstr (num2str (varargin{indi+1}));
          endswitch
          df._name{1} = genvarname (df._name{1});
          df._over{1}(1, 1:length (df._name{1})) = false;
          df._cnt(1) = size (df._name{1}, 1);
          df._ridx = (1:df._cnt(1))';
          varargin(indi:indi+1) = [];
        case 'colnames'
          switch class(varargin{indi+1})
            case {'cell'}
              df._name{2} = varargin{indi+1};
            case {'char'}
              df._name{2} = cellstr (varargin{indi+1});
            otherwise
              df._name{2} = cellstr (num2str (varargin{indi+1}));
          endswitch
          %# detect assignment - functions calls - ranges
          dummy = cellfun ('size', cellfun (@(x) strsplit (x, ":=("), df._name{2}, \
                                            "UniformOutput", false), 2);
          if (any(dummy > 1))
            warning('dataframe colnames taken literally and not interpreted');
          endif
          df._name{2} = genvarname (df._name{2});
          df._over{2}(1, 1:length (df._name{2})) = false;
          varargin(indi:indi+1) = [];
        case 'seeked',
          seeked = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'trigger',
          trigger = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'unquot',
          unquot = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'sep',
          sep = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        case 'locales'
          locales = varargin{indi + 1};
          varargin(indi:indi+1) = [];
        otherwise %# FIXME: just skip it for now
          disp (sprintf ("Ignoring unkown argument %s", varargin{indi}));
          indi = indi + 1;    
      endswitch
    else
      indi = indi + 1;    %# skip it
    endif         
  endwhile
endif

if (!isempty (seeked) && !isempty (trigger))
  error ('seeked and trigger are mutuallly incompatible arguments');
endif

indi = 0; 
while (indi <= size(varargin, 2))
  indi = indi + 1;
  if (~isa (x, 'dataframe'))
    if (isa(x, 'char') && size(x, 1) < 2)
      %# read the data frame from a file
      try
        dummy = tilde_expand (x);
        x = load (dummy);
        df._src{end+1, 1} = dummy;
      catch
        %# try our own method
        UTF8_BOM = char([0xEF 0xBB 0xBF]);
        unwind_protect
          dummy = tilde_expand (x);
          fid = fopen (dummy);
          if (fid != -1)
            df._src{end+1, 1} = dummy;
            dummy = fgetl (fid);
            if (!strcmp (dummy, UTF8_BOM))
              frewind (fid);
            endif
            %# slurp everything and convert doubles to char, avoiding
            %# problems with char > 127
            in = char (fread (fid).'); 
          else
            in = [];
          endif
        unwind_protect_cleanup
          if (fid != -1) fclose (fid); endif
        end_unwind_protect

        if (!isempty (in))
          %# explicit list taken from 'man pcrepattern' -- we enclose all
          %# vertical separators in case the underlying regexp engine
          %# doesn't have them all.
          eol = '(\r\n|\n|\v|\f|\r|\x85)';
          %# cut into lines -- include the EOL to have a one-to-one
          %# matching between line numbers. Use a non-greedy match.
          lines = regexp (in, ['.*?' eol], 'match');
          dummy = cellfun (@(x) regexp (x, eol), lines); 
          %# remove the EOL character(s)
          lines(1 == dummy) = {""};
          %# use a positive lookahead -- eol is not part of the match
          lines(dummy > 1) = cellfun (@(x) regexp (x, ['.*?(?=' eol ')'], \
                                                   'match'), lines(dummy > 1));
          %# a field either starts at a word boundary, either by + - . for
          %# a numeric data, either by ' for a string. 
          
          %# content = cellfun(@(x) regexp(x, '(\b|[-+\.''])[^,]*(''|\b)', 'match'),\
          %# lines, 'UniformOutput', false); %# extract fields
          content = cellfun (@(x) strsplit (x, sep), lines, \
                             'UniformOutput', false); %# extract fields  
          indl = 1; indj = 1; %# disp('line 151 '); keyboard
          if (~isempty (seeked))
            while (indl <= length (lines))
              dummy = content{indl};
              if (all (cellfun ('size', dummy, 2) == 0))
                indl = indl + 1; 
                continue;
              endif
              dummy = content{indl};
              if (strcmp (dummy{1}, seeked))
                break;
              endif
              indl = indl + 1;
            endwhile
          elseif (~isempty (trigger))
            while (indl <= length (lines))
              dummy = content{indl};
              indl = indl + 1;
              if (all (cellfun ('size', dummy, 2) == 0))
                continue;
              endif
              if (strcmp (dummy{1}, trigger))
                break;
              endif
            endwhile
          endif
          x = cell (1+length (lines)-indl, size(dummy, 2)); 
          empty_lines = []; cmt_lines = [];
          while (indl <= length(lines))
            dummy = content{indl};
            if (all (cellfun ('size', dummy, 2) == 0))
              empty_lines = [empty_lines indj];
              indl = indl + 1; indj = indj + 1;
              continue;
            endif
            %# does it looks like a comment line ?
            if (regexp (dummy{1}, ['^\s*' char(35)]))
              empty_lines = [empty_lines indj];
              cmt_lines = strvcat (cmt_lines, horzcat (dummy{:}));
              indl = indl + 1; indj = indj + 1;
              continue;
            endif
            %# try to convert to float
            the_line = cellfun (@(x) sscanf (x, "%f", locales), dummy, \
                                'UniformOutput', false);
            for indk = (1:size (the_line, 2))
              if (isempty (the_line{indk}) || any (size (the_line{indk}) > 1)) 
                %#if indi > 1 && indk > 1, disp('line 117 '); keyboard; %#endif
                if (unquot)
                  try
                    %# remove quotes and leading space(s)
                    x(indj, indk) = regexp (dummy{indk}, '[^'' ].*[^'']', 'match'){1};
                  catch
                    %# if the previous test fails, try a simpler one
                    in = regexp (dummy{indk}, '[^'' ]+', 'match');
                    if (!isempty(in))
                      x(indj, indk) = in{1};
                      %# else
                      %#    x(indj, indk) = [];
                    endif
                  end_try_catch
                else
                  %# no conversion possible, store and remove leading space(s)
                  x(indj, indk) = regexp (dummy{indk}, '[^ ].*', 'match');
                endif
              else
                if (!isempty (regexp (dummy{indk}, '[/:]')))
                  %# try to convert to a date
                  [timeval, nfields] = strptime( dummy{indk}, 
                                                [char(37) 'd/' char(37) 'm/' char(37) 'Y ' char(37) 'T']);
                  if (nfields > 0) %# at least a few fields are OK
                    timestr =  strftime ([char(37) 'H:' char(37) 'M:' char(37) 'S'], 
                                         timeval);
                    %# try to extract the usec field, if any
                    idx = regexp (dummy{indk}, timestr, 'end');
                    if (!isempty (idx))
                      idx = idx + 1;
                      if (ispunct (dummy{indk}(idx)))
                        idx = idx + 1;
                      endif
                      timeval.usec = str2num(dummy{indk}(idx:end));
                    endif
                    x(indj, indk) =  str2num (strftime ([char(37) 's'], timeval)) + ...
                        timeval.usec * 1e-6;
                  endif
                else
                  x(indj, indk) = the_line{indk}; 
                endif
              endif
            endfor
            indl = indl + 1; indj = indj + 1;
          endwhile
          if (!isempty(empty_lines))
            x(empty_lines, :) = [];
          endif
          %# detect empty columns
          empty_lines = find (0 == sum (cellfun ('size', x, 2)));
          if (!isempty(empty_lines))
            x(:, empty_lines) = [];
          endif
          clear UTF8_BOM fid in lines indl the_line content empty_lines
          clear timeval timestr nfields idx
        endif
      end_try_catch
    endif
  
    %# fallback, avoiding a recursive call
    idx.type = '()';
    if (!isa (x, 'char'))
      indj = df._cnt(2)+(1:size (x, 2));
    else
      %# at this point, reading some filename failed
      error("dataframe: can't open '%s' for reading data", x);
    endif;

    if (iscell(x))
      if (2 == length (x))
        %# use the intermediate value as destination column
        [indc, ncol] = df_name2idx (df._name{2}, x{1}, df._cnt(2), "column");
        if (ncol != 1)
          error (["With two-elements cell, the first should resolve " ...
                  "to a single column"]);
        endif
        try
          dummy = cellfun ('class', x{2}(2, :), 'UniformOutput', false);
        catch
          dummy = cellfun ('class', x{2}(1, :), 'UniformOutput', false);
        end_try_catch
        df = df_pad (df, 2, [length(dummy) indc], dummy);
        x = x{2}; 
        indj =  indc + (1:size(x, 2));  %# redefine target range
      else
        if (isa (x{1}, 'cell'))
          x = x{1}; %# remove one cell level
        endif
      endif
      if (length (df._name{2}) < indj(1) || isempty (df._name{2}(indj)))
        [df._name{2}(indj, 1),  df._over{2}(1, indj)] ...
            = df_colnames (inputname(indi), indj);
        df._name{2} = genvarname (df._name{2});
      endif
      %# allow overwriting of column names
      df._over{2}(1, indj) = true;
    else
      if (!isempty(indj))        
        if (1 == length (df._name{2}) && length (df._name{2}) < \
            length (indj))
          [df._name{2}(indj, 1),  df._over{2}(1, indj)] ...
              = df_colnames (char(df._name{2}), indj);
        elseif (length (df._name{2}) < indj(1) || isempty (df._name{2}(indj)))
          [df._name{2}(indj, 1),  df._over{2}(1, indj)] ...
              = df_colnames (inputname(indi), indj);
        endif
        df._name{2} = genvarname (df._name{2});
      endif
    endif
    if (!isempty (indj))
      %# the exact row size will be determined latter
      idx.subs = {'', indj};
      %# use direct assignement
      if (ndims (x) > 2), idx.subs{3} = 1:size (x, 3); endif
      %#      df = subsasgn(df, idx, x);        <= call directly lower level
      df = df_matassign (df, idx, indj, length(indj), x);
      if (!isempty (cmt_lines))
        df._cmt = vertcat(df._cmt, cellstr(cmt_lines));
        cmt_lines = [];
      endif
    else
      df._cnt(2) = length (df._name{2});
    endif
  elseif (indi > 1)
    error ('Concatenating dataframes: use cat instead');
  endif

  try
    %# loop over next variable argument
    x = varargin{1, indi};   
  catch
    %#   disp('line 197 ???');
  end_try_catch

endwhile

endfunction

function [x, y] = df_colnames(base, num)
  %# small auxiliary function to generate column names. This is required
  %# here, as only the constructor can use inputname()
  if (any ([index(base, "=")]))
    %# takes the left part as base
    x = strsplit (base, "=");
    x = deblank (x{1});
    if (isvarname (x))
      y = false;
    else
      x = 'X'; y = true; 
    endif
  else
    %# is base most probably a filename ?
    x =  regexp (base, '''[^''].*[^'']''', 'match');
    if (isempty (x))
      if (isvarname (base))
        x = base; y = false;
      else
        x = 'X'; y = true; %# this is a default value, may be changed
      endif
    else
      x = x{1}; y = true;
    endif
  endif

  if (numel (num) > 1)
    x = repmat (x, numel (num), 1);
    x = cstrcat (x, strjust (num2str (num(:)), 'left'));
    y = repmat (y, 1, numel (num));
  endif
  
  x = cellstr (x);
    
endfunction
