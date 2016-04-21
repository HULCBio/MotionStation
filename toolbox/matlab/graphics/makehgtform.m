function m=makehgtform(varargin)
%MAKEHGTFORM Make a 4x4 transform matrix.
%   M = MAKEHGTFORM  Creates an identity transform.
%
%   M = MAKEHGTFORM('translate',tx,ty,tz)  Translate along X 
%   axis by tx, along Y axis by ty, and along Z axis by tz.
%
%   M = MAKEHGTFORM('scale',s)  Scale uniformly by s.
%
%   M = MAKEHGTFORM('scale',[sx sy sz])  Scale along X axis by 
%   sx, along Y axis by sy, and along Z axis by sz.
%
%   M = MAKEHGTFORM('xrotate',t)  Rotate around X axis by t radians.
%
%   M = MAKEHGTFORM('yrotate',t)  Rotate around Y axis by t radians.
%
%   M = MAKEHGTFORM('zrotate',t)  Rotate around Z axis by t radians.
%
%   M = MAKEHGTFORM('axisrotate',[ax ay az],t)  Rotate around axis 
%   [ax ay az] by t radians.
%
%   Multiple transforms can be concatenated.
%
%   Example:
%
%   m = makehgtform('xrotate',pi/2,'yrotate',pi/2);
%
%   is the same as:
%
%   m = makehgtform('xrotate',pi/2)*makehgtform('yrotate',pi/2);
%
%   See also HGTRANSFORM.

% Copyright 1984-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/04/24 21:26:26 $

    m = eye(4);
    ai = 1;
    numArgs = length(varargin);
    while ai <= numArgs
        name = varargin{ai};
        ai = ai+1;

        if strcmpi(name,'translate')
            error(nargchk(ai,inf,numArgs,'struct'));
            
            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to translate must be numeric');
            end
            x = double(varargin{ai});
            ai = ai+1;

            if isscalar(x)
                error(nargchk(ai+1,inf,numArgs,'struct'));
            
                if ~isnumeric(varargin{ai})
                    error('MATLAB:makehgtform:InvalidParam','Arguments to translate must be numeric');
                end
                y = varargin{ai};
                ai = ai+1;

                if ~isnumeric(varargin{ai})
                    error('MATLAB:makehgtform:InvalidParam','Arguments to translate must be numeric');
                end        
                z = varargin{ai};
                ai = ai+1;    
                if (~isscalar(y) || ~isscalar(z))
                  %todo
                end
                
            elseif (~isvector(x) || length(x) ~= 3)
                error('MATLAB:makehgtform:InvalidParam',['Arguments to translate must be 3D']);
            else
                y = x(2);
                z = x(3);
                x = x(1);
            end

            if (~isfinite(x) || ~isfinite(y) || ~isfinite(z))
                error('MATLAB:makehgtform:InvalidParam',['Arguments to translate must be finite']);
            end
            
            m = m * [1 0 0 x; ...
                     0 1 0 y; ...
                     0 0 1 z; ...
                     0 0 0 1];
        
        elseif strcmpi(name,'scale')
            error(nargchk(ai,inf,numArgs,'struct'));

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to scale must be numeric');
            end            
            s = double(varargin{ai});
            ai = ai+1;
            
            if isscalar(s)
                s = [s s s];
            elseif (~isvector(s) || length(s) ~= 3)
                error('MATLAB:makehgtform:InvalidParam',['Scale factors must be either 1D or 3D']);                
            end
            
            if (~isfinite(s(1)) || ~isfinite(s(2)) || ~isfinite(s(3)))
                error('MATLAB:makehgtform:InvalidParam',['Scale factors must be finite']);
            end
            
            if (s(1) <= 0 || s(2) <= 0 || s(3) <= 0)
                error('MATLAB:makehgtform:InvalidParam',['Scale factors must be positive']);
            end
            
            m = m * [s(1) 0    0    0; ...
                     0    s(2) 0    0; ...
                     0    0    s(3) 0; ...
                     0    0    0    1];
        
        elseif strcmpi(name,'xrotate')
            error(nargchk(ai,inf,numArgs,'struct'));

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to xrotate must be numeric');
            end
            t = double(varargin{ai});
            ai = ai+1;
            
            if (~isscalar(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be scalar']);
            end

            if (~isfinite(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be finite']);
            end
            
            ct = cos(t);
            st = sin(t);
            m = m * [1  0   0 0; ...
                     0 ct -st 0; ...
                     0 st  ct 0; ...
                     0  0   0 1];

        elseif strcmpi(name,'yrotate')
            error(nargchk(ai,inf,numArgs,'struct'));

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to yrotate must be numeric');
            end
            t = double(varargin{ai});
            ai = ai+1;
            
            if (~isscalar(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be scalar']);
            end

            if (~isfinite(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be finite']);
            end
            
            ct = cos(t);
            st = sin(t);
            m = m * [ct 0 st 0; ...
                      0 1  0 0; ...
                    -st 0 ct 0; ...
                      0 0  0 1];

        elseif strcmpi(name,'zrotate')
            error(nargchk(ai,inf,numArgs,'struct'));

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to zrotate must be numeric');
            end
            t = double(varargin{ai});
            ai = ai+1;
            
            if (~isscalar(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be scalar']);
            end

            if (~isfinite(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be finite']);
            end
            
            ct = cos(t);
            st = sin(t);
            m = m * [ct -st 0 0; ...
                     st  ct 0 0; ...
                      0   0 1 0; ...
                      0   0 0 1];

        elseif strcmpi(name,'axisrotate')
            error(nargchk(ai+1,inf,numArgs,'struct'));

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to axisrotate must be numeric');
            end
            u = double(varargin{ai});
            ai = ai+1;

            if ~isnumeric(varargin{ai})
                error('MATLAB:makehgtform:InvalidParam','Arguments to axisrotate must be numeric');
            end
            t = double(varargin{ai});
            ai = ai+1;

            if ( ~isvector(u) || length(u) ~= 3)
              error('MATLAB:makehgtform:BadAxis','axis of rotation must be 3D');
            end
            
            if (~isfinite(u(1)) || ~isfinite(u(2)) || ~isfinite(u(3)))
              error('MATLAB:makehgtform:BadAxis','axis of rotation must be finite');
            end
            
            if (~isscalar(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be scalar']);
            end

            if (~isfinite(t))
                error('MATLAB:makehgtform:InvalidParam',['Rotation angle must be finite']);
            end
            
            u = u./norm(u);
            c = cos(t);
            s = sin(t);

            tmp = eye(4);     
            tmp(1:3,1:3) = c*eye(3) + (1-c)*kron(u,u') + s*SkewSymm(u);
            m = m * tmp;
        
        else
          if ischar(name)
            error('MATLAB:makehgtform:BadTransformType',['Unknown transform type: ' name]);
          elseif isnumeric(name)
            error('MATLAB:makehgtform:InvalidArg',['Unrecognized argument: ' num2str(name)]);
          else
            error('MATLAB:makehgtform:InvalidArg',['Invalid argument']);
          end
        end
    
    end
    
function s=SkewSymm(v)
    s = [  0  -v(3)  v(2); ...
         v(3)    0  -v(1); ...
        -v(2)  v(1)    0];
