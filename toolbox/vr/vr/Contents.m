% Virtual Reality Toolbox
% Version 4.0 (R14) 05-May-2004
%
% MATLAB interface functions
%   vrinstall - Check or install the toolbox components.
%   vrwho     - List virtual worlds in memory.
%   vrwhos    - List virtual worlds in memory, long form.
%   vrclear   - Purge closed virtual worlds from memory.
%   vrview    - View virtual worlds.
%   vrclose   - Close Virtual Reality figures.
%   vrgetpref - Get Virtual Reality Toolbox preferences.
%   vrsetpref - Set Virtual Reality Toolbox preferences.
%   vrdrawnow - Flush pending VR events.
%   vrdemos   - Run Virtual Reality Toolbox examples.
%
% VRWORLD object methods
%   vrworld   - Create a VRWORLD object.
%   isvalid   - True for a valid VRWORLD object.
%   isopen    - True for an open VRWORLD object.
%   open      - Open a virtual world.
%   close     - Close a virtual world.
%   reload    - Reload a world from its associated file.
%   delete    - Delete a closed virtual world from memory.
%   get       - Get a property of a virtual world.
%   set       - Change a property of a virtual world.
%   nodes     - List named nodes contained in the world.
%   view      - View a world in a browser.
%   edit      - Edit the world in the VRML editor.
%   save      - Save the world to a VRML file.
%
% VRNODE object methods
%   vrnode    - Create a VRNODE object and/or a new node.
%   delete    - Delete a node.
%   isvalid   - True for a valid VRNODE object.
%   fields    - List VRML fields belonging to this node.
%   set       - Change a property or a VRML field of the node.
%   get       - Get a property or a VRML field of the node.
%   setfield  - Change a field value of VRNODE.
%   getfield  - Get a field value of VRNODE.
%   sync      - Synchronize a VRML field with clients.
%
% VRFIGURE object methods
%   vrfigure  - Create a new Virtual Reality figure.
%   isvalid   - True for a valid VRFIGURE object.
%   close     - Close a Virtual Reality figure.
%   get       - Get a Virtual Reality figure property.
%   set       - Set a Virtual Reality figure property.
%   vrgcf     - Get the current VRFIGURE object.
%   vrgcbf    - Get the current callback VRFIGURE object.
%   capture   - Capture a figure into a RGB image.
%
% Simulink blocks
%   vrlib     - Open the Virtual Reality Toolbox Simulink block Library.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   Generated from Contents.m_template revision 1.15.4.4 $Date: 2003/10/30 18:45:38 $ $Author: batserve $
