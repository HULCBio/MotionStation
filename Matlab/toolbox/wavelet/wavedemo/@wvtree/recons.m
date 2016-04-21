function x = recons(t,node,x,sizes,edges)
%RECONS Reconstruct wavelet coefficients.
%   Y = RECONS(T,N,X,S,E) reconstructs the 
%   wavelet packet coefficients X associated with the node N
%   of the wavelet tree T, using sizes S and the edges values E.
%   S contains the size of data associated with
%   each ascendant of N.
%   The children of a node F are numbered from left 
%   to right: [0, ... , ORDER-1].
%   The edge value between F and a child C is the child number.
%
%   This method overloads the DTREE method.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.
%   Last Revision: 15-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/03/15 22:36:15 $ 

[order,dwtMode,Lo_R,Hi_R] = get(t,'order','dwtMode','Lo_R','Hi_R');
dwtATTR.extMode = dwtMode;
dwtATTR.shift1D = 0;
dwtATTR.shift2D = [0 0];
nb_up = length(edges);
f     = zeros(nb_up,length(Lo_R));
switch order
    case 2
        K = find(edges==0);
        if ~isempty(K) , f(K,:) = Lo_R(ones(size(K)),:); end
        K = find(edges==1);
        if ~isempty(K) , f(K,:) = Hi_R(ones(size(K)),:); end
        for k=1:nb_up
            s = max(sizes(k,:));
            x = upsconv1(x,f(k,:),s,dwtATTR);
        end

    case 4
        g = f;
        K = find(edges==0);
        if ~isempty(K)
            f(K,:) = Lo_R(ones(size(K)),:);
            g(K,:) = Lo_R(ones(size(K)),:);
        end
        K = find(edges==1);
        if ~isempty(K)
            f(K,:) = Hi_R(ones(size(K)),:);
            g(K,:) = Lo_R(ones(size(K)),:);
        end
        K = find(edges==2);
        if ~isempty(K)
            f(K,:) = Lo_R(ones(size(K)),:);
            g(K,:) = Hi_R(ones(size(K)),:);
        end
        K = find(edges==3);
        if ~isempty(K)
            f(K,:) = Hi_R(ones(size(K)),:);
            g(K,:) = Hi_R(ones(size(K)),:);
        end
        for k=1:nb_up
            s = sizes(k,:);
            x = upsconv2(x,{f(k,:),g(k,:)},s,dwtATTR);
        end
end
