function [map,newlegend] = resizem(map0,vec,maplegend,method,n)

%RESIZEM  Resizes a matrix map
%
%  map = RESIZEM(map0,m)  resizes the input map by a factor m.
%  map = RESIZEM(map0,[r c]) resizes map0 to a r by c matrix.
%
%  map = RESIZEM(map0,m,'method') and  map = RESIZEM(map0,[r c],'method')
%  uses 'method' to define the interpolation scheme.  Allowable
%  'method' strings are:  'bilinear' for linear interpolation;
%  'bicubic' for cubic interpolation; and 'nearest' for nearest
%  neighbor interpolation.  For sparse matrices only nearest
%  neighbor interpolation is performed.  For full maps, linear
%  interpolation is the default option.
%
%  [map,maplegend] = RESIZEM(map0,m,maplegend0) and
%  [map,maplegend] = RESIZEM(map0,m,maplegend0,'method') resizes
%  regular matrix maps and returns the new map and associated
%  map legend.  Only scalar resize factors are allowed for regular
%  matrix maps.
%
%  When the map size is being reduced, RESIZEM lowpass filters
%  the map before interpolating to avoid aliasing. By default,
%  this filter is designed using FIR1, but can be specified using:
%
%  RESIZEM(...,'method',h). The default filter is 11-by-11.
%  RESIZEM(...,'method',n) uses an n-by-n filter.
%  RESIZEM(...,'method',0) turns off the filtering.
%
%  Unless a filter h is specified, RESIZEM will not filter when
%  'nearest' is used.
%
%  See also IMRESIZE, FIR1, INTERP2, REDUCEM, MAPTRIMS


%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $  $Date: 2003/08/01 18:20:01 $


if nargin < 2
    error('Incorrect number of arguments')

elseif nargin == 2
    maplegend = [];     method = [];    n = [];

elseif nargin == 3
    if isstr(maplegend)
	     method = maplegend;    maplegend = []; n=[];
	else
	     method = [];       n = [];
	end

elseif nargin == 4
    if isstr(maplegend)
	     n = method;      method = maplegend;    maplegend = [];
	else
	     n = [];
	end

end

%  Initialize outputs

map = [];   newlegend = [];

%  Set the default method

if isempty(method);   method = 'nearest';   end

%  Test if a new maplegend is to be computed.  If so,
%  require resize factor to be scalar so that latitude and
%  longitude are equally scaled

if ~isempty(maplegend)
   if max(size(vec)) > 1
         error('Resizing regular matrix maps requires a scalar scale factor')
   else
         if ~isreal(maplegend)
		     warning('Imaginary part of complex MAPLEGEND argument ignored')
			 maplegend = real(maplegend);
		 end
		 newlegend = maplegend;    newlegend(1) = newlegend(1)*vec;
   end
end


%  Resize the map

if issparse(map0)
       map = reduce(map0,vec);        % IMRESIZE won't support
else                                  % sparse matrix computations
       if isempty(n)
	        map = imresize(map0,vec,method);
       else
	        map = imresize(map0,vec,method,n);
	   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function map = reduce(map0,vec)

%REDUCE  Reduces binary sparse matrices
%
%  Synopsis
%
%       map = reduce(map0,m)      %  Reduce by a factor of m
%       map = reduce(map0,[r c])  %  Reduce to row and column dimension
%
% 	See also RESIZEM


if nargin ~= 2;    error('Incorrect number of arguments');   end

%  Test input dimensions

if ndims(map0) > 2
    error('Input map can not contain pages')

elseif any(nonzeros(map0) ~= 1)
    error('Input map must be sparse and binary')

elseif ~isreal(vec)
    warning('Imaginary parts of complex argument ignored')
	vec = real(vec);
end

%  Set the row and column scale factors

if max(size(vec)) == 1
     if vec == 1
	     map = map0;        %  No reduction required
		 return
	 else
	     rowfact = 1 / vec;
		 colfact = 1 / vec;
	 end
elseif isequal(sort(size(vec)),[1 2])
     rowfact = size(map0,1) / vec(1);     %  Different row and column scaling
	 colfact = size(map0,2) / vec(2);
else
     error('Scale factors must be a vector of 2 elements or less')
end

%  Ensure that reduction is occuring

if rowfact < 1 | colfact < 1
    error('REDUCE only supports matrix reduction')
end

%  Determine the original size of the matrix map

[m,n]=size(map0);

%  Compute the pre-multiplier for the reduction operation.  The
%  pre-multiplication will reduce the row dimension

prerows = (1:m)';
precols = fix( (rowfact-1+prerows) / rowfact);
indx = prerows + (precols-1)*m;
pre = sparse(m,m/rowfact);
pre(indx) = ones(size(indx));

