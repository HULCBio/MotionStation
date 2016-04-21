function y = fixpt_interp1(xdata,ydata,x,xdt,xscale,ydt,yscale,RndMeth);
%FIXPT_INTERP1 fixed-point 1-D interpolation (table lookup).
%
%Y = FIXPT_INTERP1(XDATA,YDATA,X,XDT,XSCALE,YDT,YSCALE,RNDMETH) 
% implements a look up table.  The location of input x in the vector of xdata 
% points is found.  If x is in the range determined by xdata, then the output
% y is found by interpolating between the appropriate pair of ydata points.
% If x is smaller than the first xdata point, then the output y is the first
% ydata point.  If x is larger than the last xdata point, then the output
% is the last ydata point.
%   If the input data type xdt is floating point or the output data type
% ydt is floating point, then floating point calculation will be used.  
% Otherwise, all calculations will be integer only calculations that properly
% handle the inputs scaling xscale and the outputs scaling yscale.
%   Fixed point calculations will obey the specified rounding method RndMeth.
%
% Inputs
%   XDATA    the breakpoints use by the lookup table approximation
%   YDATA    the output data points corresponding to the breakpoints
%   X        input values to be processed by lookup table
%   XDT      input datatype specified using Fixed-Point Blockset conventions.  
%            For example, sfix(16), ufix(8), or float('single')
%   XSCALE   input scaling specified using Fixed-Point Blockset conventions.  
%            For example, 2^-6 means 6 bits to the right of the binary point.
%   YDT      ouput datatype.
%   YSCALE   output scaling.
%   RNDMETH  rounding method.  'floor' (default), 'ceil', 'near', or 'zero'
%
% Outputs
%   Y        output values corresponding to the input values X.
%
% Example
%   xdata = linspace(0,8,33).';
%   ydata = sinc(xdata);
%   x = linspace(-1,9,201);
%   y = FIXPT_INTERP1(xdata, ydata, x, ufix(8), 2^-8, sfix(16), 2^-14, 'Floor')
%
% see also SFIX, UFIX, 
%          FIXPT_LOOK1_FUNC_APPROX, 
%          FIXPT_LOOK1_FUNC_PLOT


% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.4 $  
% $Date: 2002/04/10 18:58:35 $



if nargin < 8
    RndMeth = 'floor';
end

%
% set modes for saturation, doubles override, and interpolation method.
%
DoSatur = 0;
dblOver = 0;
interpMethod=2;

%
% get data type and scaling vectors
%
OutTypeVec = getdatatypespecs(ydt,yscale,dblOver,0);
InTypeVec  = getdatatypespecs(xdt,xscale,dblOver,0);

%
% get a boolean for the saturation mode
%
if ischar(DoSatur)
    if strcmp(DoSatur,'on')
        boolDoSatur = 1;   
    else
        boolDoSatur = 0;   
    end                
else
    boolDoSatur = ~(~DoSatur);   
end

%
% get the integer for the rounding method
%
ROUND_ZERO  = 0;
ROUND_NEAR  = 1;
ROUND_CEIL  = 2;
ROUND_FLOOR = 3;
%
switch lower(RndMeth(1)) 
case 'z'    
    iRndMeth = ROUND_ZERO;   
case 'n'    
    iRndMeth = ROUND_NEAR;   
case 'c'    
    iRndMeth = ROUND_CEIL;   
otherwise    
    iRndMeth = ROUND_FLOOR;   
end

SatRndVec = [boolDoSatur iRndMeth];

y = fixpt_interp1_private(xdata,ydata,x,OutTypeVec,InTypeVec,SatRndVec,dblOver,interpMethod);
