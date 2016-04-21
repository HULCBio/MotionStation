## im2 = myimage (im,...) - Make im viewable by normalizing greylevels and more
##
## Scales the values of im so that they range in [0,255]. The smallest element
## of im (or range(1), if the "range" option is used) is mapped to zero, and the
## largest (or range(2)) is mapped to 255.
##
## If both dimensions are less than 180, 
##
## If the save option is not used, and nargout is 0, then im2 will be displayed,
## rather than returned. NaN and Inf pixels become black or, if the image is
## saved as a .png or .gif, transparent.
## 
## OPTIONS:
## --------
## "range", [min,max]   : Graylevel range to be mapped to 0:255. 
##                                              Default:[min(im(:)),max(im(:))]
## "qrange", [minq,maxq]: Map quantiles between minq and maxq to 0 and 255.
## "minsz", [Rows,Cols] : Minimum dims of im2. im will be scale by an integral
##                        factor so that at least one of its dimensions matches
##                        minsz.                Default: [180 180]
## "scl",   scl         : Scale image size up (scl>1) or down (scl<1)
## "invert"             : Invert image (black becomes white and vice versa).
##
## "is_col"             : Color image, consecutive rows being R, G and B.
## "colormap",          : Convert greylevel image to a 'rainbow' colormap
##
## "show_range"         : Place a graylevel scale below image.
## "scale_sz",sz        : Width of graylevel scale. Implies show_range.
##
## "text", [x,y], str   : Annotate image with str, at position x,y, with size sz
## "text", [x,y,sz],str     
## "line", [x,y,x,y,R,G,B,W] or
## "line", [x,y,x,y,R,G,B]   or
## "line", [x,y,x,y,C,W]     or
## "line", [x,y,x,y,C]       or
## "line", [x,y,x,y]  
##
## "save",    filename  : Save im2 in filename.
## "display", yesno     : Display im2 or not. Default: False iff save requested
##                        or nargout!=0. 
##
## EXAMPLES: type "demo myimage" to run the examples below
## ---------
## myimage (randn(3,3),                    "show_range")
## myimage (rand(9,3),                     "is_col")
## myimage (randn(32,32),                  "minsz",[32,50])
## myimage (ones(64,1)*linspace(0,1,256),  "colormap")
## myimage (linspace(0,3,256)'*ones(1,64), "range",[3 1])
## myimage (zeros(200,200), "text",[10,20],">> 1 + pi\nans = 4.1416\n>>")
##
## im = kron (ones(4), kron (eye(2),ones(10)));
## im += ones (80,1)*linspace(0,1/2,80);
## myimage (im,"text",[11,5],"Hello","text", [10,30,30],"world")
##
## FIXME: scl < 1 seems to be buggy

### Author Etienne Grossmann <etienne@isr.ist.utl.pt>
function im = myimage (im, varargin)

##viewer = "qiv";			# If I need to display image
##viewer = "feh";
##viewer = "display";
viewer = "eog";

is_col = 0;
invert = 0;
sameScale = 1;			# Use same greylevel scale for R, G and B
show_range = 0;
scale_sz = 0;
vrange = [];
qrange = [];
minsz = 180;
maxsz = 640;
colormap = 0;
filename = 0;
text = {};
line = {};
do_show = !nargout;
dont_wait = "";
roi = [];
scl = nan;

