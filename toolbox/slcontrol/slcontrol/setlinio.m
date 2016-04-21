function oldio = setlinio(model,ios);
%SETLINIO Assign I/O settings to Simulink model.
%
%   OLDIO=SETLINIO('sys',IO) assigns the settings in the vector of 
%   linearization I/O objects, IO, to the Simulink model, sys, where 
%   they are represented by annotations on the signal lines. Use the 
%   function GETLINIO or LINIO to create the linearization I/O objects. 
%   You can save I/O objects to disk in a MAT-file and use them later to 
%   restore linearization settings in a model.
%
%   See also LINIO, GETLINIO

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:35:14 $

%% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
    %% Throw the error
    errmsg = sprintf(['The model %s must be loaded before the settings \n in',...
                         ' the LinearizationIO objects can be uploaded.'], ...
                         model);
    error('slcontrol:ModelNotLoadedforIOUploading', errmsg)
end

%% Get the old IO settings
oldio = getlinio(model);

%% Reset the diagram ios to be off
for ct = 1:length(oldio)
    p = get_param(oldio(ct).Block,'PortHandles');
    op = p.Outport(oldio(ct).PortNumber);
    set_param(op,'LinearAnalysisInput','off');
    set_param(op,'LinearAnalysisOutput','off');
    set_param(op,'LinearAnalysisLinearizeOrder','off');    
    set_param(op,'LinearAnalysisOpenLoop','off');
end

%% Set the new properties
for ct = 1:length(ios)
    if strcmp(ios(ct).Active,'on');
        %% Get the block port handles
        try 
            p = get_param(ios(ct).Block,'PortHandles');
        catch
            %% Restore the old IO settings
            setlinio(model,oldio);
            %% Throw the error
            errmsg = sprintf('The block %s is not a valid Simulink block.', ios(ct).Block);
            error('slcontrol:InvalidIOBlock', errmsg)
        end
        
        if (length(p.Outport) < ios(ct).PortNumber)
            %% Restore the old IO settings
            setlinio(model,oldio);
            %% Throw the error
            errmsg = sprintf('The block %s does not have %dth output port.', ...
                       ios(ct).Block, ios(ct).PortNumber);
            error('slcontrol:InvalidIOBlockPort',errmsg)
        end
       
        %% Get port handle
        op = p.Outport(ios(ct).PortNumber);
        set_param(op,'LinearAnalysisOpenLoop',ios(ct).OpenLoop);
        
        if strcmpi(ios(ct).Type,'in');
            set_param(op,'LinearAnalysisInput','on');
            set_param(op,'LinearAnalysisOutput','off');
            set_param(op,'LinearAnalysisLinearizeOrder','off');
        elseif strcmpi(ios(ct).Type,'out');
            set_param(op,'LinearAnalysisInput','off');
            set_param(op,'LinearAnalysisOutput','on');
            set_param(op,'LinearAnalysisLinearizeOrder','off');
        elseif strcmpi(ios(ct).Type,'inout');
            set_param(op,'LinearAnalysisInput','on');
            set_param(op,'LinearAnalysisOutput','on');
            set_param(op,'LinearAnalysisLinearizeOrder','off');
        elseif strcmpi(ios(ct).Type,'outin');
            set_param(op,'LinearAnalysisInput','on');
            set_param(op,'LinearAnalysisOutput','on');
            set_param(op,'LinearAnalysisLinearizeOrder','on');
        elseif strcmpi(ios(ct).Type,'none');
            set_param(op,'LinearAnalysisInput','off');
            set_param(op,'LinearAnalysisOutput','off');
            set_param(op,'LinearAnalysisLinearizeOrder','off');
        end
    end
end