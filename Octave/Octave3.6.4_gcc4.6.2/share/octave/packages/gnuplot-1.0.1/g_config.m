### VALUE = g_config (NAME, [, NEW_VALUE]) - Get/set settings of g_XYZ functions
###
### NAME can be one of
###
###    "gnuplot_version"  : Gnuplot version, e.g. [MAJOR, MINOR, PATCHLEVEL] 
###                         This parameter cannot be set.
###    "gnuplot_program"  : Gnuplot program that is called in g_plot()
###                         Default is "gnuplot"
###    "eps_viewer" and "png_viewer" : Programs called to view eps or png plots.
###                         Defaults are "gv" and "eog".

function res = g_config (varargin)

persistent g_config_struct = \
    struct ("gnuplot_program", "gnuplot",\
	    "png_viewer",  "eog",\
	    "eps_viewer",  "gv",\
	    "gnuplot_version", nan);

if all (numel (varargin) != [1 2])
  help g_config
  return
end

switch varargin{1}
  case {"gnuplot_program", "png_viewer", "eps_viewer"}

    varName = varargin{1};

				# Reset gnuplot_version if needed
    if strcmp (varName, "gnuplot_program") && !strcmp (varName, g_config_struct.gnuplot_program)
      gnuplot_version = nan;
    end

    if numel (varargin) > 1
      g_config_struct.(varName) = varargin{2};
    end
    res = g_config_struct.(varName);
  case "gnuplot_version"
    if numel (varargin) > 1
      error ("gnuplot_version cannot be set");
    end
    if isnan (g_config_struct.gnuplot_version)
      g_version_cmd = [g_config_struct.gnuplot_program, " --version"];
      [status, output] = system (g_version_cmd);
      if status
	error ("Can't run '%s'", g_version_cmd)
      end
      if output(end) == "\n"
        output = output (1:end-1);
      end
      va =  toascii (output);
      va(va < toascii("0") | va > toascii("9")) = toascii (" ");
      try
	vn = eval (["[", char(va),"]"]);
      catch
	error ("Can't get gnuplot version number from output '%s'", output)
      end
      g_config_struct.gnuplot_version = vn;
      if numel (vn) < 2
	error ("Gnuplot version looks strange: '%s'", output);
      end
    end
    res = g_config_struct.gnuplot_version;
  otherwise
    help g_config
    error (["Don't know what to do with ", varargin{1}])
endswitch


				  