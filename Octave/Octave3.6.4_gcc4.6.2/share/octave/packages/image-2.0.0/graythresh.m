## Copyright (C) 2004 Antti Niemistö <antti.niemisto@tut.fi>
## Copyright (C) 2007 Søren Hauberg
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {[@var{level}, @var{sep}] =} graythresh (@var{img})
## @deftypefnx {Function File} {[@var{level}, @var{sep}] =} graythresh (@var{img}, @var{method}, @var{options})
## @deftypefnx {Function File} {[@var{level}, @var{sep}] =} graythresh (@var{hist}, @dots{})
## Compute global image threshold.
##
## Given an image @var{img} finds the optimal threshold value @var{level} for
## conversion to a binary image with @code{im2bw}.  Color images are converted
## to grayscale before @var{level} is computed.  An image histogram @var{hist}
## can also be used to allow for preprocessing of the histogram.
##
## The optional argument @var{method} is the algorithm to be used (default's to
## Otsu).  Some methods may have other @var{options} and/or return an extra
## value @var{sep} (see each entry for details).  The available @var{method}s are:
##
## @table @asis
## @item Otsu (default)
## Implements Otsu's method as described in @cite{Nobuyuki Otsu (1979). "A
## threshold selection method from gray-level histograms", IEEE Trans. Sys.,
## Man., Cyber. 9 (1): 62-66}. This algorithm chooses the threshold to minimize
## the intraclass variance of the black and white pixels.
##
## The second output, @var{sep} represents the ``goodness'' (or separability) of
## the threshold at @var{level}.  It is a value within the range [0 1], the
## lower bound (zero) being attainable by, and only by, histograms having a
## single constant gray level, and the upper bound being attainable by, and only
## by, two-valued pictures.
##
## @item concavity
## Find a global threshold for a grayscale image by choosing the threshold to
## be in the shoulder of the histogram @cite{A. Rosenfeld, and P. De La Torre
## (1983). "Histogram concavity analysis as an aid in threshold selection", IEEE
## Transactions on Systems, Man, and Cybernetics, 13: 231-235}.
##
## @item Huang
## Not yet implemented.
##
## @item ImageJ
## A variation of the intermeans algorithm, this is the default for ImageJ.
## Not yet implemented.
##
## @item intermodes
## This assumes a bimodal histogram and chooses the threshold to be the mean of
## the two peaks of the bimodal histogram @cite{J. M. S. Prewitt, and M. L.
## Mendelsohn (1966). "The analysis of cell images", Annals of the New York
## Academy of Sciences, 128: 1035-1053}.
##
## Images with histograms having extremely unequal peaks or a broad and flat
## valley are unsuitable for this method.
##
## @item intermeans
## Iterative procedure based on the iterative intermeans algorithm of @cite{T.
## Ridler, and S. Calvard (1978). "Picture thresholding using an iterative
## selection method", IEEE Transactions on Systems, Man, and Cybernetics, 8: 630-632}
## and @cite{H. J. Trussell (1979). "Comments on 'Picture thresholding using an
## iterative selection method'", IEEE Transactions on Systems, Man, and Cybernetics,
## 9: 311}.
##
## Note that several implementations of this method exist. See the source code
## for details.
##
## @item Li
## Not yet implemented.
##
## @item MaxEntropy
## Implements Kapur-Sahoo-Wong (Maximum Entropy) thresholding method based on the
## entropy of the image histogram @cite{J. N. Kapur, P. K. Sahoo, and A. C. K. Wong
## (1985). "A new method for gray-level picture thresholding using the entropy
## of the histogram", Graphical Models and Image Processing, 29(3): 273-285}.
##
## @item MaxLikelihood
## Find a global threshold for a grayscale image using the maximum likelihood
## via expectation maximization method @cite{A. P. Dempster, N. M. Laird, and D. B.
## Rubin (1977). "Maximum likelihood from incomplete data via the EM algorithm",
## Journal of the Royal Statistical Society, Series B, 39:1-38}.
##
## @item mean
## The mean intensity value. It is mostly used by other methods as a first guess
## threshold.
##
## @item MinError
## An iterative implementation of Kittler and Illingworth's Minimum Error
## thresholding @cite{J. Kittler, and J. Illingworth (1986). "Minimum error
## thresholding", Pattern recognition, 19: 41-47}.
##
## This implementation seems to converge more often than the original.
## Nevertheless, sometimes the algorithm does not converge to a solution. In
## that case a warning is displayed and defaults to the initial estimate of the
## mean method.
##
## @item minimum
## This assumes a bimodal histogram and chooses the threshold to be in the
## valley of the bimodal histogram.  This method is also known as the mode
## method @cite{J. M. S. Prewitt, and M. L. Mendelsohn (1966). "The analysis of
## cell images", Annals of the New York Academy of Sciences, 128: 1035-1053}.
##
## Images with histograms having extremely unequal peaks or a broad and flat
## valley are unsuitable for this method.
##
## @item moments
## Find a global threshold for a grayscale image using moment preserving
## thresholding method @cite{W. Tsai (1985). "Moment-preserving thresholding:
## a new approach", Computer Vision, Graphics, and Image Processing, 29: 377-393}
##
## @item percentile
## Assumes a specific fraction of pixels (set at @var{options}) to be background.
## If no value is given, assumes 0.5 (equal distribution of background and foreground)
## @cite{W Doyle (1962). "Operation useful for similarity-invariant pattern
## recognition", Journal of the Association for Computing Machinery 9: 259-267}
##
## @item RenyiEntropy
## Not yet implemented.
##
## @item Shanbhag
## Not yet implemented.
##
## @item triangle
## Not yet implemented.
##
## @item Yen
## Not yet implemented.
## @end table
##
## @seealso{im2bw}
## @end deftypefn

