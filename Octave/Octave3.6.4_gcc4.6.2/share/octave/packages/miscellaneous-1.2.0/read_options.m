## Copyright (C) 2002 Etienne Grossmann <etienne@egdn.net>
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
## @deftypefn{Function File} {@var{[op,nread]} = } read_options ( args, varargin ) 
## @cindex  
##  The function read_options parses arguments to a function as,
## [ops,nread] = read_options (args,...) - Read options
##
## The input being @var{args} a list of options and values.
## The options can be any of the following,
##
## 'op0'    , string : Space-separated names of opt taking no argument  <''>
## 
## 'op1'    , string : Space-separated names of opt taking one argument <''>
## 
## 'extra'  , string : Name of nameless trailing arguments.             <''>
## 
## 'default', struct : Struct holding default option values           <none>
## 
## 'prefix' , int    : If false, only accept whole opt names. Otherwise, <0>
##                     recognize opt from first chars, and choose 
##                     shortest if many opts start alike.
## 
## 'nocase' , int    : If set, ignore case in option names               <0>
## 
## 'quiet'  , int    : Behavior when a non-string or unknown opt is met  <0>
##              0    - Produce an error
##              1    - Return quietly (can be diagnosed by checking 'nread')
## 
## 'skipnan', int    : Ignore NaNs if there is a default value.
##     Note : At least one of 'op0' or 'op1' should be specified.
## 
## The output variables are,
## @var{ops}      : struct : Struct whose key/values are option names/values
## @var{nread}    : int    : Number of elements of args that were read
##
## USAGE 
## @example
## # Define options and defaults
## op0 = "is_man is_plane flies"
## default = struct ("is_man",1, "flies",0);
##
##                              # Read the options
##
## s = read_options (list (all_va_args), "op0",op0,"default",default)
##
##                              # Create variables w/ same name as options
##
## [is_man, is_plane, flies] = getfields (s,"is_man", "is_plane", "flies")
## pre 2.1.39 function [op,nread] = read_options (args, ...)
## @end example
## @end deftypefn

function [op,nread] = read_options (args, varargin) ## pos 2.1.39

  verbose = 0;

  op = struct ();   # Empty struct
  op0 = op1 = " ";
  skipnan = prefix = quiet = nocase = quiet = 0;
  extra = "";


  nargs = nargin-1;  # nargin is now a function
  if rem (nargs, 2), error ("odd number of optional args"); endif


  i=1;
  while i<nargs
    if ! ischar (tmp = varargin{i}), error ("non-string option"); endif
    i = i+1;
    if     strcmp (tmp, "op0")    , op0     = varargin{i}; i=i+1;
    elseif strcmp (tmp, "op1")    , op1     = varargin{i}; i=i+1;
    elseif strcmp (tmp, "extra")  , extra   = varargin{i}; i=i+1;
    elseif strcmp (tmp, "default"), op      = varargin{i}; i=i+1;
    elseif strcmp (tmp, "prefix") , prefix  = varargin{i}; i=i+1;
    elseif strcmp (tmp, "nocase") , nocase  = varargin{i}; i=i+1;
    elseif strcmp (tmp, "quiet")  , quiet   = varargin{i}; i=i+1;
    elseif strcmp (tmp, "skipnan"), skipnan = varargin{i}; i=i+1;
    elseif strcmp (tmp, "verbose"), verbose = varargin{i}; i=i+1;
    else 
      error ("unknown option '%s' for option-reading function!",tmp);
    endif
  endwhile

  if length (op0) + length (op1) < 3
    error ("Either 'op0' or 'op1' should be specified");
  endif

  if length (op0)
    if op0(1) != " ", op0 = [" ",op0]; endif
    if op0(length(op0)) != " ", op0 = [op0," "]; endif
  endif

  if length (op1)
    if op1(1) != " ", op1 = [" ",op1]; endif
    if op1(length(op1)) != " ", op1 = [op1," "]; endif
  endif

  if length (extra)
    lextra = lgrep (cellstr (strsplit (extra, " ")));
  else
    lextra = {};
  endif

  opts = [op0,op1];       # Join options
                          # Before iend : opts w/out arg. After, opts
  iend = length (op0);    # w/ arg

  spi = find (opts == " ");

  opts_orig = opts;

  if nocase, opts = tolower (opts); endif


  nread = 0;
  optread = 0;
  while nread < length (args)

    oname = name = args{++nread};
    if ! ischar (name)		# Whoa! Option name is not a string
      
      if !optread && length (lextra)
        op.(lextra{1}) = args{nread};
        lextra = lextra(2:length(lextra));
        continue
      elseif quiet, nread--; return;
      else      error ("option name in pos %i is not a string",nread);
      endif
    else
      optread = 1;
    endif
    if nocase, name = tolower (name); endif

    ii = findstr ([" ",name], opts);
    
    if isempty (ii)		# Whoa! Unknown option name
      if quiet, nread--; return;
      else      error ("unknown option '%s'",oname);
      endif
    endif
    ii++;

    if length (ii) > 1		# Ambiguous option name

      fullen = zeros (1,length (ii)); # Full length of each optio
      tmp = correct = "";
      j = 0;
      for i = ii
        fullen(++j) = spi(find (spi > i,1))-i ;
        tmp = [tmp,"', '",opts(i:i+fullen(j)-1)];
      endfor
      tmp = tmp(5:length(tmp));

      if sum (fullen == min (fullen)) > 1 || ...
             ((min (fullen) != length(name)) && ! prefix) ,
        error ("ambiguous option '%s'. Could be '%s'",oname,tmp);
      endif
      j = find (fullen == min (fullen), 1);
      ii = ii(j);
    endif

            # Full name of option (w/ correct case)

    fullname = opts_orig(ii:spi(find (spi > ii, 1))-1);
    if ii < iend
      if verbose, printf ("read_options : found boolean '%s'\n",fullname); endif
      op.(fullname) = 1;
    else
      if verbose, printf ("read_options : found '%s'\n",fullname); endif
      if nread < length (args)
        tmp = args{++nread};
        if verbose, printf ("read_options : size is %i x %i\n",size(tmp)); endif
        if !isnumeric (tmp) || !all (isnan (tmp(:))) || ...
           !isfield (op, fullname)
          op.(fullname) =  tmp;
        else
          if verbose, printf ("read_options : ignoring nan\n"); endif
        endif
      else
        error ("options end before I can read value of option '%s'",oname);
      endif
    endif
  endwhile
endfunction
