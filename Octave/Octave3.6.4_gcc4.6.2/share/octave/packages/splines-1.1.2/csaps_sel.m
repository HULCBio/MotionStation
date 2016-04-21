## Copyright (C) 2012 Nir Krakauer
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
## @deftypefn{Function File}{[@var{yi} @var{p} @var{sigma2},@var{unc_y}] =} csaps_sel(@var{x}, @var{y}, @var{xi}, @var{w}=[], @var{crit}=[])
## @deftypefnx{Function File}{[@var{pp} @var{p} @var{sigma2},@var{unc_y}] =} csaps_sel(@var{x}, @var{y}, [], @var{w}=[], @var{crit}=[])
##
## Cubic spline approximation with smoothing parameter estimation @*
## Approximates [@var{x},@var{y}], weighted by @var{w} (inverse variance; if not given, equal weighting is assumed), at @var{xi}.
##
## The chosen cubic spline with natural boundary conditions @var{pp}(@var{x}) minimizes @var{p} Sum_i @var{w}_i*(@var{y}_i - @var{pp}(@var{x}_i))^2  +  (1-@var{p}) Int @var{pp}''(@var{x}) d@var{x}.
## A selection criterion @var{crit} is used to find a suitable value for @var{p} (between 0 and 1); possible values for @var{crit} are `aicc' (corrected Akaike information criterion, the default); `aic' (original Akaike information criterion); `gcv' (generalized cross validation). If @var{crit} is a scalar instead of a string, then @var{p} is chosen to so that the mean square scaled residual Mean_i (@var{w}_i*(@var{y}_i - @var{pp}(@var{x}_i))^2) is approximately equal to @var{crit}.
##
## @var{x} and @var{w} should be @var{n} by 1 in size; @var{y} should be @var{n} by @var{m}; @var{xi} should be @var{k} by 1; the values in @var{x} should be distinct; the values in @var{w} should be nonzero.
##
## Returns the selected @var{p}, the estimated data scatter (variance from the smooth trend) @var{sigma2}, and the estimated uncertainty (SD) of the smoothing spline fit at each @var{x} value, @var{unc_y}.
##
## The optimization uses singular value decomposition of an @var{n} by @var{n} matrix for small @var{n} in order to quickly compute the residual size and model degrees of freedom for many @var{p} values for the optimization (Craven and Wahba 1979), while for large @var{n} (currently >300) an asymptotically more computation and storage efficient method that takes advantage of the sparsity of the problem's coefficient matrices is used (Hutchinson and de Hoog 1985).
##
## References: 
##
## Carl de Boor (1978), A Practical Guide to Splines, Springer, Chapter XIV
##
## Clifford M. Hurvich, Jeffrey S. Simonoff, Chih-Ling Tsai (1998), Smoothing parameter selection in nonparametric regression using an improved Akaike information criterion, J. Royal Statistical Society, 60B:271-293
##
## M. F. Hutchinson and F. R. de Hoog (1985), Smoothing noisy data with spline functions, Numerische Mathematik, 47:99-106
##
## M. F. Hutchinson (1986), Algorithm 642: A fast procedure for calculating minimum cross-validation cubic smoothing splines, ACM Transactions on Mathematical Software, 12:150-153
##
## Grace Wahba (1983), Bayesian ``confidence intervals'' for the cross-validated smoothing spline, J Royal Statistical Society, 45B:133-150
##
## @end deftypefn
## @seealso{csaps, spline, csapi, ppval, gcvspl}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [ret,p,sigma2,unc_y]=csaps_sel(x,y,xi,w,crit)

  if (nargin < 5)
    crit = [];
    if(nargin < 4)
      w = [];
      if(nargin < 3)
        xi = [];
      endif
    endif
  endif

  if(columns(x) > 1)
    x = x.';
    y = y.';
    w = w.';
  endif

  [x,i] = sort(x);
  y = y(i, :);

  n = numel(x);
  
  if isempty(w)
    w = ones(n, 1);
  end

  if isscalar(crit)
    if crit <= 0 #return an exact cubic spline interpolation
        [ret,p]=csaps(x,y,1,xi,w);
        sigma2 = 0; unc_y = zeros(size(x));
        return
      end
    w = w ./ crit; #adjust the sample weights so that the target mean square scaled residual is 1
    crit = 'msr_bound';
  end	

  if isempty(crit)
    crit = 'aicc';
  end

  h = diff(x);

  R = spdiags([h(1:end-1) 2*(h(1:end-1) + h(2:end)) h(2:end)], [-1 0 1], n-2, n-2);

  QT = spdiags([1 ./ h(1:end-1) -(1 ./ h(1:end-1) + 1 ./ h(2:end)) 1 ./ h(2:end)], [0 1 2], n-2, n);


chol_method = (n > 300); #use a sparse Cholesky decomposition followed by solving for only the central bands of the inverse to solve for large n (faster), and singular value decomposition for small n (less prone to numerical error if data values are spaced close together)

##choose p by minimizing the penalty function
  
if chol_method
  penalty_function = @(p) penalty_compute_chol(p, QT, R, y, w, n, crit);
