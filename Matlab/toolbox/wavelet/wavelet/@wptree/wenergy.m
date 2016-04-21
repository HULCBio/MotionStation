function E = wenergy(t)
%WENERGY Energy for a wavelet packet decomposition.
%   For a wavelet packet tree T, (see WPTREE, WPDEC, WPDEC2) 
%   E = WENERGY(T) returns a vector E, which contains the
%   percentages of energy corresponding to the terminal nodes
%   of the tree T. 
%
%   Examples:
%     load noisbump
%     T = wpdec(noisbump,3,'sym4');
%     E = wenergy(T)
%     ------------------------------
%     load detail
%     T = wpdec2(X,2,'sym4');
%     E = wenergy(T)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 14-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $

C = read(t,'allcfs');
Et = sum(C(:).^2);
tn = leaves(t,'s');
for k=1:length(tn)
    C = read(t,'data',tn(k));
    E(k) = sum(C(:).^2);
end
E = 100*E/Et;
