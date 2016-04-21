function [T, offset] = fitdecorrtrans(means, Cov, useCorr, targetMean, targetSigma)
% FITDECORRTRANS   Fit decorrelating transformation to image statistics.
%
% Given MEANS, a 1-by-NBANDS vector of band means, and COV, an NBANDS-by-NBANDS
% band covariance matrix, calculate an NBANDS-by-NBANDS linear transformation
% matrix, T, and 1-by-NBANDS offset vector, OFFSET, that will decorrelate
% an image with those statistics.  If A is such an image, reshaped to size
% NPIXELS-by-NBANDS, then A is decorrelated as follows:
%
%                 A * T + repmat(OFFSET,[NPIXELS 1]).
%
% Set USECORR=true to use the correlation matrix to derive T, or set
% USECORR=false to use the covariance matrix.  T is scaled to either (1)
% achieve the target standard deviation specified by TARGETSIGMA (either
% a scalar or an NBANDS-by-NBANDS diagonal matrix) or (2), if TARGETSIGMA=[],
% to preserve the variances on the diagonal of COV. Likewise, OFFSET
% includes a shift to either (1) set the mean of each output band to
% a specified target (TARGETMEAN, either a scalar or a 1-by-NBANDS vector)
% or (2), if TARGETMEAN=[], to preserve the band-means specified in MEANS.
%
% It's easy to verify that FITDECORRTRANS has worked by checking that
% 
%                T' * Cov * T
%
% equals diag(COV), TARGETSIGMA^2, or TARGETSIGMA^2 * eye(NBANDS). 
% Likewise, one can check that
%
%              means * T + OFFSET
%
% equals either MEANS or TARGETMEANS.
%
% Even in the case of perfectly or nearly correlated bands, FITDECORRTRANS
% remains stable.  T and OFFSET continue to provide a reasonable-looking
% result when applied to an image with the appropriate statistics.  However,
% 
%                T' * Cov * T
%
% will no longer be diagonal, and its diagonal elements corresponding to
% zero-variance bands will be zero.
%
% Notes
% -----
% In general, T is not unique, because once an image has been decorrelated
% (via left multiplication by T = V * inv(sqrt(D)) * V') it can be
% rotated arbitrarily in band space without reintroducing correlations.
% All these different choices will give the same value of T' * Cov * T.
%
% The correlation and covariance methods each produce a different, but
% valid T.  Those particular choices for T also have the desirable property
% of preserving, roughly, the hue of a given pixel.
%
% The correlation method may be understood as follows.  Consider the image
% that is derived by scaling the original image, band by band, to have
% unit variance in each band.  The correlation matrix of the original
% image is the covariance matrix of this derived image. That is,
% if S is a diagonal matrix containing the square-root band-variances,
% of image A, then Corr is the covariance of A / S (assuming that A has
% been reshaped to size NPIXELS-by-NBANDS).  Thus the expression
% below, T = pinv(S) * V * decorrWeight(D) * V' * targetSigma, can be
% understood as follows when applied to A step by step:
%
% Scale A band-wise to achieve unit variance in each band:
%                        A * pinv(S)
%
% Transform the scaled A to the eigenvector basis:
%                      A * pinv(S) * V
%
% Decorrelate:
%                A * pinv(S) * V * decorrWeight(D)
%
% Transform back (resulting in unit variance in each band):
%              A * pinv(S) * V * decorrWeight(D) * V'
%
% Scale each band to achieve the desired standard deviation:
%           A * pinv(S) * V * decorrWeight(D) * V' * targetSigma
%
% (The covariance method works the same, but because there's no need for an
% initial scaling to unit variance the pinv(S) factor is omitted.)
%
% Robustness is achieved by:
%   1. Ensuring that the correlation matrix has ones on the diagonal
%      (even in the event of one or more uniform bands)
%   2. Through the use of PINV in place of INV
%   3. By forcing any small negative eigenvalues to zero
%   4. By rescaling T as needed to compensate for the
%      effects of a rank-deficient covariance matrix.
%
% References
% ----------
%
% Alley, Ronald E., Algorithm Theoretical Basis Document for Decorrelation
%    Stretch, Version 2.2, Jet Propulsion Laboratory, Pasadena, CA,
%    August 15,1996.
%
% Mather, Paul M., Computer Processing of Remotely-Sensed Images: An
%    Introduction, 2nd Edition, John Wiley & Sons, 1999.

% Square-root variances in a diagonal matrix.
S = diag(sqrt(diag(Cov)));  

if isempty(targetSigma)
    % Restore original sample variances.
    targetSigma = S;
end

if useCorr
    Corr = pinv(S) * Cov * pinv(S);
    Corr(logical(eye(size(Corr,1)))) = 1;
    [V D] = eig(Corr);
    T = pinv(S) * V * decorrWeight(D) * V' * targetSigma;
else
    [V D] = eig(Cov);
    T = V * decorrWeight(D) * V' * targetSigma;
end

% Get the output variances right even for correlated bands, except
% for zero-variance bands---which can't be stretched at all.
T = T * pinv(diag(sqrt(diag(T' * Cov * T)))) * targetSigma;

if isempty(targetMean)
    % Restore original sample means.
    targetMean = means;
end

offset = targetMean - means * T;

%--------------------------------------------------------------------------
function W = decorrWeight(D)

% Given the diagonal eigenvalue matrix D, compute the decorrelating
% weights W.  In the full rank, well-conditioned case, decorrWeight(D)
% returns the same result as sqrt(inv(D)).  In addition, it provides
% a graceful way to handle rank-deficient or near-rank-deficient
% (ill-conditioned) cases resulting from situations of perfect or
% near-perfect band-to-band correlation and/or bands with zero variance.

D(D < 0) = 0;
W = sqrt(pinv(D));

%--------------------------------------------------------------------------
function S = pinv(D)

% Pseudoinverse of a diagonal matrix, with a larger-than-standard
% tolerance to help in handling edge cases.  We've provided our
% own in order to: (1) Avoid replacing all calls to PINV with calls to
% PINV(...,TOL) and (2) Take advantage of the fact that our input is
% always diagonal so we don't need to call SVD.

d = diag(D);
tol =length(d) * max(d) * sqrt(eps);
keep = d > tol;
s = ones(size(d));
s(keep) = s(keep) ./ d(keep);
s(~keep) = 0;
S = diag(s);
