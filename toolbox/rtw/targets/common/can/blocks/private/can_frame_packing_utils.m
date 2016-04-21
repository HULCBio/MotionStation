function varargout = can_frame_packing_utils(util, message_in, varargin)
% CAN_FRAME_PACKING_UTILS
%
% Syntax: varargout =  can_frame_packing_utils(util, message_in, varargin)
% 
% --- Arguments ---
%
%   util   -  'preProcessMessage' | 'postProcessMessage'

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.2 $
%   $Date: 2002/11/15 15:48:39 $
    persistent originalString;
    persistent resolvedString;
    
    switch lower(util)
        case 'preprocessmessage'
            % store the original string
            originalString = message_in.getDbFilePath;
            % process message - process tokens in dbFilePath
            message_out = i_preProcessMessage(message_in);  
            % store the resolved string
            resolvedString = message_out.getDbFilePath;
            varargout{1} = message_out;
        case 'postprocessmessage'
            varargout{1} = i_postProcessMessage(message_in, originalString, resolvedString);
        otherwise
            disp('Unknown utility.');
    end;
return;

% resolve the dbFilePath String if required
% $MATLABROOT$ is transformed into the actual
% MATLABROOT path
function message_out = i_preProcessMessage(message_in)
    % pre-process the saved path in case
    % it is a sneaky relative path
    message_out = message_in.clone;
    dbfilePath = message_out.getDbFilePath;
    if (~isempty(dbfilePath))
        token = java.lang.String('$MATLABROOT$');
        if (dbfilePath.startsWith(token)) 
              % process $MATLABROOT$
              newPath = java.lang.String(matlabroot);
              newPath = newPath.concat(dbfilePath.substring(token.length));
              message_out.setDbFilePath(newPath);
        end;
    end;
return;

% reset the dbFilePath string to the version that contains the tokens
% if appropriate eg. $MATLABROOT$
function message = i_postProcessMessage(message, originalString, resolvedString)
    newString = message.getDbFilePath;
    if (strcmp(resolvedString, newString)==1)
        % if the string did not change - always
        % restore the original string in order to preserve
        % special tags
        newString = originalString;
    end;
    message.setDbFilePath(newString);
return;