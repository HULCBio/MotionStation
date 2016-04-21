function eMsg = audioplayererror(MSGID, varargin)
%AUDIOPLAYERERROR Returns the error messages for the audioplayer object.
%
%    AUDIOPLAYERERROR(MSGID) returns the message string corresponding to
%    the error message ID, MSGID.
%

%    JCS
%    Copyright 2003-2004 The MathWorks, Inc. 
%    $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:23:24 $

switch lower(MSGID)
case {'matlab:audioplayer:subsasgn:badsubscript', 'matlab:audioplayer:subsref:badsubscript'},
    eMsg = sprintf('Unable to find subsindex function for class %s.', varargin{1});
case 'matlab:audioplayer:wrongnumberinputs',
    eMsg = 'Wrong number of arguments to audioplayer.';
case 'matlab:audioplayer:noaudioplayerobj',
    eMsg = 'OBJ must be an audioplayer object.';
case 'matlab:audioplayer:emptyaudioplayerarray'
    eMsg = 'Creation or use of an empty audioplayer object array is not allowed.\nUse CLEAR to clear objects from the workspace.';
case 'matlab:audioplayer:sizemismatch'
    eMsg = 'Matrix dimensions must agree.';
case 'matlab:audioplayer:singletonrequired'
    eMsg = 'OBJ must be a 1-by-1 audioplayer object.';
case 'matlab:audioplayer:inconsistentsubscript'
    eMsg = 'Inconsistently placed ''()'' in subscript expression.';
case 'matlab:audioplayer:badcellref'    
    eMsg = 'Cell contents reference from a non-cell array object.';
case 'matlab:audioplayer:inconsistentdotref'
    eMsg = 'Inconsistently placed ''.'' in subscript expression.';
case 'matlab:audioplayer:badref'
    eMsg = sprintf('Unknown subscript expression type: %s.',varargin{:});
case 'matlab:audioplayer:assignelementsizemismatch'
    eMsg = 'In an assignment A(I)=B, the number of elements in B and I must be the same.';
case 'matlab:audioplayer:unhandledsyntax'
    eMsg = 'Syntax not supported.';
case 'matlab:audioplayer:gapsnotallowed'
    eMsg = 'Gaps are not allowed in audioplayer array indexing.';
case 'matlab:audioplayer:assigntononaudioplayerobject'
    eMsg = 'Only audioplayer objects may be concatenated.';
case 'matlab:audioplayer:creatematrix'
    eMsg = 'Only a row or column vector of audioplayer objects can be created.';
case 'matlab:audioplayer:propnotenumtype'
    eMsg = sprintf('An audioplayer object''s ''%s'' property does not have a fixed set of property values.\n', varargin{1});
case 'matlab:audioplayer:nocatenation'
    eMsg = 'Audioplayer objects cannot be concatenated.';
case 'matlab:audioplayer:mustbeaudiorecorder'
    eMsg = 'R must be an audiorecorder object.';
case 'matlab:audioplayer:invalidsignal'
    eMsg = 'First input must be a numeric signal or audiorecorder object.';
case 'matlab:audioplayer:invalidstructure'
    eMsg = 'Invalid structure input for audioplayer creation.';
case 'matlab:audioplayer:invaliddeviceid'
    eMsg = 'Device ID must be numeric.';
case 'matlab:audioplayer:positivesamplerate'
    eMsg = 'Sample rate must be positive.';
case 'matlab:audioplayer:bitsupport'
    eMsg = 'Currently only 8, 16, and 24-bit audio is supported.';
case 'matlab:audioplayer:needjvmonunix'
    eMsg = 'This function requires Java to be run.';
case 'matlab:audioplayer:loadobj:needjvmonunix'
    eMsg = 'The audioplayer object requires Java and was not loaded.';
case 'matlab:audioplayer:unsupportedtype'
    eMsg = 'Unsupported data type.';
case 'matlab:audioplayer:numericinputs'
    eMsg = 'When creating an audioplayer object from an audio signal, all input arguments must be numeric.';
case 'matlab:audioplayer:deviceidwindows'
    eMsg = 'DeviceID parameter can only be set on Windows.';
case 'matlab:audioplayer:unix24bit'
    eMsg = '24-bit not supported on UNIX.  Using 16-bit.';
case 'matlab:audioplayer:loadobj:couldnotload'
    eMsg = sprintf('Could not load audioplayer object.  %s', varargin{1});
case 'matlab:audioplayer:loadobj:couldnotset'
    eMsg = sprintf('Could not load audioplayer object properly.  ''%s'' property was not set.', varargin{1});
otherwise
    eMsg = ['Error: ' MSGID varargin{:}];
end
    