if nargin > 1

  cnt = 1;
				# For compat w/ old style
  if ! ischar (varargin{cnt}), is_col = varargin{cnt++}; end
  while cnt <= length (varargin)

    opt = varargin{cnt++};
    if ! ischar (opt)
      error ("Expecting option name, got a %s",typeinfo(opt))
    endif
    switch opt
      case "scl",        scl      = varargin{cnt++};
      case "ROI",        roi      = varargin{cnt++};
      case "save",       filename = varargin{cnt++};
      case "range",      vrange   = varargin{cnt++};
      case "qrange",     qrange   = varargin{cnt++};
      case "minsz",      minsz    = varargin{cnt++};
      case "do_show",    do_show  = varargin{cnt++};
      case "viewer",     viewer   = varargin{cnt++}; do_show = 1; 
      case "display",    viewer   = "display"; do_show = 1; 
      case "gimp",       viewer   = "gimp";    do_show = 1; dont_wait = "&";
      case "qiv",        viewer   = "qiv";     do_show = 1; dont_wait = "&";
	if cnt<=length(varargin) && isnumeric(varargin{cnt})
	  printf ("Warning: option 'display' now takes no arg\n");
	end
      case "invert",     invert   = 1;
      case "is_col",     is_col   = 1;
      case "colormap",   colormap = 1;
	if cnt<=length(varargin) && isnumeric(varargin{cnt})
	  colormap = varargin{cnt++};
	  if columns (colormap) != 3
	    error ("colormap's optional argument has %i != 3 columns", columns(colormap));
	  end
	  colormap /= max (colormap(:));
	end
      case "show_range", show_range = 1;
      case "scale_sz",   show_range = 1; scale_sz = varargin{cnt++};
      case "circle",     circle   = {circle{:},varargin{cnt++}};
      case "line",       line     = {line{:},varargin{cnt++}};
      case "text",       text     = {text{:},varargin{cnt+[0,1]}}; cnt += 2;
      otherwise     error ("Unknown option '%s'", opt);
    endswitch
  endwhile
endif

