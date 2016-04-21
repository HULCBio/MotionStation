function h = fwind2(f1,f2,hd,w)
%FWIND2 Design 2-D FIR filter using 2-D window method.
%   Use FWIND2 to design two-dimensional FIR filters using the
%   window method. FWIND2 uses a two-dimensional window
%   specification to design a two-dimensional FIR filter based on
%   the desired frequency response HD. FWIND2 works with
%   two-dimensional windows; use FWIND1 to work with
%   one-dimensional windows.
%
%   H = FWIND2(HD,WIN) produces the two-dimensional FIR filter H
%   using an inverse Fourier transform of the desired frequency
%   response HD and multiplication by the window WIN. HD is a
%   matrix containing the desired frequency response at equally
%   spaced points in the Cartesian plane. FWIND2 returns H as a 
%   computational molecule, which is the appropriate form to use
%   with FILTER2. The size of WIN controls the size of the
%   resulting filter; if WIN is M-by-N then H will also be
%   M-by-N.
%
%   For accurate results, use frequency points returned by
%   FREQSPACE to create HD.
%
%   H = FWIND2(F1,F2,HD,WIN) lets you specify the desired
%   frequency response HD at arbitrary frequencies (F1 and F2)
%   along the x and y axes. The frequency vectors F1 and F2
%   should be in the range -1.0 to 1.0, where 1.0 corresponds to
%   half the sampling frequency, or pi radians.
%
%   Class Support
%   -------------
%   The input matrix Hd can be of class double or of any
%   integer class.  All other inputs to FWIND2 must be of
%   class double.  All outputs are of class double.
%
%   Example
%   -------
%   Use FWIND2 to design an approximately circularly symmetric
%   two-dimensional bandpass filter with passband between 0.1 and
%   0.5 (normalized frequency).
%
%       [f1,f2] = freqspace(21,'meshgrid');
%       Hd = ones(21);
%       r = sqrt(f1.^2 + f2.^2);
%       Hd((r<0.1) | (r>0.5)) = 0;
%       win = fspecial('gaussian',21,2);
%       win = win ./ max(win(:));  % Make the maximum window value be 1.
%       h = fwind2(Hd,win);
%       freqz2(h)
%
%   See also CONV2, FILTER2, FSAMP2, FREQSPACE, FTRANS2, FWIND1.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.18.4.1 $  $Date: 2003/01/26 05:55:27 $

% Reference: "Two Dimensional Signal and Image Processing" by Jae S. Lim,
%            pages 213-217.

checknargin(2,4,nargin,mfilename);

method = 'bilinear';

if nargin==2, % Uniform spacing case
  hd = f1; w = f2;
  if any(size(w)~=size(hd)), % Interpolate Hd to be the same size as W
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
    [i1,i2] = freqspace(size(w),'meshgrid');
    
    % Promote to double for call to interp2
    if ~isa(hd,'double')
       hd = double(hd);
    end
    
    hd = interp2(f1,f2,hd,i1,i2,method);
    d = find(isnan(hd)); if ~isempty(d), hd(d) = zeros(size(d)); end
  end
  h = fsamp2(hd) .* w;

elseif nargin==3,
  msg = 'Wrong number(3) of input arguments.';
  eid = sprintf('Images:%s:wrongNumberOfInputArgs',mfilename);
  error(eid,msg);
else % Non-uniform spacing case
  h = fsamp2(f1,f2,hd,size(w)) .* w;
end
