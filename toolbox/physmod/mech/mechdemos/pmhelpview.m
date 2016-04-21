function pmhelpview(path, topic_id)
% Wrapper for Physical Modeling demo model documentation callbacks.
%
% SYNTAX:
%
%   pmhelpview(map_path, topic_id)
%
% ARGUMENTS:
%
%   map_path
%     Path of a map file (see below) that maps 
%     topic ids to the paths of topic files. The path must
%     end in the extension .map.
%
%   topic_id
%     An arbitrary string that identifies a topic. PMHELPVIEW
%     uses the map file specified by path to map topic_id to
%     the path of the HTML file that documents the topic.
%
% SEE ALSO:
%
%   HELPVIEW

% Author(s): Dallas C. Kennedy
% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/09/05 21:41:05 $

try
  helpview(path, topic_id);
catch
  errordlg('Demo help not found on documentation path. Check your Documentation location in Preferences.','Help Callback Error','modal')
end