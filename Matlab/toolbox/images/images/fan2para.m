function [P,oploc,optheta] = fan2para(varargin)
%FAN2PARA Compute parallel-beam projections from fan-beam tomography data.
%   P = FAN2PARA(F,D) computes the parallel-beam data (sinogram) from the
%   fan-beam data (sinogram) F. Each column of F contains the fan-beam
%   spread angles at a single rotation angle. D is the distance from the
%   fan-beam vertex to the center of rotation. 
%
%   FAN2PARA assumes the fan-beam spread angles have the same increments as
%   the input rotation angles split equally on either side of zero. The
%   input rotation angles are assumed to be stepped in equal increments to
%   cover [0,360) degrees. Output angles are calculated to cover [0,180)
%   degrees in the same increments as the input.
%
%   P = FAN2PARA(...,PARAM1,VAL1,PARAM2,VAL2,...)
%   specifies parameters that control various aspects of the FAN2PARA 
%   conversion. Parameter names can be abbreviated, and case does not
%   matter. Default values are in braces ({}).
%
%   Parameters include:
%
%   'FanCoverage'                String specifying the range through
%                                which the beams are rotated.
%                                See IFANBEAM for details.
%
%                                {'cycle'}, 'minimal'
%
%   'FanRotationIncrement'       Positive real scalar specifying the
%                                increment of the rotation angle of the
%                                fan-beam projections. 
%                                See FANBEAM for details.
%                               
%                                There is no default. You must specify a
%                                value when 'FanCoverage' is 'minimal'.
%
%   'FanSensorGeometry'          String specifying the spacing of the fan
%                                beams. 
%                                See FANBEAM for details.
%
%                                {'arc'}, 'line'
%                               
%   'FanSensorSpacing'           Positive real scalar specifying the
%                                spacing of the fan beams.
%                                See FANBEAM for details.
%
%                                {1}
%                               
%   'Interpolation'              String specifying the type of
%                                interpolation used when interpolating
%                                between the parallel-beam and fan-beam data.
%                                See PARA2FAN for details.
%
%                                'nearest' {'linear'} 'spline' 'pchip' 'cubic'
%                               
%   'ParallelCoverage'           String specifying the range covered by
%                                projection data.
%                                See PARA2FAN for details.
%
%                                'cycle', {'halfcycle'}
%
%   'ParallelRotationIncrement'  Positive real scalar specifying the
%                                parallel beam rotation angle increment,
%                                measured in degrees. Parallel beam angles
%                                are calculated to cover [0,180) degrees
%                                with increment PAR_ROT_INC, where
%                                PAR_ROT_INC is the value of
%                                'ParallelRotationIncrement'.
%
%                                180/PAR_ROT_INC must be an integer.
%
%                                If 'ParallelRotationIncrement' is not
%                                specified, the increment is assumed to be
%                                the same as the increment of the fan-beam
%                                rotation angles.
%
%   'ParallelSensorSpacing'      Positive real scalar specifying the
%                                spacing of the parallel-beam sensors in
%                                pixels. The range of sensor locations is
%                                implied by the range of fan angles and is
%                                given by
%                               
%                                [D*SIN(MIN(FAN_ANGLES)),D*SIN(MAX(FAN_ANGLES))]
%                               
%                                If 'ParallelSensorSpacing' is not specified,
%                                the spacing is assumed to be uniform and
%                                is set to the minimum spacing implied by the
%                                fan angles and sampled over the range implied
%                                by the fan angles.
%                               
%   [P,PARALLEL_LOCATIONS,PARALLEL_ROTATION_ANGLES] = FAN2PARA(...) returns
%   the parallel-beam sensor locations in PARALLEL_LOCATIONS and rotation
%   angles in PARALLEL_ROTATION_ANGLES.
%
%   Example
%   -------
%       % Create synthetic parallel-beam data, derive fan-beam data and 
%       % then use the fan-beam data to recover the parallel-beam data.
%       ph = phantom(128);
%       theta = 0:179;
%       [Psynthetic,xp] = radon(ph,theta);
%       imshow(theta,xp,Psynthetic,[],'n'), axis normal
%       title('Synthetic Parallel-Beam Data')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(hot), colorbar
%       Fsynthetic = para2fan(Psynthetic,100,'FanSensorSpacing',1);
%
%       % Recover original parallel-beam data
%       [Precovered,Ploc,Pangles] = fan2para(Fsynthetic,100,...
%                                            'FanSensorSpacing',1,...
%                                            'ParallelSensorSpacing',1);
%       figure, imshow(Pangles,Ploc,Precovered,[],'n'), axis normal
%       title('Recovered Parallel-Beam Data')
%       xlabel('Rotation Angles (degrees)')
%       ylabel('Parallel Sensor Locations (pixels)')
%       colormap(hot), colorbar
%    
%   Class Support
%   -------------
%   All numeric inputs and outputs are of class double.
%
%   See also FANBEAM, IFANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   $Revision: 1.1.6.4 $  $Date: 2003/12/13 02:43:06 $
%   Copyright 1993-2003 The MathWorks, Inc.


