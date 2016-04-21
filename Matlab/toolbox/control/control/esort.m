function [s,ndx]=esort(p)
%ESORT  Sort complex continuous eigenvalues in descending order.
%
%   S = ESORT(P)  sorts the complex eigenvalues in the vector P in
%   descending order by real part.  The unstable eigenvalues (in
%   the continuous-time sense) will appear first.
%
%   [S,NDX] = ESORT(P) also returns the vector NDX containing the 
%   indexes used in the sort.
%
%   See also: DSORT and SORT.

%   Clay M. Thompson  7-12-90, AFP 6-1-94, PG 4-9-96, 6-11-97
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:23:47 $

error(nargchk(1,1,nargin));
p = p(:);
n = length(p);

% Create a total ordering by assigning a real value to
% each root as follows:
%   * sort real parts and assign increasing integer values Kr
%     to different real part values
%   * sort absolute imaginary parts and assign increasing integer 
%     values Ki to different absolute imaginary part values
%   * assign to each root the value Kr + Ki/n and sort p based 
%     on these values

pr = real(p);
[prs,ipr] = sort(-pr);
Kr = zeros(n,1);
Kr(ipr(2:end),:) = filter([1 0],[1 -1],(diff(prs,1,1)~=0));

pi = abs(imag(p));
[pis,ipi] = sort(pi);
Ki = zeros(n,1);
Ki(ipi(2:end),:) = filter([1 0],[1 -1],(diff(pis,1,1)~=0));

% Sort based on indicator value Kr + Ki/n
[trash,ndx] = sort(Kr+Ki/n);
s = p(ndx);


% Make sure complex conjugate eigenvalues come in pair a+jb,a-jb
% Search for clusters of roots with same a and |b|
isep = zeros(n,1);
isep(2:end,:) = (diff(real(s)+sqrt(-1)*abs(imag(s)),1,1)==0);
delims = [find(diff(isep)==1) , find(diff([isep;0])==-1)];

% and process each cluster
for lims=delims',
   % Get cluster limits
   istart = lims(1);  iend = lims(2);
   clust = s(istart:iend);
   ndxcl = ndx(istart:iend);
   
   % Identify roots a+jb and roots a-jb (b>0)
   ipos = find(imag(clust)>=0);
   ineg = find(imag(clust)<0);
   npairs = min(length(ipos),length(ineg));

   % Determine adequate permutation
   iperm = zeros(length(clust),1);
   iperm(1:2:2*npairs) = ipos(1:npairs);
   iperm(2:2:2*npairs) = ineg(1:npairs);
   iperm(2*npairs+1:end) = [ipos(npairs+1:end,:) ; ineg(npairs+1:end,:)];
   s(istart:iend) = clust(iperm);
   ndx(istart:iend) = ndxcl(iperm);
end


% end esort