else
  ##determine influence matrix for different p without repeated inversion
  [U D V] = svd(diag(1 ./ sqrt(w))*QT'*sqrtm(inv(R)), 0); D = diag(D).^2;
  penalty_function = @(p) penalty_compute(p, U, D, y, w, n, crit);
end

  p = fminbnd(penalty_function, 0, 1);

## estimate the trend uncertainty
if chol_method
  [MSR, Ht] = penalty_terms_chol(p, QT, R, y, w, n);
  Hd = influence_matrix_diag_chol(p, QT, R, y, w, n);
else
  H = influence_matrix(p, U, D, n, w);
  [MSR, Ht] = penalty_terms(H, y, w);
  Hd = diag(H);
end

  sigma2 = mean(MSR(:)) * (n / (n-Ht)); #estimated data error variance (wahba83)
  unc_y = sqrt(sigma2 * Hd ./ w); #uncertainty (SD) of fitted curve at each input x-value (hutchinson86)

## construct the fitted smoothing spline 
  [ret,p]=csaps(x,y,p,xi,w);

endfunction



function H = influence_matrix(p, U, D, n, w) #returns influence matrix for given p
  H = speye(n) - U * diag(D ./ (D + (p / (6*(1-p))))) * U';
  H = diag(1 ./ sqrt(w)) * H * diag(sqrt(w)); #rescale to original units	
endfunction	

function [MSR, Ht] = penalty_terms(H, y, w)
  MSR = mean(w .* (y - (H*y)) .^ 2); #mean square residual
  Ht = trace(H); #effective number of fitted parameters
endfunction

function Hd = influence_matrix_diag_chol(p, QT, R, y, w, n)
  #LDL factorization of 6*(1-p)*QT*diag(1 ./ w)*QT' + p*R
  U = chol(6*(1-p)*QT*diag(1 ./ w)*QT' + p*R, 'upper');
  d = 1 ./ diag(U);
  U = diag(d)*U; 
  d = d .^ 2;
  #5 central bands in the inverse of 6*(1-p)*QT*diag(1 ./ w)*QT' + p*R
  Binv = banded_matrix_inverse(d, U, 2);
  Hd = diag(speye(n) - (6*(1-p))*diag(1 ./ w)*QT'*Binv*QT);	
endfunction

function [MSR, Ht] = penalty_terms_chol(p, QT, R, y, w, n)
  #LDL factorization of 6*(1-p)*QT*diag(1 ./ w)*QT' + p*R
  U = chol(6*(1-p)*QT*diag(1 ./ w)*QT' + p*R, 'upper');
  d = 1 ./ diag(U);
  U = diag(d)*U; 
  d = d .^ 2;
  Binv = banded_matrix_inverse(d, U, 2); #5 central bands in the inverse of 6*(1-p)*QT*diag(1 ./ w)*QT' + p*R
  Ht = 2 + trace(speye(n-2) - (6*(1-p))*QT*diag(1 ./ w)*QT'*Binv);
  MSR = mean(w .* ((6*(1-p)*diag(1 ./ w)*QT'*((6*(1-p)*QT*diag(1 ./ w)*QT' + p*R) \ (QT*y)))) .^ 2);
endfunction

function J = aicc(MSR, Ht, n)
  J = mean(log(MSR)(:)) + 2 * (Ht + 1) / max(n - Ht - 2, 0); #hurvich98, taking the average if there are multiple data sets as in woltring86 
endfunction

function J = aic(MSR, Ht, n)
  J = mean(log(MSR)(:)) + 2 * Ht / n;
endfunction

function J = gcv(MSR, Ht, n)
  J = mean(log(MSR)(:)) - 2 * log(1 - Ht / n);
endfunction

function J = msr_bound(MSR, Ht, n)
  J = mean(MSR(:) - 1) .^ 2;
endfunction

function J = penalty_compute(p, U, D, y, w, n, crit) #evaluates a user-supplied penalty function crit at given p
  H = influence_matrix(p, U, D, n, w);
  [MSR, Ht] = penalty_terms(H, y, w);
  J = feval(crit, MSR, Ht, n);
  if ~isfinite(J)
    J = Inf;
  endif
endfunction

function J = penalty_compute_chol(p, QT, R, y, w, n, crit) #evaluates a user-supplied penalty function crit at given p
  [MSR, Ht] = penalty_terms_chol(p, QT, R, y, w, n);
  J = feval(crit, MSR, Ht, n);
  if ~isfinite(J)
    J = Inf;
  endif
endfunction

function Binv = banded_matrix_inverse(d, U, m) #given a (2m+1)-banded, symmetric n x n matrix B = U'*inv(diag(d))*U, where U is unit upper triangular with bandwidth (m+1), returns Binv, a sparse symmetric matrix containing the central 2m+1 bands of the inverse of B
#Reference: Hutchinson and de Hoog 1985
  Binv = diag(d);
  n = rows(U);
  for i = n:(-1):1
    p = min(m, n - i);
    for l = 1:p
      for k = 1:p
        Binv(i, i+l) -= U(i, i+k)*Binv(i + k, i + l);
      end
      Binv(i, i) -= U(i, i+l)*Binv(i, i+l);
    end
    Binv(i+(1:p), i) = Binv(i, i+(1:p))'; #add the lower triangular elements
  end
endfunction

%!shared x,y,ret,p,sigma2,unc_y
%! x = [0:0.01:1]'; y = sin(x);
%! [ret,p,sigma2,unc_y]=csaps_sel(x,y,x);
%!assert (1-p, 0, 1E-6);
%!assert (sigma2, 0, 1E-10);
%!assert (ret-y, zeros(size(y)), 1E-4);
%!assert (unc_y, zeros(size(unc_y)), 1E-5);

%{
# experiments with unequal weighting of points
rand("seed", pi)
x = [0:0.01:1]'; 
w = 1 ./ (0.1 + rand(size(x)));
rand("seed", pi+1)
y = x .^ 2 +  0.05*(rand(size(x))-0.5)./ sqrt(w);
[ret,p,sigma2,unc_y]=csaps_sel(x,y,x,w);

rand("seed", pi)
x = [0:0.01:10]'; 
w = 1 ./ (0.1 + rand(size(x)));
rand("seed", pi+1)
y = x .^ 2 +  0.5*(rand(size(x))-0.5)./ sqrt(w);
tic; [ret,p,sigma2,unc_y]=csaps_sel(x,y,x,w); toc

%}
