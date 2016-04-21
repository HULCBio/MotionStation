function [ xdata, ydata, errWorst ] = fixpt_look1_func_approx(funcStr,xMin,xMax,xdt,xscale,ydt,yscale,rndMeth,errMax,nPtsMax,spacing,Recompute);
%FIXPT_LOOK1_FUNC_APPROX find points for lookup table approximate to a function. 
%
%[ XDATA, YDATA, ERRWORST ] = FIXPT_LOOK1_FUNC_APPROX( FUNCSTR, XMIN, XMAX,
%                                                      XDT, XSCALE,
%                                                      YDT, YSCALE, RNDMETH,
%                                                      ERRMAX, NPTSMAX, SPACING)
% The goal is to approximate a one dimensional function FUNCSTR over the range
% from XMIN to XMAX.  The approximation is implemented using a lookup table 
% approach with interpolation between data points.  Based on criteria supplied
% by options ERRMAX, NPTSMAX, and SPACING, this function finds the breakpoints 
% XDATA for the lookup table and the corresponding output data points YDATA.
%    The lookup table calculations are implemented using the input datatype XDT,
% the input scaling XSCALE, the output datatype YDT, the output scaling YSCALE,
% and the desired rounding mode RNDMETH.  These arguments follow conventions 
% used by the Fixed-Point Blockset.
%    Worst case error ERRWORST is defined to be the maximum absolute error 
% between the ideal function FUNCSTR and its approximation over the range from 
% XMIN to XMAX.  If a maximum acceptable error ERRMAX is supplied, then a goal 
% is to have the worst case error ERRWORST less than ERRMAX.  If a maximum 
% number of data points NPTSMAX is supplied, a goal is for the length of XDATA 
% to be less than or equal to NPTSMAX.
%    If SPACING is provided, it can restrict the breakpoints XDATA to be
% evenly spaced.  Even Spacing can further be restricted to powers of 2. Even 
% Spacing can give implementations that are faster and require smaller command 
% code, but it may require more data points for the same worst case error,
% ERRWORST.  In fixed point cases, power of 2 Spacing further improves speed and
% simplifies command code, but it may require still more data points.
%
% Inputs
%   FUNCSTR   string that when evaluated gives the ideal function's output
%             for the input vector x.  For example, 'sin(2*pi*x)' or 'sqrt(x)'
%   XMIN      minimum input value of interest.
%   XMAX      maximum input value of interest.
%   XDT       input datatype specified using Fixed-Point Blockset conventions.  
%             For example, sfix(16), ufix(8), or float('single')
%   XSCALE    input scaling specified using Fixed-Point Blockset conventions.  
%             For example, 2^-6 means 6 bits to the right of the binary point.
%   YDT       output datatype.
%   YSCALE    output scaling.
%   RNDMETH   rounding method.  'floor' (default), 'ceil', 'near', or 'zero'
%   ERRMAX    maximum worst case approximation error.
%   NPTSMAX   maximum number of breakpoints.
%   SPACING   allowed Spacing: 'pow2', 'even', or 'unrestricted' (default).
%   RECOMPUTE variable which specifies whether the data should be cached away
%             or not. A value of 1 ensures that the lookup table breakpoints
%             are computed always. Any other value causes a global data
%             structure to be created which only computes the lookup table
%             breakpoints if it hasn't been computed before. Default value is one.
%
% Outputs
%   XDATA    breakpoints to be used in lookup table approximation.
%   YDATA    output data points to be used in lookup table approximation.
%   ERRWORST worst case error between ideal function and lookup approximation.
%
% Modes
%   ERRMAX and NPTSMAX both specified.
%     The breakpoints returned will meet both criteria if possible.  If
%     breakpoints with the allowed Spacing can't meet both criteria, then
%     ERRMAX is given priority and NPTSMAX is ignored.
%     If more than one of the allowed Spacing methods will meet both criteria,
%     then power of 2 Spacing is the first choice, evenly spaced is second
%     choice, and unevenly space is third choice.
%     Example:
%       fixpt_look1_func_approx('sin(2*pi*x)',0,0.25,ufix(16),2^-16,sfix(16),2^-14,'floor',0.01,11,'un')
%
%   ERRMAX only is specified.
%     Among the allowed Spacing methods, the breakpoints that meet the
%     error criteria and have the least number of points are returned.
%     Example:
%       fixpt_look1_func_approx('sin(2*pi*x)',0,0.25,ufix(16),2^-16,sfix(16),2^-14,'floor',0.01,[],'pow2');
%     
%   NPTSMAX only is specified  
%     Among the allowed Spacing methods, the breakpoints with NPTSMAX or fewer 
%     data points that gives the smallest worst case error are returned.
%     Example:
%       fixpt_look1_func_approx('sin(2*pi*x)',0,0.25,ufix(16),2^-16,sfix(16),2^-14,'floor',[],17,'un');
%
%   Note: it is not guaranteed that global optimums will be found.  Calculations
%   of worst case errors can depend on fixed-point calculations which are highly
%   nonlinear.  Furthermore, the optimization approach is heuristic.
%
% see also SFIX, UFIX,
%          FIXPT_INTERP1,
%          FIXPT_LOOK1_FUNC_PLOT

