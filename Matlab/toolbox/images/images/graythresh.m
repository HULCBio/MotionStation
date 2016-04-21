function level = graythresh(I)
%GRAYTHRESH Compute global image threshold using Otsu's method.
%   LEVEL = GRAYTHRESH(I) computes a global threshold (LEVEL) that can be
%   used to convert an intensity image to a binary image with IM2BW. LEVEL
%   is a normalized intensity value that lies in the range [0, 1].
%   GRAYTHRESH uses Otsu's method, which chooses the threshold to minimize
%   the intraclass variance of the thresholded black and white pixels.
%
%   Class Support
%   -------------
%   The input image I can be of class uint8, uint16, or double and it
%   must be nonsparse.  LEVEL is a double scalar.
%
%   Example
%   -------
%       I = imread('coins.png');
%       level = graythresh(I);
%       BW = im2bw(I,level);
%       imview(BW)
%
%   See also IM2BW.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.9.4.5 $  $Date: 2003/08/23 05:52:18 $

% Reference:
% N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
% IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
% pp. 62-66, 1979.

% One input argument required.
checknargin(1,1,nargin,mfilename);
checkinput(I,{'uint8','uint16' 'double'},{'nonsparse'},mfilename,'I',1);

if ~isempty(I)
  % Convert all N-D arrays into a single column.  Convert to uint8 for
  % fastest histogram computation.
  I = im2uint8(I(:));
  num_bins = 256;
  counts = imhist(I,num_bins);
  
  % Variables names are chosen to be similar to the formulas in
  % the Otsu paper.
  p = counts / sum(counts);
  omega = cumsum(p);
  mu = cumsum(p .* (1:num_bins)');
  mu_t = mu(end);
  
  previous_state = warning('off', 'MATLAB:divideByZero');
  sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));
  warning(previous_state);

  % Find the location of the maximum value of sigma_b_squared.
  % The maximum may extend over several bins, so average together the
  % locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
  % then return 0.
  maxval = max(sigma_b_squared);
  if isfinite(maxval)
    idx = mean(find(sigma_b_squared == maxval));
    
    % Normalize the threshold to the range [0, 1].
    level = (idx - 1) / (num_bins - 1);
  else
    level = 0.0;
  end
else
  level = 0.0;
end
