## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{obj} =} rigidbody ()
## @deftypefnx {Function File} {@var{obj} =} rigidbody (@var{param},@var{value})
## Create object @var{obj} of the rigid_body class.
##
## If no input arguments are provided the object is filled with default values.
## Valid values for @var{param} are:
## 
## @strong{Mass}: Scalar. Sets the total mass of the body.
##
## @strong{CoM}: 1x2 matrix. Sets the position of the center of mass of the body.
##
## @strong{Angle}: Scalar. Sets the angle of the rigid body, respect to the
## positive x-axis.
##
## @strong{Shape}: A cell with the polynomial descriptions of the edges of the
## shape or a Nx2 matrix of vertices. If no shape is provided the body is assumed
## to be a point mass. The moment of inertia respect to an axis perpendicular to the
## plane passing through the center of mass of the body is calculated based on
## this shape.
##
## @strong{CoMOffset}: 1x2 matrix. Set the displacement of the baricenter of the 
## shape respect to the center of mass. Use with care! Check demos.
##
## @end deftypefn

function rigidbody = rigidbody(varargin)

  rigidbody = struct;

  ## DYNAMIC INFO ##
  
  ## CoM: Position of the center of mass of the body.
  rigidbody.CoM = [0 0];

  ## PricipalAxes: Coordinates of the principal axes of the shape.
  rigidbody.PrincipalAxes = [];

  ## Angle: Respect to 1st axis of frame of reference. Angle of rotation of the
  ## principal axes of body.
  rigidbody.Angle = 0;

  ## Velocity: Respect to frame of reference.
  rigidbody.Velocity = [0 0];

  ## Angular speed: Rate of change of Angle
  rigidbody.AngSpeed = 0;

  ## PARAMETRIC INFO ##

  ## Mass: Mass of the body.
  rigidbody.Mass = 1;

  ## Moment of inertia
  rigidbody.InertiaMoment = Inf;

  ## Shape: Shape of the body.
  ## Data: Geometric description of the shape.
  ## Principal Axes: Shape's principal axes.
  rigidbody.Shape = struct('Data',[],'Offset',[0 0],'PrincipalAxes',[],...
                           'AreaMoments',[]);

  if !isempty (varargin)
    ## Parse param, value pairs
    valid_params = {'Shape','Mass','CoM','CoMOffset','Angle'};
    varnames = cell(size(varargin));
    varnames(:) = ' ';
    varnames(1:2:end) = varargin(1:2:end);
    [pargiven idx] = ismember (valid_params, varnames);
    
    ## Shape given
    if pargiven(1)
      if iscell (varargin{idx(1)+1})
        shapedata = varargin{idx(1)+1};
      elseif !iscell(varargin{idx(1)+1})
        shapedata = polygon2shape(varargin{idx(1)+1});
      else 
        error('rigidBody:IvalidArgument','Unrecognized shape data.');
      end

      ## Fill Shape struct
      ## Shape is always describd with axis with lower moment in positive
      ## x-axis direction and centered in [0 0].
      baricenter = masscenter(shapedata);

      shapedata = shapetransform(shapedata, -baricenter(:));

      [PA l] = principalaxes(shapedata);
      ## Put 1st axis positive in x
      if PA(1,1) < 0 ;
        PA = -PA;
      end
      rigidbody.Shape.PrincipalAxes = PA;
      rigidbody.Shape.AreaMoments = l;

      rigidbody.Shape.Data = shapetransform(shapedata, PA);

      rigidbody.InertiaMoment = inertiamoment (shapedata, rigidbody.Mass);
    end
    
    ## Mass given
    if pargiven(2)
    
      if isscalar (varargin{idx(2)+1}) 

        rigidbody.Mass = varargin{idx(2)+1};
        # has shape?
        if !isempty (rigidbody.Shape.Data)
          rigidbody.InertiaMoment = rigidbody.Mass*rigidbody.InertiaMoment;
          rigidbody.PrincipalAxes = rigidbody.Shape.PrincipalAxes;
        else # is a point mass
          rigidbody.InertiaMoment = Inf;
        end

      elseif strcmp (class (varargin{idx(2)+1}), 'function_hanlde')

        ## TODO
        error('rigidBody:Devel','Mass function, not yet implemented.');

      else
        error('rigidBody:IvalidArgument','Unrecognized mass data.');
      end
      
    end
    
    ## CoM given position of the CoM respect to frame of reference
    if pargiven(3)

      com =  varargin{idx(3)+1};
      dim = size(com);
      if all(dim == [1 2])
        rigidbody.CoM = com;
      else
        error('rigidBody:IvalidArgument','Position of the body must ba 1x2 matrix.');
      end
    end
    
    ## CoMOffset is minus the position of the shape respect to the cente rof mass
    if pargiven(4)

      offset =  varargin{idx(4)+1};
      dim = size(offset);
      if all(dim == [1 2])
        rigidbody.Shape.Offset = - offset;
        rigidbody.InertiaMoment += rigidbody.Mass*sumsq(offset);
      else
        error('rigidBody:IvalidArgument','Offset of CoM must ba 1x2 matrix.');
      end
    end

    ## Angle in [0, 2*pi] in radians respect to the x-axis of the frame of reference.
    if pargiven(5)
    
      if isscalar(varargin{idx(5)+1})
        rigidbody.Angle = mod(varargin{idx(5)+1}, 2*pi);
      else
        error('rigidBody:IvalidArgument','angle must be a scalar.');
      end
    end

  end

  # TODO Check integrity
  # CoM inside shape

  rigidbody = class (rigidbody, 'rigidbody');