% Copyright 1994-2002 The MathWorks, Inc.
% $Revision: 1.8 $  
% $Date: 2002/04/10 18:58:41 $

if nargin < 12 | isempty(Recompute)
  % Set Recompute to default value 
  Recompute = 1;
end
if nargin < 11 | isempty(spacing)
   spacing = 'uneven';
end



persistent DATA
InData = {funcStr spacing nPtsMax errMax rndMeth yscale ydt xscale xdt xMax ...
	  xMin};

if (Recompute ~= 1)

  if isempty(DATA) 
    DATA(1).ParamSettings = InData;

    [xdata_out,ydata_out,errWorst] = fixpt_func_approx(funcStr,xMin,xMax,xdt,xscale,ydt, ...
						    yscale,rndMeth,errMax,nPtsMax, ...
						    spacing);
    DATA(1).xdata_local = xdata_out;
    DATA(1).ydata_local = ydata_out;
    DATA(1).errWorst = errWorst;
    xdata = DATA(1).xdata_local{1};
    ydata = DATA(1).ydata_local{1};
    errWorst = errWorst;
  else
    idx = [];
    for ii = 1:length(DATA)
      res = isequal(DATA(ii).ParamSettings,InData);
      if res == 1
	idx = ii;
	break;
      end
    end

    % if idx = [] it implies that the Settings of the block haven't been
    % cached away yet.

    if isempty(idx)
      new_length = length(DATA) + 1;
      DATA(new_length).ParamSettings = InData;
      
      [xdata_out,ydata_out,errWorst] = fixpt_func_approx(funcStr,xMin,xMax,xdt,xscale,ydt, ...
						      yscale,rndMeth,errMax,nPtsMax, ...
						      spacing);
      DATA(new_length).xdata_local  = xdata_out;
      DATA(new_length).ydata_local  = ydata_out;
      DATA(new_length).errWorst     = errWorst;
      
      xdata    = DATA(new_length).xdata_local ;
      ydata    = DATA(new_length).ydata_local ;
      errWorst = DATA(new_length).errWorst;
    else
      % We have identified the paramsettings for which we already have
      % computed data. Just use the cached data.
      xdata    = DATA(idx).xdata_local;
      ydata    = DATA(idx).ydata_local;
      errWorst = DATA(idx).errWorst;
    end
  end  
else
  [xdata,ydata,errWorst] = fixpt_func_approx(funcStr,xMin,xMax,xdt,xscale, ...
					     ydt,yscale,rndMeth,errMax,nPtsMax,spacing);
  if isempty(DATA)
    DATA(1).ParamSettings = InData;
    DATA(1).xdata_local = xdata;
    DATA(1).ydata_local = ydata;
    DATA(1).errWorst = errWorst;
  else
    idx = [];
    for ii = 1:length(DATA)
      res = isequal(DATA(ii).ParamSettings,InData);
      if res == 1
	idx = ii;
	break;
      end
    end
    if isempty(idx)
      new_length = length(DATA) + 1;
      DATA(new_length).ParamSettings = InData;
      DATA(new_length).xdata_local  = xdata;
      DATA(new_length).ydata_local  = ydata;
      DATA(new_length).errWorst     = errWorst;
    end
  end
