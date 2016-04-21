function x = rnodcoef(t,node)
%RNODCOEF Reconstruct node coefficients.
%   X = RNODCOEF(T,N) computes reconstructed coefficients
%   of the node N of the tree T.
%
%   X = RNODCOEF(T) is equivalent to X = RNODCOEF(T,0).

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 18-Oct-96.
%   Last Revision: 21-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:37:35 $

% Check arguments.
if nargin==1, node = 0; end
if find(isnode(t,node)==0)
    error('Invalid node value.');
end

% Get node data (coefficients).
[nul,x] = nodejoin(t,node);

% Get asc, edges, ...
order = treeord(t);
asc   = nodeasc(t,node);
node  = asc(1);
if length(asc)<2 , return; end
sizes = read(t,'sizes',asc(2:end));
[d,p] = ind2depo(order,asc);
edges = rem(p,order);
edges = edges(1:end-1);

% Reconstruction.
x = recons(t,node,x,sizes,edges);
