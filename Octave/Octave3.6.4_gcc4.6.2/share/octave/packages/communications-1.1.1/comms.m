## Copyright (C) 2003 David Bateman
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} comms ('help')
## @deftypefnx {Function File} {} comms ('info')
## @deftypefnx {Function File} {} comms ('info', @var{mod})
## @deftypefnx {Function File} {} comms ('test')
## @deftypefnx {Function File} {} comms ('test', @var{mod})
##
## Manual and test code for the Octave Communications toolbox. There are
## 5 possible ways to call this function.
##
## @table @code
## @item comms ('help')
## Display this help message. Called with no arguments, this function also
## displays this help message
## @item comms ('info')
## Open the Commumications toolbox manual
## @item comms ('info', @var{mod})
## Open the Commumications toolbox manual at the section specified by
## @var{mod}
## @item comms ('test')
## Run all of the test code for the Communications toolbox.
## @item comms ('test', @var{mod})
## Run only the test code for the Communications toolbox in the module
## @var{mod}.
## @end table
##
## Valid values for the varibale @var{mod} are
##
## @table @asis
## @item 'all'
## All of the toolbox
## @item 'random'
## The random signal generation and analysis package
## @item 'source'
## The source coding functions of the package
## @item 'block'
## The block coding functions
## @item 'convol'
## The convolution coding package
## @item 'modulation'
## The modulation package
## @item 'special'
## The special filter functions
## @item 'galois'
## The Galois fields package
## @end table
##
## Please note that this function file should be used as an example of the 
## use of this toolbox.
## @end deftypefn