## Notes:
##  * The following methods were adapted from http://www.cs.tut.fi/~ant/histthresh/
##      intermodes    percentile      minimum
##      MaxEntropy    MaxLikelihood   intermeans
##      moments       minerror        concavity
##  * Carnë Draug implemented and vectorized the Otsu's method

function [varargout] = graythresh (img, algo = "otsu", varargin)
  ## Input checking
  if (nargin < 1 || nargin > 3)
    print_usage();
  elseif (nargin > 2 && !any (strcmpi (algo, {"percentile"})))
    error ("graythresh: algorithm `%s' does not accept any options.", algo);
  else
    hist_in = false;
    ## If the image is RGB convert it to grayscale
    if (isrgb (img))
      img = rgb2gray (img);
    elseif (isgray (img))
      ## do nothing
    elseif (isvector (img) && !issparse (img) && isreal (img) && all (img >= 0))
      hist_in = true;
      ihist   = img;
    else
      error ("graythresh: input must be an image or an histogram.");
    endif
  endif

  ## the "mean" is the simplest of all, we can get rid of it right here
  if (strcmpi (algo, "mean"))
    varargout{1} = mean (im2double(img)(:));
    return
  endif

  ## we only need to do this if the input is an image. If an histogram, is
  ## supplieed, no need to do any of this
  if (!hist_in)
    ## if image is uint we do nothing. If it's int, then we convert to uint since
    ## it may mess up calculations later. If it's double we need some bins so we
    ## choose uint8 by default... but should we adjust the histogram before?
    if (isa (img, "uint16") || isa (img, "uint8"))
      ## do nothing
    elseif (isa (img, "int16"))
      img     = im2uint16 (img);
      img_max = 65535;
    else
      img = im2uint8 (img);
    endif
    ihist = hist (img(:), 0:intmax (class (img)));
  endif

  switch tolower (algo)
    case {"concavity"},     thresh = concavity      (ihist);
    case {"intermeans"},    thresh = intermeans     (ihist, floor (mean (img (:))));
    case {"intermodes"},    thresh = intermodes     (ihist);
    case {"maxentropy"},    thresh = maxentropy     (ihist);
    case {"maxlikelihood"}, thresh = maxlikelihood  (ihist);
    case {"minerror"},      thresh = minerror_iter  (ihist, floor (mean (img (:))));
    case {"minimum"},       thresh = minimum        (ihist);
    case {"moments"},       thresh = moments        (ihist);
    case {"otsu"},          thresh = otsu           (ihist, nargout > 1);
    case {"percentile"},    thresh = percentile     (ihist, varargin{1});
    otherwise, error ("graythresh: unknown method '%s'", algo);
  endswitch
  ## normalize the threshold value to the [0 1] range
  thresh{1} = double (thresh{1}) / (numel (ihist) - 1);

  ## some algorithms may return more than one value...
  for i = 1:numel (thresh)
    varargout{i} = thresh{i};
  endfor
endfunction

