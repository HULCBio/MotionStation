function [F,obeta,otheta] = para2fan(varargin)
%PARA2FAN Compute fan-beam projections from parallel-beam tomography data.
%   F = PARA2FAN(P,D) computes the fan-beam data (sinogram) F from the
%   parallel-beam data (sinogram) P. Each column of P contains the
%   parallel-beam sensor samples at one rotation angle. D is the distance in
%   pixels from the center of rotation to the vertex of the fan beams.
%
%   The sensors are assumed to have a one-pixel spacing. The parallel-beam
%   rotation angles are assumed to be spaced equally to cover [0,180)
%   degrees. The calculated fan-beam rotation angles cover [0,360) degrees
%   with the same spacing as the parallel-beam rotation angles. The
%   calculated fan-beam angles are equally spaced with the spacing set to
%   the smallest angle implied by the sensor spacing.
%
%   F = PARA2FAN(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   specifies parameters that control various aspects of the PARA2FAN 
%   conversion. Parameter names can be abbreviated, and case does not
%   matter. Default values are in braces ({}).
%
%   Parameters include:
%
%   'FanCoverage'            String.
%                            See IFANBEAM for details.
%
%                            {'cycle'}, 'minimal'
%
%   'FanRotationIncrement'   Positive real scalar specifying the rotation 
%                            angle increment of the fan-beam projections in
%                            degrees.
%
%                            If 'FanCoverage' is 'cycle' the value of
%                            'FanRotationIncrement' must be a factor of 360.
%
%                            If 'FanRotationIncrement' is not specified,
%                            then it is set to the same spacing as the
%                            parallel-beam rotation angles.
%
%   'FanSensorGeometry'      String.
%                            See FANBEAM for details.
%
%                            {'arc'}, 'line'
%
%   'FanSensorSpacing'       Positive real scalar specifying the spacing
%                            of the fan beams. Interpretation of the value
%                            depends on the setting of
%                            'FanSensorGeometry'.
%
%                            If 'FanSensorGeometry' is 'arc', the value
%                            defines the angular spacing in degrees.
%
%                            If 'FanSensorGeometry' is 'line', the value
%                            defines the linear spacing in pixels.
%                           
%                            If 'FanSensorSpacing' is not specified, the
%                            default is the smallest value implied by
%                            'ParallelSensorSpacing' such that:
%                            
%                            If 'FanSensorGeometry' is 'arc' then
%                            'FanSensorSpacing' is
%                            
%                               180/PI*ASIN(PSPACE/D) 
%                            
%                            where PSPACE is the value of the
%                            'ParallelSensorSpacing'.
%                            
%                            If 'FanSensorGeometry' is 'line' then
%                            'FanSensorSpacing' is 
%                            
%                               D*ASIN(PSPACE/D).
%
%   'Interpolation'          Specifies the type of interpolation used
%                            between the parallel-beam and fan-beam data.
%
%                            'nearest'   - nearest neighbor
%                            {'linear'}  - linear
%                            'spline'    - piecewise cubic spline
%                            'pchip'     - piecewise cubic Hermite (PCHIP)
%                            'cubic'     - same as 'pchip'
%
%   'ParallelCoverage'       Specifies the range of rotation.
%
%                            'cycle'       - Parallel data covers 360 degrees
%                            {'halfcycle'} - Parallel data covers 180 degrees
%
%   'ParallelSensorSpacing'  Positive real scalar.
%                            Specifies the spacing of the parallel-beam
%                            sensors in pixels.
%                            {1}
%
%   [F,FAN_POSITIONS,FAN_ROTATION_ANGLES] = FAN2PARA(...)  If
%   'FanSensorGeometry' is 'arc', FAN_POSITIONS contains the fan-beam
%   sensor measurement angles. If 'FanSensorGeometry' is 'line',
%   FAN_POSITIONS contains the fan-beam sensor positions along the line
%   of sensors. FAN_ROTATION_ANGLES contains rotation angles.
%
%   Class Support
%   -------------
%   All numeric input arguments must be of class double.  The output
%   arguments are of class double.
%
%   Example
%   -------
%       % Generate parallel-beam projections
%       ph = phantom(128);
%       theta = 0:180;
%       [P,xp] = radon(ph,theta);
%       imshow(theta,xp,P,[],'n'), axis normal
%       title('Parallel-Beam Projections')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(hot), colorbar
%
%       % Convert to fan-beam projections
%       [F,Fpos,Fangles] = para2fan(P,100);  
%       figure, imshow(Fangles,Fpos,F,[],'n'), axis normal
%       title('Fan-Beam Projections')
%       xlabel('\theta (degrees)')
%       ylabel('Sensor Locations (degrees)')
%       colormap(hot), colorbar
%
%   See also FAN2PARA, FANBEAM, IRADON, IFANBEAM, PHANTOM, RADON.

%   $Revision.4 $  $Date: 2003/12/13 02:43:16 $
%   Copyright 1993-2003 The MathWorks, Inc.

% variable definitions
%            dploc    -   spatial increments of input parallel-beam samples
%            dtheta   -   rotation angular increment of input projections
%            cycle    -   indicates whether input data covers 180 or 360
%            minimal  -   indicates whether output will be 360 or minimal rep

args = parse_inputs(varargin{:});

P       = args.P;
d       = args.d;
dploc   = args.ParallelSensorSpacing;
dbeta   = args.FanSensorSpacing;
dtheta  = args.FanRotationIncrement;
interp  = args.Interpolation;

[m,n] = size(P);
nn = n/2;
r = 180/pi;       % radian-to-degree conversion factor

m2cn = floor((m-1)/2);
m2cc = floor((m+1)/2);
m2cp = floor((m)/2);

ploc = dploc *(-m2cn:m2cp);
betamax = asin(max(ploc)/d);
betamin = asin(min(ploc)/d);
if strcmp(args.FanSensorGeometry,'line')
   % argbeta centered at zero between two limits
   argbeta = [fliplr(0:-dbeta:d*sin(betamin)) dbeta:dbeta:d*sin(betamax)];
   beta = asin(argbeta/d);    % set fan angles to yield equal spacing
else  
   % set equal fan angles centered at zero
   beta=[fliplr(0:-pi*dbeta/180:betamin) pi*dbeta/180:pi*dbeta/180:betamax];
end

if strcmp(args.FanCoverage,'minimal')
   del = dtheta/180*pi;
   betamax = max(beta) - n*pi*eps;
   betamin = min(beta) + n*pi*eps;
   theta = [fliplr(0:-del:-betamax) del:del:pi-betamin];
   theta = [min(theta)-del theta max(theta)+del];
else
   % default is 360 degrees of rotation
   if abs(rem(360/dtheta,1)) > 2*sqrt(eps)
       eid = sprintf('Images:%s:dthetaNotFactorOf360',mfilename);
       error(eid,'''FanRotationIncrement'' must be a factor of 360.');
   end
   theta = 0:pi*dtheta/180:(2*pi*(1-2*sqrt(eps)*ceil(360/dtheta)));
end

if strcmp(args.ParallelCoverage,'cycle')
   ptheta = (0:n-1)*2*pi/n;  % input angles 0 to 2*pi
else
   ptheta = (0:n-1)*pi/n;      % input angles 0 to pi
end

% interpolate to get desired beta sample locations
Pint = zeros(length(beta),n);
ploc_beta = d*sin(beta);

% interpolate in ploc domain, since this represents actual spacing
for i=1:length(ptheta)
   Pint(:,i) = interp1(ploc,P(:,i)',ploc_beta,interp)';  
end

% build padded Pint
if ~strcmp(args.ParallelCoverage,'cycle')
   % if input covers 180 degrees, make it 360
   Ppad = [ Pint flipud(Pint)];
   pthetapad = [ptheta ptheta+pi];
else
   Ppad = Pint;
   pthetapad = ptheta;
end
ptmask = (pthetapad >= 2*pi - (max(beta) - min(beta)));
ptmask2 = (pthetapad <= (max(beta) - min(beta)));
Ppad = [Ppad(:,ptmask) Ppad Ppad(:,ptmask2)];
pthetapad = [pthetapad(ptmask)-2*pi pthetapad pthetapad(ptmask2)+2*pi];

% shift to correct for fan-beam angle offsets and interpolate
F = zeros(length(beta),length(theta));
for i=1:length(beta)
   F(i,:) = interp1(pthetapad-beta(i),Ppad(i,:),theta,interp);
end

if strcmp(args.ParallelCoverage,'cycle')
   Ppad = flipud(Ppad);
   pthetapad = pthetapad - pi;
   theta2 = mod(theta+pi,2*pi)-pi;
   for i=1:length(beta)
      F(i,:) = F(i,:) + interp1(pthetapad-beta(i),Ppad(i,:),theta2,interp);
   end
   F = F/2;
end

otheta = theta*180/pi;
if strcmp(args.FanSensorGeometry,'line')
   obeta = argbeta;
else
   obeta = beta*180/pi;
end

% check for out-of-range interpolated values that should be zero
indnan = isnan(F);
F(indnan) = 0;

%-------------------------------------
function args = parse_inputs(varargin)

checknargin(2,16,nargin,mfilename);

P = varargin{1};
d = varargin{2};

checkinput(P, {'double'}, ...
           {'real', '2d', 'nonsparse'}, ...
           mfilename, 'P', 1);

checkinput(d, {'double'},...
           {'real', '2d', 'nonsparse', 'positive'}, ...
           mfilename, 'D', 2);

% Default values
args.ParallelSensorSpacing = [];
args.FanSensorSpacing      = [];
args.FanRotationIncrement  = [];
args.ParallelCoverage      = 'halfcycle';
args.FanSensorGeometry     = 'arc';
args.FanCoverage           = 'cycle';
args.Interpolation         = 'linear';

valid_params = {'ParallelSensorSpacing',...
                'FanSensorSpacing',...
                'FanRotationIncrement',...
                'ParallelCoverage',...
                'FanSensorGeometry',...
                'FanCoverage',...
                'Interpolation'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

% quantities to figure ploc ranges
[m,n] = size(P);

% fix n if using full cycle
nn = n;
if strcmp(args.ParallelCoverage,'cycle')
   nn = n/2;
end

% make projections odd m-dimension for symmetry
if mod(m,2) == 0
   m = m + 1;
   P = [zeros(1,n) ; P];
end
% pad to make sure we have a good boundary
m = m + 2;
P = [zeros(1,n) ; P ; zeros(1,n)];

if isempty(args.ParallelSensorSpacing)
    args.ParallelSensorSpacing = 1;
end

% compute max ploc and make sure D is large enough
if (args.ParallelSensorSpacing*(m-1)/2/d > sin(80*pi/180))
    derror = sprintf(...
        'D not large enough to include all input data. D must be at least %d.',...
        ceil(args.ParallelSensorSpacing*(m-1)/2/sin(80*pi/180)));
    eid = sprintf('Images:%s:dTooSmall',mfilename);
    error(eid,'%s',derror);
end

if isempty(args.FanSensorSpacing)
    if strcmp(args.FanSensorGeometry,'line')
        % smallest spacing implied by ploc spacing
        args.FanSensorSpacing = d*asin(args.ParallelSensorSpacing/d);        
    else
        % smallest angle implied by ploc spacing
        args.FanSensorSpacing = 180/pi*asin(args.ParallelSensorSpacing/d);   
    end
end

if isempty(args.FanRotationIncrement)
    % default spacing same as PTHETA
    args.FanRotationIncrement = 180/nn;
end

args.P = P;
args.d = d;
