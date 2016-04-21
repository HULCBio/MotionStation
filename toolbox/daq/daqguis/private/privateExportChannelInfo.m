function privateExportChannelInfo(varname, info)
%PRIVATEEXPORTCHANNELINFO Export channel information to base workspace.
%
%   PRIVATEEXPORTCHANNELINFO('NAME', INFO) assigns the variable NAME
%   in the MATLAB workspace the value INFO. INFO is a structure
%   containing channel information. This information includes the 
%   channel's:
%
%       1. Horizontal Scale
%       2. Horizontal Offset
%       3. Vertical Scale
%       4. Vertical Offset
%       5. Data
%       6. Acquisition time of the first sample in Data
%       7. SampleRate
%        
%   PRIVATEEXPORTCHANNELINFO is a helper function for the softscope function.
%   It is called when the "Workspace (Scaling Structure)" menu item is selected
%   from the Channel Export Window.
%
%   This function should not be used directly by users.
%
%   See also SOFTSCOPE.
%

%   MP 01-03-02
%   Copyright 1998-2003 The MathWorks, Inc. 
%   $Revision: 1.1.2.3 $  $Date: 2003/08/29 04:45:29 $

% User exported channel data as a structure.
assignin('base', varname, struct(info));
