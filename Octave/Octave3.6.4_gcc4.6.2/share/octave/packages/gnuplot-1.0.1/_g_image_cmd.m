## [fmt, extra, i, zrange] = _g_image_cmd (sz, zrange, args, va)
##
## sz     = [H W] or [H W 3] image size
## zrange = [min, max]       range of greylevel/RGB values
## args     struct w/ current defaults
## va       extra options
##       "range" ,  r: replace zrange
##       "xrange",  r: Define region in which image is drawn
##       "yrange",  r:
##       "xyrange", r:
##       "colormap" yesno : map greylevels to color
## 
## fmt   : Gnuplot plot argument
## extra : Gnuplot pre-plot argument
## i     : Number of arguments used in va.
function [fmt, extra, i, zrange] = _g_image_cmd (sz, zrange, args, va)

if ! struct_contains (args, "xrange")
  args.xrange = [0,sz(2)];
end

if ! struct_contains (args, "yrange")
  args.yrange = [0,sz(1)];
end

grange =   [];			# Given range

colormap = 0;

flipx =  -1;
flipy =  -1;
is_col = -1;

i =       1;
done =    0;

while i <= length (va) && !done
  tmp = va{i};
  if ! ischar (tmp), break; end
  switch tmp
    case "flipx",    flipx =       va{++i};
    case "flipy",    flipy =       va{++i};
    case "range",    grange =      zrange = va{++i};
    case "is_col",   is_col =      va{++i};
    case "xrange",   args.xrange = va{++i};
    case "yrange",   args.yrange = va{++i};
    case "xyrange",  args.yrange = args.xrange = va{++i};
    case "colormap", colormap =    va{++i};
    otherwise       break;
  end
  i++;  
endwhile
i--;

if is_col == -1
  is_col =    length (sz) == 3;
end
title_str = "";

xr = args.xrange;
yr = args.yrange;

s1 = sprintf (" binary array=%ix%i ", sz([2 1]));
if flipx >= 0
  if flipx
    s1 = [s1,"flipx "];
  end
end 
if xr(2) < xr(1)
  xr = xr([2 1]);
  if flipx < 0, s1 = [s1,"flipx "]; end
end

if flipy >= 0
  if ! flipy
    s1 = [s1,"flipy "];
  end
end 
if yr(2) > yr(1)
  if flipy < 0, s1 = [s1,"flipy "]; end
else
  yr = yr([2 1]);
end

s2 = sprintf (" origin=(%g,%g) ",\
	      xr(1) + 0.5*diff(xr)/sz(2), \
	      yr(1) + 0.5*diff(yr)/sz(1));
s3 = sprintf (" dx=%g dy=%g ",\
	      (xr(2)-xr(1))/sz(2),\
	      (yr(2)-yr(1))/sz(1));

s4 = " format='%uchar' ";

if !is_col
  s5 = sprintf (" using (%g*$1/255+%g) ",\
		diff(zrange), zrange(1));
  s6 = [" with image "];

else
  s5 = sprintf (" using (%g*$1/255+%g):(%g*$2/255+%g):(%g*$3/255+%g) ",\
		[diff(zrange);zrange(1)]*[1 1 1]);
  s6 = [" with rgbimage "];
end
s7 = sprintf (" title '%s' ", title_str);


fmt = [s1 s2 s3 s4 s5 s6 s7];

extra = {};
if !colormap,
  extra = {extra{:}, "set palette gray"};
end
if !isempty (grange)
  extra = {extra{:}, sprintf("set cbrange [%g:%g]",grange)};
end
