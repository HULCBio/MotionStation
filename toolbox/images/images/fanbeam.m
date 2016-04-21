function [F,obeta,otheta] = fanbeam(varargin)
%FANBEAM Compute fan-beam transform.
%   F = FANBEAM(I,D) computes the fan-beam data (sinogram) F from the
%   image I. D is the distance in pixels from the fan-beam vertex to the
%   center of rotation. Each column of F contains the fan-beam sensor
%   samples at one rotation angle. The sensors are assumed to have a
%   one-degree angular spacing. The rotation angles are spaced equally to
%   cover [0:359] degrees.
%
%   F = FANBEAM(...,PARAM1,VAL1,PARAM2,VAL2,...)  specifies parameters that
%   control various aspects of the fanbeam projection. Parameter names can
%   be abbreviated, and case does not matter. Default values are in braces
%   like this: {default}.
%
%   Parameters include:
%
%   'FanRotationIncrement'  Positive real scalar specifying the increment 
%                           of the rotation angle of the fan-beam
%                           projections. Measure in degrees.
%                           {1}
%
%   'FanSensorGeometry'     String specyfying how sensors are positioned.
%                           {'arc'} -  Sensors are spaced equally along
%                                      a circular arc a distance D from the
%                                      center of rotation.
%                           'line' -   Sensors are spaced equally along
%                                      a line, the closest point of which is
%                                      a distance D from the center of
%                                      rotation.
%                           
%   'FanSensorSpacing'      Positive real scalar specifying the spacing
%                           of the fan beams. Interpretation of the value
%                           depends on the setting of
%                           'FanSensorGeometry'.
%                             
%                           If 'FanSensorGeometry' is 'arc', the value
%                           defines the angular spacing in
%                           degrees. Default value is 1.
%
%                           If 'FanSensorGeometry is 'line', the value
%                           defines the linear spacing in pixels.
% 
%   [F,SENSOR_POSITIONS,FAN_ROTATION_ANGLES] = FANBEAM(...)  If
%   'FanSensorGeometry' is 'arc', SENSOR_POSITIONS contains the fan-beam
%   sensor measurement angles. If 'FanSensorGeometry' is 'line',
%   SENSOR_POSITIONS contains the fan-beam sensor positions along the line
%   of sensors. FAN_ROTATION_ANGLES contains rotation angles.
%
%   Class Support
%   -------------
%   I can be of class double, logical, uint8, or uint16.  All other numeric
%   inputs and outputs are of class double. None of the inputs can be
%   sparse.
%
%   Example
%   -------
%        ph = phantom(128);
%        imview(ph)
%        [F,Floc,Fangles] = fanbeam(ph,250);
%        imshow(Fangles,Floc,F,[],'n'), axis normal
%        xlabel('Rotation Angles (degrees)')
%        ylabel('Sensor Positions (degrees)')
%        colormap(hot), colorbar
%
%   See also FAN2PARA, IFANBEAM, IRADON, PARA2FAN, PHANTOM, RADON.

%   $Revision: 1.1.6.3 $  $Date: 2003/12/13 02:43:07 $
%   Copyright 1993-2003 The MathWorks, Inc.

checknargin(2,8,nargin,mfilename);

I = varargin{1};
d = varargin{2};

checkinput(I, {'double','logical','uint8','uint16'}, ...
           {'real', '2d', 'nonsparse'}, ...
           mfilename, 'I', 1);

checkinput(d, {'double'},...
           {'real', '2d', 'nonsparse', 'positive'}, ...
           mfilename, 'D', 2);

% Default values
args.FanSensorGeometry     = 'arc';
args.FanSensorSpacing      = [];
args.FanRotationIncrement  = 1;

valid_params = {'FanSensorGeometry',...
                'FanSensorSpacing',...
                'FanRotationIncrement'};

num_pre_param_args = 2;
args = check_fan_params(varargin(3:nargin),args,valid_params,...
                        mfilename,num_pre_param_args);

P = radon(I,[0:0.5:179.5]);

[F,obeta,otheta] = para2fan(P,d,...
                            'FanSensorSpacing',args.FanSensorSpacing,... 
                            'FanRotationIncrement',args.FanRotationIncrement,...
                            'FanSensorGeometry',args.FanSensorGeometry,...
                            'Interpolation','cubic'); 