%  Compute the post-multiplier for the reduction operation.  The
%  post-multiplication will reduce the column dimension

postrows = (1:n)';
postcols = fix( (colfact-1+postrows) / colfact);
indx = postrows + (postcols-1)*n;
post = sparse(n,n/colfact);
post(indx) = ones(size(indx));


%  Reduce the map matrix

map = pre'*map0*post;
map = (map~=0);       %  Ensure a binary output


%*************************************************************************
%*************************************************************************
%*************************************************************************
%
%  Following function IMRESIZE (and functions it calls) are called
%  by RESIZEM.  These functions have been made local to this RESIZEM
%  since they have been taken from other toolboxes for the
%  sole purpose of making RESIZEM work in the Mapping Toolbox.
%
%*************************************************************************
%*************************************************************************
%*************************************************************************


function [rout,g,b] = imresize(arg1,arg2,arg3,arg4,arg5,arg6)
%IMRESIZE Resize image.
%	B = IMRESIZE(A,M,'method') returns an image matrix that is
%	M times larger (or smaller) than the image A.  The image B
%	is computed by interpolating using the method in the string
%	'method'.  Possible methods are 'nearest','bilinear', or
%	'bicubic'. B = IMRESIZE(A,M) uses 'nearest' when A for indexed
%	images and 'bilinear' for intensity images.
%
%	B = IMRESIZE(A,[MROWS NCOLS],'method') returns a matrix of
%	size MROWS-by-NCOLS.
%
%	[R1,G1,B1] = IMRESIZE(R,G,B,M,'method') or
%	[R1,G1,B1] = IMRESIZE(R,G,B,[MROWS NCOLS],'method') resizes
%	the RGB image in the matrices R,G,B.  'bilinear' is the
%	default interpolation method.
%
%	When the image size is being reduced, IMRESIZE lowpass filters
%	the image before interpolating to avoid aliasing. By default,
%	this filter is designed using FIR1, but can be specified using
%	IMRESIZE(...,'method',H). The default filter is 11-by-11.
%	IMRESIZE(...,'method',N) uses an N-by-N filter.
%	IMRESIZE(...,'method',0) turns off the filtering.
%	Unless a filter H is specified, IMRESIZE will not filter
%	when 'nearest' is used.
%
%	See also IMZOOM, FIR1, INTERP2.

%  Written by: Clay M. Thompson 7-7-92

error(nargchk(2,6,nargin));

% Trap imresize(r,b,g,...) calls.
if nargin==4,
  if ~isstr(arg3), % imresize(r,g,b,m)
    r = imresize(arg1,arg4,'bil');
    g = imresize(arg2,arg4,'bil');
    b = imresize(arg3,arg4,'bil');
    if nargout==0, imshow(r,g,b), else, rout = r; end
    return
  end
elseif nargin==5, % imresize(r,g,b,m,'method')
  r = imresize(arg1,arg4,arg5);
  g = imresize(arg2,arg4,arg5);
  b = imresize(arg3,arg4,arg5);
  if nargout==0, imshow(r,g,b), else, rout = r; end
  return
elseif nargin==6, % imresize(r,g,b,m,'method',h)
  r = imresize(arg1,arg4,arg5,arg6);
  g = imresize(arg2,arg4,arg5,arg6);
  b = imresize(arg3,arg4,arg5,arg6);
  if nargout==0, imshow(r,g,b), else, rout = r; end
  return
end

% Determine default interpolation method
if nargin<3,
  if isgray(arg1), case0 = 'bil'; else case0 = 'nea'; end,
else
  method = [lower(arg3),'   ']; % Protect against short method
  case0 = method(1:3);
end

if prod(size(arg2))==1,
  bsize = floor(arg2*size(arg1));
else
  bsize = arg2;
end

if any(size(bsize)~=[1 2]),
  error('M must be either a scalar multiplier or a 1-by-2 size vector.');
end

if nargin<4,
  nn = 11; h = []; % Default filter size
else
  if length(arg4)==1, nn = h; h = []; else nn = 0; h = arg4; end
end

[m,n] = size(arg1);

if nn>0 & case0(1)=='b',  % Design anti-aliasing filter if necessary
  if bsize(1)<m, h1 = fir1(nn-1,bsize(1)/m); else h1 = 1; end
  if bsize(2)<n, h2 = fir1(nn-1,bsize(2)/n); else h2 = 1; end
  if length(h1)>1 | length(h2)>1, h = h1'*h2; else h = []; end
end

if ~isempty(h), % Anti-alias filter A before interpolation
  a = filter2(h,arg1);
else
  a = arg1;
end