function [thresh] = otsu (ihist, compute_good)
  ## this method is quite well explained at
  ## http://www.labbookpages.co.uk/software/imgProc/otsuThreshold.html
  ##
  ## It does not, however, explain how to compute the goodness of threshold and
  ## there's not many pages explaining it either. For that, one really needs to
  ## check the paper.
  ##
  ## The implemententation on the link above assumes that threshold is to be
  ## made for values "greater or equal than" but that is not the case (in im2bw
  ## and also not ImageJ) so we subtract 1 at the end.

  bins  = 0:(numel (ihist) - 1);
  total = sum (ihist);
  ## b = black, w = white
  b_totals  = cumsum ([0 ihist(1:end-1)]);
  b_weights = b_totals / total;
  b_means   = [0 cumsum(bins(1:end-1) .* ihist(1:end-1))] ./ b_totals;

  w_totals  = total - b_totals;
  w_weights = w_totals / total;
  w_means   = (cumsum (bins(end:-1:1) .* ihist(end:-1:1)) ./ w_totals(end:-1:1))(end:-1:1);

  ## between class variance (its maximum is the best threshold)
  bcv       = b_weights .* w_weights .* (b_means - w_means).^2;
  ## in case there's more than one place with best maximum (for example, a group
  ## of empty bins, we select the one in the center (this is compatible with ImageJ)
  thresh{1} = ceil (mean (find (bcv == max (bcv)))) - 2;
  ## we subtract 2, once for the 1 based indexes and another for the greater
  ## than or equal problem

  if (compute_good)
    ## basically we need to divide the between class variance by the total
    ## variance which is a single value, independent of the threshold. From the
    ## paper, last of the equation 12, eta = sigma²b / sigma²t
    ##(where b = between and t = total)
    norm_hist      = ihist / total;
    total_mean     = sum (bins .* norm_hist);
    total_variance = sum (((bins - total_mean).^2) .* norm_hist);
    thresh{2}      = max (bcv) / total_variance;
  endif
endfunction

