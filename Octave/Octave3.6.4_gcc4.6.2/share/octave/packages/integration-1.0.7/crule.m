function [bp,wf]=crule(m)
%
%usage:  [bp,wf]=crule(m)
%  This function computes Gauss-Chebyshev base points and weight factors
%  using the algorithm given by somebody in 'SomeBook',
%  page 365, Academic Press, 1975, but modified by a change
%  in index variables:  j=i+1 and m=n+1.
%  The weights are all wf_j=pi/m
%  and the base points are bp_j=cos((2j-1)*pi/2/m)
%
%  m -- number of Gauss-Chebyshev points (integrates a (2m-1)th order
%       polynomial exactly)
%
%  The Gauss-Chebyshev Quadrature integrates an integral of the form
%     1					     m
%  Int ((1/sqrt(1-z^2)) f(z)) dz  =  pi/m Sum  (f(cos((2j-1)*pi/2/m)))
%    -1					    j=1
%  For compatability with the other Gauss Quadrature routines, I brought
%  the weight factor into the summation as
%     1					 m
%  Int ((1/sqrt(1-z^2)) f(z)) dz  =   Sum  (pi/m * f(cos((2j-1)*pi/2/m)))
%    -1					j=1

%  By Bryce Gardner, Purdue University, Spring 1993.

j=[1:m]';

wf = ones(m,1) * pi / m;

bp=cos( (2*j-1)*pi / (2*m) );

endfunction
