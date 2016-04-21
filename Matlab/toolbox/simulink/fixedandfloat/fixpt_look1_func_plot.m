function errWorst=fixpt_look1_func_plot(xdata,ydata,funcStr,xMin,xMax,xdt,xscale,ydt,yscale,rndMode);
%FIXPT_LOOK1_FUNC_PLOT plot an ideal function and its lookup approximation. 
%
%ERRWORST = FIXPT_LOOK1_FUNC_PLOT( XDATA, YDATA,
%                                  FUNCSTR, XMIN, XMAX,
%                                  XDT, XSCALE,
%                                  YDT, YSCALE, RNDMETH)
% Over the range from XMIN to XMAX, the ideal function FUNCSTR is plotted.
% Also, the lookup table approximation determined by the data points XDATA
% and YDATA is plotted.  The error between the ideal and the lookup table 
% approximation is also plotted.  
%    The lookup table calculations are implemented using the input datatype XDT,
% the input scaling XSCALE, the output datatype YDT, the output scaling YSCALE,
% and the desired rounding mode RNDMETH.  These arguments follow conventions 
% used by the Fixed-Point Blockset.
%    Worst case error ERRWORST is defined to be the maximum absolute error 
% between the ideal function FUNCSTR and its approximation over the range from 
% XMIN to XMAX.  
%
% Inputs
%   XDATA    the breakpoints use by the lookup table approximation
%   YDATA    the output data points corresponding to the breakpoints
%   FUNCSTR  string that when evaluated gives the ideal function's output
%            for the input vector x.  For example, 'sin(2*pi*x)' or 'sqrt(x)'
%   XMIN     minimum input value of interest.
%   XMAX     maximum input value of interest.
%   XDT      input datatype specified using Fixed-Point Blockset conventions.  
%            For example, sfix(16), ufix(8), or float('single')
%   XSCALE   input scaling specified using Fixed-Point Blockset conventions.  
%            For example, 2^-6 means 6 bits to the right of the binary point.
%   YDT      output datatype.
%   YSCALE   output scaling.
%   RNDMETH  rounding method.  'floor' (default), 'ceil', 'near', or 'zero'
%
% Outputs
%   ERRWORST worst case error between ideal function and lookup approximation.
%
% Example
%   xdata = linspace(0,0.25,5).';
%   ydata = sin(2*pi*xdata);
%   FIXPT_LOOK1_FUNC_PLOT(xdata, ydata, 'sin(2*pi*x)', 0, 0.25, ...
%                         ufix(8), 2^-8, sfix(16), 2^-14, 'Floor')
%
% see also SFIX, UFIX
%          FIXPT_INTERP1,
%          FIXPT_LOOK1_FUNC_APPROX

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.7 $  
% $Date: 2002/04/10 18:58:47 $

xIsFloat = isFloatDT(xdt);
yIsFloat = isFloatDT(ydt);

xbit = get_lsb(xdt,xscale,xMin,xMax);
ybit = get_lsb(ydt,yscale,xMin,xMax);

[y_fix_look_fine_grid,x_fine_grid] = fixpt_look1_sim(xdata,ydata,xMin,xMax,xdt,xscale,ydt,yscale,rndMode);

x=x_fine_grid;
y_ideal_fine_grid = eval(funcStr);

errFix = abs(y_ideal_fine_grid - y_fix_look_fine_grid);

errWorst = max(errFix);


errY = errFix;

maxErrY = errWorst;

ylabelStr = ['Absolute Error'];

if xIsFloat & yIsFloat
  titleStr = ['Function ',funcStr,'     Ideal (red)   Floating-Point Lookup Approximation (blue)'];
else
  titleStr = ['Function ',funcStr,'     Ideal (red)   Fixed-Point Lookup Approximation (blue)'];
end


ip    = 0;
ipmax = 3;

ip = ip+1;
subplot(ipmax,1,ip)
plot( x_fine_grid, y_ideal_fine_grid, 'r-', x_fine_grid, y_fix_look_fine_grid, 'b-' );
title(titleStr);
xy=axis;
axis([xMin xMax xy(3) xy(4)]);
ylabel('Outputs')

ip = ip+1;
subplot(ipmax,1,ip)
plot( x_fine_grid, errY, 'k-' );
ylabel(ylabelStr)
axis([xMin xMax 0 maxErrY]);

xdiff = diff(xdata);

mxdiff = max(xdiff);

if mxdiff == min(xdiff)

   if floor(log2(mxdiff)) == log2(mxdiff)
   
      str = ' power of 2 spaced';
   else
      str = ' evenly spaced';
   end
else
   str = ' unevenly spaced';
end

[ydtstring,ylsb,ybias] = get_dtstring(ydt,yscale);

dataTypeStrings = ['The input is ', get_dtstring(xdt,xscale), '\nThe output is ', ydtstring ];

xlabel('Input')
grid

h = gcf;

report = ['Table uses ',num2str(length(xdata)), str,' data points.'];
report = [report,'\n',dataTypeStrings];

if yIsFloat
  x1Str = '';
  report = [report '\nMaximum Absolute Error ',num2str(errWorst)];
