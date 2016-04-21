### Copyright (c) 2007, Tyzx Corporation. All rights reserved.

function g = g_locate (g, newloc)
### g = g_locate (g, [posx, posy, width, height]) - Set the origin and size of g
###
### This function replaces all "set scale W,H" by  "set scale width*W,height*H"
### and "set origin X,Y" by "set origin posx+height*X,posy+widthY".
###
### See also: g_new,...

  _g_check (g);

  ##printf ("Re-locating g at '%s'\n",g.dir);

  found_origin = found_size = 0;
  for i = 1:length (g.cmds)
    [dums,dume,dumte,dumm,toks] = \
	regexp (g.cmds{i}, '^set\s*(origin|size)\s*([^,\s]+)\s*,\s*([^,\s]+)');
    if length (toks)
      args = [str2num(toks{1}{2}), str2num(toks{1}{3})];

      if     strcmp (toks{1}{1}, "origin")
	found_origin = 1;
	args = args .* newloc(3:4) + newloc(1:2);
      elseif strcmp (toks{1}{1}, "size")
	found_size =   1;
	args = args .* newloc(3:4);
      else   
	error ("First token isn't what I thought, but '%s'",toks{1}{1});
      endif
      g.cmds{i} = sprintf ("set %s %g,%g",toks{1}{1}, args);
    endif
  endfor

  if ! found_size && any ((newloc(1:2)) || any (newloc(3:4)!= 1))
    g.cmds = {sprintf("set size %g,%g",newloc(3:4)),\
	     g.cmds{:}};
  endif
  if ! found_origin && any (newloc(3:4)!= 1)
    g.cmds = {sprintf("set origin %g,%g",newloc(1:2)),\
	     g.cmds{:}};
  endif
  
endfunction

