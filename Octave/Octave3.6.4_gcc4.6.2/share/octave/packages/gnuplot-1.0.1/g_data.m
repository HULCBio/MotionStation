### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function g = g_data (g, varargin)
### g = g_data (g, <options>, <filename>, <matrices>, ... )
###
### ARGUMENTS: 
### <filename>, <mat1>,... : Write <mat1>,... (they should all have same width)
###                      in a file named <string>. Matrices are separated by an
###                      empty line (so that gnuplot chops lines up), unless the
###                      "-join" option is used.
###
### OPTIONS:
### "-step", <num>       : Write a blank line every <num> lines in the next
###                        written file (so that gnuplot chops lines up)
###
### "-stops",[pos1, pos2,...] : Put a blank line after the pos1'th row, pos2'th
###                     row etc.  
###
### "-join",             : Do not put an empty line between the various matrices
###                        of the next file. 
##
### "-label", yesno      :
###
### "-uint8",            : Save data as uint8 (e.g. to plot as image later).
###


  _g_check (g);
  if nargout<1, error ("g_data called in void context"); endif

  i = 1;
  step =         0;	# Size of blocks; 0 means all
  join =         0;
  data =         [];
  stops =        0;
  raw_data =     0;
  chosen_stops = 0;
  label =        0;

  while i <= length(varargin)
    name = varargin{i++};

    if !ischar (name)
      error ("Data arg %i is not char, but %s", i-1, typeinfo (name));
    endif


    if strcmp (name,"-step")	# Step option
      step = varargin{i++};
      continue;
    elseif strcmp (name,"-stops")	# Step option
      chosen_stops = [0,varargin{i++}(:)'];
      continue;
    elseif strcmp (name,"-join")	# Step option
      join = 1;
      continue;
    elseif strcmp (name,"-uint8")	# Step option
      raw_data = 1;
      continue;
    elseif strcmp (name,"-label")	# Step option
      label = varargin{i++};
      continue;
    elseif name(1) == "-"	# Bad option
      error ("Unknown option '%s'",name);
    endif
				# It's data

    while i <= length(varargin) && isnumeric (varargin{i})

      stops = [stops,rows(varargin{i})];

      if isempty (data)
	data = varargin{i};
      else
	if columns (varargin{i}) == columns (data)
	  data = [data;varargin{i}];
	else
	  error ("Data was %i columns wide until now, but arg %i is %i wide",\
		 columns(data), i, columns(varargin{i}));
	endif
      endif
      i++;
      ##size(data)
    endwhile
    stops = cumsum(stops);
				# NOPE! Assume that a column is meant when a single
				# row was passed.
    ##if rows(data)==1, data = data(:); endif

    if !raw_data

      ##save("-ascii", [g.dir,"/",name], "data");
      if join
	if step, stops = [0:step:rows(data), rows(data)];
	else     stops = [0, rows(data)];
	endif
      else
	if step,
	  tmp_stops = zeros(1,0);
	  for j = 2:length(stops)
	    tmp_stops = [tmp_stops,stops(j-1):step:stops(j),stops(j)];
	  endfor
	  stops = tmp_stops;
	endif			# If step == 0, stops are fine as they are
      endif
      if length (chosen_stops) > 1, stops = chosen_stops; endif

      ibad = find (any (isnan(data') | isinf(data')));
      if length (ibad)
	printf ("Getting rid of some NaN or Inf data\n");

	igood = find (all (!isnan(data') & !isinf(data')));
	data = data(igood,:);
	stop0 =        zeros (1,1+rows(data));

	if !isempty (stops), 
	  stop0(stops+1) = 1; 
	end
	stop0(ibad) =  1;
	stops =      cumsum(!stop0)(find (stop0));
      endif

      stops = create_set (stops);
      _g_save_data ([g.dir,"/",name], data, stops,label);
    else			# Raw data
      filename = [g.dir,"/",name];
      [fid, msg] = fopen (filename,"w");
      if fid<0, 
	error ("Can't open raw data file '%s': %s", filename, msg); 
      endif
      count = fwrite (fid, uint8(data), "uint8");
      if count != prod (size (data))
	error ("Could only write %i out of %i bytes of data.",\
	       count, prod (size (data)));
      endif
      fclose (fid);
    endif
				# Reset step etc
    step = 0;
    join = 0;
    data = [];
    stops = 0;
    raw_data = 0;
    chosen_stops = 0;
  endwhile
