function res = gammaln(x)
%GAMMALN Logarithm of gamma function.
%   Y = GAMMALN(X) computes the natural logarithm of the gamma
%   function for each element of X.  GAMMALN is defined as
%
%       LOG(GAMMA(X))
%
%   and is obtained without computing GAMMA(X).  Since the gamma
%   function can range over very large or very small values, its
%   logarithm is sometimes more useful.
%
%   See also GAMMA, GAMMAINC, PSI.

%   C. Moler, 2-1-91.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.14.4.1 $  $Date: 2003/05/01 20:43:45 $

%   This is based on a FORTRAN program by W. J. Cody,
%   Argonne National Laboratory, NETLIB/SPECFUN, June 16, 1988.
%
% References:
%
%  1) W. J. Cody and K. E. Hillstrom, 'Chebyshev Approximations for
%     the Natural Logarithm of the Gamma Function,' Math. Comp. 21,
%     1967, pp. 198-203.
%
%  2) K. E. Hillstrom, ANL/AMD Program ANLC366S, DGAMMA/DLGAMA, May,
%     1969.
% 
%  3) Hart, Et. Al., Computer Approximations, Wiley and sons, New
%     York, 1968.

%   Note: This M-file is intended to document the algorithm.
%   If a .DLL file or .MEX file for a particular architecture exists,
%   it will be executed instead, but its functionality is the same.
%#mex

     d1 = -5.772156649015328605195174e-1;
     p1 = [4.945235359296727046734888e0; 2.018112620856775083915565e2; 
           2.290838373831346393026739e3; 1.131967205903380828685045e4; 
           2.855724635671635335736389e4; 3.848496228443793359990269e4; 
           2.637748787624195437963534e4; 7.225813979700288197698961e3];
     q1 = [6.748212550303777196073036e1; 1.113332393857199323513008e3; 
           7.738757056935398733233834e3; 2.763987074403340708898585e4; 
           5.499310206226157329794414e4; 6.161122180066002127833352e4; 
           3.635127591501940507276287e4; 8.785536302431013170870835e3];
     d2 = 4.227843350984671393993777e-1;
     p2 = [4.974607845568932035012064e0; 5.424138599891070494101986e2; 
           1.550693864978364947665077e4; 1.847932904445632425417223e5; 
           1.088204769468828767498470e6; 3.338152967987029735917223e6; 
           5.106661678927352456275255e6; 3.074109054850539556250927e6];
     q2 = [1.830328399370592604055942e2; 7.765049321445005871323047e3; 
           1.331903827966074194402448e5; 1.136705821321969608938755e6; 
           5.267964117437946917577538e6; 1.346701454311101692290052e7; 
           1.782736530353274213975932e7; 9.533095591844353613395747e6];
     d4 = 1.791759469228055000094023e0;
     p4 = [1.474502166059939948905062e4; 2.426813369486704502836312e6; 
           1.214755574045093227939592e8; 2.663432449630976949898078e9; 
           2.940378956634553899906876e10; 1.702665737765398868392998e11; 
           4.926125793377430887588120e11; 5.606251856223951465078242e11];
     q4 = [2.690530175870899333379843e3; 6.393885654300092398984238e5; 
           4.135599930241388052042842e7; 1.120872109616147941376570e9; 
           1.488613728678813811542398e10; 1.016803586272438228077304e11; 
           3.417476345507377132798597e11; 4.463158187419713286462081e11];
     c = [-1.910444077728e-03; 8.4171387781295e-04; 
          -5.952379913043012e-04; 7.93650793500350248e-04; 
          -2.777777777777681622553e-03; 8.333333333333333331554247e-02; 
           5.7083835261e-03];

   if ~isempty(x) && (any((imag(x) ~= 0) | (x < 0)))
      error('MATLAB:gammaln:ComplexOrNegInputs',...
            'Input arguments must be real and nonnegative.')
   end
   res = x;
%
%  0 <= x <= eps
%
   k = find(x <= eps);
   if ~isempty(k)
      res(k) = -log(x(k));
   end
%
%  eps < x <= 0.5
%
   k = find((x > eps) & (x <= 0.5));
   if ~isempty(k)
      y = x(k);
      xden = ones(size(k));
      xnum = 0;
      for i = 1:8
         xnum = xnum .* y + p1(i);
         xden = xden .* y + q1(i);
      end
      res(k) = -log(y) + (y .* (d1 + y .* (xnum ./ xden)));
   end
%
%  0.5 < x <= 0.6796875
%
   k = find((x > 0.5) & (x <= 0.6796875));
   if ~isempty(k)
      xm1 = (x(k) - 0.5) - 0.5;
      xden = ones(size(k));
      xnum = 0;
      for i = 1:8
         xnum = xnum .* xm1 + p2(i);
         xden = xden .* xm1 + q2(i);
      end
      res(k) = -log(x(k)) + xm1 .* (d2 + xm1 .* (xnum ./ xden));
   end
%
%  0.6796875 < x <= 1.5
%
   k = find((x > 0.6796875) & (x <= 1.5));
   if ~isempty(k)
      xm1 = (x(k) - 0.5) - 0.5;
      xden = ones(size(k));
      xnum = 0;
      for i = 1:8
         xnum = xnum .* xm1 + p1(i);
         xden = xden .* xm1 + q1(i);
      end
      res(k) = xm1 .* (d1 + xm1 .* (xnum ./ xden));
   end
%
%  1.5 < x <= 4
%
   k = find((x > 1.5) & (x <= 4));
   if ~isempty(k)
      xm2 = x(k) - 2;
      xden = ones(size(k));
      xnum = 0;
      for i = 1:8
         xnum = xnum .* xm2 + p2(i);
         xden = xden .* xm2 + q2(i);
      end
      res(k) = xm2 .* (d2 + xm2 .* (xnum ./ xden));
   end
%
%  4 < x <= 12
%
   k = find((x > 4) & (x <= 12));
   if ~isempty(k)
      xm4 = x(k) - 4;
      xden = -ones(size(k));
      xnum = 0;
      for i = 1:8
         xnum = xnum .* xm4 + p4(i);
         xden = xden .* xm4 + q4(i);
      end
      res(k) = d4 + xm4 .* (xnum ./ xden);
   end
%
%  x > 12
%
   k = find(x > 12);
   if ~isempty(k)
      y = x(k);
      r = repmat(c(7),size(k));
      ysq = y .* y;
      for i = 1:6
         r = r ./ ysq + c(i);
      end
      r = r ./ y;
      corr = log(y);
      spi = 0.9189385332046727417803297;
      res(k) = r + spi - 0.5*corr + y .* (corr-1);
   end
