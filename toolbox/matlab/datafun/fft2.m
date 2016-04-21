function f = fft2(x, mrows, ncols)
%FFT2 Two-dimensional discrete Fourier Transform.
%   FFT2(X) returns the two-dimensional Fourier transform of matrix X.
%   If X is a vector, the result will have the same orientation.
%
%   FFT2(X,MROWS,NCOLS) pads matrix X with zeros to size MROWS-by-NCOLS
%   before transforming.
%
%   Class support for input X: 
%      float: double, single
%
%   See also FFT, FFTN, FFTSHIFT, FFTW, IFFT, IFFT2, IFFTN.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.13.4.2 $  $Date: 2004/03/09 16:16:17 $

if ndims(x)==2
    if nargin==1
        f = fftn(x);
    else
        f = fftn(x,[mrows ncols]);
    end
else
    if nargin==1
        f = fft(fft(x,[],2),[],1);
    else
        f = fft(fft(x,ncols,2),mrows,1);
    end
end   
