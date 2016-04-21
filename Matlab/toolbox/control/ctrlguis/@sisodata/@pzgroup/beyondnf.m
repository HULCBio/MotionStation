function boo = beyondnf(Group,PZType,tol)
%BEYONDNF  Returns true for root with natural frequency beyond Nyquist freq.
%
%   For a group G of discrete-time roots, 
%       G.BEYONDNF(PZTYPE,TOL)       PZTYPE = 'pole','zero'
%   returns 1 when there's no nearby root of the same type (real or complex) 
%   with natural frequency < pi/Ts.
% 
%   Nearby is defined as 
%       min | log(z)/s - 1 | < TOL   
%   where min taken over all s of same type with |s|<pi.                                  

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 04:52:46 $

z = get(Group,PZType);
z = z(1);  % nominal root value z

if any(strcmp(Group.Type,{'Real','LeadLag'}))
    % Real root
    boo = (z<=0 | abs(log(z))>(1+tol)*pi);
else
    boo = (abs(log(z))>(1+tol)*pi);
end
    
    
    