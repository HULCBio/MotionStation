function h = fwind1(f1,f2,hd,w1,w2)
%FWIND1 Design 2-D FIR filter using 1-D window method.
%   FWIND1 designs two-dimensional FIR filters using the window
%   method. FWIND1 uses a one-dimensional window specification to
%   design a two-dimensional FIR filter based on the desired
%   frequency response HD. FWIND1 works with one-dimensional
%   windows only; use FWIND2 to work with two-dimensional
%   windows.
%
%   H = FWIND1(HD,WIN) designs a two-dimensional FIR filter H
%   with frequency response HD. (FWIND1 returns H as a
%   computational molecule, which is the appropriate form to use
%   with FILTER2.) FWIND1 uses the one-dimensional window WIN to
%   form an approximately circularly symmetric two-dimensional
%   window using Huang's method. You can specify WIN using
%   window functions in the Signal Processing Toolbox, such as
%   BOXCAR, HAMMING, HANNING, BARTLETT, BLACKMAN, KAISER, or
%   CHEBWIN. If length(WIN) is N, then H is N-by-N.
%
%   HD is a matrix containing the desired frequency response
%   sampled at equally spaced points between -1.0 and 1.0 (in
%   normalized frequency, where 1.0 corresponds to half the
%   sampling frequency, or pi radians) along the x and y
%   frequency axes. For accurate results, use frequency points
%   returned by FREQSPACE to create HD. 
%
%   H = FWIND1(HD,WIN1,WIN2) uses the two one-dimensional windows
%   WIN1 and WIN2 to create a separable two-dimensional
%   window. If length(WIN1) is N and length(WIN2) is M, then H is
%   M-by-N.
%
%   H = FWIND1(F1,F2,HD,...) lets you specify the desired
%   frequency response HD at arbitrary frequencies (F1 and F2, in
%   normalized frequency) along the x and y axes. The length of
%   the window(s) controls the size of the resulting filter, as
%   above.
%
%   Class Support
%   -------------
%   The input matrix Hd can be of class double or of any
%   integer class.  All other inputs to FWIND1 must be of
%   class double.  All outputs are of class double.
%
%   Example
%   -------
%   Use FWIND1 to design an approximately circularly symmetric
%   two-dimensional bandpass filter with passband between 0.1 and
%   0.5 (normalized frequency).
%
%       [f1,f2] = freqspace(21,'meshgrid');
%       Hd = ones(21);
%       r = sqrt(f1.^2 + f2.^2);
%       Hd((r<0.1) | (r>0.5)) = 0;
%       h = fwind1(Hd,hamming(21));
%       freqz2(h)
%
%   See also CONV2, FILTER2, FSAMP2, FREQSPACE, FTRANS2, FWIND2.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.19.4.1 $  $Date: 2003/01/26 05:55:26 $

% Reference: Jae S. Lim, "Two Dimensional Signal and Image Processing",
%            Prentice Hall, 1990, pages 213-217.

checknargin(2,5,nargin,mfilename);

method1 = 'linear';
method2 = 'bilinear';

if nargin==2, % Uniform spacing case with Huang's method
  hd = f1; w1 = f2;
  n = length(w1); m = n;
elseif nargin==3, % Uniform spacing with separable window
  w2 = hd;  hd = f1; w1 = f2;
  n = length(w1); m = length(w2);
elseif nargin==4, % Non-uniform spacing with Huang's method
  n = length(w1); m = n;
else
  n = length(w1); m = length(w2);
end


%
% Create 2-D window using either Huang's method or separable method.
%
if nargin==2 | nargin==4, % Huang's method: Create 2-D circular window
  if any(abs(w1-rot90(w1,2))>sqrt(eps)),
    msg = '1-D window must be symmetric to use Huang''s method.';
    eid = sprintf('Images:%s:oneDWindowMustBeSymmetric',mfilename);
    error(eid,msg);
  end
  if length(w1)<2,
    msg = 'Length of window must be greater than 1.';
    eid = sprintf('Images:%s:windowLengthMustBeGreaterThanOne',mfilename);
    error(eid,msg);
  end

  t = (-(n-1)/2:(n-1)/2)*(2/(n-1));
  [t1,t2] = meshgrid(t,t);
  t12 = sqrt(t1.*t1 + t2.*t2);
  d = find(t12<t(1) | t12>t(length(w1)));
  if ~isempty(d), t12(d) = zeros(size(d)); end
  w = zeros(size(t12)); w(:) = interp1(t,w1,t12(:),method1);
  if ~isempty(d), w(d) = zeros(size(d)); end

else % Create separable window
  w = w2(:)*w1(:).';

end

%
% Design filter using fsamp2 and apply window
%
if nargin<4, % Uniformly spaced data
  % Interpolate Hd to be the same size as W, if necessary
  if any([m n]~=size(hd)), 
    if any(size(hd)<[2 2]),
        msg = 'Hd must have at least 2 rows and 2 columns.';
        eid = sprintf('Images:%s:hdMustHaveAtLeast2rowsAnd2cols',mfilename);
        error(eid,msg);
    end

    [f1,f2] = freqspace(size(hd));
    % Extrapolate hd so that interpolation is never out of range.
    [mh,nh] = size(hd);
    if floor(nh/2)==nh/2, % if even
      hd = [hd,hd(:,1)]; f1 = [f1 1];
    else
      hd = [zeros(mh,1) hd zeros(mh,1)]; 
      df = f1(2)-f1(1); f1 = [f1(1)-df f1 f1(nh)+df];
    end
    [mh,nh] = size(hd);
    if floor(mh/2)==mh/2, % if even
      hd = [hd;hd(1,:)]; f2 = [f2 1];
    else
      hd = [zeros(1,nh);hd;zeros(1,nh)]; 
      df = f2(2)-f2(1); f2 = [f2(1)-df f2 f2(mh)+df];
    end
    [t1,t2] = freqspace([m n],'meshgrid');
    
    % Promote to double for call to interp2
    if ~isa(hd,'double')
       hd = double(hd);
    end
    
    hd = interp2(f1,f2,hd,t1,t2,method2);
    d = find(isnan(hd)); if ~isempty(d), hd(d) = zeros(size(d)); end
  end
  h = fsamp2(hd) .* w;

else % Non-uniformly spaced data
  h = fsamp2(f1,f2,hd,size(w)) .* w;

end
