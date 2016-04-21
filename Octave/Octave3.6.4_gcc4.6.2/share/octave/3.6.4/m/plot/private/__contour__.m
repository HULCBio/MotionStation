## Copyright (C) 2007-2012 David Bateman
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{c}, @var{hg}] =} __contour__ (@dots{})
## Undocumented internal function.
## @end deftypefn

function [c, hg] = __contour__ (varargin)
  ax = varargin{1};
  zlevel = varargin{2};
  filled = "off";

  linespec.linestyle = "-";
  linespec.color = "auto";
  edgecolor = "flat";
  for i = 3 : nargin
    arg = varargin {i};
    if ((ischar (arg) || iscell (arg)))
      [linespec, valid] = __pltopt__ ("__contour__", arg, false);
      if (isempty (linespec.color))
        linespec.color = "auto";
      endif
      if (isempty (linespec.linestyle))
        linespec.linestyle = "-";
      endif
      if (valid)
        have_line_spec = true;
        varargin(i) = [];
        break;
      endif
    endif
  endfor

  opts = {};
  i = 3;
  while (i < length (varargin))
    if (ischar (varargin {i}))
      if (strcmpi (varargin{i}, "fill"))
        filled = varargin {i + 1};
        varargin(i:i+1) = [];
      elseif (strcmpi (varargin{i}, "linecolor"))
        linespec.color = varargin {i + 1};
        edgecolor = linespec.color;
        if (ischar (edgecolor) && strcmpi (edgecolor, "auto"))
          edgecolor = "flat";
        endif
        varargin(i:i+1) = [];
      elseif (strcmpi (varargin{i}, "edgecolor"))
        linespec.color = varargin {i + 1};
        edgecolor = linespec.color;
        if (ischar (edgecolor) && strcmpi (edgecolor, "flat"))
          linespec.color = "auto";
        endif
        varargin(i:i+1) = [];
      else
        opts{end+1} = varargin{i};
        varargin(i) = [];
        opts{end+1} = varargin{i};
        varargin(i) = [];
      endif
    else
      i++;
    endif
  endwhile

  if (length(varargin) < 5)
    z1 = varargin{3};
    x1 = 1 : columns(z1);
    y1 = 1 : rows(z1);
  else
    x1 = varargin{3};
    y1 = varargin{4};
    z1 = varargin{5};
  endif
  if (!ismatrix (z1) || isvector (z1) || isscalar (z1))
    error ("__contour__: z argument must be a matrix");
  endif
  if (length (varargin) == 4 || length (varargin) == 6)
    vn = varargin {end};
    vnauto = false;
  else
    vnauto = true;
    vn = 10;
  endif

  if (isscalar (vn))
    lvl = linspace (min (z1(!isinf(z1))), max (z1(!isinf(z1))),
                    vn + 2)(1:end-1);
  else
    lvl = vn;
  endif

  if (strcmpi (filled, "on"))
    if (isvector (x1) || isvector (y1))
      [x1, y1] = meshgrid (x1, y1);
    endif
    [nr, nc] = size (z1);
    x0 = prepad(x1, nc+1, 2 * x1(1, 1) - x1(1, 2), 2);
    x0 = postpad(x0, nc+2, 2 * x1(1, nc) - x1(1, nc - 1), 2);
    x0 = [x0(1, :); x0; x0(1, :)];
    y0 = prepad(y1, nr+1, 2 * y1(1, 1) - y1(2, 1), 1);
    y0 = postpad(y0, nr+2, 2 * y1(nr, 1) - y1(nr - 1, 1));
    y0 = [y0(:, 1), y0, y0(:, 1)];
    z0 = -Inf(nr+2, nc+2);
    z0(2:nr+1, 2:nc+1) = z1;
    [c, lev] = contourc (x0, y0, z0, lvl);
  else
    [c, lev] = contourc (x1, y1, z1, lvl);
  endif

  hg = hggroup ();
  opts = __add_datasource__ ("__countour__", hg, {"x", "y", "z"}, opts{:});

  addproperty ("xdata", hg, "data", x1);
  addproperty ("ydata", hg, "data", y1);
  addproperty ("zdata", hg, "data", z1);
  addproperty ("contourmatrix", hg, "data", c);

  addlistener (hg, "xdata", @update_data);
  addlistener (hg, "ydata", @update_data);
  addlistener (hg, "zdata", @update_data);
  addlistener (hg, "contourmatrix", @update_data);

  addproperty ("fill", hg, "radio", "on|{off}", filled);

  ## The properties zlevel and zlevelmode don't exist in matlab, but
  ## allow the use of contourgroups with the contour3, meshc and surfc
  ## functions.
  if (isnumeric (zlevel))
    addproperty ("zlevelmode", hg, "radio", "{none}|auto|manual", "manual");
    addproperty ("zlevel", hg, "data", zlevel);
  else
    addproperty ("zlevelmode", hg, "radio", "{none}|auto|manual", zlevel);
    if (ischar (zlevel) && strcmpi (zlevel, "manual"))
      z = varargin{3};
      z = 2 * (min (z(:)) - max (z(:)));
      addproperty ("zlevel", hg, "data", z);
    else
      addproperty ("zlevel", hg, "data", 0.);
    endif
  endif

  lvlstep = sum (abs (diff (lvl))) / (length (lvl) - 1);

  addproperty ("levellist", hg, "data", lev);
  addproperty ("levelstep", hg, "double", lvlstep);
  if (vnauto)
    addproperty ("levellistmode", hg, "radio", "{auto}|manual", "auto");
    addproperty ("levelstepmode", hg, "radio", "{auto}|manual", "auto");
  elseif (isscalar (vn))
    addproperty ("levellistmode", hg, "radio", "{auto}|manual", "auto");
    addproperty ("levelstepmode", hg, "radio", "{auto}|manual", "manual");
  else
    addproperty ("levellistmode", hg, "radio", "{auto}|manual", "manual");
    addproperty ("levelstepmode", hg, "radio", "{auto}|manual", "auto");
  endif

  addproperty ("labelspacing", hg, "double", 144);
  addproperty ("textlist", hg, "data", lev);
  addproperty ("textlistmode", hg, "radio", "{auto}|manual", "auto");
  addproperty ("textstep", hg, "double", lvlstep);
  addproperty ("textstepmode", hg, "radio", "{auto}|manual", "auto");
  addproperty ("showtext", hg, "radio", "on|{off}", "off");

  addproperty ("linecolor", hg, "color", linespec.color, "{auto}|none");
  addproperty ("linestyle", hg, "linelinestyle", linespec.linestyle);
  addproperty ("linewidth", hg, "linelinewidth", 0.5);

  ## FIXME It would be good to hide this property which is just an undocumented
  ## alias for linecolor
  addproperty ("edgecolor", hg, "color", edgecolor, "{flat}|none");

  addlistener (hg, "fill", @update_data);

  addlistener (hg, "zlevelmode", @update_zlevel);
  addlistener (hg, "zlevel", @update_zlevel);

  addlistener (hg, "levellist", @update_data);
  addlistener (hg, "levelstep", @update_data);
  addlistener (hg, "levellistmode", @update_data);
  addlistener (hg, "levelstepmode", @update_data);

  addlistener (hg, "labelspacing", @update_text);
  addlistener (hg, "textlist", @update_text);
  addlistener (hg, "textlistmode", @update_text);
  addlistener (hg, "textstep", @update_text);
  addlistener (hg, "textstepmode", @update_text);
  addlistener (hg, "showtext", @update_text);

  addlistener (hg, "linecolor", @update_line);
  addlistener (hg, "linestyle", @update_line);
  addlistener (hg, "linewidth", @update_line);

  addlistener (hg, "edgecolor", @update_edgecolor);

  add_patch_children (hg);

  axis("tight");

  if (!isempty (opts))
    set (hg, opts{:});
  endif
