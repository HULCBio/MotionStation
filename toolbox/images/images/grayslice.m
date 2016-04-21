function bout=grayslice(I,z)
%GRAYSLICE Create indexed image from intensity image by thresholding.
%   X=GRAYSLICE(I,N) thresholds the intensity image I using
%   threshold values 1/n, 2/n, ..., (n-1)/n, returning an indexed
%   image in X.
%
%   X=GRAYSLICE(I,V), where V is a vector of values between 0 and
%   1, thresholds I using the values of V as thresholds,
%   returning an indexed image in X.
%
%   You can view the thresholded image using IMSHOW(X,MAP) with a
%   colormap of appropriate length.
%
%   Class Support
%   -------------
%   The input image I can be of class uint8, uint16, or double,
%   and it must be nonsparse. Note that the threshold values are
%   always between 0 and 1, even if I is of class uint8 or uint16.
%   In this case, each threshold value is multiplied by 255 or 
%   65535 to determine the actual threshold to use.
%
%   The class of the output image X depends on the number of
%   threshold values, as specified by N or length(V). If the
%   number of threshold values is less than 256, then X is of
%   class uint8, and the values in X range from 0 to N or
%   length(V). If the number of threshold values is 256 or
%   greater, X is of class double, and the values in X range from
%   1 to N+1 or length(V)+1.
%
%   Example
%   -------
%   Use multilevel thresholding to enhance high intensity areas in the image.
%
%       I = imread('snowflakes.png');
%       X = grayslice(I,16);
%       imview(I),imview(X,jet(16))
%
%   See also GRAY2IND.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.22.4.2 $  $Date: 2003/05/03 17:50:32 $


checknargin(1,2,nargin,mfilename);
checkinput(I,'double uint8 uint16','nonsparse',mfilename,'I',1);

if nargin<2, z = 10; end

if ((prod(size(z)) == 1) & ((round(z)==z) | (z>1)))
   % arg2 is scalar: Integer number of equally spaced levels.
   n = z; 
   if isa(I,'uint8'), 
      z = 255*(0:(n-1))/n; 
   elseif isa(I, 'uint16')
      z = 65535*(0:(n-1))/n; 
   else % I is double
      z = (0:(n-1))/n;
   end
else
   % arg2 is vector containing threshold levels
   n = length(z)+1;
   if isa(I,'uint8')
      zmax = 255;
      zmin = 0;
   elseif isa(I,'uint16')
      zmax = 65535;
      zmin = 0;
   else    % I was a double
      zmax = max(1,max(I(:)));
      zmin = min(0,min(I(:))); 
   end
   % if z isn't double, promote it to double for the call to sort
   if ~isa(z, 'double'), 
      z = double(z); 
   end;
   z = [zmin,max(zmin,min(zmax,sort(z(:)')))]; % sort and threshold z
end

% Get output matrix of appropriate size and type
if n<256
   b = repmat(uint8(0), size(I));  
else 
   b = zeros(size(I)); 
end

% Loop over all intervals, except the last
for i=1:length(z)-1,
   % j is the index value we will output, so it depend upon storage class
   if isa(b,'uint8'), 
      j = i-1; 
   else 
      j = i;  
   end
   d = find(I>=z(i) & I<z(i+1));
   if ~isempty(d), 
      b(d) = j; 
   end
end

% Take care of that last interval
d = find(I >= z(end));
if ~isempty(d)
   % j is the index value we will output, so it depend upon storage class
   if isa(b, 'uint8'), 
      j = length(z)-1; 
   else 
      j = length(z); 
   end
   b(d) = j; 
end

if nargout==0,
   imshow(b,jet(n))
   return
end
bout = b;





