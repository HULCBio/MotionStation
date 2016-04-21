function varargout = HilBlkMaskHelper(varargin)
% Mask Helper Function for the HIL Block.

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:27 $

blk = gcb;
action = varargin{1};

switch action
    case 'init',
        if nargout~=4, error('mask init function syntax error'), end
        try
            [numInports,inports,numOutports,outports] = HilBlkPortInfo(blk);
        catch
            % Don't just quietly fail.
            disp(['Error in HIL Block:  ' lasterr]);
            varargout = {0 [] 0 []};
            error(lasterr);
        end
        varargout{1} = numInports;
        varargout{2} = inports; 
        varargout{3} = numOutports; 
        varargout{4} = outports;
        % checkMaskDialogParamsForErrors(blk);
        
end % switch