endfunction

function add_patch_children (hg)
  c = get (hg, "contourmatrix");
  lev = get (hg, "levellist");
  fill = get (hg, "fill");
  zlev = get (hg, "zlevel");
  zmode = get (hg, "zlevelmode");
  lc = get (hg, "linecolor");
  lw = get (hg, "linewidth");
  ls = get (hg, "linestyle");
  filled = get (hg, "fill");
  ca = gca ();

  if (strcmpi (lc, "auto"))
    lc = "flat";
  endif

  if (strcmpi (filled, "on"))

    lvl_eps = get_lvl_eps (lev);

    ## Decode contourc output format.
    i1 = 1;
    ncont = 0;
    while (i1 < columns (c))
      ncont++;
      cont_lev(ncont) = c(1, i1);
      cont_len(ncont) = c(2, i1);
      cont_idx(ncont) = i1+1;
      ii = i1+1:i1+cont_len(ncont);
      cont_area(ncont) = polyarea (c(1, ii), c(2, ii));
      i1 += c(2, i1) + 1;
    endwhile

    ## Handle for each level the case where we have (a) hole(s) in a patch.
    ## Those are to be filled with the color of level below or with the
    ## background colour.
    for k = 1:numel (lev)
      lvl_idx = find (abs (cont_lev - lev(k)) < lvl_eps);
      len = numel (lvl_idx);
      if (len > 1)
        ## mark = logical(zeros(size(lvl_idx)));
        mark = false (size (lvl_idx));
        a = 1;
        while (a < len)
          ## take 1st patch
          b = a + 1;
          pa_idx = lvl_idx(a);
          ## get pointer to contour start, and contour length
          curr_ct_idx = cont_idx(pa_idx);
          curr_ct_len = cont_len(pa_idx);
          ## get contour
          curr_ct = c(:, curr_ct_idx:curr_ct_idx+curr_ct_len-1);
          b_vec = (a+1):len;
          next_ct_pt_vec = c(:, cont_idx(lvl_idx(b_vec)));
          in = inpolygon (next_ct_pt_vec(1,:), next_ct_pt_vec(2,:),
                          curr_ct(1, :), curr_ct(2, :));
          mark(b_vec(in)) = !mark(b_vec(in));
          a++;
        endwhile
        if (numel (mark) > 0)
          ## All marked contours describe a hole in a larger contour of
          ## the same level and must be filled with colour of level below.
          ma_idx = lvl_idx(mark);
          if (k > 1)
            ## Find color of level below.
            tmp = find(abs(cont_lev - lev(k - 1)) < lvl_eps);
            lvl_bel_idx = tmp(1);
            ## Set color of patches found.
            cont_lev(ma_idx) = cont_lev(lvl_bel_idx);
          else
            ## Set lowest level contour to NaN.
            cont_lev(ma_idx) = NaN;
          endif
        endif
      endif
    endfor

    ## The algorithm can create patches with the size of the plotting
    ## area, we would like to draw only the patch with the highest level.
    del_idx = [];
    max_idx = find (cont_area == max (cont_area));
    if (numel (max_idx) > 1)
      ## delete double entries
      del_idx = max_idx(1:end-1);
      cont_area(del_idx) = cont_lev(del_idx) = [];
      cont_len(del_idx) = cont_idx(del_idx) = [];
    endif

    ## Now we have everything together and can start plotting the patches
    ## beginning with largest area.
    [tmp, svec] = sort (cont_area);
    len = ncont - numel (del_idx);
    h = [];
    for n = len:(-1):1
      idx = svec(n);
      ctmp = c(:, cont_idx(idx):cont_idx(idx) + cont_len(idx) - 1);
      if (all (ctmp(:,1) == ctmp(:,end)))
        ctmp(:, end) = [];
      else
        ## Special case unclosed contours
      endif
      if (isnan(cont_lev(idx)))
        fc = get (ca, "color");
        if (strcmp (fc, "none"))
          fc = get (ancestor (ca, "figure"), "color");
        endif
      else
        fc = "flat";
      endif
      h = [h; __go_patch__(ca, "xdata", ctmp(1, :)(:), "ydata", ctmp(2, :)(:),
                           "vertices", ctmp.', "faces", 1:(cont_len(idx)-1),
                           "facevertexcdata", cont_lev(idx),
                           "facecolor", fc, "cdata", cont_lev(idx),
                           "edgecolor", lc, "linestyle", ls,
                           "linewidth", lw, "parent", hg)];
    endfor

    if (min (lev) == max (lev))
      set (ca, "clim", [min(lev)-1, max(lev)+1], "layer", "top");
    else
      set (ca, "clim", [min(lev), max(lev)], "layer", "top");
    endif
  else
    ## Decode contourc output format.
    i1 = 1;
    h = [];
    while (i1 < length (c))
      clev = c(1,i1);
      clen = c(2,i1);

      if (all (c(:,i1+1) == c(:,i1+clen)))
        p = c(:, i1+1:i1+clen-1).';
      else
        p = [c(:, i1+1:i1+clen), NaN(2, 1)].';
      endif

      switch (zmode)
        case "none"
          h = [h; __go_patch__(ca, "xdata", p(:,1), "ydata", p(:,2),
                               "zdata", [], "facecolor", "none",
                               "vertices", p, "faces", 1:rows(p),
                               "facevertexcdata", clev,
                               "edgecolor", lc, "linestyle", ls,
                               "linewidth", lw,
                               "cdata", clev, "parent", hg)];
        case "auto"
          h = [h; __go_patch__(ca, "xdata", p(:,1), "ydata", p(:,2),
                               "zdata", clev * ones(rows(p),1),
                               "vertices", [p, clev * ones(rows(p),1)],
                               "faces", 1:rows(p),
                               "facevertexcdata", clev,
                               "facecolor", "none", "edgecolor", lc,
                               "linestyle", ls, "linewidth", lw,
                               "cdata", clev, "parent", hg)];
        otherwise
          h = [h; __go_patch__(ca, "xdata", p(:,1), "ydata", p(:,2),
                               "zdata", zlev * ones (rows(p), 1),
                               "vertices", [p, zlev * ones(rows(p),1)],
                               "faces", 1:rows(p),
                               "facevertexcdata", clev,
                               "facecolor", "none", "edgecolor", lc,
                               "linestyle", ls, "linewidth", lw,
                               "cdata", clev, "parent", hg)];
      endswitch
      i1 += clen + 1;
    endwhile
  endif

