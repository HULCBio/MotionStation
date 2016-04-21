%COMMBLKEQUPDATEPORTS
% Update the input/output ports for the Linear Equalizer and DFE blocks
% Add, delete ports as needed, based upon checkboxes in mask.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2003/12/01 18:59:29 $

% if the mode box is checked, add a mode port, if needed.
if(exist('mode','var')) % mode does not exist for the CMA EQ
    if(mode == 1)
        if( strcmp(get_param([gcb,'/Mode'],'BlockType'),'Constant'))
            replace_block([gcb,'/Mode'],'Constant','Inport','noprompt')
        end
    end

    if(mode == 0)
        if( strcmp(get_param([gcb,'/Mode'],'BlockType'),'Inport'))
            replace_block([gcb,'/Mode'],'Inport','Constant','noprompt')
        end
    end
end

%if the Output Weights checkbox is checked, add an output port, if neccessary
if(outWeights == 1)
    if( strcmp(get_param([gcb,'/Wts'],'BlockType'),'Terminator'))        
        replace_block([gcb,'/Wts'],'Terminator','Outport','noprompt')
    end
end
% if the Output Weights checkbox is not checked, add terminator, if neccesary
if( outWeights  == 0)
    if( strcmp(get_param([gcb,'/Wts'],'BlockType'),'Outport'))
       % replace_block([gcb,'/Err'],'Port','2','Terminator','noprompt')
        replace_block([gcb,'/Wts'],'Outport','Terminator','noprompt')
    end
end

%if the Output error checkbox is checked, add an output port, if neccessary
if(outErr == 1)
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Terminator'))        
        replace_block([gcb,'/Err'],'Terminator','Outport','noprompt')
    end
end
% if the Output error checkbox is not checked, add terminator, if neccesary
if( outErr  == 0)
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Outport'))
       % replace_block([gcb,'/Err'],'Port','2','Terminator','noprompt')
        replace_block([gcb,'/Err'],'Outport','Terminator','noprompt')
    end
end

% make sure that the Err ouput has the correct port number
if(outErr == 1)
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Outport'))
        set_param([gcb,'/Err'],'Port','2');
    end
end
    

