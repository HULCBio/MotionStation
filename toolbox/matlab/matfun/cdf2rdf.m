function [vv,dd] = cdf2rdf(v,d)
%CDF2RDF Complex diagonal form to real block diagonal form.
%   [V,D] = CDF2RDF(V,D) transforms the outputs of EIG(X) (where X is
%   real) from complex diagonal form to a real diagonal form.  In
%   complex diagonal form, D has complex eigenvalues down the
%   diagonal.  In real diagonal form, the complex eigenvalues are in
%   2-by-2 blocks on the diagonal.  Complex conjugate eigenvalue pairs
%   are assumed to be next to one another.
%
%   Class support for inputs V,D: 
%      float: double, single
%
%   See also EIG, RSF2CSF.

%   Based upon M-file from M. Steinbuch, N.V.KEMA & Delft Univ. of Tech.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.11.4.3 $  $Date: 2004/04/10 23:29:56 $

i = find(imag(diag(d))');
index = i(1:2:length(i));
if isempty(index)
   vv=v; dd=d;
else   
   if max(index)==size(d,1) | any(conj(d(index,index))~=d(index+1,index+1))
      error('MATLAB:cdf2rdf:invalidDiagonal',...
            ['The diagonal of D must be a collection of real '...
            'eigenvalues and complex\nconjugate pairs (like '...
            'the output of EIG(X) when X is a real matrix).']);
   end
   j = sqrt(-1);
   t = eye(length(d));
   twobytwo = [1 1;j -j];
   for i=index
      t(i:i+1,i:i+1) = twobytwo;
   end 
   vv=v/t; dd=t*d/t;
end
