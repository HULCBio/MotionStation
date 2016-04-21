function sys = lti(Ny,Nu,Ts)
%LTI  Constructor for the LTI parent object.
%
%   SYS = LTI(NY,NU) creates a LTI object with NY outputs and
%   NU inputs.
%
%   SYS = LTI(NY,NU,TS) creates a LTI object with NY outputs,
%   NU inputs, and sample time TS. 
%
%   Note: This function is not intended for users.
%         Use TF, SS, or ZPK to specify LTI models.

%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.17.4.1 $  $Date: 2003/01/07 19:32:09 $

% Define default property values.
% RE: system is continuous by default, and I/O names are cell vectors of
%     empty strings
ni = nargin;
if ni==0,
   % Create empty LTI
   Ny = 0;  Nu = 0;  Ts = 0;
elseif isa(Ny,'lti')
   % Conversion to LTI for LTI object
   sys = Ny;
   return
elseif ni<3,
   Ts = 0;
end

% Create the structure
sys = struct(...
   'Ts',Ts,...
   'ioDelay',zeros(Ny,Nu),...
   'InputDelay',zeros(Nu,1),...
   'OutputDelay',zeros(Ny,1),...
   'InputName',{repmat({''},[Nu,1])},...
   'OutputName',{repmat({''},[Ny,1])},...
   'InputGroup',struct,...
   'OutputGroup',struct,...
   'Notes',{{}},...
   'UserData',[],...
   'Version',[]);

% Label SYS as an object of class LTI
sys = class(sys,'lti');

% Set version
sys.Version = getVersion(sys);