if case0(1)=='n', % Nearest neighbor interpolation
  dx = n/bsize(2); dy = m/bsize(1);
  uu = (dx/2+.5):dx:n+.5; vv = (dy/2+.5):dy:m+.5;
elseif all(case0 == 'bil') | all(case0 == 'bic'),
  uu = 1:(n-1)/(bsize(2)-1):n; vv = 1:(m-1)/(bsize(1)-1):m;
else
  error(['Unknown interpolation method: ',method]);
end

%
% Interpolate in blocks
%
nu = length(uu); nv = length(vv);
blk = bestblk([nv nu]);
nblks = floor([nv nu]./blk); nrem = [nv nu] - nblks.*blk;
mblocks = nblks(1); nblocks = nblks(2);
mb = blk(1); nb = blk(2);

rows = 1:blk(1); b = zeros(nv,nu);
for i=0:mblocks,
  if i==mblocks, rows = (1:nrem(1)); end
  for j=0:nblocks,
    if j==0, cols = 1:blk(2); elseif j==nblocks, cols=(1:nrem(2)); end
    if ~isempty(rows) & ~isempty(cols)
      [u,v] = meshgrid(uu(j*nb+cols),vv(i*mb+rows));
      % Interpolate points
      if case0(1) == 'n', % Nearest neighbor interpolation
        b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'nearest');
      elseif all(case0 == 'bil'), % Bilinear interpolation
         b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'linear');
     elseif all(case0 == 'bic'), % Bicubic interpolation
        b(i*mb+rows,j*nb+cols) = interp2(a,u,v,'cubic');
      end
    end
  end
end

if nargout==0,
  if isgray(b), imshow(b,size(colormap,1)), else imshow(b), end
  return
end

if isgray(arg1), rout = max(0,min(b,1)); else rout = b; end


%*************************************************************************
%*************************************************************************
%*************************************************************************
%
%  Following functions ISGRAY, BESTBLK & FIR1 are called by
%  IMRESIZE.  They have been made local to RESIZEM
%  since they have been taken from other toolboxes for the
%  sole purpose of making RESIZEM work in the Mapping Toolbox.
%
%*************************************************************************
%*************************************************************************
%*************************************************************************


function y = isgray(x)
%ISGRAY True for intensity images.
%	ISGRAY(A) returns 1 if A is an intensity image and 0 otherwise.
%	An intensity image contains values between 0.0 and 1.0.
%
%	See also ISIND, ISBW.

%  Written by: Clay M. Thompson 2-25-93

y = min(min(x))>=0 & max(max(x))<=1;


%*************************************************************************
%*************************************************************************
%*************************************************************************


function [mb,nb] = bestblk(siz,k)
%BESTBLK Best block size for block processing.
%	BLK = BESTBLK([M N],K) returns the 1-by-2 block size BLK
%	closest to but smaller than K-by-K for block processing.
%
%	[MB,NB] = BESTBLK([M N],K) returns the best block size
%	as the two scalars MB and NB.
%
%	[...] = BESTBLK([M N]) returns the best block size smaller
%	than 100-by-100.
%
%	BESTBLK returns the M or N when they are already smaller
%	than K.
%
%	See also BLKPROC, SIZE.

%  Written by: Clay M. Thompson

if nargin==1, k = 100; end % Default block size

%
% Find possible factors of siz that make good blocks
%

% Define acceptable block sizes
m = floor(k):-1:floor(min(ceil(siz(1)/10),k/2));
n = floor(k):-1:floor(min(ceil(siz(2)/10),k/2));

% Choose that largest acceptable block that has the minimum padding.
[dum,ndx] = min(ceil(siz(1)./m).*m-siz(1)); blk(1) = m(ndx);
[dum,ndx] = min(ceil(siz(2)./n).*n-siz(2)); blk(2) = n(ndx);

if nargout==2,
  mb = blk(1); nb = blk(2);
else
  mb = blk;
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function [b,a] = fir1(N,Wn,Ftype,Wind)
%FIR1	FIR filter design using the window method.
%	B = FIR1(N,Wn) designs an N'th order lowpass FIR digital filter
%	and returns the filter coefficients in length N+1 vector B.
%	The cut-off frequency Wn must be between 0 < Wn < 1.0, with 1.0
%	corresponding to half the sample rate.
%
%	If Wn is a two-element vector, Wn = [W1 W2], FIR1 returns an
%	order N bandpass filter with passband  W1 < W < W2.
%	B = FIR1(N,Wn,'high') designs a highpass filter.
%	B = FIR1(N,Wn,'stop') is a bandstop filter if Wn = [W1 W2].
%	For highpass and bandstop filters, N must be even.
%
%	By default FIR1 uses a Hamming window.  Other available windows,
%	including Boxcar, Hanning, Bartlett, Blackman, Kaiser and Chebwin
%	can be specified with an optional trailing argument.  For example,
%	B = FIR1(N,Wn,bartlett(N+1)) uses a Bartlett window.
%	B = FIR1(N,Wn,'high',chebwin(N+1,R)) uses a Chebyshev window.
%
%	FIR1 is an M-file implementation of program 5.2 in the IEEE
%	Programs for Digital Signal Processing tape.  See also FIR2,
%	FIRLS, REMEZ, BUTTER, CHEBY1, CHEBY2, YULEWALK, FREQZ and FILTER.

