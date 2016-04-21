## Copyright (C) 2009-2012 Eric Chassande-Mottin, CNRS (France)
## Copyright (C) 2012 Philip Nienhuis
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{a}, @dots{}] =} strread (@var{str})
## @deftypefnx {Function File} {[@var{a}, @dots{}] =} strread (@var{str}, @var{format})
## @deftypefnx {Function File} {[@var{a}, @dots{}] =} strread (@var{str}, @var{format}, @var{format_repeat})
## @deftypefnx {Function File} {[@var{a}, @dots{}] =} strread (@var{str}, @var{format}, @var{prop1}, @var{value1}, @dots{})
## @deftypefnx {Function File} {[@var{a}, @dots{}] =} strread (@var{str}, @var{format}, @var{format_repeat}, @var{prop1}, @var{value1}, @dots{})
## Read data from a string.
##
## The string @var{str} is split into words that are repeatedly matched to the
## specifiers in @var{format}.  The first word is matched to the first
## specifier, the second to the second specifier and so forth.  If there are
## more words than specifiers, the process is repeated until all words have
## been processed.
##
## The string @var{format} describes how the words in @var{str} should be
## parsed.
## It may contain any combination of the following specifiers:
##
## @table @code
## @item %s
## The word is parsed as a string.
##
## @itemx %f
## @itemx %n
## The word is parsed as a number and converted to double.
##
## @item  %d
## @itemx %u
## The word is parsed as a number and converted to int32.
##
## @item %*', '%*f', '%*s
## The word is skipped.
##
## For %s and %d, %f, %n, %u and the associated %*s @dots{} specifiers an
## optional width can be specified as %Ns, etc. where N is an integer > 1.
## For %f, format specifiers like %N.Mf are allowed.
##
## @item literals
## In addition the format may contain literal character strings; these will be
## skipped during reading.
## @end table
##
## Parsed word corresponding to the first specifier are returned in the first
## output argument and likewise for the rest of the specifiers.
##
## By default, @var{format} is @t{"%f"}, meaning that numbers are read from
## @var{str}.  This will do if @var{str} contains only numeric fields.
##
## For example, the string
##
## @example
## @group
## @var{str} = "\
## Bunny Bugs   5.5\n\
## Duck Daffy  -7.5e-5\n\
## Penguin Tux   6"
## @end group
## @end example
##
## @noindent
## can be read using
##
## @example
## [@var{a}, @var{b}, @var{c}] = strread (@var{str}, "%s %s %f");
## @end example
##
## Optional numeric argument @var{format_repeat} can be used for
## limiting the number of items read:
##
## @table @asis
## @item -1
## (default) read all of the string until the end.
##
## @item N
## Read N times @var{nargout} items.  0 (zero) is an acceptable
## value for @var{format_repeat}.
## @end table
##
## The behavior of @code{strread} can be changed via property-value
## pairs.  The following properties are recognized:
##
## @table @asis
## @item "commentstyle"
## Parts of @var{str} are considered comments and will be skipped.
## @var{value} is the comment style and can be any of the following.
## @itemize
## @item "shell"
## Everything from @code{#} characters to the nearest end-of-line is skipped.
##
## @item "c"
## Everything between @code{/*} and @code{*/} is skipped.
##
## @item "c++"
## Everything from @code{//} characters to the nearest end-of-line is skipped.
##
## @item "matlab"
## Everything from @code{%} characters to the nearest end-of-line is skipped.
##
## @item user-supplied.  Two options:
## (1) One string, or 1x1 cell string: Skip everything to the right of it;
## (2) 2x1 cell string array: Everything between the left and right strings
## is skipped.
## @end itemize
##
## @item "delimiter"
## Any character in @var{value} will be used to split @var{str} into words
## (default value = any whitespace).
##
## @item "emptyvalue":
## Value to return for empty numeric values in non-whitespace delimited data.
## The default is NaN@.  When the data type does not support NaN
## (int32 for example), then default is zero.
##
## @item "multipledelimsasone"
## Treat a series of consecutive delimiters, without whitespace in between,
## as a single delimiter.  Consecutive delimiter series need not be vertically
## "aligned".
##
## @item "treatasempty"
## Treat single occurrences (surrounded by delimiters or whitespace) of the
## string(s) in @var{value} as missing values.
##
## @item "returnonerror"
## If @var{value} true (1, default), ignore read errors and return normally.
## If false (0), return an error.
##
## @item "whitespace"
## Any character in @var{value} will be interpreted as whitespace and
## trimmed; the string defining whitespace must be enclosed in double
## quotes for proper processing of special characters like \t.
## The default value for whitespace = " \b\r\n\t" (note the space).
## Unless whitespace is set to '' (empty) AND at least one "%s" format
## conversion specifier is supplied, a space is always part of whitespace.
##
## @end table
##
## @seealso{textscan, textread, load, dlmread, fscanf}
## @end deftypefn

