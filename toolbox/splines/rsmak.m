function rs = rsmak(knots,varargin)
%RSMAK Put together a rational spline in rBform.
%
%   RSMAK(KNOTS,COEFS) returns the rBform of the rational spline
%   specified by the input.
%
%   This is exactly the output of SPMAK(KNOTS,COEFS) except that it is tagged 
%   to be the B-form of a rational spline, namely the rational spline 
%   whose denominator is provided by the last component of the spline, while 
%   its remaining components describe the numerator. Correspondingly, the
%   dimension of its target is one less than it would be for the output of
%   SPMAK(KNOTS,COEFS).
%
%   In particular, the input coefficients must be (d+1)-vector valued for some
%   d>0 and cannot be ND-valued.
%
%   For example, since spmak([-5 -5 -5 5 5 5],[26 -24 26]) provides the B-form
%   of the polynomial t |-> t^2+1 on the interval [-5 .. 5], while 
%   spmak([-5 -5 -5 5 5 5], [1 1 1]) provides the B-form of the constant
%   function 1 there, the command
%
%      runge = rsmak([-5 -5 -5 5 5 5],[1 1 1; 26 -24 26]);
%
%   provides the rBform on the interval [-5 .. 5] for the rational function 
%   t |-> 1/(t^2+1)  famous from Runge's example concerning polynomial inter-
%   polation at equally spaced sites.
%
%   RSMAK(KNOTS,COEFS,SIZEC) is used when COEFS has trailing singleton
%   dimensions in which case SIZEC must be the vector giving the intended
%   size of COEFS. In particular, SIZEC(1) must be the actual first dimension
%   of COEFS, hence SIZEC(1)-1 is the dimension of the target.
%   
%   The rBform is the homogeneous version of a NURBS, in the sense that the
%   typical coefficient in the rBform has the form [w(i)*c(:,i);w(i)], with
%   c(:,i) the corresponding control point of the NURBS and w(i) its
%   corresponding weight.
%
%   RSMAK(OBJECT,varargin) returns the specific geometric shape specified
%   by the string OBJECT. For example,
%
%   rsmak('circle',radius,center)  provides a quadratic rational spline
%   that describes the circle with given radius (default 1) and center
%   (default (0,0) ) .
%
%   rsmak('cone',radius,height)  provides a quadratic rational spline
%   that describes the symmetric cone of given radius (default 1) and 
%   half-height (default 1) centered on the z-axis with apex at (0,0,0).
%
%   rsmak('cylinder',radius,height)  provides a quadratic rational spline
%   that describes the cylinder of given radius (default 1) and 
%   height (default 1) centered on the z-axis.
%
%   rsmak('southcap',radius,center)  provides the south sixth of a sphere of 
%   given radius (default 1) and given center (default (0,0,0) ).
%
%   Use fncmb(rs,transf) to subject the resulting geometric objects to the
%   affine transformation specified by transf.  For example, the following 
%   generates a plot of 2/3 a sphere, as supplied by the `southcap', two 
%   of its rotates, and its reflection:
%
%      southcap = rsmak('southcap');
%      xpcap = fncmb(southcap,[0 0 -1;0 1 0;1 0 0]);
%      ypcap = fncmb(xpcap,[0 -1 0; 1 0 0; 0 0 1]);
%      northcap = fncmb(southcap,-1);
%      fnplt(southcap), hold on, fnplt(xpcap), fnplt(ypcap), fnplt(northcap)
%      axis equal, shading interp, view(-115,10), axis off, hold off
%
%   See also RSBRK, RPMAK, PPMAK, SPMAK, FNBRK.

%   Copyright 1999-2003 C. de Boor and The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2003/04/25 21:12:22 $

if ischar(knots)
             % set defaults for input if needed
   if isempty(varargin) 
      radius = 1;
   else
      radius = varargin{1}; 
      if length(varargin)>1, arg2 = varargin{2}; end
   end

   switch knots
   
   case 'circle' % follow Farin and Lee, representing the circle as
                 % four quadratic BB-patches

      if ~exist('arg2','var'), arg2 = [0;0]; end

      oo = 1/sqrt(2);
      x = radius*[1 1 0 -1 -1 -1  0  1 1]+arg2(1); 
      y = radius*[0 1 1  1  0 -1 -1 -1 0]+arg2(2);
      w =        [1 oo 1 oo 1 oo 1 oo 1];
      rs = spmak(augknt(0:4,3,2),[x.*w;y.*w;w]);
      rs.form = 'rB';
      rs.dim = 2;

%   case 'torus' % follow Tony DeRose, taking the tensor product of a circle
                % with itself.

   case 'cylinder' % follow Tony DeRose, taking the tensor product of a circle
                   % with a line.
   
      if ~exist('arg2','var'), arg2 = 1; end
      circle = rsmak('circle',radius,[0;0]);
      coefs = fnbrk(circle,'coefs');
      newcoefs = zeros(4,size(coefs,2),2);
      newcoefs([1 2 4],:,1) = coefs;
      newcoefs([1 2 4],:,2) = coefs;
      newcoefs(3,:,2) = arg2*coefs(3,:);
      rs = spmak({fnbrk(circle,'knots'),[0 0 1 1]},newcoefs);
      rs.form = 'rB';
      rs.dim = 3;

   case 'cone' % analogous to `cylinder'
   
      if ~exist('arg2','var'), arg2 = 1; end
      circle = rsmak('circle',radius,[0;0]);
      coefs = fnbrk(circle,'coefs');
      newcoefs = zeros(4,size(coefs,2),2);
      newcoefs([1 2 4],:,2) = coefs;
      newcoefs(3,:,2) = arg2.*coefs(3,:);
      newcoefs(1:3,:,1) = -newcoefs(1:3,:,2);
      newcoefs(4,:,1) = coefs(3,:);
      rs = spmak({fnbrk(circle,'knots'),[0 0 1 1]},newcoefs);
      rs.form = 'rB';
      rs.dim = 3;

   case 'southcap' % the south sixth of a sphere, as given by J. Cobb in
                   % `A rational bicubic representation of the sphere',
                   % TR, Computer Science, U.Utah, 1988, as quoted (with one 
                   % excessive minus sign) in G. Farin, NURBS, AKPeters, 1999.

      s = sqrt(2); t = sqrt(3); u = -5*sqrt(6)/3;
      coefs = zeros([4,5,5]);
      coefs(:,:,1) = [4*(1-t) -s        0             s         4*(t-1)
                      4*(1-t) s*(t-4)   (4/3)*(1-2*t) s*(t-4)   4*(1-t)
                      4*(1-t) s*(t-4)   (4/3)*(1-2*t) s*(t-4)   4*(1-t)
                      4*(3-t) s*(3*t-2) (4/3)*(5-t)   s*(3*t-2) 4*(3-t)];

      coefs(:,:,2) = [s*(t-4) (2-3*t)/2 0             (3*t-2)/2 s*(4-t)
                      -s      (2-3*t)/2 s*(2*t-7)/3   (2-3*t)/2 -s
                      s*(t-4) -(t+6)/2  u             -(t+6)/2  s*(t-4)
                      s*(3*t-2) (t+6)/2 s*(t+6)/3     (t+6)/2   s*(3*t-2)];

      coefs(:,:,3) = [4*(1-2*t)/3 s*(2*t-7)/3 0 -s*(2*t-7)/3 -4*(1-2*t)/3
                      0       0         0             0         0
                      4*(1-2*t)/3 u      4*(t-5)/3    u        4*(1-2*t)/3
                      4*(5-t)/3   s*(t+6)/3 4*(5*t-1)/9 s*(t+6)/3 4*(5-t)/3];

      coefs(:,:,4) = [s*(t-4) (2-3*t)/2 0             (3*t-2)/2 s*(4-t)
                      s      -(2-3*t)/2 -s*(2*t-7)/3 -(2-3*t)/2 s
                      s*(t-4) -(t+6)/2  u             -(t+6)/2  s*(t-4)
                      s*(3*t-2) (t+6)/2 s*(t+6)/3     (t+6)/2   s*(3*t-2)];

      coefs(:,:,5) = [4*(1-t) -s        0             s         4*(t-1)
                      4*(t-1) s*(4-t)   (4/3)*(2*t-1) s*(4-t)   4*(t-1)
                      4*(1-t) s*(t-4)   (4/3)*(1-2*t) s*(t-4)   4*(1-t)
                      4*(3-t) s*(3*t-2) (4/3)*(5-t)   s*(3*t-2) 4*(3-t)];

      if radius~=1
         coefs(1:3,:,:) = radius*coefs(1:3,:,:);
      end
      knots = [-1 -1 -1 -1 -1 1 1 1 1 1];
      rs = spmak({knots,knots},coefs);
      rs.form = 'rB';
      rs.dim = 3;
      if exist('arg2','var')&&any(arg2), rs = fncmb(rs,arg2); end

   otherwise
      error('SPLINES:RSMAK:unknowntype',...
      ['Cannot (yet) handle the type ''',knots,'''.'])
   end

else
   rs = spmak(knots,varargin{:});
   dp1 = fnbrk(rs,'dim');
   if length(dp1)>1
      error('SPLINES:RSMAK:onlyvec','A rational spline cannot be ND-valued.')
   end
   if dp1==1
      error('SPLINES:RSMAK:needmorecomps', ...
            'A rational spline must have more than one component.')
   end
   rs.dim = dp1-1; rs.form = 'rB';
end