end

% Memory management
s = whos('DATA');
memory_Size = s.bytes;

while (memory_Size > 1000000)
  % Find the record in the DATA struct array which hogs the greatest amount
  % of memory and throw that out. If the memory useage still exceeds the
  % memory bound find the next biggest contributor to memory useage and clear
  % that and so on and so forth.
  mem_size = zeros(length(DATA),1);
  for jj = 1:length(DATA)
    mem_struct = DATA(jj);
    s_new = whos( 'mem_struct');
    mem_size(jj) = s_new.bytes;
  end
  [max_value,mem_hog_index] = max(mem_size);
  
  % Now get rid of the memory hogging record
  DATA(mem_hog_index) = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
function [ xdata, ydata, errWorst ] = fixpt_func_approx(funcStr,xMin,xMax, ...
						  xdt,xscale,ydt,yscale, ...
						  rndMeth,errMax,nPtsMax,spacing)
  
xMinFix = num2fixpt( xMin, xdt, xscale, 'Nearest', 'on' );
xMaxFix = num2fixpt( xMax, xdt, xscale, 'Nearest', 'on' );

if xMaxFix <= xMinFix
    error('Maximum x value must be larger than minimum x value (including quantization).');
    return;
end

if nargin < 11 | isempty(spacing)
   unevenAllowed = 1;
   evenAllowed   = 1;
else
   % determine modes that are allowed
   %   allowing less efficient modes automatically allowes more efficient modes
   unevenAllowed =                 ( 'u' == lower(spacing(1)) );
   evenAllowed   = unevenAllowed | ( 'e' == lower(spacing(1)) );
   %
   if ~evenAllowed & isFloatDT(xdt)
     warning('The input is not a fixed point data type so the power of two spacing restriction will be ignored.');
     evenAllowed = 1;
   end
end

if nargin < 10 | isempty(nPtsMax) | nPtsMax <= 1
   nPtsMaxValid = 0;
else
   nPtsMaxValid = 1;
end

if nargin < 9 | isempty(errMax) | errMax <= 0
   errMaxValid = 0;
else
   errMaxValid = 1;
end

if nargin < 8 | isempty(rndMeth)
   rndMeth = 'floor';
end


