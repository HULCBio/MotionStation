### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function g = _g_instantiate (g, varargin)
### g = _g_instantiate (g,"VAR", Value,  ...) - Substitute all values in g.cmds.
###
### For each occurence of "<VAR>" in g.cmds{:}, a value is seeked either on the
### command line (preferentially) or in g.values.(VAR).
###
### If no value is found, an error occurs. Otherwise, the value is used to
### substitute "<VAR>". Non-string values are converted to strings by sprintf
### ("%g",value).
###
### See also: g_new, g_set.

  ##printf ("Instantiating g at '%s'\n",g.dir);

  cmd_str = sprintf ("%s\n",g.cmds{:});
  				# Substitute variables ###############
  [dums,dume,dumte,dumm,toks] = regexp (cmd_str, '<(\w+)>');

				# Determine used tokens
  kword_cnt = struct();
  for i = 1:length (toks), kword_cnt.(toks{i}{1}) = 1; end

				# Get all values
  if struct_contains (g, "values"), 
    if !isstruct (g.values)
      error ("g.values should be a struct. Got a %s",typeinfo (g.values));
    endif
    vals = g.values;
  else    
    vals = struct();
  endif
  if length (varargin), vals = setfield (vals, varargin{:}); endif

				# Substitution
  for [dumv, kword] = kword_cnt
    
    if struct_contains (vals, kword)

      value = vals.(kword);
      if !ischar (value), value = sprintf ("%g",value); endif
      cmd_str = strrep (cmd_str, ["<",kword,">"], value);
    else
      error ("No value specified for variable '%s'",kword);
    endif
  endfor
				# Put back in cmds 
  				# note: there's a "\n" at end of cmd_str.
  end_of_lines = [0, find(cmd_str == "\n")];

  if length (g.cmds) != length (end_of_lines) - 1
    g.cmds
    end_of_lines
    keyboard
    error ("g.cmds has %i elements, but cmd_str has %i lines",\
	   length (g.cmds), length (end_of_lines) - 1);
  endif
  for i = 1:length(end_of_lines)-1
    g.cmds{i} = cmd_str(end_of_lines(i)+1:end_of_lines(i+1)-1);
  endfor

endfunction			# EOF _g_instantiate
