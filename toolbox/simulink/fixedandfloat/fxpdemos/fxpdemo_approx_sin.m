%FXPDEMO_APPROX_SIN illustrates the use of the function approximation scripts
%  FIXPT_LOOK1_FUNC_APPROX
%  FIXPT_LOOK1_FUNC_PLOT
% provided with the fixed point blockset.

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.5 $  
% $Date: 2002/04/10 19:02:54 $


funcStr = 'sin(2*pi*x)';

xminStr = '0';
xmaxStr = '0.25';
xmin = eval(xminStr);
xmax = eval(xmaxStr);

xdtStr = 'ufix(16)';
xscaleStr = '2^-16';
xdt=eval(xdtStr);
xscale=eval(xscaleStr);

ydtStr = 'sfix(16)';
yscaleStr = '2^-14';
ydt=eval(ydtStr);
yscale=eval(yscaleStr);

nBitsGoodStr = '8';
errMaxStr = ['2^-',nBitsGoodStr];
nPtsMaxStr = '21';

errMax = eval(errMaxStr);
nPtsMax = eval(nPtsMaxStr);

rndMeth = 'Floor';

home
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp('The general goal of this demo is to find an approximation to ');
disp('the following ideal function')
disp(['   ',funcStr])
disp(['over the input range from ',xminStr,' to ',xmaxStr])
disp(' ')
disp('The approximation is to use a lookup table approach and');
disp('is to be implemented in fixed-point math.')
disp(['The input has data type ', xdtStr, ' and scaling ',xscaleStr])
disp(['The output has data type ', ydtStr, ' and scaling ',yscaleStr])
disp(['Rounding operations should be towards ',rndMeth])
disp(' ')
disp(['A specific goal is to have the approximation good to ',nBitsGoodStr,' bits to the right'])
disp('of the binary point.  In other words, the worst case error should be less')
disp(['than ',errMaxStr])  
disp(' ')
disp('Many sets of lookup table data points would meet this goal.')
disp('The function FIXPT_LOOK1_FUNC_APPROX can be used to find a solution that')
disp('meets the goal with a minimal number of data points.')
disp(' ')
format long
echo on
[xuneven,yuneven] = fixpt_look1_func_approx(funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth,errMax,[])
echo off
disp('The function FIXPT_LOOK1_FUNC_PLOT can be used to view this approximation.')
figure(1)
disp(' ')
echo on
fixpt_look1_func_plot(xuneven,yuneven,funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth);
echo off
drawnow
disp('The bottom of Figure 1 indicates that this approximation uses unevenly ')
disp('spaced breakpoints which requires a fairly intensive implementation.')
disp(' ')
disp('A more streamlined implementation can be obtained if the breakpoints')
disp('are required to be evenly spaced.')
figure(2)
disp(' ')
echo on
[xeven,yeven] = fixpt_look1_func_approx(funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth,errMax,[],'even');
fixpt_look1_func_plot(xeven,yeven,funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth);
echo off
drawnow
disp('The bottom of Figure 2 indicates that more data points were required ')
disp('for the evenly spaced case to achieve the same worst case error limit.')
disp(' ')
disp('An even more streamlined implementation can be obtained if the')
disp('breakpoints are required to be evenly spaced by a power of 2.')
figure(3)
disp(' ')
echo on
[xpow2,ypow2] = fixpt_look1_func_approx(funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth,errMax,[],'pow2');
fixpt_look1_func_plot(xpow2,ypow2,funcStr,xmin,xmax,xdt,xscale,ydt,yscale,rndMeth);
echo off
drawnow
disp('The bottom of Figure 3 indicates that even more data points were required')
disp('for the power of 2 spaced case to achieve the same worst case error limit.')
disp(' ')
disp('The ideal function and the three approximations are used in the mdoel')
disp('fxpdemo_approx.')
disp('   If you have a license to Real Time Workshop, code can be generated for')
disp('this model.  If inline parameters is ON, the generated code will show')
disp('the large differences in the implementation of unevenly spaced, evenly')
disp('spaced, and power of 2 spacing.')
open_system('fxpdemo_approx')
disp(' ')