endfunction

function update_zlevel (h, d)
  z = get (h, "zlevel");
  zmode = get (h, "zlevelmode");
  kids = get (h, "children");

  switch (zmode)
    case "none"
      set (kids, "zdata", []);
    case "auto"
      for i = 1 : length (kids)
        set (kids(i), "zdata", get (kids (i), "cdata") .*
             ones (size (get (kids (i), "xdata"))));
      endfor
    otherwise
      for i = 1 : length (kids)
        set (kids(i), "zdata", z .* ones (size (get (kids (i), "xdata"))));
      endfor
  endswitch
endfunction

function update_edgecolor (h, d)
  ec = get (h, "edgecolor");
  lc = get (h, "linecolor");
  if (ischar (ec) && strcmpi (ec, "flat"))
    if (! strcmpi (lc, "auto"))
      set (h, "linecolor", "auto");
    endif
  elseif (! isequal (ec, lc))
    set (h, "linecolor", ec);
  endif
endfunction

function update_line (h, d)
  lc = get (h, "linecolor");
  ec = get (h, "edgecolor");
  if (strcmpi (lc, "auto"))
    lc = "flat";
  endif
  if (! isequal (ec, lc))
    set (h, "edgecolor", lc);
  endif
  set (findobj (h, "type", "patch"), "edgecolor", lc,
       "linewidth", get (h, "linewidth"), "linestyle", get (h, "linestyle"));
