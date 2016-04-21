function [P,oploc,optheta] = fan2para_int(varargin)
%FAN2PARA Compute parallel-beam projections from fan-beam tomography data.
%   P = FAN2PARA(F,D) computes the parallel-beam data (sinogram) from
%   the fan-beam data (sinogram) F whose columns are the fan-beam spread
%   angles and whose rows are the rotation angles.  D is the distance 
%   from the fan-beam vertex to the origin of rotation.  The fan-beam
%   spread angles are assumed to be at 1-degree increments split equally
%   on either side of zero.  The input rotation angles are assumed to be
%   stepped in equal increments to cover [0,360) degrees.  Output angles
%   are set to the valid range of the fan-beam data:
%
%   [min(rotation angle)+max(fan angle),max(rotation angle)+min(fan angle)]
%
%   with increment set to the min of the rotation increment.
%
%   P = FAN2PARA(F,D,BETA,THETA,PLOC,PTHETA) specifies parameters to use
%   in the conversion.  
%
%   BETA specifies the fan-beam angles.  If BETA is a scalar, it is 
%   interpreted as an angle increment in degrees, and the rows of F are
%   assumed to correspond to angles equally spaced by BETA with row 
%   ceil(size(F,2)/2) taken as the origin.  If BETA is a vector,
%   it is interpreted as the set of fan-beam angles in degrees.
%   BETA must be in the range [-80,80].  If BETA is [], then the increment
%   is assumed to be one degree.
%
%   THETA specifies the input rotation angles.  If THETA is a scalar, it
%   is interpreted as an angle increment in degrees, and the columns of F
%   are assumed to correspond to angles equally spaced by THETA beginning
%   with an angle of zero.  If THETA is a vector, it is interpreted as the
%   set of rotation angles in degrees.  THETA must be in the range
%   [min(BETA),360) degrees.  If THETA is 'cycle' or [], then the range
%   is assumed to be [0,360) degrees with the angles dividing it into 
%   size(F,2) equal increments.  'cycle' forces the algorithm to compute
%   a 180-degree parallel-beam data set using the full 360-degree fan-beam
%   data set by averaging reconstructions from two half-cycles of fan-beam
%   data.
%
%   PLOC specifies the parallel-beam sensor locations in pixels.  If PLOC
%   is a scalar, it is interpreted as an increment in pixels.  The range
%   of PLOC is implied by the range of BETA and is given by:
%
%   [D*sin(min(BETA)),D*sin(max(BETA))]
%
%   If PLOC is a vector, it is interpreted as the set of sensor locations
%   in pixels.  If PLOC is [], then the spacing is assumed to be uniform
%   and is set to the minimum spacing implied by BETA and sampled over the
%   range implied by BETA.
%
%   PTHETA specifies the parallel-beam rotation angles.  If PTHETA is a
%   scalar, it is interpreted as a uniform increment with angles covering
%   a 180-degree range with the starting value determined by the THETA and
%   BETA arguments (or defaults).  PTHETA must divide 180 degrees into 
%   uniform increments.  If PTHETA is a vector, it is interpreted as the set 
%   of angles.  In this case, the angles must be in the range [0,360).  If
%   THETA is set to 'cycle', then the PTHETA vector must be in the range 
%   [0,180) with equal increments.  If PTHETA is [], the the increment is 
%   set to the minimum fan-beam rotation 
%   angle; if THETA is set to 'cycle', then the range of PTHETA is set to 
%   [0,180).  Otherwise, the range is set by the valid range of the 
%   fan-beam data:
%
%   [min(THETA)+max(BETA),max(THETA)+min(BETA)]
%
%   [...] = FAN2PARA(...,'interp') specifies the interpolation method used
%   to interpolate between the fan-beam and parallel-beam data.  Default is
%   'linear'.
%
%   [P,OPLOC,OPTHETA] = FAN2PARA(...) returns the parallel-beam sensor 
%   locations in OPLOC and rotation angles in OPTHETA.
%
%   Class Support
%   -------------
%   I can be of class double or of any integer class. All
%   other inputs and outputs are of class double.
%
%   Remarks
%   -------
%   The radial coordinates returned in Xp are the values along
%   the x-prime axis, which is oriented at THETA degrees
%   counterclockwise from the x-axis. The origin of both axes is
%   the center pixel of the image, which is defined as:
%
%        ceil(size(I)/2)
%
%   For example, in a 20-by-30 image, the center pixel is
%   (10,15).
%
%   See also FAN2PARA, PARA2FAN, FANBEAM, IFANBEAM, IRADON, PHANTOM.

%   $Revision: 1.1.6.2 $  $Date: 2003/08/01 18:11:06 $  
%   Copyright 1993-2003 The MathWorks, Inc.

[F,d,beta,theta,ploc,ptheta,cycle,interp] = parse_inputs(varargin{:});

[m,n] = size(F);
r = 180/pi;       % radian-to-degree conversion factor

