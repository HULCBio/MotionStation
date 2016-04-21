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

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi  12-Feb-2003.
%   Last Revision: 11-Jul-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/03/15 22:38:55 $ 

order = treeord(t);
typeWT = t.WT_Settings.typeWT;
nb_up = length(edges);
switch typeWT
    case {'dwt','wpt'}
        dwtSHIFT = t.WT_Settings.shift;
        dwtEXTM  = t.WT_Settings.extMode;
        Lo_R    = t.WT_Settings.Filters.Lo_R;
        Hi_R    = t.WT_Settings.Filters.Hi_R;
        f = zeros(nb_up,length(Lo_R));
        switch order
            case 2
                K = find(edges==0);
                if ~isempty(K) , f(K,:) = Lo_R(ones(size(K)),:); end
                K = find(edges==1);
                if ~isempty(K) , f(K,:) = Hi_R(ones(size(K)),:); end
                for k=1:nb_up
                    s = max(sizes(k,:));
                    x = upsconv1(x,f(k,:),s,dwtEXTM,dwtSHIFT);
                end
                
            case 4
                dwtATTR = struct('extMode',dwtEXTM,'shift1D',dwtSHIFT,'shift2D',dwtSHIFT);
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
            
    case {'lwt','lwpt'}
        typeDEC = typeWT(2:3);
        LS = t.WT_Settings.LS;
        switch order
            case 2 ,
                
            case 4 ,
                
        end        
end