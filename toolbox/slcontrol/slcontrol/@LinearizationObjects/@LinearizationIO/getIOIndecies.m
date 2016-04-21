function [input_ind,output_ind,input_name,output_name] = getIOIndecies(io,inports,outports,varargin);
%Obtains the input output index information used in linearization.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

%% Note: The case where nargin == 3 is model linearization and when nargin == 4 this is the 
%%       block linearization. 

%% Initialize indicies
input_ind = [];
input_name = {};
output_ind = [];
output_name = {};

activeio = io(find(strcmp(get(io,'Active'),'on')));

for ct1 = 1:length(activeio)
    port_handles = get_param(activeio(ct1).Block,'PortHandles');
    port = port_handles.Outport(activeio(ct1).PortNumber);
    
    if strcmp(activeio(ct1).Type,'in')
        %% Find the indicies to the port handles
        ind = find(port==inports);
        input_ind(end+1:end+length(ind)) = ind;
        if (nargin == 3)
            if length(ind) > 1
                for ct2 = 1:length(ind)  
                    %% Remove the new line and carriage returns in the model/block name
                    block = regexprep(activeio(ct1).Block,'\n',' ');
                    input_name{end+1} = sprintf('%s (pout %d, ch %d)',...
                                            block,activeio(ct1).PortNumber,ct2);
                end
            else
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(activeio(ct1).Block,'\n',' ');
                input_name{end+1} = sprintf('%s (%d)',block,activeio(ct1).PortNumber);                
            end
        else
            if length(ind) > 1
                for ct2 = 1:length(ind)  
                    %% Remove the new line and carriage returns in the model/block name
                    block = regexprep(varargin{1}.Name,'\n',' ');
                    input_name{end+1} = sprintf('%s (pin %s, ch %d)',...
                                            block,activeio(ct1).Description,ct2);
                end 
            else
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(varargin{1}.Name,'\n',' ');
                input_name{end+1} = sprintf('%s (%s)',block,activeio(ct1).Description);                    
            end
        end
    elseif strcmp(activeio(ct1).Type,'out')
        %% Find the indicies to the port handles
        ind = find(port==outports);
        output_ind(end+1:end+length(ind)) = ind;
        if (nargin == 3)
            if length(ind) > 1
                for ct2 = 1:length(ind)     
                    %% Remove the new line and carriage returns in the model/block name
                    block = regexprep(activeio(ct1).Block,'\n',' ');
                    output_name{end+1} = sprintf('%s (pout %d, ch %d)',...
                                            block,activeio(ct1).PortNumber,ct2);
                end
            else
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(activeio(ct1).Block,'\n',' ');
                output_name{end+1} = sprintf('%s (%d)',block,activeio(ct1).PortNumber);                
            end
        else
            if length(ind) > 1
                for ct2 = 1:length(ind)    
                    %% Remove the new line and carriage returns in the model/block name
                    block = regexprep(varargin{1}.Name,'\n',' ');
                    output_name{end+1} = sprintf('%s (Output Port %d, Channel %d)',...
                                                block,activeio(ct1).Description,ct2);
                end    
            else
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(varargin{1}.Name,'\n',' ');
                output_name{end+1} = sprintf('%s (%s)',block,activeio(ct1).Description);                
            end
        end
    elseif  (strcmp(activeio(ct1).Type,'outin') || strcmp(io(ct1).Type,'inout'))
        %% Find the indicies to the port handles
        ind = find(port==inports);
        input_ind(end+1:end+length(ind)) = ind;  
        if length(ind) > 1
            for ct2 = 1:length(ind)
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(activeio(ct1).Block,'\n',' ');
                input_name{end+1} = sprintf('%s (pout %d, ch %d)',...
                                            block,activeio(ct1).PortNumber,ct2);
            end
        else
            %% Remove the new line and carriage returns in the model/block name
            block = regexprep(activeio(ct1).Block,'\n',' ');
            input_name{end+1} = sprintf('%s (%d)',block,activeio(ct1).PortNumber);
        end
        ind = find(port==outports);
        output_ind(end+1:end+length(ind)) = ind;
        if length(ind) > 1
            for ct2 = 1:length(ind)
                %% Remove the new line and carriage returns in the model/block name
                block = regexprep(activeio(ct1).Block,'\n',' ');
                output_name{end+1} = sprintf('%s (Output Port %d, Channel %d)',...
                                                block,activeio(ct1).PortNumber,ct2);
            end
        else
            %% Remove the new line and carriage returns in the model/block name
            block = regexprep(activeio(ct1).Block,'\n',' ');
            output_name{end+1} = sprintf('%s (%d)',block,activeio(ct1).Description);
        end
    end
end