endfunction

function update_data (h, d)
  persistent recursive = false;

  if (!recursive)
    recursive = true;

    delete (get (h, "children"));

    if (strcmpi (get (h, "levellistmode"), "manual"))
      lvl = get (h, "levellist");
    elseif (strcmpi (get (h, "levelstepmode"), "manual"))
      z = get (h, "zdata");
      lvl = ceil ((max(z(:)) - min (z(:)) ./ get (h, "levelstep")));
    else
      lvl = 10;
    endif

    if (strcmpi (get (h, "fill"), "on"))
      X = get (h, "xdata");
      Y = get (h, "ydata");
      Z = get (h, "zdata");
      if (isvector (X) || isvector (Y))
        [X, Y] = meshgrid (X, Y);
      endif
      [nr, nc] = size (Z);
      X0 = prepad(X, nc+1, 2 * X(1, 1) - X(1, 2), 2);
      X0 = postpad(X0, nc+2, 2 * X(1, nc) - X(1, nc - 1), 2);
      X0 = [X0(1, :); X0; X0(1, :)];
      Y0 = prepad(Y, nr+1, 2 * Y(1, 1) - Y(2, 1), 1);
      Y0 = postpad(Y0, nr+2, 2 * Y(nr, 1) - Y(nr - 1, 1));
      Y0 = [Y0(:, 1), Y0, Y0(:, 1)];
      Z0 = -Inf(nr+2, nc+2);
      Z0(2:nr+1, 2:nc+1) = Z;
      [c, lev] = contourc (X0, Y0, Z0, lvl);
    else
      [c, lev] = contourc (get (h, "xdata"), get (h, "ydata"),
                           get (h, "zdata"), lvl);
    endif
    set (h, "contourmatrix", c);

    if (strcmpi (get (h, "levellistmode"), "manual"))
      ## Do nothing
    elseif (strcmpi (get (h, "levelstepmode"), "manual"))
      set (h, "levellist", lev);
    else
      set (h, "levellist", lev);
      z = get (h, "zdata");
      lvlstep = (max(z(:)) - min(z(:))) / 10;
      set (h, "levelstep", lvlstep);
    endif

    add_patch_children (h);
    update_text (h, d);
  endif

  recursive = false;
