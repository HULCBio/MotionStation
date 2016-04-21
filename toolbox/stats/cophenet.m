function c = cophenet(Z,Y)
%COPHENET Cophenetic correlation coefficient.
%   C = COPHENET(Z,Y) computes the cophenetic correlation coefficient for
%   the hierarchical cluster tree represented by Z.  Z is the output of the
%   function LINKAGE.  Y contains the distances or dissimilarities used to
%   construct Z, as output by the function PDIST.
%
%   The cophenetic correlation for a cluster tree is defined as the linear
%   correlation coefficent between the cophenetic distances obtained from
%   the tree, and the original distances (or dissimilarities) used to
%   construct the tree.  Thus, it is a measure of of how faithfully the
%   tree represents the dissimilarities among observations.
%
%   The cophenetic distance between two observations is represented in a
%   dendrogram by the height of the link at which those two observations
%   are first joined.  That height is the distance between the two
%   subclusters that are merged by that link.
%
%   Example:
%
%      X = [rand(10,3); rand(10,3)+1; rand(10,3)+2];
%      Y = pdist(X);
%      Z = linkage(Y,'average');
%      c = cophenet(Z,Y);
%
%   See also PDIST, LINKAGE, INCONSISTENT, DENDROGRAM, CLUSTER, CLUSTERDATA.

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.11.4.2 $


n = size(Z,1)+1;

link = zeros(n,1); listhead = 1:n;
sum1 = 0; sum2 = 0; s11 = 0; s22 = 0; s12 = 0;

for k = 1:(n-1)
   i = Z(k,1); j = Z(k,2); t = Z(k,3);
   m1 = listhead(i); % head of the updated cluster i
   while m1 > 0
      m = listhead(j);
      while m > 0
         m2 = min(m1,m); m3 = max(m1,m);
	 u = Y((m2-1)*(n-m2/2)+m3-m2); % distance between m and m1.
         sum1 = sum1+t; sum2 = sum2+u; 
         s11 = s11+t*t; s22 = s22+u*u;
         s12 = s12+t*u; 
         msav = m;
         m = link(m);
      end
      m1 = link(m1); % find the next point in cluster i 
   end
   
   % link the end of cluster j to the head of cluster i 
   link(msav) = listhead(i);
   
   % make the head of newly formed cluster i to be the head of cluster
   % j before the merge.
   listhead(n+k) = listhead(j);

end
t = 2/(n*(n-1));
s11 = s11-sum1*sum1*t; s22 = s22-sum2*sum2*t; s12 = s12-sum1*sum2*t;
c = s12/sqrt(s11*s22); % cophenectic coefficient formula 
