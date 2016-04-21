function q=pdetriq(p,t)
%PDETRIQ Triangle quality measure.
%
%       Q=PDETRIQ(P,T) returns a triangle quality measure given triangle
%       data. Details on the representation of triangle data in INITMESH.
%       The triangle quality is given by the formula
%
%                   4*sqrt(3)*a
%               q=---------------,
%                  h1^2+h2^2+h3^2
%
%       where a is the area and h1, h2, and h3 the side lengths of
%       the triangle. If q>0.6 the triangle is of acceptable quality.
%       q=1 when h_1=h_2=h_3.
%
%
%       See also INITMESH, JIGGLEMESH, REFINEMESH

%       A. Nordmark 11-28-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:22 $

[ar,tmp1,tmp2,tmp3]=pdetrg(p,t);

h3sq=(p(1,t(1,:))-p(1,t(2,:))).^2+(p(2,t(1,:))-p(2,t(2,:))).^2;
h1sq=(p(1,t(2,:))-p(1,t(3,:))).^2+(p(2,t(2,:))-p(2,t(3,:))).^2;
h2sq=(p(1,t(3,:))-p(1,t(1,:))).^2+(p(2,t(3,:))-p(2,t(1,:))).^2;

q=4*sqrt(3)*ar./(h1sq+h2sq+h3sq);