function level = moments (y)
  n = numel (y) - 1;

  % The threshold is chosen such that partial_sumA(y,t)/partial_sumA(y,n) is closest to x0.
  Avec = zeros (1, n+1);

  for t = 0:n
    Avec(t+1) = partial_sumA (y, t) / partial_sumA (y, n);
  end

  % The following finds x0.
  x2 = (partial_sumB(y,n)*partial_sumC(y,n) - partial_sumA(y,n)*partial_sumD(y,n)) / (partial_sumA(y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x1 = (partial_sumB(y,n)*partial_sumD(y,n) - partial_sumC(y,n)^2) / (partial_sumA (y,n)*partial_sumC(y,n) - partial_sumB(y,n)^2);
  x0 = .5 - (partial_sumB(y,n)/partial_sumA(y,n) + x2/2) / sqrt (x2^2 - 4*x1);

  % And finally the threshold.
  [minimum, ind] = min (abs (Avec-x0));
  level{1} = ind-1;
endfunction

function T = maxentropy(y)
  n = numel (y) - 1;

  dz_warn = warning ("query", "divide-by-zero");
  unwind_protect
    warning ("off", "Octave:divide-by-zero");
    % The threshold is chosen such that the following expression is minimized.
    for j = 0:n
      vec(j+1) = negativeE(y,j)/partial_sumA(y,j) - log10(partial_sumA(y,j)) + ...
          (negativeE(y,n)-negativeE(y,j))/(partial_sumA(y,n)-partial_sumA(y,j)) - log10(partial_sumA(y,n)-partial_sumA(y,j));
    end
  unwind_protect_cleanup
    ## restore broadcats warning status
    warning (dz_warn.state, "Octave:divide-by-zero");
  end_unwind_protect

  [minimum,ind] = min(vec);
  T{1} = ind-1;
endfunction

function [T] = intermodes (y)
  ## checked with ImageJ and is slightly different but not by much
  n = numel (y) - 1;

  % Smooth the histogram by iterative three point mean filtering.
  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = conv2(y,h,'same');
    iter = iter+1;
    % If the histogram turns out not to be bimodal, set T to zero.
    if iter > 10000;
      T = 0;
      return
    end
  end

  % The threshold is the mean of the two peaks of the histogram.
  ind = 0;
  for k = 2:n
    if y(k-1) < y(k) && y(k+1) < y(k)
      ind = ind+1;
      TT(ind) = k-1;
    end
  end
  T{1} = floor(mean(TT));
endfunction

function [T] = percentile (y, p)
  n = numel (y) - 1;

  % The threshold is chosen such that 50% of pixels lie in each category.
  Avec = zeros(1,n+1);
  for t = 0:n
    Avec(t+1) = partial_sumA(y,t)/partial_sumA(y,n);
  end

  [minimum,ind] = min(abs(Avec-p));
  T{1} = ind-1;
endfunction


function T = minimum(y)
  n = numel (y) - 1;

  % Smooth the histogram by iterative three point mean filtering.
  iter = 0;
  while ~bimodtest(y)
    h = ones(1,3)/3;
    y = conv2(y,h,'same');
    iter = iter+1;
    % If the histogram turns out not to be bimodal, set T to zero.
    if iter > 10000;
      T{1} = 0;
      return
    end
  end

  % The threshold is the minimum between the two peaks.
  for k = 2:n
    if y(k-1) > y(k) && y(k+1) > y(k)
      T{1} = k-1;
    end
  end
endfunction

function [Tout] = minerror_iter (y, T)
  n = numel (y) - 1;

  Tprev = NaN;

  dz_warn = warning ("query", "divide-by-zero");
  unwind_protect
    warning ("off", "Octave:divide-by-zero");
    while T ~= Tprev
      % Calculate some statistics.
      mu = partial_sumB(y,T)/partial_sumA(y,T);
      nu = (partial_sumB(y,n)-partial_sumB(y,T))/(partial_sumA(y,n)-partial_sumA(y,T));
      p = partial_sumA(y,T)/partial_sumA(y,n);
      q = (partial_sumA(y,n)-partial_sumA(y,T)) / partial_sumA(y,n);
      sigma2 = partial_sumC(y,T)/partial_sumA(y,T)-mu^2;
      tau2 = (partial_sumC(y,n)-partial_sumC(y,T)) / (partial_sumA(y,n)-partial_sumA(y,T)) - nu^2;

      % The terms of the quadratic equation to be solved.
      w0 = 1/sigma2-1/tau2;
      w1 = mu/sigma2-nu/tau2;
      w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));

      % If the next threshold would be imaginary, return with the current one.
      sqterm = w1^2-w0*w2;
      if sqterm < 0
        warning('MINERROR:NaN','Warning: th_minerror_iter did not converge.')
        break
      endif

      % The updated threshold is the integer part of the solution of the
      % quadratic equation.
      Tprev = T;
      T = floor((w1+sqrt(sqterm))/w0);

      % If the threshold turns out to be NaN, return with the previous threshold.
      if isnan(T)
        warning('MINERROR:NaN','Warning: th_minerror_iter did not converge.')
        T = Tprev;
      end
    endwhile
  unwind_protect_cleanup
    ## restore broadcats warning status
    warning (dz_warn.state, "Octave:divide-by-zero");
  end_unwind_protect
  Tout{1} = T;
endfunction
#{
  ## this is an implementation of the original minerror algorithm but seems
  ## to converge less often than the iterative version. This one is also from the
  ## HistThresh toolbox
  function T = th_minerror(I,n)
    if nargin == 1
      n = 255;
    end

    I = double(I);

    % Calculate the histogram.
    y = hist(I(:),0:n);

    % The threshold is chosen such that the following expression is minimized.
    for j = 0:n
      mu = partial_sumB(y,j)/partial_sumA(y,j);
      nu = (partial_sumB(y,n)-partial_sumB(y,j))/(partial_sumA(y,n)-partial_sumA(y,j));
      p = partial_sumA(y,j)/partial_sumA(y,n);
      q = (partial_sumA(y,n)-partial_sumA(y,j)) / partial_sumA(y,n);
      sigma2 = partial_sumC(y,j)/partial_sumA(y,j)-mu^2;
      tau2 = (partial_sumC(y,n)-partial_sumC(y,j)) / (partial_sumA(y,n)-partial_sumA(y,j)) - nu^2;
      vec(j+1) = p*log10(sqrt(sigma2)/p) + q*log10(sqrt(tau2)/q);
    end

    vec(vec==-inf) = NaN;
    [minimum,ind] = min(vec);
    T = ind-1;
  endfunction
#}

