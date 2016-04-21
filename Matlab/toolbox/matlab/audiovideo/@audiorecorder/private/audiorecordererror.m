function eMsg = audiorecordererror(MSGID, varargin)
%AUDIORECORDERERROR Returns the error messages for the audiorecorder object.
%
%    AUDIORECORDERERROR(MSGID) returns the message string corresponding to
%    the error message ID, MSGID.
%

%    JCS
%    Copyright 2003 The MathWorks, Inc. 
%    $Revision $  $Date: 2003/12/22 00:50:18 $

switch lower(MSGID)
case {'matlab:audiorecorder:subsasgn:badsubscript', 'matlab:audiorecorder:subsref:badsubscript'},
    eMsg = sprintf('Unable to find subsindex function for class %s.', varargin{1});
case 'matlab:audiorecorder:noaudiorecorderobj',
    eMsg = 'OBJ must be an audiorecorder object.';
case 'matlab:audiorecorder:emptyaudiorecorderarray'
    eMsg = 'Creation or use of an empty audiorecorder object array is not allowed.\nUse CLEAR to clear objects from the workspace.';
case 'matlab:audiorecorder:sizemismatch'
    eMsg = 'Matrix dimensions must agree.';
case 'matlab:audiorecorder:singletonrequired'
    eMsg = 'OBJ must be a 1-by-1 audiorecorder object.';
case 'matlab:audiorecorder:inconsistentsubscript'
    eMsg = 'Inconsistently placed ''()'' in subscript expression.';
case 'matlab:audiorecorder:badcellref'    
    eMsg = 'Cell contents reference from a non-cell array object.';
case 'matlab:audiorecorder:inconsistentdotref'
    eMsg = 'Inconsistently placed ''.'' in subscript expression.';
case 'matlab:audiorecorder:badref'
    eMsg = sprintf('Unknown subscript expression type: %s.',varargin{:});
case 'matlab:audiorecorder:assignelementsizemismatch'
    eMsg = 'In an assignment A(I)=B, the number of elements in B and I must be the same.';
case 'matlab:audiorecorder:unhandledsyntax'
    eMsg = 'Syntax not supported.';
case 'matlab:audiorecorder:gapsnotallowed'
    eMsg = 'Gaps are not allowed in audiorecorder array indexing.';
case 'matlab:audiorecorder:assigntononaudiorecorderobject'
    eMsg = 'Only audiorecorder objects may be concatenated.';
case 'matlab:audiorecorder:creatematrix'
    eMsg = 'Only a row or column vector of audiorecorder objects can be created.';
case 'matlab:audiorecorder:propnotenumtype'
    eMsg = sprintf('An audiorecorder object''s ''%s'' property does not have a fixed set of property values.\n', varargin{1});
case 'matlab:audiorecorder:nocatenation'
    eMsg = 'Audiorecorder objects cannot be concatenated.';
case 'matlab:audiorecorder:invalidstructure'
    eMsg = 'Invalid structure input for audiorecorder creation.';
case 'matlab:audiorecorder:positivesamplerate'
    eMsg = 'Sample rate must be positive.';
case 'matlab:audiorecorder:bitsupport'
    eMsg = 'Currently only 8, 16, and 24-bit audio is supported.';
case 'matlab:audiorecorder:loadobj:needjvmonunix'
    eMsg = 'The audiorecorder object requires Java and was not loaded.';
case 'matlab:audiorecorder:needjvmonunix'
    eMsg = 'This function requires Java to be run.';
case 'matlab:audiorecorder:unsupportedtype'
    eMsg = 'Unsupported data type.';
case 'matlab:audiorecorder:numericinputs'
    eMsg = 'When creating an audiorecorder object for an audio signal, all input arguments must be numeric.';
case 'matlab:audiorecorder:deviceidwindows'
    eMsg = 'DeviceID parameter can only be set on Windows.';
case 'matlab:audiorecorder:unix24bit'
    eMsg = '24-bit not supported on UNIX.  Using 16-bit.';
case 'matlab:audiorecorder:loadobj:couldnotload'
    eMsg = sprintf('Could not load audiorecorder object.  %s', varargin{1});
case 'matlab:audiorecorder:loadobj:couldnotset'
    eMsg = sprintf('Could not load audiorecorder object properly.  ''%s'' property was not set.', varargin{1});
case 'matlab:audiorecorder:incorrectnumberinputs'
    eMsg = sprintf('Incorrect number of parameters to audiorecorder.');
case 'matlab:audiorecorder:numchannelsupport'
    eMsg = sprintf('Currently only one and two channel audio is supported.');
otherwise
    eMsg = ['Error: ' MSGID varargin{:}];
end
    