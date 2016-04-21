function str = opengl(mode)
%OPENGL Change automatic selection mode of OpenGL rendering.
%   The auto selection mode of OpenGL is only relevant when the
%   RendererMode of the FIGURE is AUTO.
%   OPENGL AUTOSELECT allows OpenGL to be auto selected if OpenGL
%   is available and if there is graphics hardware on the host machine.
%   OPENGL NEVERSELECT disables auto selection of OpenGL.
%   OPENGL ADVISE prints a string to the command window if OpenGL
%   rendering is advised and does not select OpenGL.
%   OPENGL, by itself, returns the current auto selection state.
%   OPENGL INFO prints information with the Version and Vendor
%   of the OpenGL on your system.  The return argument can be used
%   to programmatically determine if OpenGL is available on your
%   system.
%   OPENGL DATA returns a structure containing the same data
%   printed when OPENGL INFO is called.
%
%   Note that the auto selection state only specifies that OpenGL
%   should or not be considered for rendering, it does not
%   explicitly set the rendering to OpenGL.  This can be done by
%   setting the Renderer property of FIGURE to OpenGL,
%   e.g. set(GCF, 'Renderer','OpenGL');    

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.3 $  $Date: 2004/04/16 22:07:00 $

if (nargin == 0)
  current_setting = feature('openglmode');
  switch(current_setting),
    case 0,
      str = 'NeverSelect';
    case 1,
      str = 'Advise';
    case 2
      str = 'AutoSelect';
  end
else
  switch(lower(mode)),
   case 'neverselect',
    feature('openglmode', 0);
   case 'advise',
    feature('openglmode', 1);
   case 'autoselect',
    feature('openglmode', 2);
   case 'info',
    try
      if(nargout==0),
        feature('getopenglinfo');
      else
        str = feature('getopenglinfo');
      end
    catch
      if(nargout==0)
        disp('An error occured while querying for Opengl:')
        disp(lasterr);
      else
        str = 0;
      end
    end
   case 'data'
    try
      str = feature('getopengldata');
    catch
      disp('An error occured while querying for OpenGL:')
      disp(lasterr);
    end
   otherwise,
    error('OpenGL auto mode settings are info, autoselect, advise, and neverselect');
  end
end
