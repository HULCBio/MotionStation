### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function g = g_delete (g)
### g = g_delete (g)             - Delete a gnuplot_object and its directory
###     g_delete ()                Delete all gnuplot_object directories 
###     g_delete ("all")           Delete all gnuplot_object directories 
###     g_delete ("siblings")      Delete all gnuplot_object directories created
###                                by this octave process
###
### TODO: A mechanism to make sure no directories are forgotten (disk
###       leaks, as in "memory leaks") and that no dir gets deleted spuriously
###       (that side is ok now. Just do g_delete() now and then).
###
  if !nargin, g = "all"; endif

  if ischar (g)			# Clear all directories I'm allowed to clear
    if strcmp (g, "all")
      allpidfiles = glob ("/tmp/oct-*/PID-*.txt")
    elseif strcmp (g, "sib") || strcmp (g, "siblings") 
      allpidfiles = glob (sprintf("/tmp/oct-*/PID-%i.txt",getpid()))
    else
      error ("unknown string argument '%s'",g);
    end
    for i = 1:length(allpidfiles)
      tmp = allpidfiles{i};
      j = rindex (tmp, "/");
      system (["rm -f ",tmp(1:j),"*"]);
      system (["rmdir ",tmp(1:j-1)]);
    endfor
  else
    _g_check (g);
    
    if exist (g.dir, "dir")
      system (["rm -f ",g.dir,"/*"]);
      system (["rmdir ",g.dir]);
    endif
    for i = 1:length(g.owns)
      if exist (g.owns{i}, "dir")
	system (["rm -f ",g.owns{i},"/*"]);
	system (["rmdir ",g.owns{i}]);
      endif
    endfor
    g = struct();
  end
  if !nargout, clear g; endif
endfunction
