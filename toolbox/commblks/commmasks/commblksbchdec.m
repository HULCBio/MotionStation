function params = commblksbchdec(n,k,showNumErr);
%commblksbchdec Mask dynamic dialog function for the BCH Decoder block  

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:03:04 $


% Get the parameters to pass down to the S-function block
[genpoly,params.t] = bchgenpoly(n,k);
params.m = ceil(log2(n+1));
params.poly = primpoly(params.m,'nodisplay');

%if the Show Number of Errors checkbox is checked, add an output port, if neccessary
if( showNumErr == 1)
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Terminator'))        
        replace_block([gcb,'/Err'],'Terminator','Outport','noprompt')
    end
    params.portnum = 2;
    params.portlabel = 'Err';
end
% if the Output error checkbox is not checked, add terminator, if neccesary
if( showNumErr ==0)
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Outport'))
        replace_block([gcb,'/Err'],'Port','2','Terminator','noprompt')      
    end
    params.portnum = 1;
    params.portlabel = '';
end
