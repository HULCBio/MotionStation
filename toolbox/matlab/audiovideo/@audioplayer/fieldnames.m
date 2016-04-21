function out = fieldnames(obj, flag)
%FIELDNAMES Get audioplayer object property names.
%
%    NAMES = FIELDNAMES(OBJ) returns a cell array of strings containing 
%    the names of the properties associated with the audioplayer object, OBJ.
%    
%    NAMES = FIELDNAMES(OBJ, '-full') returns a cell array of strings 
%    containing the name, type, attributes, and inheritance of each 
%    field associated with the audioplayer object, OBJ.

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision: 1.1.6.1 $  $Date: 2003/12/04 19:00:10 $

% Error checking
if ~isa(obj, 'audioplayer')
   error('MATLAB:audioplayer:noAudioplayerObj', ...
         audioplayererrror('MATLAB:audioplayer:noAudioplayerObj'));
end

error(nargchk(1, 2, nargin, 'struct'));

% If -full is specified
if (nargin == 2)
   % This will error with 'Unknown command option' if -full not passed
   out = fieldnames(obj.internalObj, flag);

   % Replace class name with M-object class name so that everything says
   % 'Inhertied from audioplayer'
   if ispc
      out = strrep(out,'winaudioplayer', 'audioplayer');
   else
      out = strrep(out,'com.mathworks.toolbox.audio.JavaAudioPlayer', ...
                   'audioplayer');
   end
else
   out = fieldnames(obj.internalObj);
end