function Tout = maxlikelihood (y)
  ## this method seems to be broken. When we got it from the HistThresh toolbox,
  ## the author, Antti Niemistö, said:
  ##
  ## By the way, there appears to be a bug in my implementation of MAXLIK, and I
  ## never got around to fixing it. The loop in that function is never actually
  ## entered so it always returns the first estimate of the threshold. I think
  ## this would be easy to fix...
  ##
  ## Instead of a do-until loop, there was a while loop where the x_prev variables
  ## were set to NaN. This caused the loop to never start. However, fixing that
  ## seems to cause the loop to never exit...

  n = numel (y) - 1;

  ## initial estimate for the threshold is found with the minimum algorithm
  T = minimum (y){1};

  ## initial values for the statistics
  mu     = partial_sumB (y, T) / partial_sumA (y, T);
  nu     = (partial_sumB (y, n) - partial_sumB (y, T)) / (partial_sumA (y, n) - partial_sumA (y, T));
  p      = partial_sumA (y, T) / partial_sumA (y, n);
  q      = (partial_sumA (y, n) - partial_sumA (y, T)) / partial_sumA (y, n);
  sigma2 = partial_sumC (y, T) / partial_sumA (y, T) - mu^2;
  tau2   = (partial_sumC (y, n) - partial_sumC (y, T)) / (partial_sumA (y, n) - partial_sumA (y, T)) - nu^2;

  do
    ## we store the previous values for comparison at the end (we will stop when
    ## they stop changing)
    mu_prev     = mu;
    nu_prev     = nu;
    p_prev      = p;
    q_prev      = q;
    sigma2_prev = nu;
    tau2_prev   = nu;

    for i = 0:n
      phi(i+1) = p/q * exp(-((i-mu)^2) / (2*sigma2)) / ...
          (p/sqrt(sigma2) * exp(-((i-mu)^2) / (2*sigma2)) + ...
           (q/sqrt(tau2)) * exp(-((i-nu)^2) / (2*tau2)));
    endfor
    ind   = 0:n;
    gamma = 1-phi;
    F     = phi*y';
    G     = gamma*y';

    mu      = ind.*phi*y'/F;
    nu      = ind.*gamma*y'/G;
    p       = F / partial_sumA (y,n);
    q       = G / partial_sumA (y,n);
    sigma2  = ind.^2.*phi*y'/F - mu^2;
    tau2    = ind.^2.*gamma*y'/G - nu^2;
  until (abs (mu - mu_prev)         <= eps && abs (nu - nu_prev)     <= eps && ...
         abs (p  - p_prev)          <= eps && abs (q - q_prev)       <= eps && ...
         abs (sigma2 - sigma2_prev) <= eps && abs (tau2 - tau2_prev) <= eps)

  ## the terms of the quadratic equation to be solved
  w0 = 1/sigma2-1/tau2;
  w1 = mu/sigma2-nu/tau2;
  w2 = mu^2/sigma2 - nu^2/tau2 + log10((sigma2*q^2)/(tau2*p^2));

  ## If the threshold would be imaginary, return with threshold set to zero
  sqterm = w1^2-w0*w2;
  if (sqterm < 0)
    Tout{1} = 0;
    return
  endif

  ## The threshold is the integer part of the solution of the quadratic equation
  Tout{1} = floor((w1+sqrt(sqterm))/w0);
endfunction

function Tout = intermeans (y, T)
  n = numel (y) - 1;

  Tprev = NaN;

  % The threshold is found iteratively. In each iteration, the means of the
  % pixels below (mu) the threshold and above (nu) it are found. The
  % updated threshold is the mean of mu and nu.
  while T ~= Tprev
    mu = partial_sumB(y,T)/partial_sumA(y,T);
    nu = (partial_sumB(y,n)-partial_sumB(y,T))/(partial_sumA(y,n)-partial_sumA(y,T));
    Tprev = T;
    T = floor((mu+nu)/2);
  end
  Tout{1} = T;
endfunction

function T = concavity (h)
  n = numel (y) - 1;
  H = hconvhull(h);

  % Find the local maxima of the difference H-h.
  lmax = flocmax(H-h);

  % Find the histogram balance around each index.
  for k = 0:n
    E(k+1) = hbalance(h,k);
  end

  % The threshold is the local maximum with highest balance.
  E = E.*lmax;
  [dummy ind] = max(E);
  T{1} = ind-1;
endfunction

################################################################################
## Auxiliary functions from HistThresh toolbox http://www.cs.tut.fi/~ant/histthresh/
################################################################################

## partial sums from C. A. Glasbey, "An analysis of histogram-based thresholding
## algorithms," CVGIP: Graphical Models and Image Processing, vol. 55, pp. 532-537, 1993.
function x = partial_sumA (y, j)
  x = sum (y(1:j+1));
