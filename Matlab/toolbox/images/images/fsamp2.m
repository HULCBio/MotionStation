function h = fsamp2(f1,f2,hd,siz)
%FSAMP2 Design 2-D FIR filter using frequency sampling.
%   FSAMP2 designs two-dimensional FIR filters based on a desired
%   two-dimensional frequency response sampled at points on the
%   Cartesian plane.
%
%   H = FSAMP2(HD) designs a two-dimensional FIR filter with
%   frequency response HD, and returns the filter coefficients in
%   matrix H. (FSAMP2 returns H as a computational molecule,
%   which is the appropriate form to use with FILTER2.) The
%   filter H has a frequency response that passes through points
%   in HD. If HD is M-by-N then H is also M-by-N.
%
%   HD is a matrix containing the desired frequency response
%   sampled at equally spaced points between -1.0 and 1.0 along
%   the x and y frequency axes, where 1.0 corresponds to half the
%   sampling frequency, or pi radians. For accurate results, use
%   frequency points returned by FREQSPACE to create HD.
%
%   H = FSAMP2(F1,F2,HD,[M N]) produces an M-by-N FIR filter by
%   matching the filter response HD at the points in the vectors
%   F1 and F2. The resulting filter fits the desired response as
%   closely as possible in the least squares sense. For best
%   results, there must be at least M*N desired frequency
%   points. FSAMP2 issues a warning if you specify fewer than M*N
%   points.
%
%   Class Support
%   -------------
%   The input matrix HD must be numeric and nonsparse. All other 
%   inputs to FSAMP2 must be of class double. All outputs are of 
%   class double.
%
%   Example
%   -------
%   Use FSAMP2 to design an approximately symmetric
%   two-dimensional bandpass filter with passband between 0.1 and
%   0.5 (normalized frequency).
%   
%       [f1,f2] = freqspace(21,'meshgrid');
%       Hd = ones(size(f1));
%       r = sqrt(f1.^2 + f2.^2);
%       Hd((r<0.1) | (r>0.5)) = 0;
%       h = fsamp2(Hd);
%       freqz2(h)
%
%   See also CONV2, FILTER2, FREQSPACE, FTRANS2, FWIND1, FWIND2.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.20.4.2 $  $Date: 2003/11/11 12:35:01 $

% Reference: Jae S. Lim, "Two Dimensional Signal and Image Processing",
%            Prentice Hall, 1990, pages 213-217.

checknargin(1,4,nargin,mfilename);

if nargin==1, % Uniform spacing case (fast)
  hd = f1;
  hd = rot90(fftshift(rot90(hd,2)),2); % Inverse fftshift
  h = double(fftshift(ifft2(hd)));

elseif nargin==2 | nargin==3,
  msg = 'Wrong number of input arguments.';
  eid = sprintf('Images:%s:expectedOneOrFourInputs',mfilename);
  error(eid, msg);

else, % Create filter of size SIZ to solve problem at the points (f1,f2,hd)
  if ~isa(hd, 'double')
    hd = double(hd);
  end
   
  % Expand f1 and f2 if they are vectors.
  if min(size(f1))==1 & min(size(f2))==1 & any(size(hd)~=size(f1)),
    [f1,f2] = meshgrid(f1,f2);
  end

  if prod(size(hd))<prod(siz),
      msg = ['Not enough desired frequency points.' ...
             '  Results may be inaccurate.'];
      wid = sprintf('Images:%s:notEnoughFreqPoints',mfilename);
      warning(wid,msg);
  end

  % Convert frequency to radians.
  f1 = f1*pi; f2 = f2*pi;
  h = zeros(siz);
  [n1,n2] = meshgrid((0:siz(2)-1)-floor(siz(2)/2),(0:siz(1)-1)-floor(siz(1)/2));
  DFT = exp(-sqrt(-1)*f1(:)*n1(:)').*exp(-sqrt(-1)*f2(:)*n2(:)');
  h(:) = DFT\hd(:);

end  

% Convert to real if possible.
if all(max(abs(imag(h)))<sqrt(eps)), h = real(h); end

h = rot90(h,2); % Rotate for use with filter2