function retval = comms(typ, tests)

  if (nargin < 1)
    help ("comms");
  elseif (nargin < 2)
    tests = 'all';
  endif


  if strcmp(tests,"all") 
    nodename = "Top";
  elseif strcmp(tests,"random") 
    nodename = "Random Signals";
  elseif  strcmp(tests,"source") 
    nodename = "Source Coding";
  elseif  strcmp(tests,"block") 
    nodename = "Block Coding";
  elseif  strcmp(tests,"convol") 
    nodename = "Convolutional Coding";
  elseif  strcmp(tests,"modulation") 
    nodename = "Modulations";
  elseif  strcmp(tests,"special") 
    nodename = "Special Fields";
  elseif  strcmp(tests,"galois") 
    nodename = "Galois Fields";
  else
    error ("comms: unrecognized package");
  endif

  if (strcmp(typ,"help"))
    help ("comms");
  elseif (strcmp(typ,"info"))
    infopaths = ["."];
    if (!isempty(char(strsplit (path, ":"))))
      infopaths =[infopaths; char(strsplit (path, ":"))];
    endif
    if (!isempty(char(strsplit (DEFAULT_LOADPATH, ":"))))
      infopaths =[infopaths; char(strsplit (DEFAULT_LOADPATH, ":"))];
    endif
    for i=1:size(infopaths,1)
      infopath = deblank(infopaths(i,:));
      len = length(infopath);
      if (len)
        if (len > 1 && strcmp(infopath([len-1, len]),"//"))
          [status, showfile] = system(["find '", infopath(1:len-1), ...
                              "' -name ", infofile]);
        else
          [status, showfile] = system(["find '", infopath, "' -name ", ...
                              infofile, " -maxdepth 1"]);
        endif
        if (length(showfile))
          break;
        endif
      endif
    end
    if (!exist("showfile") || !length(showfile))
      error("comms: info file not found");
    endif
    if (showfile(length(showfile)) == "\n")
      showfile = showfile(1:length(showfile)-1);
    endif
    
    if (exist("INFO_PROGAM")) 
      [testret, testout] = system(["'", INFO_PROGRAM, "' --version"]);
      if (testret)
        error("comms: info command not found");
      else
        system(["'", INFO_PROGRAM, "' --file '", showfile, "' --node '", ...
                nodename, "'"]); 
      endif
    else
      [testret, testout] = system("info --version");
      if (testret)
        error("comms: info command not found");
      else
        system(["info --file '", showfile, "' --node '", nodename, "'"]); 
      endif
    endif
  elseif (strcmp(typ,"test"))
    pso = page_screen_output();
    unwind_protect
      page_screen_output(0);

      if (strcmp(tests,"random") || strcmp(tests,"all"))
	fprintf("\n<< Random Signals Package >>\n");
	fprintf("  Signal Creation:                          ");
	n = 10;
	m = 32;
	x = randint(n,n,m);
	if (any(size(x) != [10, 10]) || (max(x(:)) >= m) || (min(x(:) < 0)))
	  error ("FAILED");
	endif
	x = randsrc(n,n,[1, 1i, -1, -1i,]);
	if (any(size(x) != [10, 10]) || ...
	    !all(all((x == 1) | (x == 1i) | (x == -1) | (x == -1i))))
	  error ("FAILED");
	endif
	x = randerr(n,n);
	if (any(size(x) != [10, 10]) || any(sum(x') != ones(1,n)))
	  error ("FAILED");
	endif

	nse_30dBm_1Ohm = wgn(10000,1,30,1,"dBm");
	nse_0dBW_1Ohm = wgn(10000,1,0,1,"dBW");
	nse_1W_1Ohm = wgn(10000,1,1,1,"linear");
	## Standard deviations should be about 1... If it is greater than 
	## some value flag an error
	dev = [std(nse_30dBm_1Ohm), std(nse_0dBW_1Ohm), std(nse_1W_1Ohm)];
	if (any(dev > 1.5))
	  error ("FAILED");
	endif

	x = [0:0.1:2*pi];
	y = sin(x);
	noisy = awgn(y, 10, "dB", "measured");
	if (any(size(y) != size(noisy)))
	  error ("FAILED");
	endif
	## This is a pretty arbitrary test, but should pick up gross errors
	if (any(abs(y-noisy) > 1))
	  error ("FAILED");
	endif
	fprintf("PASSED\n");

	fprintf("  Signal Analysis:                          ");
	## Protect!! Since bitxor might not be installed
	try
	  n = 10;
	  m = 8;
	  msg = randint(n,n,2^m);
	  noisy = bitxor(msg,diag(3*ones(1,n)));
	  [berr, brate] = biterr(msg, noisy, m);
	  if ((berr != 2*n) || (brate != 2/(n*m)))
	    error ("FAILED");
	  endif
	  [serr, srate] = symerr(msg, noisy);
	  if ((serr != n) || (srate != 1/n))
	    error ("FAILED");
	  endif
	catch
	end
	## Can not easily test eyediagram, scatterplot!!
	fprintf("PASSED\n");
      endif
      if (strcmp(tests,"source") || strcmp(tests,"all"))
	fprintf("\n<< Source Coding Package >>\n");
	fprintf("  PCM Functions:                            ");
	fprintf("Not tested\n");
	fprintf("  Quantization Functions:                   ");
	x = [0:0.1:2*pi];
	y = sin(x);
	[tab, cod] = lloyds(y, 16);
	[i, q, d] = quantiz(y, tab, cod);
	if (abs(d) > 0.1)
	  error ("FAILED");
	endif

	mu = 0.1;
	V = 1;
	x = sin([0:0.1:2*pi]);
	y = compand(x, mu, V, "mu/compressor");
	z = compand(x, mu, V, "mu/expander");
	## Again this is a pretty arbitrary test
	if (max(abs(x-z)) > 0.1)
	  error ("FAILED");
	endif
	fprintf("PASSED\n");
      endif
      if (strcmp(tests,"block") || strcmp(tests,"all"))
	fprintf("\n<< Block Coding Package >>\n");
	fprintf("  Cyclic Coding:                            ");
	nsym = 100;
	m = 4;
	n = 2^m-1;			# [15,11] Hamming code
	k = n - m;
	p = cyclpoly(n,k);
	if (bi2de(p) != primpoly(m,"nodisplay"))
          error("FAILED");
	endif
	[par, gen] = cyclgen(n,p);
	if (any(any(gen2par(par) != gen)))
          error("FAILED");
	endif
	if (gfweight(gen) != 3)
          error("FAILED");
	endif

	msg = randint(nsym,k);
	code = encode(msg,n,k,"cyclic");
	noisy = mod(code + randerr(nsym,n), 2);
	dec = decode(noisy,n,k,"cyclic");
	if (any(any(dec != msg)))
          error("FAILED");
	endif         
	try			# Protect! If bitshift isn't install!!
	  msg = randint(nsym,1,n);
	  code = encode(msg,n,k,"cyclic/decimal");
	  noisy = mod(code + bitshift(1,randint(nsym,1,n)), n+1);
	  dec = decode(noisy,n,k,"cyclic/decimal");
	  if (any(dec != msg))
            error("FAILED");
	  endif
	catch
	end
	fprintf("PASSED\n");

	fprintf("  Hamming Coding:                           ");
	nsym = 100;
	m = 4;
	[par, gen, n, k] = hammgen (m);
	if (any(any(gen2par(par) != gen)))
          error("FAILED");
	endif
	if (gfweight(gen) != 3)
          error("FAILED");
	endif
	msg = randint(nsym,k);
	code = encode(msg,n,k,"hamming");
	noisy = mod(code + randerr(nsym,n), 2);
	dec = decode(noisy,n,k,"hamming");
	if (any(any(dec != msg)))
          error("FAILED");
	endif         
	try			# Protect! If bitshift isn't install!!
	  msg = randint(nsym,1,n);
	  code = encode(msg,n,k,"hamming/decimal");
	  noisy = mod(code + bitshift(1,randint(nsym,1,n)), n+1);
	  dec = decode(noisy,n,k,"hamming/decimal");
	  if (any(dec != msg))
            error("FAILED");
	  endif
	catch
	end
	fprintf("PASSED\n");

	fprintf("  BCH Coding:                               ");
	## Setup
	m = 5;
	nsym = 100;
	p = bchpoly(2^m - 1);
	## Pick a BCH code from the list at random
	l = ceil(size(p,1) * rand(1,1));
	n = p(l,1);
	k = p(l,2);
	t = p(l,3);
	## Symbols represented by rows of binary matrix
	msg = randint(nsym,k);
	code = encode(msg,n,k,"bch");
	noisy = mod(code + randerr(nsym,n), 2);
	dec = decode(noisy,n,k,"bch");
	if (any(any(dec != msg)))
          error("FAILED");
	endif         
	try			# Protect! If bitshift isn't install!!
	  msg = randint(nsym,1,n);
	  code = encode(msg,n,k,"bch/decimal");
	  noisy = mod(code + bitshift(1,randint(nsym,1,n)), n+1);
	  dec = decode(noisy,n,k,"bch/decimal");
	  if (any(dec != msg))
            error("FAILED");
	  endif
	catch
	end
	fprintf("PASSED\n");

	fprintf("  Reed-Solomon Coding:                      ");
	## Test for a CCSDS like coder, but without dual-basis translation
	mrs = 8;
	nrs = 2^mrs -1;
	krs = nrs - 32;
	prs = 391;
	fcr = 112;
	step = 11;
      
	## CCSDS generator polynomial
	ggrs = rsgenpoly(nrs, krs, prs, fcr, step);

	## Code two blocks
	msg = gf(floor(2^mrs*rand(2,krs)),mrs,prs);
	cde = rsenc(msg,nrs,krs,ggrs);
	
	## Introduce errors
	noisy = cde + [ 255,0,255,0,255,zeros(1,250); ...
		       0,255,0,255,zeros(1,251)];
      
	## Decode (better to pass fcr and step rather than gg for speed)
	dec = rsdec(noisy,nrs,krs,fcr,step);
      
	if (any(dec != msg))
          error("FAILED");
	endif         
	fprintf("PASSED\n");
      endif
      if (strcmp(tests,"convol") || strcmp(tests,"all"))
	fprintf("\n<< Convolutional Coding Package >>\n");
	fprintf("  Utility functions:                        ");
	## create a trellis, use poly2trellis and test with istrellis
	fprintf("Not tested\n");
	fprintf("  Coding:                                   ");
	## use convenc, punturing??
	fprintf("Not tested\n");
	fprintf("  Viterbi:                                  ");
	## use vitdec
	fprintf("Not tested\n");
      endif
      if (strcmp(tests,"modulation") || strcmp(tests,"all"))
	fprintf("\n<< Modulation Package >>\n");
	fprintf("  Analog Modulation:                        ");
	Fs = 100;
	t = [0:1/Fs:2];
	x = sin(2*pi*t);
	xq = x + 1i * cos(2*pi*t);
	## Can not test FM as it doesn't work !!!
	if ((max(abs(x - ademodce(amodce(x,Fs,"pm"),Fs,"pm"))) > 0.001) || ...
	    (max(abs(x - ademodce(amodce(x,Fs,"am"),Fs,"am"))) > 0.001) || ...
	    (max(abs(xq - ademodce(amodce(xq,Fs,"qam"),Fs,"qam/cmplx"))) > 0.001))
          error("FAILED");
	endif         
	fprintf("PASSED\n");
	fprintf("  Digital Mapping:                          ");
	m = 32;
	n = 100;
	x = randint(n,n,32);
	if ((x != demodmap(modmap(x,1,1,"ask",m),1,1,"ask",m)) || ...
	    (x != demodmap(modmap(x,1,1,"fsk",m),1,1,"fsk",m)) || ...
	    (x != demodmap(modmap(x,1,1,"msk"),1,1,"msk")) || ...
	    (x != demodmap(modmap(x,1,1,"psk",m),1,1,"psk",m)) || ...
	    (x != demodmap(modmap(x,1,1,"qask",m),1,1,"qask",m)) || ...
	    (x != demodmap(modmap(x,1,1,"qask/cir", ...
		  [floor(m/2), m - floor(m/2)]),1,1,"qask/cir", ...
		  [floor(m/2), m - floor(m/2)])))
          error("FAILED");
	endif         
	fprintf("PASSED\n");
	fprintf("  Digital Modulation:                       ");
	fprintf("Not tested\n");
      endif
      if (strcmp(tests,"special") || strcmp(tests,"all"))
	fprintf("\n<< Special Filters Package >>\n");
	fprintf("  Hankel/Hilbert:                           ");
	## use hank2sys, hilbiir
	fprintf("Not tested\n");
	fprintf("  Raised Cosine:                            ");
	## use rcosflt, rcosiir rcosine, rcosfir
	fprintf("Not tested\n");
      endif
      if (strcmp(tests,"galois") || strcmp(tests,"all"))
	fprintf("\n<< Galois Fields Package >>\n");
	## Testing of the Galois Fields package
	m = 3;			## must be greater than 2

	fprintf("  Find primitive polynomials:               ");
	prims = primpoly(m,"all","nodisplay");
	for i=2^m:2^(m+1)-1
          if (find(prims == i))
            if (!isprimitive(i))
              error("Error in primitive polynomials");
            endif
          else
            if (isprimitive(i))
              error("Error in primitive polynomials");
            endif
          endif
	end
	fprintf("PASSED\n");
	fprintf("  Create Galois variables:                  ");
	n = 2^m-1;
	gempty = gf([],m);
	gzero = gf(0,m);
	gone = gf(1,m);
	gmax = gf(n,m);
	grow = gf(0:n,m);
	gcol = gf([0:n]',m);
	matlen = ceil(sqrt(2^m));
	gmat = gf(reshape(mod([0:matlen*matlen-1],2^m),matlen,matlen),m);
	fprintf("PASSED\n");
	fprintf("  Access Galois structures:                 ");
	if (gcol.m != m || gcol.prim_poly != primpoly(m,"min", ...
                                                      "nodisplay"))
          error("FAILED");
	endif
	fprintf("PASSED\n");
	fprintf("  Miscellaneous functions:                  ");
	if (size(gmat) != [matlen, matlen])
          error("FAILED");
	endif
	if (length(grow) != 2^m)
          error("FAILED");
	endif
	if (!any(grow) || all(grow) || any(gzero) || !all(gone))
          error("FAILED");
	endif
	if (isempty(gone) || !isempty(gempty))
          error("FAILED");
	endif
	tmp = diag(grow);
	if (size(tmp,1) != 2^m || size(tmp,2) != 2^m)
          error("FAILED");
	endif
	for i=1:2^m
          for j=1:2^m
            if ((i == j) && (tmp(i,j) != grow(i)))
              error("FAILED");
            elseif ((i != j) && (tmp(i,j) != 0))
              error("FAILED");
            endif
          end
	end
	tmp = diag(gmat);
	if (length(tmp) != matlen)
          error("FAILED");
	endif
	for i=1:matlen
          if (gmat(i,i) != tmp(i))
            error("FAILED");
          endif
	end          
	tmp = reshape(gmat,prod(size(gmat)),1);
	if (length(tmp) != prod(size(gmat)))
          error("FAILED");
	endif
	if (exp(log(gf([1:n],m))) != [1:n])
          error("FAILED");
	endif
	tmp = sqrt(gmat);
	if (tmp .* tmp != gmat)
          error("FAILED");
	endif

	fprintf("PASSED\n");
	fprintf("  Unary operators:                          ");
	tmp = - grow;
	if (tmp != grow)
          error("FAILED");
	endif
	tmp = !grow;
	if (tmp(1) != 1)
          error("FAILED");
	endif
	if (any(tmp(2:length(tmp))))
          error("FAILED");
	endif
	tmp = gmat';
	for i=1:size(gmat,1)
          for j=1:size(gmat,2)
            if (gmat(i,j) != tmp(j,i))
              error("FAILED");
            endif
          end
	end
	fprintf("PASSED\n");
	fprintf("  Arithmetic operators:                     ");
	if (any(gmat + gmat))
          error("FAILED");
	endif
	multbl = gcol * grow;
	elsqr = gcol .* gcol;
	elsqr2 = gcol .^ gf(2,m);
	for i=1:length(elsqr)
          if (elsqr(i) != multbl(i,i))
            error("FAILED");
          endif
	end
	for i=1:length(elsqr)
          if (elsqr(i) != elsqr2(i))
            error("FAILED");
          endif
	end
	tmp = grow(2:length(grow)) ./ gcol(2:length(gcol))';
	if (length(tmp) != n || any(tmp != ones(1,length(grow)-1)))
          error("FAILED");
	endif
	fprintf("PASSED\n");
	fprintf("  Logical operators:                        ");
	if (grow(1) != gzero || grow(2) != gone || grow(2^m) != n)
          error("FAILED");
	endif
	if (!(grow(1) == gzero) || any(grow != gcol'))
          error("FAILED");
	endif
	fprintf("PASSED\n");

	fprintf("  Polynomial manipulation:                  ");
	poly1 = gf([2,4,5,1],3);
	poly2 = gf([1,2],3);
	sumpoly = poly1 + [0,0,poly2];   ## Already test "+"
	mulpoly = conv(poly1, poly2);    ## multiplication
	poly3 = [poly,remd] = deconv(mulpoly, poly2);
	if (!isequal(poly1,poly3))
          error("FAILED");
	endif
	if (any(remd))
          error("FAILED");
	endif
	x0 = gf([0,1,2,3],3);
	y0 = polyval(poly1, x0);
	alph = gf(2,3);
	y1 = alph * x0.^3 + alph.^2 * x0.^2 + (alph.^2+1) *x0 + 1;
	if (!isequal(y0,y1))
          error("FAILED");
	endif
	roots1 = roots(poly1);
	ck1 = polyval(poly1, roots1);
	if (any(ck1))
          error("FAILED");
	endif
	b = minpol(alph);
	bpoly = bi2de(b.x,"left-msb");
	if (bpoly != alph.prim_poly)
          error("FAILED");
	endif
	c = cosets(3);
	c2 = c{2};
	mpol = minpol(c2(1));
	for i=2:length(c2)
          if (mpol != minpol(c2(i)))
            error("FAILED");
          endif
	end
	fprintf("PASSED\n");

	fprintf("  Linear Algebra:                           ");
	[l,u,p] = lu(gmat);
	if (any(l*u-p*gmat))       
          error("FAILED");
	endif
	g1 = inv(gmat);
	g2 = gmat ^ -1;
	if (any(g1*gmat != eye(matlen)))
          error("FAILED");
	endif
	if (any(g1 != g2))
          error("FAILED");
	endif
	matdet = 0;
	while (!matdet)
          granmat = gf(floor(2^m*rand(matlen)),m);
          matdet = det(granmat);
	endwhile
	matrank = rank(granmat);
	smallcol = gf([0:matlen-1],m)';
	sol1 = granmat \ smallcol;
	sol2 = smallcol' / granmat;
	if (any(granmat * sol1 != smallcol))
          error("FAILED");
	endif
	if (any(sol2 * granmat != smallcol'))
          error("FAILED");
	endif
	fprintf("PASSED\n");
	fprintf("  Signal Processing functions:              ");
	b = gf([1,0,0,1,0,1,0,1],m);
	a = gf([1,0,1,1],m);
	x = gf([1,zeros(1,99)],m);
	y0 = filter(b, a, x);
	y1 = conv(grow+1, grow);
	y2 = grow * convmtx(grow+1, length(grow));
	if (any(y1 != y2))
          error("FAILED");
	endif
	[y3,remd] = deconv(y2, grow+1);
	if (any(y3 != grow))
          error("FAILED");
	endif
	if (any(remd))
          error("FAILED");
	endif
	alph = gf(2,m);
	x = gf(floor(2^m*rand(n,1)),m);
	fm = dftmtx(alph);
	ifm = dftmtx(1/alph);
	y0 = fft(x);
	y1 = fm * x;
	if (any(y0 != y1))
          error("FAILED");
	endif
	z0 = ifft(y0);
	z1 = ifm * y1;
	if (any(z0 != x))
          error("FAILED");
	endif
	if (any(z1 != x))
          error("FAILED");
	endif
	fprintf("PASSED\n");
    
      endif
      fprintf("\n");
    unwind_protect_cleanup
      page_screen_output(pso);
    end_unwind_protect
  else
    usage("comms: Unknown argument");
  endif
endfunction

%!test
%! try comms("test");
%! catch disp(lasterr()); end