%  Written by: L. Shure

%	Reference(s):
%	  [1] "Programs for Digital Signal Processing", IEEE Press
%	      John Wiley & Sons, 1979, pg. 5.2-1.

nw = 0;
a = 1;
if nargin == 3
	if ~isstr(Ftype);
		nw = max(size(Ftype));
      		Wind = Ftype;
		Ftype = [];
	end
elseif nargin == 4
   nw = max(size(Wind));
else
   Ftype = [];
end

Btype = 1;
if nargin > 2 & max(size(Ftype)) > 0
	Btype = 3;
end
if max(size(Wn)) == 2
	Btype = Btype + 1;
end

N = N + 1;
odd = rem(N, 2);
if (Btype == 3 | Btype == 4)
   if (~odd)
      disp('For highpass and bandstop filters, order must be even.')
      disp('Order is being increased by 1.')
      N = N + 1;
      odd = 1;
   end
end
if nw ~= 0 & nw ~= N
   error('The window length must be the same as the filter length.')
end
if nw > 0
   wind = Wind;
else        	 % replace the following with the default window of your choice.
   wind = hamming(N);
end
%
% to use Chebyshev window, you must specify ripple
% ripple=60;
% wind=chebwin(N, ripple);
%
% to use Kaiser window, beta must be supplied
% att = 60; % dB of attenuation desired in sidelobe
% beta = .1102*(att-8.7);
% wind = kaiser(N,beta);

fl = Wn(1)/2;
if (Btype == 2 | Btype == 4)
   fh = Wn(2)/2;
   if (fl >= .5 | fl <= 0 | fh >= .5 | fh <= 0.)
      error('Frequencies must fall in range between 0 and 1.')
   end
   c1=fh-fl;
   if (c1 <= 0)
      error('Wn(1) must be less than Wn(2).')
   end
else
   c1=fl;
   if (fl >= .5 | fl <= 0)
      error('Frequency must lie between 0 and 1')
   end
end

nhlf = fix((N + 1)/2);
i1=1 + odd;

if Btype == 1			% lowpass
if odd
   b(1) = 2*c1;
end
xn=(odd:nhlf-1) + .5*(1-odd);
c=pi*xn;
c3=2*c1*c;
b(i1:nhlf)=(sin(c3)./c);
b = real([b(nhlf:-1:i1) b(1:nhlf)].*wind(:)');
gain = abs(polyval(b,1));
b = b/gain;
return;

elseif Btype ==2		% bandpass
b(1) = 2*c1;
xn=(odd:nhlf-1)+.5*(1-odd);
c=pi*xn;
c3=c*c1;
b(i1:nhlf)=2*sin(c3).*cos(c*(fl+fh))./c;
b=real([b(nhlf:-1:i1) b(1:nhlf)].*wind(:)');
gain = abs(polyval(b,exp(sqrt(-1)*pi*(fl+fh))));
b = b/gain;
return;

elseif Btype == 3		% highpass
b(1)=2*c1;
xn=(odd:nhlf-1);
c=pi*xn;
c3=2*c1*c;
b(i1:nhlf)=sin(c3)./c;
att=60.;
b=real([b(nhlf:-1:i1) b(1:nhlf)].*wind(:)');
b(nhlf)=1-b(nhlf);
b(1:nhlf-1)=-b(1:nhlf-1);
b(nhlf+1:N)=-b(nhlf+1:N);
gain = abs(polyval(b,-1));
b = b/gain;
return;

elseif Btype == 4		% bandstop
b(1) = 2*c1;
xn=(odd:nhlf-1)+.5*(1-odd);
c=pi*xn;
c3=c*c1;
b(i1:nhlf)=2*sin(c3).*cos(c*(fl+fh))./c;
b=real([b(nhlf:-1:i1) b(1:nhlf)].*wind(:)');
b(nhlf)=1-b(nhlf);
b(1:nhlf-1)=-b(1:nhlf-1);
b(nhlf+1:N)=-b(nhlf+1:N);
gain = abs(polyval(b,1));
b = b/gain;
return;
end