if ischar(im), im = imread (im); endif
if length(size(im)) == 3, # 3D-array to 2D matrix of interlaced R,G,B
  is_col = 1;
  ##im = reshape
  ##([im(:,:,1)(:),im(:,:,2)(:),im(:,:,3)(:)]',size(im)(1:2).*[3,1]);
  im = reshape (reshape(im,prod(size(im))/3,3)',size(im)(1:2).*[3,1]);
endif
[R,C] = size(im);
im(!isfinite(im)) = nan;

R0 = R; C0 = C;

if prod (size (maxsz)) == 1, maxsz = maxsz*[1 1]; endif
if isnan (scl) && ((R>maxsz(1)*(1+2*is_col)) || (C>maxsz(2)))
  scl =  ceil (max (R/(maxsz(1)*(1+is_col*2)), C/maxsz(2)))
end

if !isnan (isnan (scl)) && scl > 1
  if is_col
    im = im([1:3*scl:R;2:3*scl:R;3:3*scl:R],1:scl:C);
  else
    im = im(1:scl:R,1:scl:C);
  endif
  [R,C] = size(im);
endif

if prod (size (minsz)) == 1, minsz = minsz*[1 1]; endif
if isnan (scl) && ((R<minsz(1)*(1+is_col*2)) && C<minsz(2))
  scl = 1 / ceil(min (minsz(1)*(1+is_col*2)/R, minsz(2)/C));
end

if !isnan (isnan (scl)) && scl < 1
  ## printf ("Scaling up by %i\n",scl);
  scl0 = round (1/scl);
  if is_col
    im = reshape ([kron(im(1:3:end,:), ones (scl0))(:),\
		   kron(im(2:3:end,:), ones (scl0))(:),\
		   kron(im(3:3:end,:), ones (scl0))(:)]', R*scl0,C*scl0);

  else
    im = kron (im, ones (scl0));
  endif
  [R,C] = size(im);
end

if isnan (scl)
  scl = 1;
end

if ! isempty (qrange)
  if length (qrange) != 2
    qrange = sort ([qrange, 1-qrange]);
  end
  vrange = qnt (im(:),qrange);
end

## Set imin (maps to 0), imax (maps to 255) and irng ( = imax - imin)
if ! isempty (vrange)
  if prod (size (vrange)) == 2
    imin = vrange(1);
    imax = vrange(2);
    irng = vrange(2) - vrange(1);
  elseif prod (size (vrange)) == 6
    if rows (vrange) == 2, vrange = vrange'; end
    imin = vrange(1:3);
    imax = vrange(4:6);
    irng = imax - imin;
  else
    error ("range should have 2 or 6 elements; got %s",\
	   sprintf("%i x ",size(vrange))(1:end-3));
  end
else
  if !is_col || sameScale
    imin = min (im(:));
    imax = max (im(:));
    irng = imax - imin;
  else
    imin = min (reshape (im,3,R*C/3)');
    imax = max (reshape (im,3,R*C/3)');
    irng = imax - imin;
  endif
end
if any (irng) < 0
  error ("Range ( %s) is not positive",sprintf("%f ",irng));
endif
##length(create_set(im))
if !is_col || sameScale
  im-=imin;
  if irng
    im .*= 255/irng;
  else
    im += min (1, max (imin/255,0));
  endif
else
  for j = 1:3, im(j:3:R,:) -= imin(j); endfor
  for j = 1:3
    if irng(j)
      im(j:3:R,:) .*= 255/irng(j); 
    else 
      im(j:3:R,:) += min (1,max (imin(j)/255,0)); 
    endif
  endfor
endif
im(im<0) = 0;
im(im>255) = 255;
if (invert), im = 255 - im; end

if !isempty (roi)
  
  roi *= scl;
  #size(im)
  #[min(im(:)),max(im(:))]
  highlight = 64;
  im(roi(2):roi(4),roi(1):roi(3)) += highlight;
  im .*= 255/(255+highlight);
  #size(im)
  #[min(im(:)),max(im(:))];


endif


if show_range && !is_col
				# Assume graylevel

  ## scale_C, scale_R : size of scale image
  if scale_sz
    scale_C = max (128, scale_sz);
  else
    scale_C = min (max (128, C), 256);
  endif
  scale_R = 2*round (12*scale_C/128);

				# Image w/ room for image and scale below
  scale_im0 = ones(scale_R/2,1)*linspace(0,255,scale_C);
  if invert, scale_im0 = 255 - scale_im0; end
  scale_im = [255+zeros(scale_R/2,scale_C);\
	     scale_im0];
  tn = [tempname(),".pgm"];
  if imin && abs(log10(abs(imin)))>5, ado = sprintf ("%.3g",imin);
  else                                ado = sprintf ("%.3f",imin);
  endif

  if imin && abs(log10(abs(imax)))>5, aup = sprintf ("%.3g",imax);
  else                                aup = sprintf ("%.3f",imax);
  endif

  roundBy = 0.01;
  if irng > 1-2*roundBy;
    if abs (imin-round(imin)) < roundBy, ado = num2str(round(imin)); endif
    if abs (imax-round(imax)) < roundBy, aup = num2str(round(imax)); endif
  endif
  
  psz = round(8*scale_C/128);
  
  ado = sprintf ("-annotate +%i+%i \"%s\"",\
		 2,\
		 psz,\
		 ado);
  aup = sprintf ("-annotate +%i+%i \"%s\"",\
		 scale_C-length(aup)*round(5*psz/10)-3,\
		 psz,\
		 aup);


  imwrite (tn, uint8 (scale_im),[aup; ado; sprintf("-pointsize %i",psz)]);
  scale_im = imread (tn);
  unlink (tn);

  pC = max (scale_C, C);
  padded_im = 255*ones (R+scale_R,pC);

  padded_im(1:R,floor((pC-C)/2)+(1:C)) = im;
  padded_im(R+1:R+scale_R,floor((pC-scale_C)/2)+(1:scale_C)) = \
      double (scale_im);
  im = padded_im;
endif
				       
if colormap && !is_col
  
  sz = size (im);

  if prod (size (colormap)) == 1
    colormap = rainbow()(end:-1:1,:);
  end
  ncol = rows (colormap);
  cmap = 255*interp1 ((1:ncol),colormap,linspace(1,ncol,256))';

  nanpix = isnan (im);
  im(nanpix) = 0;		# Dummy value, replacement is done below
  im = reshape (cmap (:,1+floor(im(:))),3*sz(1),sz(2));

  if show_range			# Get the text back in bw
    im(3*R+(1:3*scale_R),1:floor((pC-scale_C)/2)) = 255;
    im(3*R+(1:3*scale_R),floor((pC+scale_C)/2):end) = 255;
    im(3*R+(1:3*scale_R/2),floor((pC-scale_C)/2)+(1:scale_C)) = \
	kron (double (scale_im(1:scale_R/2,:)),ones(3,1));
  endif

  nanpix = !!reshape ([1;1;1]*nanpix(:)', size(im));
  im(nanpix) = nan;
  is_col = 1;
endif

#imin
#imax
#length(create_set(im))

assert (all (im(:) >= 0   | isnan (im(:))));
assert (all (im(:) <= 255 | isnan (im(:))));

				# Process text annotation commands
wopts = "";
i = 1;
while i < length (text)
  if !isnumeric (text{i}),   
    error ("Arg of type '%s' where numeric required, in 'text' option",\
	   typeinfo(text{i})); 
  end
  if length (text{i}) != 2 && length (text{i}) != 3
    error ("Position argument has size %s (should have 2 or 3 elements)",\
	   sprintf("%i x ",size(text{i})(1:end-3)));
  endif
  if !ischar    (text{i+1}), 
    error ("Arg of type '%s' where string required, in 'text' option",\
	   typeinfo(text{i+1})); 
  endif
  if !length (text{i+1}), i+=2; continue; endif

  ptsz = floor (C0/16);		# Size of text characters (in orig image)
  if length (text{i}) == 3, ptsz = text{i}(3); endif

				# Height and Width of text box
  tmp = [1, text{i+1} == "\n"];
  if tmp(end), tmp = tmp(1:end-1); endif
  tmp = cumsum (tmp);
  tmp = loop_add (zeros(1,max(tmp)),tmp);
  
  txtsz = [length(tmp),max(tmp)-1];
  
				# Choose a color, white, gray or black according
				# to histogram of image in bounding box.
  txtbb = (text{i}([2,1,2,1])(:)' + [-txtsz(1),0,0,txtsz(2)] * ptsz/2) * scl;
  txtbb = round (txtbb);
  txtbb = min (txtbb, size(im)([1 2 1 2]));
  txtbb = max (txtbb, 1);

  bbh = hist (im(txtbb(1):txtbb(3),txtbb(2):txtbb(4))(:),[55,127,200]);
  bbh = 0.98*bbh + 0.01*bbh([1 1 2]) + 0.01*bbh([2 3 3]);
  [dummy,tmp] = min (bbh);
  ##im(txtbb(1):txtbb(3),txtbb(2):txtbb(4)) = 0;
  fillColorStr = {"-fill \"#000000\" ",\
		  "-fill \"#A0A0A0\" ",\
		  "-fill \"#ffffff\" "}{tmp};
  
  wopts = [wopts, fillColorStr];

  wopts = [wopts, sprintf("-pointsize %i ",ptsz*scl)];

  #wopts = [wopts, sprintf("-annotate +%i+%i \"%s\" ",text{i}(1:2),text{i+1})];
  wopts = [wopts, sprintf("-draw \"text %i,%i '%s'\" ",scl*text{i}(1:2),text{i+1})];
  i += 2;
endwhile			# EOF loop thru text annotation commands

i = 1;
while i <= length (line)
  ll = line{i}(:);
  lll = length(ll);
  if !isnumeric (ll)
    error ("%ith 'line' argument is of type '%s', not numeric",\
	   i, typeinfo(line{i})); 
  endif

  if lll < 4
    error ("%ith 'line' argument has %i elements, 4 at least are needed",\
	   i, lll);
  endif
  if lll > 8
    error ("%ith 'line' argument has %i elements, 8 at most are taken",\
	   i, lll)
  endif
  rgb = [nan,nan,nan];
  wid = nan;
  switch lll 
    case 4, 			# All defaults
    case 5, rgb = ll(5)*[1 1 1]; # x,y,x,y,c
				# x,y,x,y,c, w
    case 6, rgb = ll(5)*[1 1 1]; wid = ll(6);
    case 7, rgb = ll(5:7)';
    case 8, rgb = ll(5:7)'; wid = ll(8);
  endswitch
  if all (!isnan (ll(1:4)))	# Don't bother for nans
    if !isnan (wid), 
      wopts = [wopts, sprintf("-stroke-width %i ",wid)];
    endif
    if all(!isnan (rgb)), 
      wopts = [wopts, sprintf("-fill \"#%02x%02x%02x\" ",rgb)];
    endif
    wopts = [wopts, sprintf("-draw \"line %i,%i %i,%i\" ",ll(1:4))];
  else
    printf ("myimage: Hey, there's some 'nan' in the %i'th line argument\n",i);
  endif
  i++;
  #wopts
endwhile			# EOF loop thru lines

nanmask = isnan(im);
im(nanmask) = 0;

				# Do I need to use libmagick to save and
				# display, or because save was requested, or to
				# annotate image.
if do_show || filename || length(wopts)

	     # If I save, should I do sthing for transparency?
  nanmaskfile = "";
  if filename && any (nanmask(:))\
    && (strcmp (filename(end-3:end), ".png")\
	|| strcmp (filename(end-3:end), ".gif"))

    nanmaskfile = "tmp-mask.pgm"
    imwrite (nanmaskfile, uint8 (255*!nanmask));
    ##myimage (nanmask);
  endif

  if !is_col
    if !filename, filename = "tmp.pgm"; endif
    imwrite (filename, uint8 (im), wopts);
  else

    if !filename, filename = "tmp.ppm"; endif
    RC3 = prod (size(im));
    RC = size(im)./[3 1];

    imwrite (filename, \
	     reshape(uint8 (im(1:3:RC3)),RC),\
	     reshape(uint8 (im(2:3:RC3)),RC),\
	     reshape(uint8 (im(3:3:RC3)),RC),\
	     wopts);
    
  end
	     # If there's transparency, do a separate call to convert
  if length(nanmaskfile)
    ["convert ",filename," ",\
	     "tmp-mask.pgm -quality 100 +matte -compose CopyOpacity ",\
	     filename]
    system (["cp ",filename," tmp-im.png"])
    system (["convert ",filename," ",\
	     "tmp-mask.pgm -quality 100 +matte -compose CopyOpacity ",\
	     filename]);
  endif
  if do_show
    
    [o,s] = system ([viewer, " ",filename," ",dont_wait]);
    if s
      error("%s exited w/ status %im after \
      outputing<<EOF\n%s\nEOF\n",viewer,s,o);
    endif
  endif
				# If I annotated image, annotation is now in
				# file, but not in im, so I load im from file
  if length(wopts) && nargout
    im = imread (filename);
    assert (all (im(:) >= 0));
    assert (all (im(:) <= 255));
  end
end

assert (all (im(:) >= 0));
assert (all (im(:) <= 255));

if !nargout, clear im; endif


endfunction

%!demo 
%! 
%! myimage (randn(3,3),                    "show_range")
%! myimage (rand(9,3),                     "is_col")
%! myimage (randn(32,32),                  "minsz",[32,50])
%! myimage (ones(64,1)*linspace(0,1,256),  "colormap")
%! myimage (linspace(0,3,256)'*ones(1,64), "range",[3 1])
%! myimage (zeros(200,200), "text",[10,20],">> 1 + pi\nans = 4.1416\n>>")
%!
%! im = kron (ones(4), kron (eye(2),ones(10)));
%! im += ones (80,1)*linspace(0,1/2,80);
%! myimage (im,"text",[11,5],"Hello","text", [10,30,30],"world")
