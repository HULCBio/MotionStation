function pp=mkpp(breaks,coefs,d)
%MKPP Make piecewise polynomial.  
%   PP = MKPP(BREAKS,COEFS) puts together a piecewise polynomial PP from its
%   breaks and coefficients.  BREAKS must be a vector of length L+1 with
%   strictly increasing elements representing the start and end of each of L
%   intervals.  The matrix COEFS must be L-by-K, with the i-th row, 
%   COEFS(i,:), representing the local coefficients of the order K polynomial
%   on the interval [BREAKS(i) ... BREAKS(i+1)], i.e., the polynomial                 
%   COEFS(i,1)*(X-BREAKS(i))^(K-1) + COEFS(i,2)*(X-BREAKS(i))^(K-2) + ... 
%   COEFS(i,K-1)*(X-BREAKS(i)) + COEFS(i,K)
%   Note: A K-th order polynomial uses K coefficients in its description:
%      C(1)*X^(K-1) + C(2)*X^(K-2) + ... + C(K-1)*X + C(K)
%   hence is of degree < K.  For example, a cubic polynomial is usually
%   written as a vector with 4 elements.
%
%   PP = MKPP(BREAKS,COEFS,D) denotes that the piecewise polynomial PP has
%   values of size D, with D either a scalar or an integer vector.
%   BREAKS must be an increasing vector of length L+1.
%   Whatever the size of COEFS may be, its last dimension is taken to be the
%   polynomial order, K, hence the product of the remaining dimensions must
%   equal prod(D)*L. If we take COEFS to be of size [prod(D),L,K], then
%   COEFS(r,i,:) are the K coefficients of the r-th component of the i-th
%   polynomial piece.
%   Internally, COEFS is stored as a matrix, of size [prod(D)*L,K].
%
%   Examples:
%   These first two plots show the quadratic 1-(x/2-1)^2 = -x^2/4 + x 
%   shifted from the interval [-2 .. 2] to the interval [-8 .. -4], and the
%   negative of that quadratic, namely the quadratic (x/2-1)^2-1 = x^2/4 - x,
%   but shifted from [-2 .. 2] to the interval [-4 .. 0].
%      subplot(2,2,1)
%      cc = [-1/4 1 0];
%      pp1 = mkpp([-8 -4],cc); xx1 = -8:0.1:-4;
%      plot(xx1,ppval(pp1,xx1),'k-')
%      subplot(2,2,2)
%      pp2 = mkpp([-4 -0],-cc); xx2 = -4:0.1:0;
%      plot(xx2,ppval(pp2,xx2),'k-')
%      subplot(2,1,2)
%      pp = mkpp([-8 -4 0 4 8],[cc; -cc; cc; -cc]);
%      xx = -8:0.1:8;
%      plot(xx,ppval(pp,xx),'k-')
%      [breaks,coefs,l,k,d] = unmkpp(pp);
%      dpp = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
%      hold on, plot(xx,ppval(dpp,xx),'r-'), hold off
%   This last plot shows a piecewise polynomial constructed by alternating the
%   first two quadratic pieces over 4 intervals.  To stress the piecewise
%   polynomial character, also shown is its first derivative, as constructed 
%   from information about the piecewise polynomial obtained via UNMKPP.
%
%   Class support for inputs BREAKS,COEFS:
%      float: double, single
%
%   See also UNMKPP, PPVAL, SPLINE.

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.3 $  $Date: 2004/03/02 21:47:50 $

if nargin==2, d = 1; else d = d(:).'; end
dlk=numel(coefs); l=length(breaks)-1; dl=prod(d)*l; k=fix(dlk/dl+100*eps);
if (k<=0)||(dl*k~=dlk)
   error('MATLAB:mkpp:PPNumberMismatchCoeffs',...
         sprintf(['The requested number of polynomial pieces, ' int2str(l), ...
        ',\nis incompatible with the proposed size, [' int2str(d), ...
	'],\nof a coefficient and the number, ' int2str(dlk), ...
	',\nof scalar coefficients provided.']))
end

pp.form = 'pp';
pp.breaks = reshape(breaks,1,l+1);
pp.coefs = reshape(coefs,dl,k);
pp.pieces = l;
pp.order = k;
pp.dim = d;
