function s = getonoff(x)
%GETONOFF Returns a matrix of strings with 'off' or 'on '.
%   S = GETONOFF(X)
%   X is a vector : 
%       X(i) = 0 ==> S(i) = 'off' else S(i) = 'on '     

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 01-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.10 $

r   = length(x);
s   = 'on ';
s   = s(ones(1,r),:);
ind = find(x==0);
if ~isempty(ind)
    soff = 'off';
    soff = soff(ones(1,length(ind)),:);
    s(ind,:) = soff; 
end
