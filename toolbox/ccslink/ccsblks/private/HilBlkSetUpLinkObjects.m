function HilBlkSetUpLinkObjects(blk)
% This function is shared by multiple m-code modules of the HIL Block.  

% $Revision: 1.1.6.3 $ $Date: 2004/04/08 20:44:48 $
% Copyright 2001-2004 The MathWorks, Inc.


% Get CCS Handle in PDATA.
HilBlkGetCcsHandle(blk);

UDATA = get_param(blk,'UserData');
PDATA = HilBlkPersistentData(blk,'get');

% Get Function object in PDATA.
if isempty(UDATA.funcName),

    HilBlkClearUserData(blk);
    HilBlkPersistentData(blk,'clear');
    
else  

    if PDATA.tgtFcnObjStale, 
        
        PDATA.tgtFcnObjFullyDeclared = false;
        
        % * * * * * * * * * * * * * * * * * * * * * * 
        % Function constructor & Declaration
        warningMode = warning;
        warning off;
        if UDATA.declAutoDetermined,
            lastwarn('');
            PDATA.tgtFcnObj = PDATA.ccsObj.createobj( ...
                UDATA.funcName,'function');
        else  % Specify:
            % This syntax errors out (geck 161672)
            % PDATA.tgtFcnObj = PDATA.ccsObj.createobj(, ...
            %     UDATA.funcName,'function','funcdecl', ...
            %     UDATA.funcDecl);
            if isempty(UDATA.funcDecl),
                error('The function prototype parameter is empty.')
            end
            PDATA.tgtFcnObj = PDATA.ccsObj.createobj( ...
                UDATA.funcName,'function');
            lastwarn('');  % We want to examine the declare warning
            PDATA.tgtFcnObj.declare('decl',UDATA.funcDecl);
        end
        declarationWarning = lastwarn;
        warning(warningMode);
        
        if ~isfield(UDATA,'funcTimeout'),
            UDATA.funcTimeout = 30;
        end    
        PDATA.tgtFcnObj.timeout = UDATA.funcTimeout;
        
        HilBlkPersistentData(blk,'set',PDATA);
        
        % Check for expected warning.
        [pass, msg, decl] = HilBlkParseWarning(declarationWarning);
        if ~pass,
            % Since decl edit box is empty, provide the
            % faulty candidate for the user to view/edit.
            UDATA.funcDecl = decl;
            set_param(blk,'UserData',UDATA);
            if ~isequal(UDATA,get_param(blk,'UserData')),
                set_param(blk,'UserData',UDATA);
                mdlName = HilBlkGetParentSystemName(blk);
                set_param(mdlName,'Dirty','on');
            end
            % Issue error (terminates this function)
            error(msg)
        end

        % Check for successful declaration.
        if UDATA.declAutoDetermined,
            if ~isempty(PDATA.tgtFcnObj.funcdecl),
                UDATA.funcDecl = PDATA.tgtFcnObj.funcdecl;
                PDATA.tgtFcnObjFullyDeclared = true;
                PDATA.tgtFcnObjStale = false;
            else
                error(['Linking to the function was unsuccessful. ' ...
                        'To solve the problem, turn on ' ...
                        '"Specify function prototype" ' ...
                        'and type in the function prototype.'])
            end       
        else % Specify-prototype mode
            if ~isempty(PDATA.tgtFcnObj.funcdecl),
                PDATA.tgtFcnObjFullyDeclared = true;
                PDATA.tgtFcnObjStale = false;
            else
                error(['There was a problem registering your ' ...
                        'function prototype.'])
            end
        end
        
        HilBlkPersistentData(blk,'set',PDATA);
        if ~isequal(UDATA,get_param(blk,'UserData')),
            set_param(blk,'UserData',UDATA);
            mdlName = HilBlkGetParentSystemName(blk);
            set_param(mdlName,'Dirty','on');
        end
        
        
    end
    
    % update all dependent UserData 
    HilBlkParseArgs(blk);
    
end
