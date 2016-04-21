function spline = spmak(knots,coefs,sizec)
%SPMAK Put together a spline in B-form.
%
%   SPMAK(KNOTS,COEFS) puts together a spline from the knots and
%   coefficients. Let SIZEC be size(COEFS). Then the spline is taken to be
%   SIZEC(1:end-1)-valued, hence there are altogether n = SIZEC(end)
%   coefficients.
%   The order of the spline is inferred as  k := length(KNOTS) - n .
%   Knot multiplicity is held to <= k , with the coefficients
%   corresponding to a B-spline with trivial support ignored.
%
%   SPMAK  will prompt you for KNOTS and COEFS.
%
%   If KNOTS is a cell array of length  m , then COEFS must be at least
%   m-dimensional, i.e., length(SIZEC) must be at least m. If COEFS is
%   m-dimensional, then the spline is taken to be scalar-valued; otherwise,
%   it is taken to be SIZEC(1:end-m)-valued.
%
%   SPMAK(KNOTS,COEFS,SIZEC) uses SIZEC to specify the intended array
%   dimensions of COEFS, and may be needed for proper interpretation
%   of COEFS in case one or more of its trailing dimensions is a singleton
%   and thus COEFS appears to be of lower dimension.
%
%   For example, if the intent is to construct a 2-vector-valued bivariate
%   polynomial on the rectangle [-1 .. 1] x [0 .. 1], linear in the first
%   variable and constant in the second, say
%      coefs = zeros([2 2 1]); coefs(:,:,1) = [1 0;0 1];
%   then the straightforward
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs);
%   will fail, producing a scalar-valued function of (illegal) order [2 0],
%   as will
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs,size(coefs));
%   while proper use of that third argument, as in
%      sp = spmak({[-1 -1 1 1],[0 1]},coefs,[2 2 1]);
%   will succeed.
%
%   See also SPBRK, RSMAK, PPMAK, RPMAK, STMAK, FNBRK.

%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.17 $

if nargin==0;
   knots = input('Give the vector of knots  >');
   coefs = input('Give the array of B-spline coefficients  >');
end

if nargin>2
   if prod(size(coefs))~=prod(sizec)
     error('SPLINES:SPMAK:coefsdontmatchsize', ...
           'The coefficient array is not of the explicitly specified size.')
   end
else
   if isempty(coefs)
      error('SPLINES:SPMAK:emptycoefs','The coefficient array is empty.')
   end
   sizec = size(coefs);
end

m = 1; if iscell(knots), m = length(knots); end
if length(sizec)<m
   error('SPLINES:SPMAK:coefsdontmatchknots', ...
        ['According to KNOTS, the function is %g-dimensional;\n',...
          'hence COEFS must be at least %g-dimensional.'],m,m)
end
if length(sizec)==m,  % coefficients of a scalar-valued function
   sizec = [1 sizec];
end

% convert ND-valued coefficients into vector-valued ones, retaining the
% original size in SIZEVAL, to be stored eventually in SP.DIM .
sizeval = sizec(1:end-m); sizec = [prod(sizeval), sizec(end-m+(1:m))];
coefs = reshape(coefs, sizec);

if iscell(knots), % we are putting together a tensor-product spline
   [knots,coefs,k,sizec] = chckknt(knots,coefs,sizec);
else            % we are putting together a univariate spline
   [knots,coefs,k,sizec] = chckknt({knots},coefs,sizec); knots = knots{1};
end

spline.form = 'B-';
spline.knots = knots;
spline.coefs = coefs;
spline.number = sizec(2:end);
spline.order = k;
spline.dim = sizeval;
% spline = [11 d n coefs(:).' k knots(:).'];

function [knots,coefs,k,sizec] = chckknt(knots,coefs,sizec)
%CHCKKNT check knots, omit trivial B-splines

for j=1:length(sizec)-1
   n = sizec(j+1); k(j) = length(knots{j})-n;
   if k(j)<=0, error('SPLINES:SPMAK:knotsdontmatchcoefs', ...
                     'There should be more knots than coefficients.'), end
   if any(diff(knots{j})<0)
      error('SPLINES:SPMAK:knotdecreasing',...
      'The knot sequence should be nondecreasing.')
   end
   if knots{j}(1)==knots{j}(end)
      error('SPLINES:SPMAK:extremeknotssame',...
      'The extreme knots should be different.')
   end

   % throw out trivial B-splines:
   index = find(knots{j}(k(j)+[1:n])-knots{j}(1:n)>0);
   if length(index)<n
      oldn = n; n = length(index);
      knots{j} = reshape(knots{j}([index oldn+[1:k(j)]]),1,n+k(j));
      coefs = ...
          reshape(coefs, [prod(sizec(1:j)),sizec(j+1),prod(sizec(j+2:end))]);
      sizec(j+1) = n; coefs = reshape(coefs(:,index,:),sizec);
   end
end
