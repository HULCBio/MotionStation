function sys=simsizes(sizesStruct)
%SIMSIZES utility used to set S-function sizes
%   SIMSIZES is a helper function used in M-file S-functions to
%   provide specific information about the S-function. This
%   information includes the number of inputs, outputs, states, 
%   and other block characteristics.
%   
%   To give Simulink this information, call the SIMSIZES function 
%   at the beginning of mdlInitializeSizes with no arguments.
%   For example:
%        sizes = simsizes;
%   This returns an uninitialized structure of the form:
%        sizes.NumContStates   Number of continuous states
%        sizes.NumDiscStates   Number of discrete states
%        sizes.NumOutputs      Number of outputs
%        sizes.NumInputs       Number of inputs
%        sizes.DirFeedthrough  Flag for direct feedthrough
%        sizes.NumSampleTimes  Number of sample times
%
%   After initializing the structure above to fit the
%   specifications of the S-function, SIMSIZES should be called
%   again to convert the structure into a vector that can be 
%   processed by Simulink. For example:
%        sys = simsizes(sizes);
%
%   See also SFUNTMPL.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

switch nargin,

  case 0,  % return a sizes structure
    sys.NumContStates  = 0;
    sys.NumDiscStates  = 0;
    sys.NumOutputs     = 0;
    sys.NumInputs      = 0;
    sys.DirFeedthrough = 0;
    sys.NumSampleTimes = 0;

  case 1,  % convert a sizes structure into an array, or the other way around
    
    %
    % if the input is an array, return a sizes structure
    %
    if ~isstruct(sizesStruct),
      sys = sizesStruct;

      %
      % the array length must be at least 6
      %
      if length(sys) < 6,
        error('Length of sizes array must be at least 6');
      end

      clear sizesStruct;
      sizesStruct.NumContStates  = sys(1);
      sizesStruct.NumDiscStates  = sys(2);
      sizesStruct.NumOutputs     = sys(3);
      sizesStruct.NumInputs      = sys(4);
      sizesStruct.DirFeedthrough = sys(6);
      if length(sys) > 6,
        sizesStruct.NumSampleTimes = sys(7);
      else
        sizesStruct.NumSampleTimes = 0;
      end

    else,
      %
      % validate the sizes structure
      %
      sizesFields=fieldnames(sizesStruct);
      for i=1:length(sizesFields),
        switch (sizesFields{i})
          case { 'NumContStates', 'NumDiscStates', 'NumOutputs',...
                 'NumInputs', 'DirFeedthrough', 'NumSampleTimes' },

          otherwise,
            error(['Invalid field name ''', sizesFields{i}, '''']);
        end
      end

      sys = [...
        sizesStruct.NumContStates,...
        sizesStruct.NumDiscStates,...
        sizesStruct.NumOutputs,...
        sizesStruct.NumInputs,...
        0,...
        sizesStruct.DirFeedthrough,...
        sizesStruct.NumSampleTimes ...
      ];
    end

end

% end simsizes