if (cycle) % use full 360-deg fan-beam set to get 180-deg p-beam
   n4 = ceil(n/4);

   % first reconstruction
   Fpad = [ F(:,end-n4+1:end) F ];   % exploit periodicity of sinogram
   thetapad = [ theta(:,end-n4+1:end)-2*pi theta ];
   [P1,oploc,optheta] = fan2para_int(Fpad,d,beta*r,thetapad*r,ploc,ptheta*r,interp);

   % second reconstruction
   Fpad = [ F F(:,1:n4) ];   % exploit periodicity of sinogram
   thetapad = [ theta theta(:,1:n4)+2*pi ];
   ptheta = [2*pi pi+ptheta(end:-1:2)];
   [P2,tploc,tptheta] = fan2para_int(Fpad,d,beta*r,thetapad*r,ploc,ptheta*r,interp);

   P = P1;
else
   % shift to correct for fan-beam angles and interp to desired p-beam angles
   Fsh = zeros(m,length(ptheta));
   for i=1:m
      Fsh(i,:) = interp1(theta+beta(i),F(i,:),ptheta,interp);
   end

   % interpolate to get desired p-beam sample locations
   P = zeros(length(ploc),length(ptheta));
   loc = d*sin(beta);
   for i=1:length(ptheta)
      P(:,i) = interp1(loc,Fsh(:,i)',ploc,interp)';
   end

   oploc = ploc;
   optheta = ptheta*180/pi;

end

% check for out-of-range interpolated values that should be zero
indnan = isnan(P);
P(indnan) = 0;

%%%
%%%  Sub-Function:  parse_inputs
%%%

function [F,d,beta,theta,ploc,ptheta,cycle,interp] = parse_inputs(varargin);
%  Parse the input arguments and return things
%
%  Inputs:   varargin -   Cell array containing all of the actual inputs
%
%  Outputs:  d        -   distance from fan vertex to center of rotation
%            beta     -   fan detector angles
%            theta    -   rotation angles at which the fan-beams were taken
%            ploc     -   locations of output parallel-beam samples in
%                         each projection
%            ptheta   -   angles of output parallel-beam projections
%            interp   -   the type of interpolation to use
%            cycle    -   value 1 indicates that 180-pbeam data will be 
%                         calculated using all angles of 360-fbeam data

nargin = prod(size(varargin));

if nargin<2
   error('Images:fan2para_int:numberOfInputs', 'Too few arguments.');
end

F = varargin{1};
d = varargin{2};

% Default values
interp = 'linear';     % default interpolation is linear
string_args = {'nearest neighbor', 'linear', 'spline', 'cycle'};

% find interp string anywhere in argument list and then delete it from list
% ignore cycle string
for i=3:nargin
   arg = varargin{i};
   if ischar(arg)
      idx = strmatch(lower(arg),string_args);
      if isempty(idx)
         error('Images:fan2para_int:unknownInput', ...
               ['Unknown input string: ' arg '.']);
      elseif prod(size(idx)) > 1
         error('Images:fan2para_int:ambiguousInput', ...
               ['Ambiguous input string: ' arg '.']);
      elseif prod(size(idx)) == 1
         if ~strcmp(lower(arg),string_args{idx})
            interp = string_args{idx};
            vidx = [1:prod(size(varargin))];
            vidx(i) = [];
            varargin = varargin(vidx);
            nargin = nargin-1;
         end
      end
   end
end

% null missing variables to make subsequent argument handling simpler
for i=nargin+1:6
   varargin{i} = [];
end

% in case we need these quantities to figure angle ranges
[m,n] = size(varargin{1});
m2cn = floor((m-1)/2);
m2cc = floor((m+1)/2);
m2cp = floor((m)/2);

arg = varargin{3};
if prod(size(arg)) > length(arg)
   error('Images:fan2para_int:illegalBeta', 'Internal problem: BETA must be a scalar or vector.');
elseif prod(size(arg)) == 1
   beta = [-m2cn:m2cp]*pi*arg/180;
elseif prod(size(arg)) > 1
   if prod(size(arg)) ~= m
      error('Images:fan2para_int:sizeOfF', 'Internal problem: Number of rows in F must match length of vector BETA.');
   end
   if any(arg(2:end)-arg(1:end-1)) <= 0
      error('Images:fan2para_int:illegalBeta', 'Internal problem: BETA values must increase monotonically.');
   end
   beta = arg(:)'*pi/180;
else
   beta = [-m2cn:m2cp]*pi/180;   % default is 1-degree angles in the fan
end
if (180/pi*max(abs(beta)) > 80)
180/pi*max(abs(beta))
180/pi*min(abs(beta))
180/pi*min(beta)
   error('Images:fan2para_int:fanbeamAngle', 'Internal problem: Maximum fan-beam angle greater than 80 degrees.');
end

cycle = 0;
arg = varargin{4};
if prod(size(arg)) > length(arg)
   error('Images:fan2para_int:illegalTheta', 'Internal problem: THETA must be a scalar, vector, or string.');
elseif prod(size(arg)) == 1
   theta = [0:n-1]*pi*arg/180;     % n angles are spaced scalar theta apart
elseif (prod(size(arg)) > 1) & ~isstr(arg) % THETA is a vector
   if prod(size(arg)) ~= n
      error('Images:fan2para_int:sizeOfF', 'Internal problem: Number of columns in F must match length of vector THETA.');
   end
   if any(arg(2:end)-arg(1:end-1)) <= 0
      error('Images:fan2para_int:illegalTheta', 'Internal problem: THETA values must increase monotonically.');
   end
   if (any(arg) < min(beta)) | (any(arg) >= 360)
      error('Images:fan2para_int:illegalTheta', 'Internal problem: THETA values must be in the range [min(BETA),360) degrees.');
   end
   theta = arg(:)'*pi/180;             % convert to radians
elseif isstr(arg)   % THETA is a string -- use complete cycle of data
   theta = [0:n-1]*360/n*pi/180;   % default is 360 degrees of rotation
   cycle = 1;
else
   theta = [0:n-1]*360/n*pi/180;   % default is 360 degrees of rotation
end
%if (max(beta)-min(beta) + pi) > (max(theta)-min(theta))
%   warning('The range of angles is insufficient to specify a full set of projections.');
%end

arg = varargin{5};
if prod(size(arg)) > length(arg)
   error('Images:fan2para_int:illegalPLOC', 'Internal problem: PLOC must be a scalar or vector.');
elseif prod(size(arg)) == 1
   % divide total range by ploc if it is a scalar
   pnum = d*(sin(max(beta)) - sin(min(beta)))/arg;
   ploc = [fliplr([0:-arg:d*sin(min(beta))]) [arg:arg:d*sin(max(beta))]];
elseif prod(size(arg)) > 1
   if any(arg(2:end)-arg(1:end-1)) <= 0
      error('Images:fan2para_int:illegalPLOC', 'Internal problem: PLOC values must increase monotonically.');
   end
   % set arg to ploc if a vector
   ploc = arg(:)';
else
   % compute minimum spacing and divide range by that spacing
   mindel = d*(min(abs(sin(beta(2:end))-sin(beta(1:end-1))))); % closest spacing
   pnum = d*(sin(max(beta)) + sin(min(beta)))/mindel;
   ploc=[fliplr([0:-mindel:d*sin(min(beta))]) [mindel:mindel:d*sin(max(beta))]];
end

arg = varargin{6};
if prod(size(arg)) > length(arg)
   error('Images:fan2para_int:illegalPtheta', 'Internal problem: PTHETA must be a scalar or vector.');
elseif prod(size(arg)) == 1
   % use scalar ptheta as size of increment for total 180 degrees of view
   if abs(rem(180/arg,1)) > 2*sqrt(eps)
      error('Images:fan2para_int:illegalPtheta', 'Internal problem: 180/PTHETA must be an integer for scalar ptheta.');
   end
   minpt = min(theta)+max(beta);
   ptheta = [minpt:pi*arg/180:minpt+pi*(1-2*sqrt(eps)*ceil(180/arg))];
elseif prod(size(arg)) > 1
   if any(arg(2:end)-arg(1:end-1)) <= 0
      error('Images:fan2para_int:illegalPtheta', 'Internal problem: PTHETA values must increase monotonically.');
   end
   if (any(arg) < 0) | (any(arg) >= 360)
      error('Images:fan2para_int:illegalPtheta', 'Internal problem: Requested PTHETA values must be in the range [0,360) degrees.');
   end
   if (cycle & any(arg) >= 180)
      error('Images:fan2para_int:illegalPtheta', 'Internal problem: Requested PTHETA values must be in the range [0,180) degrees when using CYCLE.');
   end
   if (cycle & any(abs(arg(2:end)-(180-arg(end:-1:2)))) > 2*sqrt(eps))
       eid = sprintf('Images:%s:pthetaIncrementsBad',mfilename);
       msg = ['PTHETA must increment equally over the range [0,180) ',...
              'degrees when using CYCLE.'];
       error(eid,'%s',msg)
   end
   ptheta = arg(:)'*pi/180;       % convert to radians
else
   % find smallest fan-beam rotation angles
   mindel = (min(abs(theta(2:end)-theta(1:end-1)))); 
   minpt = min(theta)+max(beta);
   maxpt = max(theta)+min(beta);
   if abs(rem(pi/mindel,1)) > 2*sqrt(eps)
      warning('Images:fan2para_int:outputAngles', 'Output angles do not cover 180 degrees uniformly.');
   end
   if cycle
      % cycle is set, so set output angles to range of [0,180)
      ptheta = [0:mindel:pi*(1-2*sqrt(eps)*ceil(pi/mindel))];
   else 
      % default is same rotation angle as minimum of fan and fan rotation
      % angles with limits determined by valid measurements of fan-beam data
      ptheta = [minpt:mindel:maxpt]; 
   end
end

% find and check theta and ptheta ranges
if ((max(ptheta) > max(theta)+min(beta)) | (min(ptheta) < min(theta)+max(beta)))
   if ~cycle
      error('Images:fan2para_int:cannotComputePtheta', 'Internal problem: Desired PTHETA range cannot be computed from given THETA range.');
   end
end