endfunction

function update_text (h, d)
  persistent recursive = false;

  if (!recursive)
    recursive = true;

    delete (findobj (h, "type", "text"));

    if (strcmpi (get (h, "textlistmode"), "manual"))
      lvl = get (h, "textlist");
    elseif (strcmpi (get (h, "textstepmode"), "manual"))
      lev = get (h, "levellist");

      lvl_eps = get_lvl_eps (lev);

      stp = get (h, "textstep");
      t = [0, floor(cumsum(diff (lev)) / (abs(stp) - lvl_eps))];
      lvl = lev([true, t(1:end-1) != t(2:end)]);
      set (h, "textlist", lvl);
    else
      lvl = get (h, "levellist");
      set (h, "textlist", lvl, "textstep", get (h, "levelstep"));
    endif

    if (strcmpi (get (h, "showtext"), "on"))
      switch (get (h, "zlevelmode"))
        case "manual"
          __clabel__ (get (h, "contourmatrix"), lvl, h,
                      get (h, "labelspacing"), get (h, "zlevel"));
        case "auto"
          __clabel__ (get (h, "contourmatrix"), lvl, h,
                      get (h, "labelspacing"), "auto");
        otherwise
          __clabel__ (get (h, "contourmatrix"), lvl, h,
                      get (h, "labelspacing"), []);
      endswitch
    endif

    recursive = false;
  endif
endfunction

function lvl_eps = get_lvl_eps (lev)
  ## FIXME -- is this the right thing to do for this tolerance?  Should
  ## it be an absolute or relative tolerance, or switch from one to the
  ## other depending on the value of lev?
  if (isscalar (lev))
    lvl_eps = abs (lev) * sqrt (eps) + sqrt (eps);
  else
    tmp = min (abs (diff (lev)));
    if (tmp < 10*eps)
      lvl_eps = sqrt (eps);
    else
      lvl_eps = tmp / 1000.0;
    endif
  endif
endfunction