else

  report = [report '\nMaximum Absolute Error  ',num2str(errWorst),'   log2(MAE) = ',num2str(log2(errWorst)),'   MAE/yBit = ',num2str(errWorst/ybit)];

  badBits = ceil(log2(errWorst/ybit));

  badBits = max(0,badBits);
     
  if badBits == 1
    report = [report '\nThe least significant bit of the output can be inaccurate.'];
  elseif badBits > 0
    report = [report '\nThe least significant ',num2str(badBits),' bits of the output can be inaccurate.'];
  else
    report = [report '\nThe least significant bit of the output is accurate.'];
  end

  yIntegers = (ydata-ybias)/ylsb;
  
  log2maxInteger = log2(max(yIntegers));
  
  reachedBits = ceil(log2maxInteger) + (log2maxInteger == ceil(log2maxInteger));
  
  if min(ydata) < 0
    reachBits = max( reachedBits, ceil(log2(abs(min(ydata)))) );
  end 
  
  notReachedBits = max(0, ydt.MantBits - ydt.IsSigned - reachedBits );
  
  accurateBits = ydt.MantBits - ydt.IsSigned - notReachedBits - badBits;

  if ydt.IsSigned
    if notReachedBits == 1
      report = [report '\nThe most significant nonsign bit of the output is not used.'];
    elseif notReachedBits > 1
      report = [report '\nThe most significant ',num2str(notReachedBits),' nonsign bits of the output are not used.'];
    else
      report = [report '\nThe most significant nonsign bit of the output is used.'];
    end
    
    report = [report '\nThe remaining ',num2str(accurateBits),' nonsign bits of the output are used and always accurate.'];

    if min(ydata) >= 0
       report = [report '\nThe sign bit of the output is not used.'];
    else
       report = [report '\nThe sign bit of the output is used.'];
    end
    
  else
  
    if notReachedBits == 1
      report = [report '\nThe most significant bit of the output is not used.'];
    elseif notReachedBits > 1
      report = [report '\nThe most significant ',num2str(notReachedBits),' bits of the output are not used.'];
    else
      report = [report '\nThe most significant bit of the output is used.'];
    end
    
    report = [report '\nThe remaining ',num2str(accurateBits),' bits of the output are used and always accurate.'];

  end    
  
  report = [report '\nThe rounding mode is to ',rndMode];  
end

text(xMin-0.125*(xMax-xMin),-maxErrY,sprintf(report))

%%%%%%%%
function [y,u] = fixpt_look1_sim(xdata,ydata,xMin,xMax,xdt,xscale,ydt,yscale,rndMode)

xbit = get_lsb(xdt,xscale,xMin,xMax);

xMinFix = num2fixpt( xMin, xdt, xscale, 'Nearest', 'on' );

xMaxFix = num2fixpt( xMax, xdt, xscale, 'Nearest', 'on' );

u = (xMinFix:xbit:xMaxFix).';

if u(end) < xMaxFix;
  u(end+1) = xMaxFix;
end

y = fixpt_interp1(xdata,ydata,u,xdt,xscale,ydt,yscale,rndMode); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function lsb = get_lsb(xdt,xscale,xmin,xmax);

  switch xdt.Class

  case 'FIX'
    lsb = xscale(1);

  case 'INT'
    lsb = 1;

  case 'FRAC'
      lsb = xdt.IsSigned-xdt.MantBits+xdt.GuardBits;

  case { 'DOUBLE', 'SINGLE' 'FLOAT' }
      lsb = (xmax-xmin)/10000;
      if lsb <= 0
        lsb = sqrt(eps);
      end

  otherwise
      error('This class of data type is not supported')
  end  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resultBool = isFloatDT(xdt);

  switch xdt.Class

  case { 'DOUBLE', 'SINGLE' 'FLOAT' }
      resultBool = 1;

  otherwise
      resultBool = 0;
  end  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dtstring,lsb,bias] = get_dtstring(xdt,xscale);

  lsb = [];
  bias = [];
  
  switch xdt.Class

  case {'FIX', 'INT', 'FRAC' }
  
    dtstring = '';
    
    if xdt.IsSigned
      dtstring = [ dtstring, 'Signed'];
    else
      dtstring = [ dtstring, 'Unsigned'];
    end
    
    dtstring = [ dtstring, ' ',num2str(xdt.MantBits),' Bit'];
    
    
    lsb = get_lsb(xdt,xscale,0,1);
    
    if lsb ~= 1
      expPow2 = log2(lsb);
      
      if expPow2 < 0 & floor(expPow2) == expPow2
        dtstring = [ dtstring, ' with ',num2str(-expPow2),' bits right of binary point'];
      else
        dtstring = [ dtstring, ' Slope ',num2str(lsb)];
      end
    end
    
    if strcmp(xdt.Class,'FIX') &  length(xscale) > 1
      bias = xscale(2);
    else
      bias = 0;
    end
    
    if bias ~= 0
      dtstring = [ dtstring, ' Bias ',num2str(bias)];
    end

  case 'DOUBLE'
    dtstring = 'Floating-Point Double';
  
  case 'SINGLE' 
    dtstring = 'Floating-Point Single';
  
  case 'FLOAT'
    dtstring = 'Floating-Point Custom';
  
  otherwise
      error('This class of data type is not supported')
  end  
