### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function g = g_set (g, varargin)
### g = g_set (g, key, value, ...)      - Set values.(key) = value
###
### Used values:
### "title",    string         : Title of the plot. Used (only; TODO; should be
###                              used always) if this plot is later inserted in
###                              another plot.
###
### "geometry", "WxH" or [W,H] : Geometry of plot, used by g_plot.
###
### See also: g_new,...
  _g_check (g);
  i = 1;
  while i < length (varargin)
    key = varargin{i++};
    value = varargin{i++};
    g.values.(key) = value;
  endwhile
endfunction

