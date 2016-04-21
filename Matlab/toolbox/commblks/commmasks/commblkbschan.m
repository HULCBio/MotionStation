function blk_icon = commblksbschan(P,s)
%commblkbschan2 Mask dynamic dialog function Binaray Symmetric Channel block

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2004/04/12 23:02:48 $


% Check parameters
if ( sum(~isreal(P)) ) | ( sum(P<0) > 0 ) | ( sum(P>1) > 0 )
    error('Error probability values must be real numbers between zero and one.');
end
if ( sum(abs(s) ~= s) ) | ( sum(floor(s) ~= s) )
    error('Initial seed values must be real, positive integers.');
end
% P and S must be the same length if they are not scalars
if(length(P)>1&length(s)>1)
    if(length(P)~=length(s))
        error('Error probablity and initial seed must be the same length if nonscalar.');
    end
end

maskValues = get_param(gcb,'MaskValues');

%if the Output error checkbox is checked, add an output port, if necessary
if( strcmp(maskValues(3),'on'))
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Terminator'))        
        replace_block([gcb,'/Err'],'Terminator','Outport','noprompt')
    end
    blk_icon.portnum = 2;
    blk_icon.portlabel = 'Err';
end
% if the Output error checkbox is not checked, add terminator, if neccesary
if( strcmp(maskValues(3),'off'))
    if( strcmp(get_param([gcb,'/Err'],'BlockType'),'Outport'))
        replace_block([gcb,'/Err'],'Port','2','Terminator','noprompt')
        
    end
    blk_icon.portnum = 1;
    blk_icon.portlabel = '';
end
