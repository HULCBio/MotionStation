function varargout = rltool(varargin);
%RLTOOL  Opens the SISO Design Tool and sets it up for root locus design.
%
%   RLTOOL opens the SISO Design Tool with Root Locus view on.  Using this
%   GUI, you can interactively design a single-input/single-output (SISO) 
%   compensator using the Root Locus technique.  To import the plant model 
%   into the SISO Design Tool, select the Import Model item from the File 
%   menu.  By default, the feedback configuration is
%
%             u --->O--->[ COMP ]--->[ PLANT ]----+---> y
%                 - |                             |
%                   +-----------------------------+
%
%   RLTOOL(PLANT) further specifies the plant model PLANT to be used in
%   the SISO Tool.  PLANT is any linear model created with TF, ZPK, or SS.
%
%   RLTOOL(PLANT,COMP) also specifies an initial value COMP for the 
%   compensator (also a linear model created with TF, ZPK, or SS).
%
%   RLTOOL(PLANT,COMP,LocationFlag,FeedbackSign) specifies alternative 
%   compensator location and feedback sign as follows:
%
%      LocationFlag = 'forward':  Compensator in the forward loop
%      LocationFlag = 'feedback': Compensator in the feedback loop
%       
%      FeedbackSign = -1: Negative feedback
%      FeedbackSign =  1: Positive feedback
% 
%   See also SISOTOOL.

%   Additional Comments:
%
%   For backwards compatibility, LocationFlag can also be either the number
%   zero, one, or two.
%       LocationFlag = 1: Places the compensator in the forward loop
%       LocationFlag = 2: Places the compensator in the feedback loop
%       LocationFlag = 0; Turns the feedback structure toggle feature on. 
%
%   In toggle mode, the user may switch the location of the compensator during 
%   the design session. This is not consistant with how the GUI will function 
%   when it is called from CODA.
%
%   RLTOOL(ModelData,CompData,Parent) where Model/CompData are structured 
%   arrays and Parent is the handle of a CODA interface is used to open the
%   Root Locus Design GUI from CODA

%   Karen D. Gondoly
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 06:25:29 $

ni=nargin;

% Default feedback configuration
Location = 'forward';
Sign = -1;

if ni>=3 & ~isempty(varargin{3})
   %---Convert to identifiers 'feedback' or 'forward' expected by SISO Tool
   Location = varargin{3};
   if isa(Location,'double')
      switch Location
      case {0 1}
         Location = 'forward';
      case 2
         Location = 'feedback';
      otherwise
         error('The third input must be either ''feedback'' or ''forward''.')
      end
   end
end

if ni==4 & ~isempty(varargin{4}),
   if ~any(varargin{4}==[-1 1]),
      error('The fourth input argument must be a 1 or -1, indicating the feedback sign')
   else
      Sign = varargin{4};
   end
end

% Call SISOTOOL
FeedbackConfig = struct('Location',Location,'Sign',Sign);

try
   if nargout
      [varargout{1:nargout}] = sisotool('rlocus',varargin{1:min(2,ni)},FeedbackConfig);
   else
      sisotool('rlocus',varargin{1:min(2,ni)},FeedbackConfig)
   end
catch
   rethrow(lasterror)
end

