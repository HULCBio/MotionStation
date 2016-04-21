### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function g = g_plot (g, varargin)
### g = g_plot (g,...)            - Plot a gnuplot_object
###
### If g.values has a field "geometry" of the form, [width, heigth]  or
### "<width>x<height>, it will be used to set the geometry, in pixels of the
### gnuplot window.
###
### 
###
### OPTIONS:
### "geometry",geometry 
###
### "-wait" : Gnuplot does not exit immediately, which allows to manipulate the
###           plot with the mouse.
###
### Any string ending in '.eps' causes postscript output. The plot is output to
###           that file, and the file is viewed using ggv.
###
### "-display", yesno : View eps file or not (senseless unless an eps was saved)
##
### "-color",  yesno : In color or monochrome (for eps and fig)
###
### All optional arguments other than the options above will be passed to
### _g_instantiate before plotting.
###
### TODO: Have a better choice of postscript viewers (e.g. gv ...)
###       Do the same for .pdf, .fig and .png arguments. 
###
### See also: g_new,...

  _g_check (g);

  do_eps =          0;
  do_fig =          0;
  do_png =          0;
#  do_ppm =          0;
#  do_pgm =          0;
#  do_jpg =          0;
  do_display =      1;
  outputFile =      "";
  gnuplot_options = "";
  geometry =        [];
  pre_cmd =         {};
  pos_cmd =         {};
  do_color =        1;

  wait_for_q = struct_contains (g.values, "wait") && g.values.wait;

  if 0
    eps_viewer = "ggv";
  else
    eps_viewer = "gv";
  end
  if 0
    png_viewer = "qiv";
  elseif 0
    png_viewer = "xzgv";
  elseif 0
    png_viewer = "display";
  else
    png_viewer = "eog";
  end

  i = 1;
  keep = ones (1,length(varargin)); # Opts that'll be passed to _g_instantiate
  while i <= length (varargin)
    opt = varargin{i++};
    ll = length(opt);
    if ll>=4 \
	  && (strcmp (opt(ll-3:ll), ".eps")    \
	      || strcmp (opt(ll-3:ll), ".fig") \
	      || strcmp (opt(ll-3:ll), ".png"))
      
      if do_eps || do_fig || do_png,
	printf ("Will save to '%s'\n",opt);
      end
      switch opt(ll-3:ll)
	case ".eps", do_eps = 1;
	case ".fig", do_fig = 1; 
	case ".png", do_png = 1; 
      endswitch
      
      outputFile = opt;
      keep(i-1) = 0;

    elseif strcmp (opt, "-wait")
      wait_for_q = 1;
      keep(i-1) = 0;

    elseif strcmp (opt, "geometry")

      geometry = varargin{i++};
	keep([i-2,i-1]) = 0;

    elseif strcmp (opt, "-display")
      if i > length (varargin) \
	    || (i == length(varargin) && !isnumeric (varargin{i}))
	do_display = 1;
	keep([i-1]) = 0;
      else
	do_display = varargin{i++};
	keep([i-2,i-1]) = 0;
      endif
    elseif strcmp (opt, "-color")
      if i > length (varargin) \
	    || (i == length(varargin) && !isnumeric (varargin{i}))
	do_color = 1;
	keep([i-1]) = 0;
      else
	do_color = varargin{i++};
	keep([i-2,i-1]) = 0;
      endif
    else 
      ##error ("Unknown option '%s'",opt);
    endif
  endwhile			# EOF reading options

				# Make outputFile absolute
  if length(outputFile) && outputFile(1) != "/"
    outputFile = [pwd(),"/",outputFile];
  endif

  if  do_eps
    if isempty (geometry)
      if ! struct_contains (g.values, "geometry")
	geometry = [10,8];
      else
	geometry = g.values.geometry;
	if ischar(geometry)
	  geometry = strrep (geometry, "x", " ");
	  geometry = eval (["[",geometry,"]"])
	endif
	geometry ./= 28;
      endif
    endif
  elseif do_png
    if isempty (geometry)
      if ! struct_contains (g.values, "geometry")
	geometry = [600,400];
      else
	geometry = g.values.geometry;
	if ischar(geometry)
	  geometry = strrep (geometry, "x", " ");
	  geometry = eval (["[",geometry,"]"])
	endif
	##geometry .*= 72;
      endif
    endif
  endif
  if do_color, colorStr = "color"; else colorStr = "monochrome"; end
  if do_eps

    pre_cmd = {sprintf("set term postscript eps %s size %.1fcm,%.1fcm 20",colorStr,geometry),\
	       ["set out '",outputFile,"'"]};

  elseif do_fig
    pre_cmd = {sprintf("set term fig big landscape metric %s fontsize 20 ",colorStr),\
	       ["set out '",outputFile,"'"]};

  elseif do_png

    if do_color
      pcolors = "xffffff x000000 x000000 xc00000 xa0ffa0 x0000ff xE0E000 x00E0E0 xE000E0 x000000";
    else
      pcolors = "xffffff x000000 x000000 x000000 x808080 xA0A0A0 xE0E0E0 x404040 xC0C0C0 x202020";
    end
    pre_cmd = {sprintf("set term png truecolor size %i, %i %s",geometry, pcolors),\
	       ["set out '",outputFile,"'"]};

  elseif wait_for_q		# Not eps and -wait

    pre_cmd = {pre_cmd{:},\
	       "set mouse",\
	       "set mouse labels",\
	       "set mouse verbose"\
	       };

    pos_cmd = {pos_cmd{:},\
	       "pause -1"};

    ## FIXME: gnuplot croaks w/ warning: Mousing not active, even if I've set mouse..
    ##       "pause mouse keypress"};

    ## This hack does not work either
    #,\	       "if (MOUSE_KEY != 113) reread"};

  else				# Neither eps nor -wait
    gnuplot_options = " -persist ";
  endif
  g = _g_instantiate (g,varargin{find(keep)});


  cmd_str = sprintf ("%s\n",pre_cmd{:},g.cmds{:},pos_cmd{:});

  ## Redundant w/ geometry treatment above?
  if !isempty (geometry)
    if !ischar (geometry),
      opt_str = sprintf ("%ix%i",geometry);
    else
      opt_str = geometry;
    endif
    gnuplot_options = [gnuplot_options," -geometry ",opt_str," "];
    
  elseif struct_contains (g.values, "geometry")
    if !ischar (g.values.geometry),
      opt_str = sprintf ("%ix%i",g.values.geometry);
    else
      opt_str = g.values.geometry;
    endif
    gnuplot_options = [gnuplot_options," -geometry ",opt_str," "];
  endif

  ## Hack for png font
  if do_png, cmd_str = strrep (cmd_str, "Times-Roman",""); endif
  cmdfname = [g.dir,"/cmds.plt"];
  [fid, msg] = fopen (cmdfname,"w");
  if fid<0, 
    error ("Can't open command file '%s': %s", cmdfname, msg); 
  endif
  fprintf (fid,"cd '%s'\n",g.dir);
  fprintf (fid, "%s", cmd_str);
  fclose (fid);

  ##system (["cat ",cmdfname]);
  gnuplot_command = [g_config("gnuplot_program")," ",gnuplot_options,\
		     " ",cmdfname];
  
  output_file = [g.dir,"/gnuplot-output.txt"];
  gnuplot_command = [gnuplot_command, " 2>&1 | tee ",output_file];

  status = system (gnuplot_command);
  [status2, msg] = system (["cat ",output_file]);

  if !status

    tokens = regexp (msg, 'put\D*([\+\-\d\.]+)\D+([\+\-\d\.]+)', "tokens");
    if length (tokens)
      double_clicks = zeros (length (tokens),2);
      for i=1:length (tokens)
				# Strangely eval seems faster than str2double
	double_clicks(i,1) = eval (tokens{i}{1});
	double_clicks(i,2) = eval (tokens{i}{2});
      end
      ##if struct_contains (g, "double_clicks")
      ##g.double_clicks = [g.double_clicks; double_clicks];
      ##else
      ## Keep only clicks from last plot
      g.double_clicks = double_clicks;
      ##end
    end
    
    tokens = regexp (msg, 'set label\D*([\+\-\d\.]+)\D+([\+\-\d\.]+)', "tokens");
    if length (tokens)
      middle_clicks = zeros (length (tokens),2);
      for i=1:length (tokens)
				# Strangely eval seems faster than str2double
	middle_clicks(i,1) = eval (tokens{i}{1});
	middle_clicks(i,2) = eval (tokens{i}{2});
      end
      ##if struct_contains (g, "middle_clicks")
      ##g.middle_clicks = [g.middle_clicks; middle_clicks];
      ##else
      ## Keep only clicks from last plot
      g.middle_clicks = middle_clicks;
      ##end
    end

  else
    printf ("Couldn't run gnuplot: Exited, saying \n%s\n",msg);
    #keyboard
  endif

  if do_display 
    if do_eps 
      [status, msg] = system ([g_config("eps_viewer")," ",outputFile]);
      if status
	error ("Couldn't run %s: Exited, saying \n%s\n",eps_viewer, msg);
      endif
    elseif do_fig
      [status, msg] = system (["xfig ",outputFile]);
      if status
	error ("Couldn't run xfig: Exited, saying \n%s\n",msg);
      endif
    elseif do_png
      [status, msg] = system ([g_config("png_viewer")," ",outputFile]);
      if status
	error ("Couldn't run %s: Exited, saying \n%s\n",png_viewer, msg);
      endif
    endif
  endif
  ##keyboard
  if nargout<1, clear g; endif
endfunction