if errMaxValid & nPtsMaxValid
   %
   % Upper limits on BOTH error and number of data points given
   %    NOTE: the result may have more points than desired, error
   %    goal takes priority.  Also, restrictions on whether even or unrestricted
   %    are allowed will be obeyed even if restriction on number of
   %    points are not met.
   %
   % try power of 2 approach
   %
   xdata = handle_pow2(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
   
   if length(xdata) > nPtsMax & evenAllowed
      %
      %  power of 2 was too big, try even space if allowed
      %
      xdata = handle_even(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
      
      if length(xdata) > nPtsMax & unevenAllowed
          %
          %  even was too big, so use uneven space if allowed
          %
          xdata = handle_uneven(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
      end
   end

elseif errMaxValid
   %
   % No upper limit on Number of Points given 
   %   the least number of points that meet the error bound should be found
   %
   if unevenAllowed   
   
      xdata = handle_uneven(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
   
   elseif evenAllowed
   
      xdata = handle_even(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
   else

      xdata = handle_pow2(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
   end

elseif nPtsMaxValid
   %
   % No upper limit on error given
   %    using the specified number of data points 
   %    the data points that give the smallest worst case error should be found
   %
   xdata = handle_best_npts(funcStr,nPtsMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth,unevenAllowed,evenAllowed);
   
else
   error('Both upper limits were invalid.');
end  
   
errWorst = get_sim_error(funcStr,xdata,xMin,xMax,xdt,xscale,ydt,yscale,rndMeth);    

x = xdata;
ydata = eval(funcStr);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xdata = handle_uneven(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
%
% uneven spacing case
%
xdata = [ xMinFix; xMaxFix ];

xbit = get_lsb(xdt,xscale,xMinFix,xMaxFix);

while 1

   xLeft = xdata(end-1);

   xLargestKnownGood = xLeft + xbit;
   
   xSmallestKnownBad = xMaxFix + xbit;
   
   while ( xSmallestKnownBad - xLargestKnownGood ) > xbit
   
      xTry = num2fixpt( 0.5*(xLargestKnownGood+xSmallestKnownBad), xdt, xscale, 'Nearest', 'on' );
      
      if xTry <= xLargestKnownGood | xSmallestKnownBad <= xTry
        break;
      end
   
      xlast2 = [xLeft xTry];
         
      x = xlast2;
      ylast2 = eval(funcStr);

      % test mid point
      
      xMid = num2fixpt( 0.5*sum(xlast2), xdt, xscale, 'Nearest', 'on' );

      yMid_fix = fixpt_interp1(xlast2,ylast2,xMid,xdt,xscale,ydt,yscale,rndMeth);

      x = xMid;
      yMid_ideal = eval(funcStr);

      if max( abs( yMid_ideal - yMid_fix ) ) > errMax

          xSmallestKnownBad = xTry;

      else          
          errCur = get_sim_error(funcStr,xlast2,xlast2(1),xlast2(2),xdt,xscale,ydt,yscale,rndMeth);    
       
          if errCur <= errMax
          
            xLargestKnownGood = xTry;
            
          else
          
            xSmallestKnownBad = xTry;
            
          end
      end              
   end
   
   if xLargestKnownGood < xMaxFix
   
      xdata(end) = xLargestKnownGood;
      xdata(end+1) = xMaxFix;
   else
      xdata(end) = xMaxFix;
      break;
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xdata = handle_even(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
%
% even spacing case
%

xdata = handle_pow2(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);

nSmallestKnownGood = length(xdata);

nLargestKnownBad = floor(0.5*length(xdata));

while ( nSmallestKnownGood - nLargestKnownBad ) > 1

   nTry = round( 0.5 * ( nSmallestKnownGood + nLargestKnownBad ) );
   
   if nTry <= nLargestKnownBad | nSmallestKnownGood <= nTry
     break;
   end

   xDataTry = get_neven_xdata(nTry,xMinFix,xMaxFix,xdt,xscale);
   
   errCur = get_sim_error(funcStr,xDataTry,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);    
       
   if errCur <= errMax
   
        nSmallestKnownGood = nTry;
        xdata = xDataTry;
   else            
        nLargestKnownBad   = nTry;
   end
end
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xdata = handle_pow2(funcStr,errMax,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
%
% power of 2 case
%
xdata = get_x_sim(xMinFix,xMaxFix,xdt,xscale);

pLargestKnownGood = 0;

xbit = get_lsb(xdt,xscale,xMinFix,xMaxFix);

pSmallestKnownBad = ceil(log2((xMaxFix-xMinFix)/xbit))+1;

while ( pSmallestKnownBad - pLargestKnownGood ) > 1

    pTry = round( 0.5 * ( pLargestKnownGood + pSmallestKnownBad ) );
    
    if pTry <= pLargestKnownGood | pSmallestKnownBad <= pTry
     break;
    end
    
    xSpacingTry = xbit * 2^pTry;
    
    xDataTry = ( xMinFix : xSpacingTry : (xMaxFix+(0.5-eps)*xbit) ).';
             
    %
    % get worst case error
    %
    if length(xDataTry) < 2       
       % too few points, so force it to fail    
       errCur = 2*errMax;
    else
       errCur = get_sim_error(funcStr,xDataTry,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);    
    end
    
    if errCur <= errMax
    
        pLargestKnownGood = pTry;
        xdata = xDataTry;            
    else            
        
       if xDataTry(end) > (xMaxFix-0.5*xbit)
       
            pSmallestKnownBad = pTry;
            
       else
          % try point beyond end
           
          xDataTry = [ xDataTry; xDataTry(end)+xSpacingTry ];
           
          xDataTry = num2fixpt( xDataTry, xdt, xscale, 'Nearest', 'on' );
    
          ii = find( abs( diff( diff( xDataTry ) ) ) > xbit/16 );
           
          if length(ii) > 0
    
              % no good because extra point saturated
              pSmallestKnownBad = pTry;
          else
              errCur = get_sim_error(funcStr,xDataTry,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);    
                  
              if errCur <= errMax
                   pLargestKnownGood = pTry;
                   xdata = xDataTry;                       
              else            
                   pSmallestKnownBad = pTry;
              end
          end           
       end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x_sim = get_x_sim(xMin,xMax,xdt,xscale);
%
% get x sim vector
%
xMinFix = num2fixpt( xMin, xdt, xscale, 'Nearest', 'on' );
xMaxFix = num2fixpt( xMax, xdt, xscale, 'Nearest', 'on' );

xbit = get_lsb(xdt,xscale,xMinFix,xMaxFix);

x_sim = (xMinFix:xbit:xMaxFix).';

if x_sim(end) < xMaxFix;
  x_sim(end+1) = xMaxFix;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xdata,xSpacing] = get_neven_xdata(nPts,xMin,xMax,xdt,xscale);
%
% get x sim vector
%
xMinFix = num2fixpt( xMin, xdt, xscale, 'Nearest', 'on' );
xMaxFix = num2fixpt( xMax, xdt, xscale, 'Nearest', 'on' );

xbit = get_lsb(xdt,xscale,xMinFix,xMaxFix);

%
% don't use bias for spacing
%
xSpacing = num2fixpt( (xMaxFix-xMinFix)/(nPts-1), xdt, xbit, 'Nearest', 'on' );

if xSpacing == 0
   % step at least one bit
   xSpacing = xbit;
end
   
xdata = xMinFix + (0:(nPts-1)).'*xSpacing;
   
ii = find( xdata > xMaxFix );

if length(ii) > 1
  %
  % never have use for more than one point beyond xMaxFix
  %
  xdata(ii(2:end)) = [];
end
             
xdata = num2fixpt( xdata, xdt, xscale, 'Nearest', 'on' );

ii = find( abs( diff( diff( xdata ) ) ) > xbit/16 );

if length(ii) > 0
  %
  % strip off end points that have saturated to the same value
  %
  xdata(ii+2) = [];
  %
  % check that spacing still even
  %
  if any( abs( diff( diff( xdata ) ) ) > xbit/16 )
     error('ASSERT: Scaling not even.')
  end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function errCur = get_sim_error(funcStr,xdata,xMin,xMax,xdt,xscale,ydt,yscale,rndMeth);
%
x_sim = get_x_sim(xMin,xMax,xdt,xscale);

x = xdata;
ydata = eval(funcStr);
 
y_sim = fixpt_interp1(xdata,ydata,x_sim,xdt,xscale,ydt,yscale,rndMeth);

x = x_sim;
y_ideal = eval(funcStr);
                 
errCur = max( abs( y_ideal - y_sim ) );



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xdata = handle_best_npts(funcStr,nPts,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth,unevenAllowed,evenAllowed);

ybit = get_lsb(ydt,yscale,xMinFix,xMaxFix);

errTol = max(0.5*ybit,eps);

xbit = get_lsb(xdt,xscale,xMinFix,xMaxFix);

if evenAllowed | unevenAllowed

   xdata = [xMinFix;xMaxFix];

else
   % power of two case
   xSpacingTry = xbit * 2^ceil( log2( (xMaxFix-xMinFix)/xbit/(nPts-1) ) );
    
   xdata = ( xMinFix : xSpacingTry : (xMaxFix+(0.5-eps)*xbit) ).';             
end

errAttained = get_sim_error(funcStr,xdata,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);

errFailed = 0;

while ( errAttained - errFailed ) > 0.5*errTol;

  errAttempt = 0.5*(errAttained+errFailed);
    
  if errAttempt >= errAttained | errFailed >= errAttempt
    break;
  end
  
  if unevenAllowed

     xx = handle_uneven(funcStr,errAttempt,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);

  elseif evenAllowed
  
     xx = handle_even(funcStr,errAttempt,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
  else

     xx = handle_pow2(funcStr,errAttempt,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);
  end

  errNew = get_sim_error(funcStr,xx,xMinFix,xMaxFix,xdt,xscale,ydt,yscale,rndMeth);

  if length(xx) > nPts
  
     errFailed   = max(errAttempt,errNew);
     
  else
     errNew = min(errAttempt,errNew);
     
     if errNew < errAttained
        errAttained = errNew;
        xdata = xx;
     end
  end
   
end

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

  
  