function varargout = strread (str, format = "%f", varargin)

  ## Check input
  if (nargin < 1)
    print_usage ();
  endif

  if (isempty (format))
    format = "%f";
  endif

  if (! ischar (str) || ! ischar (format))
    error ("strread: STR and FORMAT arguments must be strings");
  endif

  ## Parse format string to compare number of conversion fields and nargout
  nfields = length (strfind (format, "%")) - length (strfind (format, "%*"));
  ## If str only has numeric fields, a (default) format ("%f") will do.
  ## Otherwise:
  if ((max (nargout, 1) != nfields) && ! strcmp (format, "%f"))
    error ("strread: the number of output variables must match that specified by FORMAT");
  endif

  ## Check for format string repeat count
  format_repeat_count = -1;
  if (nargin > 2 && isnumeric (varargin{1}))
    if (varargin{1} >= 0)
      format_repeat_count = varargin{1};
    endif
    if (nargin > 3)
      varargin = varargin(2:end);
    else
      varargin = {};
    endif
  endif

  ## Parse options.  First initialize defaults
  comment_flag = false;
  delimiter_str = "";
  empty_str = "";
  eol_char = "";
  err_action = 0;
  mult_dlms_s1 = false;
  numeric_fill_value = NaN;
  white_spaces = " \b\r\n\t";
  for n = 1:2:length (varargin)
    switch (lower (varargin{n}))
      case "bufsize"
        ## We could synthesize this, but that just seems weird...
        warning ('strread: property "bufsize" is not implemented');
      case "commentstyle"
        comment_flag = true;
        switch (lower (varargin{n+1}))
          case "c"
            [comment_start, comment_end] = deal ("/*", "*/");
          case "c++"
            [comment_start, comment_end] = deal ("//", "eol_char");
          case "shell"
            [comment_start, comment_end] = deal ("#" , "eol_char");
          case "matlab"
            [comment_start, comment_end] = deal ("%" , "eol_char");
          otherwise
            if (ischar (varargin{n+1}) ||
               (numel (varargin{n+1}) == 1 && iscellstr (varargin{n+1})))
              [comment_start, comment_end] = deal (char (varargin{n+1}), "eol_char");
            elseif (iscellstr (varargin{n+1}) && numel (varargin{n+1}) == 2)
              [comment_start, comment_end] = deal (varargin{n+1}{:});
            else
              ## FIXME - a user may have numeric values specified: {'//', 7}
              ##         this will lead to an error in the warning message
              error ("strread: unknown or unrecognized comment style '%s'",
                      varargin{n+1});
            endif
        endswitch
      case "delimiter"
        delimiter_str = varargin{n+1};
        if (strcmp (typeinfo (delimiter_str), "sq_string"))
          delimiter_str = do_string_escapes (delimiter_str);
        endif
      case "emptyvalue"
        numeric_fill_value = varargin{n+1};
      case "expchars"
        warning ('strread: property "expchars" is not implemented');
      case "whitespace"
        white_spaces = varargin{n+1};
        if (strcmp (typeinfo (white_spaces), "sq_string"))
          white_spaces = do_string_escapes (white_spaces);
        endif
      ## The following parameters are specific to textscan and textread
      case "endofline"
        eol_char = varargin{n+1};
        if (strcmp (typeinfo (eol_char), "sq_string"))
          eol_char = do_string_escapes (eol_char);
        endif
      case "returnonerror"
        err_action = varargin{n+1};
      case "multipledelimsasone"
        mult_dlms_s1 = varargin{n+1};
      case "treatasempty"
        if (iscellstr (varargin{n+1}))
          empty_str = varargin{n+1};
        elseif (ischar (varargin{n+1}))
          empty_str = varargin(n+1);
        else
          error ('strread: "treatasempty" value must be string or cellstr');
        endif
      otherwise
        warning ('strread: unknown property "%s"', varargin{n});
    endswitch
  endfor

  ## First parse of FORMAT
  if (strcmpi (strtrim (format), "%f"))
    ## Default format specified.  Expand it (to desired nargout)
    fmt_words = cell (nargout, 1);
    fmt_words (1:nargout) = format;
  else
    ## Determine the number of words per line as a first guess.  Forms
    ## like %f<literal>) (w/o delimiter in between) are fixed further on
    format = strrep (format, "%", " %");
    fmt_words = regexp (format, '[^ ]+', 'match');
    ## Format conversion specifiers following literals w/o space/delim
    ## in between are separate now.  Separate those w trailing literals
    idy2 = find (! cellfun ("isempty", strfind (fmt_words, "%")));
    a = strfind (fmt_words(idy2), "%");
    b = regexp (fmt_words(idy2), '[nfdus]', 'end');
    for jj = 1:numel (a)
      ii = numel (a) - jj + 1;
      if (! (length (fmt_words{idy2(ii)}) == b{ii}(1)))
        ## Fix format_words
        fmt_words(idy2(ii)+1 : end+1) = fmt_words(idy2(ii) : end);
        fmt_words{idy2(ii)} = fmt_words{idy2(ii)}(a{ii} : b{ii}(1));
        fmt_words{idy2(ii)+1} = fmt_words{idy2(ii)+1}(b{ii}+1:end);
      endif
    endfor
  endif
  num_words_per_line = numel (fmt_words);

  ## Special handling for CRLF EOL character in str
  if (! isempty (eol_char) && strcmp (eol_char, "\r\n"))
    ## Strip CR from CRLF sequences
    str = strrep (str, "\r\n", "\n");
    ## CR serves no further purpose in function
    eol_char = "\n";
  endif

  ## Remove comments in str
  if (comment_flag)
    ## Expand 'eol_char' here, after option processing which may have set value
    comment_end = regexprep (comment_end, 'eol_char', eol_char);
    cstart = strfind (str, comment_start);
    cstop  = strfind (str, comment_end);
    ## Treat end of string as additional comment stop
    if (isempty (cstop) || cstop(end) != length (str))
      cstop(end+1) = length (str);
    endif
    if (! isempty (cstart))
      ## Ignore nested openers.
      [idx, cidx] = unique (lookup (cstop, cstart), "first");
      if (idx(end) == length (cstop))
        cidx(end) = []; # Drop the last one if orphaned.
      endif
      cstart = cstart(cidx);
    endif
    if (! isempty (cstop))
      ## Ignore nested closers.
      [idx, cidx] = unique (lookup (cstart, cstop), "first");
      if (idx(1) == 0)
        cidx(1) = []; # Drop the first one if orphaned.
      endif
      cstop = cstop(cidx);
    endif
    len = length (str);
    c2len = length (comment_end);
    str = cellslices (str, [1, cstop + c2len], [cstart - 1, len]);
    str = [str{:}];
  endif

  if (! isempty (white_spaces))
    ## For numeric fields, whitespace is always a delimiter, but not for text fields
    if (isempty (strfind (format, "%s")))
      ## Add whitespace to delimiter set
      delimiter_str = unique ([white_spaces delimiter_str]);
    else
      ## Remove any delimiter chars from white_spaces list
      white_spaces = setdiff (white_spaces, delimiter_str);
    endif
  endif
  if (isempty (delimiter_str))
    delimiter_str = " ";
  endif
  if (! isempty (eol_char))
    ## Add eol_char to delimiter collection
    delimiter_str = unique ([delimiter_str eol_char]);
    ## .. and remove it from whitespace collection
    white_spaces = strrep (white_spaces, eol_char, '');
  endif

  pad_out = 0;
  ## Trim whitespace if needed
  if (! isempty (white_spaces))
    ## Check if trailing "\n" might signal padding output arrays to equal size
    ## before it is trimmed away below
    if ((str(end) == 10) && (nargout > 1))
      pad_out = 1;
    endif
    ## Condense all repeated whitespace into one single space
    ## FIXME: this will also fold repeated whitespace in a char field
    rxp_wsp = sprintf ("[%s]+", white_spaces);
    str = regexprep (str, rxp_wsp, ' ');
    ## Remove possible leading space at string
    if (str(1) == 32)
       str = str(2:end);
    endif
    ## Check for single delimiter followed/preceded by whitespace
    ## FIXME: Double strrep on str is enormously expensive of CPU time.
    ## Can this be eliminated
    if (! isempty (delimiter_str))
      dlmstr = setdiff (delimiter_str, " ");
      rxp_dlmwsp = sprintf ("( [%s]|[%s] )", dlmstr, dlmstr);
      str = regexprep (str, rxp_dlmwsp, delimiter_str(1));
    endif
    ## FIXME: Double strrep on str is enormously expensive of CPU time.
    ## Can this be eliminated
    ## Wipe leading and trailing whitespace on each line (it may be delimiter too)
    if (! isempty (eol_char))
      str = strrep (str, [eol_char " "], eol_char);
      str = strrep (str, [" " eol_char], eol_char);
    endif
  endif

  ## Split 'str' into words
  words = split_by (str, delimiter_str, mult_dlms_s1, eol_char);
  if (! isempty (white_spaces))
    ## Trim leading and trailing white_spaces
    ## FIXME: Is this correct?  strtrim clears what matches isspace(), not
    ## necessarily what is in white_spaces.
    words = strtrim (words);
  endif
  num_words = numel (words);
  ## First guess at number of lines in file (ignoring leading/trailing literals)
  num_lines = ceil (num_words / num_words_per_line);

  ## Replace TreatAsEmpty char sequences by empty strings
  if (! isempty (empty_str))
    for ii = 1:numel (empty_str)
      idz = strmatch (empty_str{ii}, words, "exact");
      words(idz) = {""};
    endfor
  endif

  ## fmt_words has been split properly now, but words{} has only been split on
  ## delimiter positions. 
  ## As numeric fields can also be separated by whitespace, more splits may be
  ## needed.
  ## We also don't know the number of lines (as EndOfLine may have been set to
  ## "" (empty) by the caller).
  ##
  ## We also may have to cope with 3 cases as far as literals go:
  ## A: Trailing literals (%f<literal>) w/o delimiter in between.
  ## B: Leading literals (<literal>%f) w/o delimiter in between.
  ## C. Skipping leftover parts of specified skip fields (%*N )
  ## Some words columns may have to be split further to fix these.

  ## Find indices and pointers to possible literals in fmt_words
  idf = cellfun ("isempty", strfind (fmt_words, "%"));
  ## Find indices and pointers to conversion specifiers with fixed width
  idg = ! cellfun ("isempty", regexp (fmt_words, '%\*?\d'));
  idy = find (idf | idg);
  ## Find indices to numeric conversion specifiers
  idn = ! cellfun ("isempty", regexp (fmt_words, "%[dnfu]"));

  ## If needed, split up columns in three steps:
  if (! isempty (idy))
    ## Try-catch because complexity of strings to read can be infinite
    try

      ## 1. Assess "period" in the split-up words array ( < num_words_per_line).
      ## Could be done using EndOfLine but that prohibits EndOfLine = "" option.
      ## Alternative below goes by simply parsing a first grab of words
      ## and counting words until the fmt_words array is exhausted:
      iwrd = 1; iwrdp = 0; iwrdl = length (words{iwrd});
      for ii = 1:numel (fmt_words)

        nxt_wrd = 0;

        if (idf(ii))
          ## Literal expected
          if (isempty (strfind (fmt_words{ii}, words(iwrd))))
            ## Not found in current word; supposed to be in next word
            nxt_wrd = 1;
          else
            ## Found it in current word.  Subtract literal length
            iwrdp += length (fmt_words{ii});
            if (iwrdp > iwrdl)
              ## Parse error.  Literal extends beyond delimiter (word boundary)
              warning ("strread: literal '%s' (fmt spec # %d) does not match data", ...
                fmt_words{ii}, ii);
              ## Word assumed to be completely "used up". Next word
              nxt_wrd = 1;
            elseif (iwrdp == iwrdl)
              ## Word completely "used up". Next word
              nxt_wrd = 1;
            endif
          endif

        elseif (idg(ii))
          ## Fixed width specifier (%N or %*N): read just a part of word
          iwrdp += floor ...
           (str2double (fmt_words{ii}(regexp(fmt_words{ii}, '\d') : end-1)));
          if (iwrdp > iwrdl)
            ## Match error. Field extends beyond word boundary.
            warning  ...
            ("strread: field width '%s' (fmt spec # %d) extends beyond actual word limit", ...
               fmt_words{ii}, ii);
            ## Assume word to be completely "used up".  Next word
            nxt_wrd = 1;
          elseif (iwrdp == iwrdl)
            ## Word completely "used up".  Next word
            nxt_wrd = 1;
          endif

        else
          ## A simple format conv. specifier. Either (1) uses rest of word, or
          ## (2) is squeezed between current iwrdp and next literal, or (3) uses
          ## next word. (3) is already taken care of.  So just check (1) & (2)
          if (ii < numel (fmt_words) && idf(ii+1))
            ## Next fmt_word is a literal...
            if (! index (words{iwrd}(iwrdp+1:end), fmt_words{ii+1}))
              ## ...but not found in current word => field uses rest of word
              nxt_wrd = 1;
            else
              ## ..or it IS found.  Add inferred width of current conversion field
              iwrdp += index (words{iwrd}(iwrdp+1:end), fmt_words{ii+1}) - 1;
            endif
          elseif (iwrdp < iwrdl)
            ## No bordering literal to the right => field occupies (rest of) word
            nxt_wrd = 1;
          endif

        endif

        if (nxt_wrd)
          ++iwrd; iwrdp = 0;
          if (ii < numel (fmt_words))
            iwrdl = length (words{iwrd});
          endif
        endif

      endfor
      ## Done
      words_period = max (iwrd - 1, 1);
      num_lines = ceil (num_words / words_period);

      ## 2. Pad words array so that it can be reshaped
      tmp_lines = ceil (num_words / words_period);
      num_words_padded = tmp_lines * words_period - num_words;
      if (num_words_padded)
        words = [words'; cell(num_words_padded, 1)];
      endif
      words = reshape (words, words_period, tmp_lines);

      ## 3. Do the column splitting on rectangular words array
      icol = 1; ii = 1;    # icol = current column, ii = current fmt_word
      while (ii <= num_words_per_line)

        ## Check if fmt_words(ii) contains a literal or fixed-width
        if ((idf(ii) || idg(ii)) && (rows(words) < num_words_per_line))
          if (idf(ii))
            s = strfind (words(icol, 1), fmt_words{ii});
            if (isempty (s{:}))
              error ("strread: Literal '%s' not found in column %d", fmt_words{ii}, icol);
            endif
            s = s{:}(1);
            e = s(1) + length (fmt_words{ii}) - 1;
          endif
          if (! strcmp (fmt_words{ii}, words{icol, 1}))
            ## Column doesn't exactly match literal => split needed.  Insert a column
            words(icol+1:end+1, :) = words(icol:end, :);
            ## Watch out for empty cells
            jptr = find (! cellfun ("isempty", words(icol, :)));

            ## Distinguish leading or trailing literals
            if (! idg(ii) && ! isempty (s) && s(1) == 1)
              ## Leading literal.  Assign literal to icol, paste rest in icol + 1
              ## Apply only to those cells that do have something beyond literal
              jptr = find (cellfun("length", words(icol+1, jptr), ...
                            "UniformOutput", false) > e(1));
              words(icol+1, :) = {""};
              words(icol+1, jptr) = cellfun ...
                (@(x) substr(x, e(1)+1, length(x)-e(1)), words(icol, jptr), ...
                "UniformOutput", false);
              words(icol, jptr) = fmt_words{ii};

            else
              if (! idg(ii) && ! isempty (strfind (fmt_words{ii-1}, "%s")))
                ## Trailing literal.  If preceding format == '%s' this is an error
                warning ("Ambiguous '%s' specifier next to literal in column %d", icol);
              elseif (idg(ii))
                ## Current field = fixed width. Strip into icol, rest in icol+1
                wdth = floor (str2double (fmt_words{ii}(regexp(fmt_words{ii}, ...
                              '\d') : end-1)));
                words(icol+1, jptr) = cellfun (@(x) x(wdth+1:end),
                     words(icol,jptr), "UniformOutput", false);
                words(icol, jptr) = strtrunc (words(icol, jptr), wdth);
              else
                ## FIXME: this assumes char(254)/char(255) won't occur in input!
                clear wrds;
                wrds(1:2:2*numel (words(icol, jptr))) = ...
                     strrep (words(icol, jptr), fmt_words{ii}, ...
                     [char(255) char(254)]);
                wrds(2:2:2*numel (words(icol, jptr))-1) = char(255);
                wrds = strsplit ([wrds{:}], char(255));
                words(icol, jptr) = ...
                  wrds(find (cellfun ("isempty", strfind (wrds, char(254)))));
                wrds(find (cellfun ("isempty", strfind (wrds, char(254))))) ...
                   = char(255);
                words(icol+1, jptr) = strsplit (strrep ([wrds{2:end}], ...
                   char(254), fmt_words{ii}), char(255));
                ## Former trailing literal may now be leading for next specifier
                --ii;
              endif
            endif
          endif

        else
          ## Conv. specifier.  Peek if next fmt_word needs split from current column
          if (ii < num_words_per_line)
            if (idf(ii+1) && (! isempty (strfind (words{icol, 1}, fmt_words{ii+1}))))
              --icol;
            elseif (idg(ii+1))
              --icol;
            endif
          endif
        endif
        ## Next fmt_word, next column
        ++ii; ++icol;
      endwhile

      ## Done.  Reshape words back into 1 long vector and strip padded empty words
      words = reshape (words, 1, numel (words))(1 : end-num_words_padded);

    catch
      warning ("strread: unable to parse text or file with given format string");
      return;

    end_try_catch
  endif

  ## For each specifier, process corresponding column
  k = 1;
  for m = 1:num_words_per_line
    try
      if (format_repeat_count < 0)
        data = words(m:num_words_per_line:end);
      elseif (format_repeat_count == 0)
        data = {};
      else
        lastline = ...
          min (num_words_per_line * format_repeat_count + m - 1, numel (words));
        data = words(m:num_words_per_line:lastline);
      endif

      ## Map to format
      ## FIXME - add support for formats like "<%s>", "%[a-zA-Z]"
      ##         Someone with regexp experience is needed.
      switch fmt_words{m}(1:min (2, length (fmt_words{m})))
        case "%s"
          if (pad_out)
            data(end+1:num_lines) = {""};
          endif
          varargout{k} = data';
          k++;
        case {"%d", "%u", "%f", "%n"}
          n = cellfun ("isempty", data);
          ### FIXME - erroneously formatted data lead to NaN, not an error
          data = str2double (data);
          if (! isempty (regexp (fmt_words{m}, "%[du]")))
            ## Cast to integer
            ## FIXME: NaNs will be transformed into zeros
            data = int32 (data);
          endif
          data(n) = numeric_fill_value;
          if (pad_out)
            data(end+1:num_lines) = numeric_fill_value;
          endif
          varargout{k} = data.';
          k++;
        case {"%0", "%1", "%2", "%3", "%4", "%5", "%6", "%7", "%8", "%9"}
          nfmt = strsplit (fmt_words{m}(2:end-1), '.');
          swidth = str2double (nfmt{1});
          switch fmt_words{m}(end)
            case {"d", "u", "f", "n%"}
              n = cellfun ("isempty", data);
              ### FIXME - erroneously formatted data lead to NaN, not an error
              ###         => ReturnOnError can't be implemented for numeric data
              data = str2double (strtrunc (data, swidth));
              data(n) = numeric_fill_value;
              if (pad_out)
                data(end+1:num_lines) = numeric_fill_value;
              endif
              if (numel (nfmt) > 1)
                sprec = str2double (nfmt{2});
                data = 10^-sprec * round (10^sprec * data);
              elseif (! isempty (regexp (fmt_words{m}, "[du]")))
                ## Cast to integer
                ## FIXME: NaNs will be transformed into zeros
                data = int32 (data);
              endif
              varargout{k} = data.';
              k++;
            case "s"
              if (pad_out)
                data(end+1:num_lines) = {""};
              endif
              varargout{k} = strtrunc (data, swidth)';
              k++;
            otherwise
          endswitch
        case {"%*", "%*s"}
          ## skip the word
        otherwise
          ## Ensure descriptive content is consistent.
          ## Test made a bit lax to accomodate for incomplete last lines
          n = find (! cellfun ("isempty", data));
          if (numel (unique (data(n))) > 1
              || ! strcmpi (unique (data), fmt_words{m}))
            error ("strread: FORMAT does not match data");
          endif
      endswitch
    catch
      ## As strread processes columnwise, ML-compatible error processing
      ## (row after row) is not feasible. In addition Octave sets unrecognizable
      ## numbers to NaN w/o error.  But maybe Octave is better in this respect.
      if (err_action)
        ## Just try the next column where ML bails out
      else
        rethrow (lasterror);
      endif
    end_try_catch
  endfor

endfunction

function out = split_by (text, sep, mult_dlms_s1, eol_char)

  ## Check & if needed, process MultipleDelimsAsOne parameter
  if (mult_dlms_s1)
    mult_dlms_s1 = true;
    ## FIXME: Should re-implement strsplit() function here in order
    ## to avoid strrep on megabytes of data.
    ## If \n is in sep collection we need to enclose it in text
    ## to avoid it being included in consecutive delim series
    enchr = ' ';
    ## However watch out if eol_char is also in delimiters
    if (index (sep, eol_char)); enchr = char(255); endif
    text = strrep (text, eol_char, [enchr eol_char enchr]);
  else
    mult_dlms_s1 = false;
  endif

  ## Split text string along delimiters
  out = strsplit (text, sep, mult_dlms_s1);
  if (index (sep, eol_char)); out = strrep (out, char(255), ''); endif
  ## In case of trailing delimiter, strip stray last empty word
  if (!isempty (out) && any (sep == text(end)))
    out(end) = [];
  endif

  ## Empty cells converted to empty cellstrings.
  out(cellfun ("isempty", out)) = {""};

endfunction


%!test
%! [a, b] = strread ("1 2", "%f%f");
%! assert (a, 1);
%! assert (b, 2);

%!test
%! str = '';
%! a = rand (10, 1);
%! b = char (randi ([65, 85], 10, 1));
%! for k = 1:10
%!   str = sprintf ('%s %.6f %s\n', str, a(k), b(k));
%! endfor
%! [aa, bb] = strread (str, '%f %s');
%! assert (a, aa, 1e-6);
%! assert (cellstr (b), bb);

%!test
%! str = '';
%! a = rand (10, 1);
%! b = char (randi ([65, 85], 10, 1));
%! for k = 1:10
%!   str = sprintf ('%s %.6f %s\n', str, a(k), b(k));
%! endfor
%! aa = strread (str, '%f %*s');
%! assert (a, aa, 1e-6);

%!test
%! str = sprintf ('/* this is\nacomment*/ 1 2 3');
%! a = strread (str, '%f', 'commentstyle', 'c');
%! assert (a, [1; 2; 3]);

%!test
%! str = "# comment\n# comment\n1 2 3";
%! [a, b] = strread (str, '%n %s', 'commentstyle', 'shell', 'endofline', "\n");
%! assert (a, [1; 3]);
%! assert (b, {"2"});

%!test
%! str = sprintf ("Tom 100 miles/hr\nDick 90 miles/hr\nHarry 80 miles/hr");
%! fmt = "%s %f miles/hr";
%! c = cell (1, 2);
%! [c{:}] = strread (str, fmt);
%! assert (c{1}, {"Tom"; "Dick"; "Harry"})
%! assert (c{2}, [100; 90; 80])

%!test
%! a = strread ("a b c, d e, , f", "%s", "delimiter", ",");
%! assert (a, {"a b c"; "d e"; ""; "f"});

%!test
%! # Bug #33536
%! [a, b, c] = strread ("1,,2", "%s%s%s", "delimiter", ",");
%! assert (a{1}, '1');
%! assert (b{1}, '');
%! assert (c{1}, '2');

%!test
%! # Bug #33536
%! a = strread ("[SomeText]", "[%s", "delimiter", "]");
%! assert (a{1}, "SomeText");

%!test
%! dat = "Data file.\r\n=  =  =  =  =\r\nCOMPANY    : <Company name>\r\n";
%! a = strread (dat, "%s", 'delimiter', "\n", 'whitespace', '', 'endofline', "\r\n");
%! assert (a{2}, "=  =  =  =  =");
%! assert (double (a{3}(end-5:end)), [32 110 97 109 101 62]);

%!test
%! [a, b, c, d] = strread ("1,2,3,,5,6", "%d%f%d%f", 'delimiter', ',');
%! assert (c, int32 (3));
%! assert (d, NaN);

%!test
%! [a, b, c, d] = strread ("1,2,3,,5,6\n", "%d%d%f%d", 'delimiter', ',');
%! assert (c, [3; NaN]);
%! assert (d, int32 ([0; 0]));

%!test
%! # Default format (= %f)
%1 [a, b, c] = strread ("0.12 0.234 0.3567");
%1 assert (a, 0.12);
%1 assert (b, 0.234);
%1 assert (c, 0.3567);

%!test
%! [a, b] = strread('0.41 8.24 3.57 6.24 9.27', "%f%f", 2, 'delimiter', ' ');
%1 assert (a, [0.41; 3.57]);

%!test
%! # TreatAsEmpty
%! [a, b, c, d] = strread ("1,2,3,NN,5,6\n", "%d%d%d%f", 'delimiter', ',', 'TreatAsEmpty', 'NN');
%! assert (c, int32 ([3; 0]));
%! assert (d, [NaN; NaN]);

%!test
%! # No delimiters at all besides EOL.  Plain reading numbers & strings
%! str = "Text1Text2Text\nText398Text4Text\nText57Text";
%! [a, b] = strread (str, "Text%dText%1sText");
%! assert (a, int32 ([1; 398; 57]));
%! assert (b(1:2), {'2'; '4'});
%! assert (isempty (b{3}), true);

%% MultipleDelimsAsOne
%!test
%! str = "11, 12, 13,, 15\n21,, 23, 24, 25\n,, 33, 34, 35";
%! [a b c d] = strread (str, "%f %f %f %f", 'delimiter', ',', 'multipledelimsasone', 1, 'endofline', "\n");
%! assert (a', [11, 21, NaN]);
%! assert (b', [12, 23, 33]);
%! assert (c', [13, 24, 34]);
%! assert (d', [15, 25, 35]);

%% delimiter as sq_string and dq_string
%!test
%! assert (strread ("1\n2\n3", "%d", "delimiter", "\n"),
%!         strread ("1\n2\n3", "%d", "delimiter", '\n'))

%% whitespace as sq_string and dq_string
%!test
%! assert (strread ("1\b2\r3\b4\t5", "%d", "whitespace", "\b\r\n\t"),
%!         strread ("1\b2\r3\b4\t5", "%d", "whitespace", '\b\r\n\t'))

%!test
%! str =  "0.31 0.86 0.94\n 0.60 0.72 0.87";
%! fmt = "%f %f %f";
%! args = {"delimiter", " ", "endofline", "\n", "whitespace", " "};
%! [a, b, c] = strread (str, fmt, args {:});
%! assert (a, [0.31; 0.60], 0.01)
%! assert (b, [0.86; 0.72], 0.01)
%! assert (c, [0.94; 0.87], 0.01)

%!test
%! str =  "0.31,0.86,0.94\n0.60,0.72,0.87";
%! fmt = "%f %f %f";
%! args = {"delimiter", ",", "endofline", "\n", "whitespace", " "};
%! [a, b, c] = strread (str, fmt, args {:});
%! assert (a, [0.31; 0.60], 0.01)
%! assert (b, [0.86; 0.72], 0.01)
%! assert (c, [0.94; 0.87], 0.01)

%!test
%! str =  "0.31 0.86 0.94\n 0.60 0.72 0.87";
%! fmt = "%f %f %f";
%! args = {"delimiter", ",", "endofline", "\n", "whitespace", " "};
%! [a, b, c] = strread (str, fmt, args {:});
%! assert (a, [0.31; 0.60], 0.01)
%! assert (b, [0.86; 0.72], 0.01)
%! assert (c, [0.94; 0.87], 0.01)

%!test
%! str =  "0.31, 0.86, 0.94\n 0.60, 0.72, 0.87";
%! fmt = "%f %f %f";
%! args = {"delimiter", ",", "endofline", "\n", "whitespace", " "};
%! [a, b, c] = strread (str, fmt, args {:});
%! assert (a, [0.31; 0.60], 0.01)
%! assert (b, [0.86; 0.72], 0.01)
%! assert (c, [0.94; 0.87], 0.01)
