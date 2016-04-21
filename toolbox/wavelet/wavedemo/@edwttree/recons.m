function x = recons(t,node,x,sizes,edges)
%RECONS Reconstruct wavelet coefficients.
%   Y = RECONS(T,N,X,S,E) reconstructs the wavelet
%   packet coefficients X associated with the node N
%   of the wavelet tree T, using sizes S and the edges values E.
%   S contains the size of data associated with
%   each ascendant of N.
%   The children of a node F are numbered from left 
%   to right: [0, ... , ORDER-1].
%   The edge value between F and a child C is the child number.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.
%   Last Revision: 11-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2004/03/15 22:36:04 $ 

dwtEXTM = t.dwtMode;
Lo_R  = t.waveInfo.Lo_R;
Hi_R  = t.waveInfo.Hi_R;
mode  = t.dwtMode;
nb_up = length(edges);
f     = zeros(nb_up,length(Lo_R));
shift = zeros(nb_up,1);

K = find(edges==0 | edges==3);
if ~isempty(K)
    f(K,:) = Lo_R(ones(size(K)),:);
end
K = find(edges==1 | edges==2);
if ~isempty(K)
    f(K,:) = Hi_R(ones(size(K)),:);
end
K = find(edges==2 | edges==3);
if ~isempty(K) , shift(K) = 1; end
for k=1:nb_up
    s = max(sizes(k,:));
    x = upsconv1(x,f(k,:),s,dwtEXTM,shift(k));
end
