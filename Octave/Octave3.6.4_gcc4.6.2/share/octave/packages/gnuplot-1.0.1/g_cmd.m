### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function g = g_cmd (g, varargin)
### g = g_cmd (g, <command or gnuplot_object or option>,...)
###
### Adds plotting commands to g. Each command is either a string that will be
### passed to gnuplot, or a "gnuplot_object" whose commands will be executed
### (in the right directory). gnuplot_objects are instantiated (see
### _g_instantiate) before being insterted in the command list.
###
### OPTIONS:
### "-at", <num>  : Insert subsequent sequence of commands (until next "-at"
###                 option, or end of commands) after position <num>, rather
###                 than end of g's command list. Use <num> = 0 to insert at
###                 beginning.
###
### see also: g_new ...

  _g_check (g);
  if nargout<1, error ("g_cmd called in void context"); endif
  
  ## Position at which commands are inserted
  insert_pos      = length (g.cmds);

  ## Should I force multiplot? (checked at end)
  force_multiplot = 0;		

  i = 1;
  while i <=length(varargin)
				# ####################################
    if ischar (varargin{i})	# Command is a string
      
      cmds = varargin{i++};
      
      if cmds(1)=="-"		# It's an option
	switch cmds
	  case "-at", insert_pos = varargin{i++}; 
	  otherwise   error ("Unknown option '%s'",cmds);
	endswitch
	continue;
      endif

				# Command is printf format
      labelEnd = _g_istoken (cmds, "printf:");
      if labelEnd
      ##if length(cmds)>2 && all (cmds(1:2) == ("printf:")(1:2))

      ## labelEnd = index (cmds, ":");
	## if !labelEnd, error ("malformed print directive : '%s'",cmds); endif

	label = cmds(1:labelEnd);
				# Search for end of args

				# Check if user provided it
	firstPrintArg = i;
	lastPrintArg = i;
	nPrintArgs = -1;

	if labelEnd < length(cmds)
				# !!! \d does not work
	  [numSta,numEnd] = regexp (cmds(labelEnd+1:end),'^[0-9]+:');
	  if !isempty(numSta), 
	    nPrintArgs = str2num (cmds(labelEnd+(numSta:numEnd-1)));
	    labelEnd += numEnd;
	    lastPrintArg = firstPrintArg + nPrintArgs - 1;
	    i = lastPrintArg + 1;
	  endif
	endif

	if nPrintArgs < 0	# Not provided: search for end label

	  label = ["/",label];	# End label
	  while lastPrintArg<=length(varargin)                  \
		&& (   !ischar (varargin{lastPrintArg})         \
		    || !strcmp (varargin{lastPrintArg}, label))
	    lastPrintArg++;
	  endwhile

	  if lastPrintArg > length(varargin)
	    warning ("g_cmd_PRINTF_NOT_CLOSED",\
		     "Can't find closing label for '%s'",cmds);
	    i = lastPrintArg;
	  else
	    i = lastPrintArg + 1;
	    lastPrintArg--;
	  endif
	endif
	if firstPrintArg <= lastPrintArg
	  spf_format = cmds(labelEnd+1:end);

          cmds = sprintf (spf_format, varargin{firstPrintArg:lastPrintArg});
	else
	  cmds = cmds(labelEnd+1:end);
        endif
				# now, cmds is plain string
      endif			# EOF process printf arguments

				# ####################################
				# Add plain string command
      ##g.cmds = {g.cmds{:}, cmds};
      while cmds(end) == "\n"
        printf ("g_cmd: removing newline at end of command\n");
	cmds = cmds(1:end-1);
      end
      if index (cmds, "\n")
        printf ("g_cmd: Warning: there's a newline in command\n");
      endif
      ##cmds = [cmds,"\n"]
      g.cmds = csplice (g.cmds, insert_pos++, 0, {cmds});

				# ####################################
				# Command is a gnuplot_object: 
				# Instantiate it and insert its commands (making
				# sure they are executed in the right directory)
    elseif isstruct (varargin{i}) 

      if _g_check (varargin{i})
	
	g2 = _g_instantiate (varargin{i++});

	if 1 ## && struct_contains (g2, "local") && g2.local

	  g.owns = {g.owns{:}, g2.dir};
	  g.owns = {g.owns{:}, g2.owns{:}};
	endif

				# remove multiplot commands from g2.cmds: they
				# would erase what was plotted until now
	if 1
	  i1 = i2 = 1;
	  for i1 = 1:length(g2.cmds)
	    if isempty (regexp (g2.cmds{i1}, 'set\s+multiplot'))
	      g2.cmds{i2++} = g2.cmds{i1};
	    endif
	  endfor
	  g2.cmds = {g2.cmds{1:i2-1}};
	endif
	if 0
	  g.cmds = {g.cmds{:}, \
	 	   ["cd '",g2.dir,"'"],\
	 		 g2.cmds{:},\
	 	   ["cd '",g.dir,"'"]};
	endif
	if 1
	  #printf ("Insert at %i\n",insert_pos);
	  #g2.cmds
	  #g.cmds
	  g.cmds = csplice (g.cmds, insert_pos, 0, \
			   {["cd '",g2.dir,"'"],   \
			    g2.cmds{:},             \
			    ["cd '",g.dir,"'"]\
			    });
	  insert_pos += 2 + length (g2.cmds);
	  #g.cmds
	  ##printf ("After insert\n");
	  #g
	  #keyboard
	endif
	force_multiplot = 1;
      else
	error ("Command %i is a struct but not a 'gnuplot_object'\n", i);
      endif
    else
      error ("Command %i is neither string nor struct, but a",\
	     i, typeinfo (varargin{i}));
    endif
  endwhile
  if force_multiplot		# Make sure there's a multiplot command at the
				# top
    i = 1;
    while i <= length (g.cmds)	# Check for existing set multiplot
      if regexp (g.cmds{i}, 'set\s+multiplot')
	break
      endif
      i++;
    endwhile
    if i > length (g.cmds)	# If there's none, put one at the head.

      multiplot_cmd = "set multiplot";
      if struct_contains (g.values, "title")
	multiplot_cmd = [multiplot_cmd," '",g.values.title,"'"];
      endif
      g.cmds = {multiplot_cmd,\
	       g.cmds{:}};
    endif
  endif
endfunction
