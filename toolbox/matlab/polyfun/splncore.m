function yi = splncore(x,v,xi,flag)
%SPLNCORE N-D Spline interpolation.
%   Core implemenation for N-D spline interpolation.  Called by INTERP2, 
%   INTERP3 and INTERPN to implement the spline method.
%
%   See also INTERP2, INTERP3, INTERPN.

%   YI = SPLNCORE(X,V,XI) interpolates the N-D data V defined at the
%   values in the length N cell array X at the points in the length N
%   cell array XI.  X must contain the grid row vectors used to construct V.
%   Each grid vector must be monotonically increasing. The elements 
%   of XI must all be the same size.
%
%   YI = SPLNCORE(X,V,XI,'gridded') uses the vectors in XI to produce
%   the gridded solution YI.  In this case, the vectors in XI must be rows
%   and can have different lengths.  This produces the same result as the
%   two statements
%
%       [XXI{1:length(XI)}] = ndgrid(XI{:});
%       YI = splncore(X,V,XXI);
%
%   but much faster.

%   Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.6.4.2 $
%   cb 5-Oct-1997

% References: 
%   C. de Boor;
%   Efficient computer manipulation of tensor products;
%   ACM Trans. Math. Software;  5; 1979; 173--182. {\it Corrigenda:} 525;
%
%   See also the tensor product example in the spline toolbox tutorial.

if nargin==4 % xxi is gridded
  % gridded spline interpolation via tensor products
  nv = size(v);
  d = length(x);
  values = v;
  sizeg = zeros(1,d);
  for i=d:-1:1
     values = spline(x{i},reshape(values,prod(nv(1:d-1)),nv(d)),xi{i}).';
     sizeg(i) = length(xi{i}); 
     nv = [sizeg(i), nv(1:d-1)];
  end
  yi = reshape(values,sizeg);
else
  % Scatterd spline interpolation
  % Use SPLINT to convert data into coefficients.
  nv = size(v);
  d = length(x);
  values = v;
  siz = size(xi{1});
  for i=1:d,
     xi{i} = xi{i}(:).';
  end
  points = cat(1,xi{:});
  n = size(points,2);

  sizeg = zeros(1,d);
  for i=d:-1:1
     values = splint(x{i},reshape(values,prod(nv(1:d-1)),nv(d))).';
     sizeg(i) = length(values(:,1)); nv = [sizeg(i), nv(1:d-1)];
  end
  values = reshape(values,sizeg);
  
  % now we must locate the scattered data in the break sequence:
  ipoint = zeros(size(points));
  for i=1:d
     [opoints,iindex] = sort(points(i,:));
     breaks = x{i};
     l = length(breaks)-1; l(l<3) = 1;
     [ignored,index] = sort([breaks(1:l) opoints]);
     ipoint(i,iindex) = max(find(index>l)-(1:n),ones(1,n));
  end
  
  % ... and now set up lockstep cubic polynomial evaluation
  % first,  select the relevant portion of the coefficients array. This
  % has the additional pain that now there are four coefficients for each
  % univariate interval.  
  % The coefficients sit in the d-dimensional array  values,  sizeg is its size.
  % Note that, because of the transpositions we did, each dimension is organized
  % to give, in order, the first (or highest) coefficients for each interval,
  % then the second (or next highest), and so on. 
  % sizeg(i) equals 4*l(i), with  l(i) := length(x{i})-1 .
  % ipoint(:,j) is the index vector for the lower corner of j-th point
  
  ells = sizeg/4; 
  ind = ells(1)*(0:3)'; 
  for j=2:d
     ind = [ind zeros(length(ind),1);...
            ind repmat(ells(j),length(ind),1); ...
            ind repmat(2*ells(j),length(ind),1); ...
            ind repmat(3*ells(j),length(ind),1)];
  end
  ind = num2cell(1+ind,1);
  offset = repmat(reshape(sub2ind(sizeg,ind{:}),4^d,1),1,n);
  
  ind = num2cell(ipoint.',1);
  base = repmat(sub2ind(sizeg,ind{:}).',4^d,1)-1;
  coefs = reshape(values(base+offset),[repmat(4,1,d),n]);
  
  % ... then do a version of local cubic evaluation
  for i=d:-1:1
     s = reshape(points(i,:) - x{i}(ipoint(i,:)),[1,1,n]);
     coefs = reshape(coefs,[4^(i-1),4,n]);
     for j=2:4
        coefs(:,1,:) = coefs(:,1,:).*s(ones(4^(i-1),1),1,:)+coefs(:,j,:);
     end
     coefs(:,2:4,:) = [];
  end
  yi = reshape(coefs,siz);
end

%-------------------------------------------------------------
function coefs = splint(x,y)
%SPLINT coefficients of the cubic spline interpolant, reshaped for use
%       in evaluation of tensor product cubic spline at scattered points.

% cb 6oct97
[ignored,coefs,l,k,d] = unmkpp(spline(x,y));
if k<4, coefs = [zeros(d,4-k) coefs]; end
coefs = reshape(coefs,d,l*4);
