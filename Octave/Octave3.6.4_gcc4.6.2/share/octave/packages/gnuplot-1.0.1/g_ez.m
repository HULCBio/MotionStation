### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function g = g_ez (varargin)
### g = g_ez (command, args,...) - Single-command plotting function 
###
### This function allows to do basic plots with a single function call, i.e.
### like octave's plot() commant.
###
### If no output argument is required, the plot is shown and all data created
### for this plot is deleted. Otherwise use, g_plot(g) to plot g.
###
### Commands:
### ---------
### "plot", <PLOT_DATA>, where the plotted data can be 2D points or images
###        2D data can be specified by a two-column matrix of 2D points,
###        optionnally followed by a cell array of label strings
###     
### "plot", x, y, fmt,... : Reads arguments like in octave's plot (x,y,fmt,...)
###            fmt can be an octave-like formatting, e.g. "-;My Key;", see
###            _g_parse_oct_fmt(). 
###            or "img", which may be followed by "range", "xrange", "yrange",
###            "colormap" options. See _g_image_cmd().
### "geometry",[w,h]      : Set gnuplot window geometry
### "FILE.(eps|fig)"      : Plot to FILE.eps or FILE.fig file.
### "xrange", [min,max]   : Set horizontal range
### "yrange", [min,max]   : Set vertical range
### "xlabel", str         : Set x label
### "ylabel", str         : Set y label
### "title",  str         : Set title
### "cmd",    str         : Insert command str.
### "grid",               : Same as "cmd","set grid"
### "xgrid",
### "ygrid"               : Same as "cmd","set grid x"
### "xtics", arg          : If arg is a non-empty string, then this adds the 
###                         command ["set xtics " arg]. If arg is empty, same as
###                         "unset xtics". 
### "ytics", arg          : Same as "cmd","set ytics " arg
### "color",   yesno
### "display", yesno
###
### TODO: "hist", "mesh" etc ...

  ## args = struct();
  args.cmds = {};
  filename = "";
  
				# Read arguments and put them in args.

  cnt = 1;			# Arg counter
  nplots = 0;			# Plot counter
  plotcmds = "";		# arguments to plot
  step = zeros(1,0);		# Number of points per "plot" curve
  stop = {};
  N = length (varargin);
  plots =       {};		# Plotted data
  names =       {};		# Names of data files
  labels =      {};		# Labels of each dataset
  dataLabels =  {};		# Labels attached to individual data points
  do_color =    1;
  do_wait =     1;
  do_display =  1;
  labpos =      zeros(0,2);
  img_indices = zeros(1,0);

  args.xmap = args.ymap = args.map = [];

  while cnt < N
    cmd = varargin{cnt};
    if !ischar (cmd)
      error ("Expecting string, got a '%s' as %ith argument",\
	     typeinfo(cmd),cnt); 
    end

				# It's a filename
    if length (cmd) > 3 \
      && (strcmp (cmd(end-3:end), ".eps") \
	  || strcmp (cmd(end-3:end), ".fig")\
	  || strcmp (cmd(end-3:end), ".png"))