% variable definitions
%            cycle    -   indicates output data will be averaged from 360 input
%            minimal  -   indicates the input is the minimal angular range to
%                         specify the object

args = parse_inputs(varargin{:});

[F,beta,theta,ploc,ptheta] = setup_vectors(args);

if strmatch(args.ParallelCoverage,'cycle') 
    cycle = 'cycle';
else
    cycle = []; %'none'; Is there a meaningful difference between
                %cycle=[] and cycle='none', was getting set to 'none' by
                %default and [] for minimal='minimal'.
end

[P,oploc,optheta] = fan2para_int(F,args.d,...
                                 beta,theta,ploc,ptheta,cycle,...
                                 args.Interpolation);


%-------------------------------------
function [F,beta,theta,ploc,ptheta] = ...
    setup_vectors(args)
%  Calculate vectors to call fan2para_int
%
%  Outputs:  F        -   fan-beam data (sinogram)
%            beta     -   fan sensor angles
%            theta    -   rotation angles at which the fan-beams were taken
%            ploc     -   locations of output parallel-beam samples in
%                         each projection
%            ptheta   -   angles of output parallel-beam projections

F = args.F;
d = args.d;
dbeta   = args.FanSensorSpacing;
dptheta = args.ParallelRotationIncrement;
dploc   = args.ParallelSensorSpacing;
dtheta  = args.FanRotationIncrement;

% in case we need these quantities to figure angle ranges
[m,n] = size(F);
m2cn = floor((m-1)/2);
m2cp = floor((m)/2);
r = 180/pi;

if strcmp(args.FanSensorGeometry,'line')
    beta = asin((-m2cn:m2cp)*dbeta/d)*180/pi;
else
    beta = (-m2cn:m2cp)*dbeta;
end

if strcmp(args.ParallelCoverage,'cycle')
    theta = 'cycle';

else    
    if strcmp(args.FanCoverage,'minimal')

        if mod(m,2) == 0
            ibegin = 3;
        else
            ibegin = 2;
        end
        betamin = min(beta(ibegin:end)) + n*180*eps;
        betamax = max(beta(1:end-1)) - n*180*eps;
        
        theta = [fliplr(0:-dtheta:-betamax) (dtheta:dtheta:180-betamin)];
        theta = [min(theta)-dtheta theta max(theta)+dtheta];
        if length(theta) ~= n
            eid = sprintf('Images:%s:badThetaLength',mfilename);
            msg = ['Internal Problem: FanRotationAngles ',...
                   'has the wrong length.'];       
            error(eid,msg);
        end

        F = F(2:end-1,:);
        beta = beta(2:end-1);

    else
        if abs(rem(180/dptheta,1)) > 2*sqrt(eps)
            eid = sprintf('Images:%s:badParallelRotationIncrement',mfilename);
            msg = 'ParallelRotationIncrement must be a factor of 180.';
            error(eid,msg);
        end

        theta = (0:n-1)*dptheta;     % n angles are spaced dptheta apart
        if max(theta) >= 360
            eid = sprintf('Images:%s:bigParallelRotationIncrement',mfilename);
            msg = 'ParallelRotationIncrement too large.';
            error(eid,msg);
        end
    end

