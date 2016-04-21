## Author: Paul Kienzle
## This program is public domain.
function tclphoto(name,expr)
  ## grab the colormap and convert it to uchar
  map=floor(256*(1-eps)*colormap);

  ## clip the image levels to the range of the colormap
  expr(expr<1) = 1;
  expr(expr>rows(map)) = rows(map);

  ## send the image to tcl as a PPM data string
  ## image is stored in the matrix as level one column at a time, bottom to top
  ## image is stored in PPM as RGB one row at a time, top to bottom
  send('::octave::RGBdata', char(map(flipud(expr)',:)'(:)'));

  [r,c] = size(expr);
  send(sprintf('imagefromppm %s "P6 %d %d 255\n$::octave::RGBdata"', 
	       name, c, r));
endfunction