endfunction

%!demo
%! % Create an empty rigidbody
%!  ebody = rigidbody();
%!  ebody
%!
%! % Create a mass point with mass ==2 at [0,0]
%!  mp = rigidbody('Mass', 2);
%!  mp
%! 
%! % Create a mass point with mass == 1.5 at [1,1]
%!  mp2 = rigidbody('Mass', 1.5,'CoM',[5,5]);
%!  mp2
%! 
%! % Create a body with a shape
%!  t = linspace(0,2*pi,64).';
%!  shape = [cos(t)-0.3*cos(3*t) sin(t)](1:end-1,:);
%!  body = rigidbody('Mass', 1.5,'CoM',[-5,-5],'Shape',shape);
%!  body
%! 
%! % Create a body with a shape and an offset
%!  shape = [cos(t)-0.3*cos(3*t) sin(t)](1:end-1,:);
%!  body2 = rigidbody('Mass', 1,'CoM',[-5,-5],'Shape',shape,'CoMOffset',[0 0.1]);
%!  body2
%! 
%! % ---------------------------------------------------------------------------
%! %   Shows how to create rigid bodies. The case with Offset has to be treated
%! % carefully. It models a new rigid body with half the mass together with a
%! % point mass with the other half of the mass, such that the CoM moves away
%! % from the baricenter of the shape the given amount. The total mass is
%! % conserved.

%!demo
%! % Create bodies
%!  mp = rigidbody('Mass', 2);
%!  mp.plot();
%!
%!  t = linspace(0,2*pi,64).';
%!  shape = [cos(t)-0.3*cos(3*t) sin(t)](1:end-1,:);
%!  body = rigidbody('Mass', 1.5,'CoM',[-2,-2],'Shape',shape);
%!  body.plot(gca)
%!
%!  shape = [cos(t) sin(t)-0.3*cos(4*t)](1:end-1,:);
%!  body2 = rigidbody('Mass', 1,'CoM',[2,2],'Shape',shape,'CoMOffset',[0 0.5]);
%!  body2.plot(gca)
%!
%! % ---------------------------------------------------------------------------
%! %   Shows how to plot rigid bodies

