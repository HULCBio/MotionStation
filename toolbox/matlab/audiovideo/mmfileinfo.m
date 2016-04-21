function fileInfo = mmfileinfo(filename)
%MMFILEINFO Information about a multimedia file.
%
%   INFO = MMFILEINFO(FILENAME) returns a structure whose fields contain
%   information about FILENAME's audio and/or video data.  FILENAME
%   is a string that specifies the name of the multimedia file.  
%
%   The set of fields for the INFO structure are:
%
%      Filename - A string, indicating the name of the file.
%
%      Duration - The length of the file in seconds.
%
%      Audio    - A structure whose fields contain information about the
%                 audio component of the file.
%      
%      Video    - A structure whose fields contain information about the
%                 video component of the file.
%
%   The set of fields for the Audio structure are:
%
%      Format           - A string, indicating the audio format.
%      
%      NumberOfChannels - The number of audio channels.
%      
%   The set of fields for the Video structure are:
%    
%      Format          - A string, indicating the video format.
%           
%      Height          - The height of the video frame.
%           
%      Width           - The width of the video frame.
%
%   See also AUDIOVIDEO.

% JCS
% Copyright 1984-2004 The MathWorks, Inc.
% $ Date: $ $Revision: 1.1.8.3 $

% Check number of input arguments.
error(nargchk(1, 1, nargin, 'struct'));

% Currently, this is Windows-only functionality.
if ~ispc
    error('This function is currently only for use on Windows machines.')    
end

% Call the MEX-function which gets all of the information about the file.
try
    fileInfo = winmmfileinfo(filename);
catch
    rethrow(lasterror);
end