endfunction
function x = partial_sumB (y, j)
  ind = 0:j;
  x   = ind*y(1:j+1)';
endfunction
function x = partial_sumC (y, j)
  ind = 0:j;
  x = ind.^2*y(1:j+1)';
endfunction
function x = partial_sumD (y, j)
  ind = 0:j;
  x = ind.^3*y(1:j+1)';
endfunction

## Test if a histogram is bimodal.
function b = bimodtest(y)
  len = length(y);
  b = false;
  modes = 0;

  % Count the number of modes of the histogram in a loop. If the number
  % exceeds 2, return with boolean return value false.
  for k = 2:len-1
    if y(k-1) < y(k) && y(k+1) < y(k)
      modes = modes+1;
      if modes > 2
        return
      end
    end
  end

  % The number of modes could be less than two here
  if modes == 2
    b = true;
  end
endfunction

## Find the local maxima of a vector using a three point neighborhood.
function y = flocmax(x)
%  y    binary vector with maxima of x marked as ones

  len = length(x);
  y = zeros(1,len);

  for k = 2:len-1
    [dummy,ind] = max(x(k-1:k+1));
    if ind == 2
      y(k) = 1;
    end
  end
endfunction

## Calculate the balance measure of the histogram around a histogram index.
function E = hbalance(y,ind)
%  y    histogram
%  ind  index about which balance is calculated
%
% Out:
%  E    balance measure
%
% References:
%
% A. Rosenfeld and P. De La Torre, "Histogram concavity analysis as an aid
% in threhold selection," IEEE Transactions on Systems, Man, and
% Cybernetics, vol. 13, pp. 231-235, 1983.
%
% P. K. Sahoo, S. Soltani, and A. K. C. Wong, "A survey of thresholding
% techniques," Computer Vision, Graphics, and Image Processing, vol. 41,
% pp. 233-260, 1988.

  n = length(y)-1;
  E = partial_sumA(y,ind)*(partial_sumA(y,n)-partial_sumA(y,ind));
endfunction

## Find the convex hull of a histogram.
function H = hconvhull(h)
  % In:
  %  h    histogram
  %
  % Out:
  %  H    convex hull of histogram
  %
  % References:
  %
  % A. Rosenfeld and P. De La Torre, "Histogram concavity analysis as an aid
  % in threhold selection," IEEE Transactions on Systems, Man, and
  % Cybernetics, vol. 13, pp. 231-235, 1983.

  len = length(h);
  K(1) = 1;
  k = 1;

  % The vector K gives the locations of the vertices of the convex hull.
  while K(k)~=len

    theta = zeros(1,len-K(k));
    for i = K(k)+1:len
      x = i-K(k);
      y = h(i)-h(K(k));
      theta(i-K(k)) = atan2(y,x);
    end

    maximum = max(theta);
    maxloc = find(theta==maximum);
    k = k+1;
    K(k) = maxloc(end)+K(k-1);

  end

  % Form the convex hull.
  H = zeros(1,len);
  for i = 2:length(K)
    H(K(i-1):K(i)) = h(K(i-1))+(h(K(i))-h(K(i-1)))/(K(i)-K(i-1))*(0:K(i)-K(i-1));
  end
endfunction

## Entroy function. Note that the function returns the negative of entropy.
function x = negativeE(y,j)
  ## used by the maxentropy method only
  y = y(1:j+1);
  y = y(y~=0);
  x = sum(y.*log10(y));
endfunction

## these were tested with ImageJ
%!shared img, histo
%! [img, cmap] = imread ("default.img");
%! img = im2uint8 (ind2gray (img, cmap));
%!assert (graythresh (img, "percentile", 0.5), 142/255);
%!assert (graythresh (img, "moments"),         142/255);
%!assert (graythresh (img, "minimum"),          93/255);
%!assert (graythresh (img, "maxentropy"),      150/255);
%!assert (graythresh (img, "intermodes"),       99/255);
%!assert (graythresh (img, "otsu"),            115/255);
%! histo = hist (img(:), 0:255);
%!assert (graythresh (histo, "otsu"),          115/255);

## for the mean our results differ from matlab because we do not calculate it
## from the histogram. Our results should be more accurate.
%!assert (graythresh (img, "mean"), 0.51445615982, 0.000000001);  # here our results differ from ImageJ
