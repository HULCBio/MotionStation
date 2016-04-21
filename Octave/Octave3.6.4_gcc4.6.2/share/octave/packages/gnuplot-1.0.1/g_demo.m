### Copyright (c) 2007, Tyzx Corporation. All rights reserved.
function g_demo ()
### g_demo()                     - Show a few plots created by g_XYZ
###
### See also: g_new, demo g_ez, etc..

  save_snapshots =     0;
  g_demo_plot_cnt =    0;
  plot_extras =        {};
  image_tpl =          "g_demo_plots-%i.eps"

  printf ("Plotting two dashed circles w/ a connection\n");
  printf ("\n\tNote: You may need to resize the window to see the plots\n\n");

  gg = g_new("COL",3,"geometry",[256,256]);
  tt = linspace (0,2*pi,65); xx = [sin(tt);cos(tt)]';
  gg = g_data (gg,"-join","-step",3,"x",xx,xx/2);
  gg = g_cmd (gg,"set xrange [-1.1:1.1]");
  gg = g_cmd (gg,"set yrange [-1.1:1.1]");
  gg = g_cmd (gg,"set title \"Two dashed circles w/ a connection\"");
  ## Example of token substitution and printf directive
  gg = g_cmd (gg,"printf:plot 'x' w lp lc <COL> lw %i  pt 7 ps 4 ",3,"/printf:");
  ##gg = g_cmd (gg,"plot 'x' w lp ls <COL>");
  ## ls(gg.dir)

  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (gg, "-wait","COL",2, plot_extras{:});
  ##system (["less ",gg.dir,"/x"])
  printf ("Don't forget to close the plot window\n");
  printf ("Hit any key for the next plot\n");
  pause;
  hh = g_new("geometry","640x330");
  hh = g_cmd (hh,\
	      "pr:1:set multiplot  title \"Two (%i) of the same\"", 2,\
	      "set size 0.5,0.9",\
	      "set origin 0,0",\
	      _g_instantiate (gg,"COL",1),\
	      "set origin 0.5,0",\
	      gg,\
	      "set size 1,1",\
	      "set origin 0,0"\
	      );
  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (hh, "-wait",plot_extras{:});
  pause
  ff = g_new("geometry","400x400");
  ff = g_cmd (ff,\
	      "pr:1:set multiplot  title \"Four (%i) of the same\"", 4,\
	      g_locate (_g_instantiate (gg,"COL",1),[0.0,  0.0, 0.45, 0.45]),\
	      g_locate (_g_instantiate (gg,"COL",2),[0.55, 0.0, 0.45, 0.45]),\
	      g_locate (_g_instantiate (gg,"COL",3),[0.0,  0.5, 0.45, 0.45]),\
	      g_locate (_g_instantiate (gg,"COL",4),[0.55, 0.5, 0.45, 0.45])\
	      );
  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (ff, "-wait", plot_extras{:});
  pause

  printf ("Plotting surfaces");
  [xx,yy] = meshgrid (linspace (-3*pi,3*pi,51));
  zz = sin (sqrt (xx.^2 + yy.^2)) ./ (sqrt (xx.^2 + yy.^2));
  zz(isnan(zz)) = 1;
  ## zz = cos (2*pi*xx) .* (1-yy.^3) - yy.^2;
  ii = g_new ();
  ii = g_data (ii, "-step",51, "mygrid", [xx(:),yy(:),zz(:)]);
  ii = g_cmd (ii, "set hidden3d", "splot 'mygrid' w lines");
  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (ii, "-wait",plot_extras{:});

  
  jj = g_new ("wait",1);
  jj = g_data (jj, "mygrid", zz);
  jj = g_cmd (jj, "set hidden3d", "splot 'mygrid' matrix w pm3d, 'mygrid' matrix w lines title ''");
  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (jj,plot_extras{:});

  printf ("Plotting images in 2D and 3D");
  imgdata = 64*kron(ones(4), eye(2)) + linspace(0,128,8)'*ones(1,8);

  kk = g_new ("wait",1,"geometry",[400,400]);
  kk = g_data(kk, "-uint8","checker",imgdata);
  kk = g_cmd (kk, \
	      "set palette gray",\
	      "set title 'Binary array: Checkerboard seen in 2D'",\
	      "plot 'checker' binary array=8x8 flipy format='%uchar' with image",\
	      "pause  1",\
	      "pause -1",\
	      "set title 'Binary array: Checkerboard seen in 3D'",\
	      "splot [0:9] [0:9] 'checker' binary array=8x8 flipy perp=(0,1,0) center=(4,4,4) format='%uchar' with image");

  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (kk,plot_extras{:});

  

  ll = g_new ("wait",1);
  ll = g_data(ll, "sombrero",zz);
  ll = g_cmd (ll, \
	      "set palette gray",\
	      "set title 'Image saved as text matrix: Sombrero'",\
	      "splot [-25:25] [-25:25] 'sombrero' matrix using ($1-25):($2-25):($3) with image");

  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (ll,plot_extras{:});

  zrgb = reshape ([zz(:),-zz(:),abs(zz(:))]',size(zz).*[3,1]);
  zrgb -= min(zrgb(:));
  zrgb *= 255/max(zrgb(:));
  mm = g_new ("wait",1);
  mm = g_data(mm, "-uint8","sombrero",zrgb);
  mm = g_cmd (mm, \
	      "set title 'Image saved as text matrix: Sombrero'",\
	      "plot 'sombrero' binary array=51x51 origin=(-25,-25) format='%uchar%uchar%uchar' with rgbimage");

  if save_snapshots
    plot_extras = {sprintf(image_tpl, g_demo_plot_cnt++)};
  end
  g_plot (mm,plot_extras{:});


  g_delete (gg);
  g_delete (hh);
  g_delete (ff);
  g_delete (ii);
  g_delete (jj);
  g_delete (kk);
  g_delete (ll);
  g_delete (mm);

  if save_snapshots
    all_figs = sprintf ([image_tpl,"  "],1:g_demo_plot_cnt-1);
    printf ("Viewing saved figures %s\n",all_figs);
    system (["eog ", all_figs]);
  end

endfunction