#	  || strcmp (cmd(end-3:end), ".ppm")\
#	  || strcmp (cmd(end-3:end), ".pgm")\
#	  || strcmp (cmd(end-3:end), ".jpg"))
      filename = cmd;
      cnt++;
      continue
    endif

    switch cmd

      case {"title", "xlabel", "ylabel", "x2label", "y2label"},
	str = varargin{++cnt};
	if !ischar (str),
	  error ("Option '%s' requires a char argument; got a %s",\
		 cmd, typeinfo (str));
	endif
	#str = strrep (str,"%","\\%")
	args.(cmd) = str;

      case "color"
	do_color = varargin{++cnt};

      case {"display", "-display"}
	do_display = varargin{++cnt};

      case "label"

	str = varargin{++cnt};
	if !ischar (str),
	  error ("Option '%s' requires a char argument; got a %s",\
		 cmd, typeinfo (str));
	endif
	pos = varargin{++cnt};
	if !isnumeric (pos),
	  error ("Option '%s' requires a 1 x 2 matrix argument; got a %s",\
		 cmd, typeinfo (pos));
	endif
	if length (pos) != 2
	  error ("Option '%s' requires a 1 x 2 matrix argument; got %s",\
		 cmd, sprintf("%i x",size (pos))(1:end-2));
	endif
	labels = {labels{:},str};
	labpos = [labpos;pos];
	#str = strrep (str,"%","\\%")
      case {"geometry", "xrange", "yrange", "x2range", "y2range"},
	args.(cmd) = varargin{++cnt};

      case {"range"},
	args.xrange = args.yrange = varargin{++cnt};

      case "grid"
	args.grid = "";
      case "xgrid"
	args.grid = "x";
      case "ygrid"
	args.grid = "y";

      case "xmap"
	args.xmap = varargin{++cnt};
      case "ymap"
	args.ymap = varargin{++cnt};

      case "plot"
	do			# Add following datasets
	  nplots++;

	  foundLabels = {};	# Labels for datapoints

    	  data = varargin{++cnt};
	  if !isnumeric (data)
	    error ("Argument after 'plot' should be numeric. Got '%s'.",\
		   typeinfo(data));
	  endif
	  orig_data_size = size (data);
	  if rows (data) == 1, data = data'; endif
	  ##nplots
	  ##step
	  ##rows(data)
	  ##keyboard
	  step(1,nplots) = rows (data);

	  if cnt < length (varargin)
  	    if isnumeric (varargin{cnt+1}) # x and y are separate args
	      tmp = varargin{++cnt};
	      if prod (size (tmp))    != prod (size (data)) 
		if rows (data) != rows (tmp)
		  if rows (data) == columns (tmp)
		    tmp = tmp';
		  end
		end
		if rows (data) == rows (tmp) \
		      && columns (data) == 1
		  data = data*ones(1,columns(tmp)); # Replicate abscissa data
		else
		  error ("First 'plot' arg is %i x %i, while 2nd is %i x %i\n",\
			 orig_data_size, size (tmp));
		endif
	      endif
	      if !xor (isuint(data), isuint(tmp)) # Octave's stupid bug
		data = [data(:), tmp(:)];
	      else
		data = [double(data(:)),double(tmp(:))];
	      end
	    else
	      if columns(data) == 1
		data = [(1:rows(data))', data];
	      end
	    endif		# EOF x and y are separate args
	  else
	    if columns(data) == 1
	      data = [(1:rows(data))', data];
	    end
	  end
				# Transpose data, if needed.
	  if rows(data)==2 && columns(data)>2, data = data'; endif

	  names{nplots} = sprintf ("data%i",nplots);
				# Determine how to plot it
	  try_arg = [];
	  if cnt < N
	    try_arg = varargin{cnt+1};
	  endif
				# Labels passed as a vector: turn into a cell
	  if isnumeric (try_arg) && ! isempty (try_arg)
	    if numel (try_arg) > rows (data)
	      error (["Don't know what to do with third numeric argument of size",\
		      sprintf(" %i",size(try_arg)),". Plot has has %i points"],\
		     rows(data));
	    end
	    try_arg = num2cell (try_arg);
	  end
	  ##foundLabels
	  if iscell (try_arg)	# user-specified labels
	    foundLabels = try_arg;
	    cnt++;
	    try_arg = 0;
	    if cnt < N
	      try_arg = varargin{cnt+1};
	    endif
	  end
	  if ischar (try_arg) && strcmp (try_arg, "img")

	    zrange = [min(data(:)), max(data(:))];
	    ##data =   floor (255.999*(data - zrange(1))/diff(zrange));
	    
	    [imFmt, extra, nImArgs,zrange] = _g_image_cmd (size (data), zrange, args, {varargin{cnt+2:end}});

	    cnt += nImArgs + 1;

	    data =   floor (255.999*(data - zrange(1))/diff(zrange));
	    data(data < 0) =   0;
	    data(data > 255) = 255;
	    data(isnan (data)) = 0;

	    if length (size (data)) == 3 && size(data)(3) == 3
	      data = [data(:,:,1)'(:),data(:,:,2)'(:),data(:,:,3)'(:)]';
	    else
	      data = data';
	    end
	    plotcmds =    [plotcmds,"'", names{nplots},"' ",imFmt,", "];
	    img_indices = [img_indices,  nplots];
	    args.cmds =   {args.cmds{:}, extra{:}};

	    			# EOF "img"
	  elseif ischar (try_arg) && strcmp (try_arg, "box") # Unused for now

	    interlaced = prod (orig_data_size) == rows (data)
	    if !interlaced
	      nbox = prod (orig_data_size);
	      datlen = rows (data)/nbox;
	      data1 =  data(1:datlen,1);
	      data2 =  reshape (data(:,2), nbox, datlen)';
	    else
	      datindices = data(:,1);
	      #data1 = create_set (data(:,1));
	      data1 = unique (data(:,1));
	      nbox = length (data1);
	      data2 = data(:,2);
	    end
	    data =   zeros(0,2);
	    stops =  zeros(1,0);

	    for i = 1:nbox
	      if !interlaced, the_data = data2(:,i);
	      else            the_data = data2(data1(i) == datindices);
	      end
	      boxData = boxplot_data (the_data);
	      boxWid = 0.1;
	      data = [data;\
		      [  data1(i)+boxWid*[1 -1 -1 1 1 -1 -1]/2;\
		       boxData.quantiles([3  3  2 2 4  4  3])']';\
		      [         data1(i)*[1 1 1 1];\
		       boxData.quantiles([1 2 4 5])']';];
	      stops = [stops, [7 9 11]+11*(i-1)];
	    end

	    cnt += 1;
	    plotcmds = [plotcmds, "'", names{nplots},"' ","w l title '' , "];
	    stop{nplots} = stops;

				# EOF "box"
	  else			# Plain N x 2 data

	    [isFmt, fmtContents, wantLabel] = _g_parse_oct_fmt (try_arg, nplots,foundLabels);

	    cnt += isFmt;
	    if wantLabel
	      dataLabels{nplots} = 1;
	    else
	      dataLabels{nplots} = 0;
	    end
	    if !isempty (foundLabels)
	      dataLabels{nplots} = foundLabels;
	    end
	    plotcmds = [plotcmds,"'",names{nplots},"' ",fmtContents,", "];
	    if wantLabel
	      plotcmds = [plotcmds,"'",names{nplots},"' ",wantLabel,", "];
	    end
	  end
	  plots{nplots} = data;
				# Determine how to plot it

				# EOF read datasets
        until (cnt >= N) || !isnumeric (varargin{cnt+1});

				# EOF case plot
      case "cmd" 
	args.cmds = {args.cmds{:}, varargin{++cnt}};

      case "wait"
	do_wait = varargin{++cnt};

      case {"xtics","ytics", "x2tics", "y2tics", "tics"}, 
	t = varargin{++cnt};
	args.(cmd) =  t;

      otherwise
	error ("Unknown command '%s'", cmd);
    endswitch
    cnt++;
  endwhile			# EOF Read arguments and put in struct

				# Transform args in a gnuplot_object

  if struct_contains (args, "geometry"), g = g_new ("geometry", args.geometry);
  else                                   g = g_new ();
  endif

				# Special case: quote title
  #if struct_contains (args, "title"), args.title = ["'",args.title,"'"]; endif

  if length (args.cmds), g = g_cmd (g, args.cmds{:}); endif

				# set all in g.cmds
  tmp = {"title", \
	 "xrange", "yrange", "y2range", "x2range", \
	 "xlabel", "ylabel", "x2label", "y2label", \
	 "grid", "xgrid", "ygrid"};
  for i = 1:length(tmp)
    if struct_contains (args, tmp{i})
      value = args.(tmp{i});
      val_str = _g_stringify (tmp{i}, value);
      g = g_cmd (g,["set ",tmp{i}," ",val_str,""]);
    endif
  endfor
  for i = 1:length(labels)
    g = g_cmd (g,"pr:3:set label %i \"%s\" at screen %g,%g",i,labels{i},labpos(i,:));
  endfor

  if nplots

    for j = 1:3
      
      Z = {"x","y",""}{j};
      Zmap =   [Z,"map"];
      Ztics =  [Z,"tics"];
      Zrange = [Z,"range"];

      if ! isempty (args.(Zmap)) && ! struct_contains (args,Ztics) # Must figure tics for map

	if struct_contains(args,Zrange)	# Determine range
	  rng = args.(Zrange);
	else
	  rng = [inf,-inf];
	  for i = 1:nplots
	    if all (img_indices != i)
	      rng = [min(rng(1), min (plots{i}(:,1))), \
		     max(rng(2), max (plots{i}(:,1)))];
	    end
	  end
	  assert (all (isfinite (rng)))
	end
	args.(Ztics) = _g_default_tics (rng);
      end
      if struct_contains(args,Ztics)

	if isempty (args.(Ztics))	# No tics

	  g = g_cmd (g,["unset ",Ztics]);

				# Explicit command tics
	elseif ischar (args.(Ztics))

	  g =  g_cmd (g, ["set ", Ztics, " ", args.(Ztics)]);

				# Numerical tics
	else
	  Zmajor = {};
	  if any (isnan (args.(Ztics)))	# FIXME only works for vector args.(Ztics)
	    imajor =  find(isnan (args.(Ztics)));
	    imajor -= cumsum(isnan (args.(Ztics)))(imajor) - 1;
	    Zmajor = {"major",imajor};
	    args.(Ztics) = args.(Ztics)(! isnan (args.(Ztics)));
	  end
	  if ! isempty (args.(Zmap)) && isvector (args.(Ztics))
	    args.(Ztics) = [_g_map(args.(Zmap), args.(Ztics)(:)'); args.(Ztics)(:)']; 
	    g = g_cmd (g, _g_tics (args.(Ztics)(1,:), args.(Ztics)(2,:), Z, Zmajor{:}));
	  else
	    g = g_cmd (g, _g_tics (args.(Ztics), args.(Ztics), Z, Zmajor{:}));
	  end
	end
      end
    end				# EOF loop over x, y

    for i = 1:nplots

      if all (img_indices != i)

	plots{i}(:,1) = _g_map (args.xmap, plots{i}(:,1));
	plots{i}(:,2) = _g_map (args.ymap, plots{i}(:,2));
	if length (stop) >= i && ! isempty (stop{i})
	  pre_args = {"-stops",stop{i}};
	else
	  pre_args = {"-step", step(i)};
	end

	if ! (isscalar (dataLabels{i}) && !dataLabels{i})
	  pre_args = {pre_args{:}, "-label", dataLabels{i}};
	end

	g = g_data (g,pre_args{:}, names{i}, plots{i});

      else
	g = g_data (g,"-uint8",        names{i}, plots{i});
      end
    endfor
    ##plotcmds
    g = g_cmd (g,["plot ",plotcmds(1:end-2)]);
  endif
				# EOF Transform args in a gnuplot_object
  if nargout < 1 || length(filename) || do_display
    extras = {"-color",do_color};
    if do_wait
      extras = {extras{:}, "-wait"};
    endif
    if ! do_display
      extras = {extras{:}, "-display", 0};
    endif
    if filename, g = g_plot (g,filename,extras{:});
    else         g = g_plot (g,extras{:});
    endif
    if struct_contains (g, "double_clicks")
      printf ("Double-clicked locations:\n");
      g.double_clicks
    end
    if struct_contains (g, "middle_clicks")
      printf ("Middle-clicked locations:\n");
      g.middle_clicks
    end
    filename = "";
    if nargout < 1
      "deleting"
      g_delete (g);
      clear g;
    else
      "not deleting"
    endif
  endif
endfunction


%!demo
%! printf ("\n\tNote: You may need to resize the window to see the plots\n\n");
%! %-------------------------------------------------
%! im = rand(16,31); 
%! im(3:10,5:25) = linspace(0,0.5,8)'*ones(1,21)+ones(8,1)*linspace(0,0.5,21);
%! g_ez ("title","A random grey image","plot",im, "img")
%! %-------------------------------------------------
%! % a random greylevel image

%!demo
%! t=linspace(-pi,pi,101); x = sin(t); y = sin (t+pi/3);
%! g_ez ("title","Some sines","plot",t,x,"-",t,y,"-")
%! %-------------------------------------------------
%! % some sines

%!demo
%! im = rand(16,31,3); 
%! im(3:10,5:25,1) = linspace(0,1,8)'*ones(1,21); 
%! im(3:10,5:25,2) = 0.5; 
%! im(3:10,5:25,3) = 1;
%! g_ez ("xrange",[-1,1],"plot",im*255, "img")
%! %-------------------------------------------------
%! % a random color image