end

% divide total range by dploc

ploc=[fliplr(0:-dploc:d*sin(min(beta)/r)) (dploc:dploc:d*sin(max(beta)/r))];

ptheta = 0:dptheta:180+sqrt(eps);
ptheta = ptheta(1:end-1);


%-------------------------------------
function args = parse_inputs(varargin)

checknargin(2,18,nargin,mfilename);

F = varargin{1};
d = varargin{2};

checkinput(F, {'double'}, ...
           {'real', '2d', 'nonsparse'}, ...
           mfilename, 'F', 1);

checkinput(d, {'double'},...
           {'real', '2d', 'nonsparse', 'positive'}, ...
           mfilename, 'D', 2);

% Default values
args.FanSensorSpacing          = [];
args.ParallelRotationIncrement = [];
args.ParallelSensorSpacing     = [];
args.ParallelCoverage          = 'cycle';
args.FanSensorGeometry         = 'arc';
args.Interpolation             = 'linear';
args.FanCoverage               = 'cycle';
args.FanRotationIncrement      = [];

valid_params = {'FanSensorSpacing',...          
                'ParallelRotationIncrement',...                
                'ParallelSensorSpacing',...
                'ParallelCoverage',...
                'FanSensorGeometry',...
                'Interpolation',...
                'FanCoverage',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

if strcmp(args.FanCoverage,'minimal')
    args.ParallelCoverage = 'halfcycle';
    
    if isempty(args.FanRotationIncrement)
        eid = sprintf('Images:%s:mustSpecifyDtheta',mfilename);
        error(eid,'%s%s','Must specify ''FanRotationIncrement'' when ',...
              '''FanCoverage'' is ''minimal''.');
    end
end

% quantities to figure ploc ranges
[m,n] = size(F);

% make projections odd m-dimension for symmetry
if mod(m,2) == 0
   m = m + 1;
   F = [zeros(1,n) ; F];
end
% pad to make sure we have a good boundary
m = m + 2;
F = [zeros(1,n) ; F ; zeros(1,n)];

if isempty(args.ParallelRotationIncrement)
   % default spacing same as THETA
   if strcmp(args.FanCoverage,'minimal')
	  args.ParallelRotationIncrement = args.FanRotationIncrement;
   else
      args.ParallelRotationIncrement = 360/n;
   end
end

if isempty(args.FanSensorSpacing)
    args.FanSensorSpacing = args.ParallelRotationIncrement;
end

if strcmp(args.FanSensorGeometry,'line')
    max_fan_angle = 180/pi*asin(args.FanSensorSpacing*(m-1)/2/d);    
else % args.FanSensorGeometry=='arc'
    max_fan_angle = args.FanSensorSpacing*(m-1)/2;   
end
if (max_fan_angle > 80)
    eid = sprintf('Images:%s:maxAngleTooBig',mfilename);
    msg = 'Maximum fan-beam angle greater than 80 degrees.';
    error(eid,'%s',msg);
end

if isempty(args.ParallelSensorSpacing)
    % smallest spacing implied by FanSensorSpacing 
    if strcmp(args.FanSensorGeometry,'line')
        args.ParallelSensorSpacing = args.FanSensorSpacing;
    else
        args.ParallelSensorSpacing = ...
            d*(sin(args.FanSensorSpacing*(m-1)/2*pi/180) - ...
               sin(args.FanSensorSpacing*(m-3)/2*pi/180));
    end
end

args.F       = F;
args.d       = d;
