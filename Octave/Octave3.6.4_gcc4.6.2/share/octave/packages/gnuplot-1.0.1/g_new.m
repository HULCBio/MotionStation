### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function g = g_new (varargin)
### g = g_new ( ...)            - Create a new gnuplot_object and its directory
###
### The g_XYZ() functions allow Octave to create plots with Gnuplot. They
### are little more than an Octave front-end to Gnuplot, but allow to do
### anything Gnuplot can do directly from Octave. In addition, there are some
### commodity functions (g_cmd() with struct arg, g_locate()) that allow to nest
### one figure in another.
###
### g_new() creates a temporary directory in which data and commands will be
### stored in a gnuplot-readable format.
###
### g_new accepts key, value pairs of arguments, which will be passed to g_set.
###
### Typical usage:
###
### g = g_new  (<my options, e.g. on how to display>)
### g = g_data (g, "myChosenDataFileName", data, ...)
### g = g_cmd  (g, <gnuplot commands, e.g.>,\
###                "plot 'myChosenDataFileName' with lines",...);
### g_plot     (g,<options on how to plot, e.g. to file>);
###
###
### DEMO: Run g_demo(), or see http://gnuplot.sourceforge.net/demo_4.1 on how to
###       do nice plots.
### 
### SEE ALSO: g_ez, g_delete, g_data, g_cmd, g_plot, g_set, g_locate.
###
### TODO: an OO style of function call (see failed attempt at end of g_new code)
  g.type =   "gnuplot_object";
  g.cmds =    {};		# Gnuplot commands
  g.owns =   {};		# Directories of other gnuplot_objects that have
				# been added to g, and must be cleaned when g is
				# deleted.
  g.dir =    tmpnam();		# Directory that contains g's data etc
  g.values = struct();		# Plot variables, e.g. "geometry", "title"

  g =        g_set (g, varargin{:});

  if !mkdir (g.dir),
    error ("Couldn't create '%s'",g.dir);
  endif

  mypid =  getpid();
  pidfname = sprintf ("%s/PID-%i.txt", g.dir, mypid);
  [fid, msg] = fopen (pidfname,"w");
  if fid<0, 
    error ("Can't open pid file '%s': %s", pidfname, msg); 
  endif
  fprintf (fid,"%i\n", mypid);
  fclose (fid);

  ##printf ("Created g at '%s'\n",g.dir);

  #g.plot = inline ("g_plot (g,varargin{:})");
  #g.data = inline ("g_data (g,varargin{:})");
  #g.cmd =  inline ("g_cmd (g,varargin{:})");
endfunction
