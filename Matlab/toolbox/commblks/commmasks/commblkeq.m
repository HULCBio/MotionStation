function commblkeq
% commblkeq
% This M-file will handle the selection between the linear and DFE branches
% of the equalizer block. It will also handle the switching in of different
% weight update algorithms

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2003/12/01 18:59:26 $

maskValues = get_param(gcb,'MaskValues');
thisBlock = gcb;
% Select the linear of dfe branch
if ( strcmp(maskValues{1} ,'DFE') == 1);
    set_param([thisBlock '/Subsystem/Decision Feedback branch'],'BlockChoice','DFE branch');
else
    set_param([thisBlock '/Subsystem/Decision Feedback branch'],'BlockChoice','Linear EQ branch');
end

% select the weight update algorithm
if( strcmp(maskValues{2}, 'LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','LMS');
end

if( strcmp(maskValues{2}, 'RLS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','RLS');
end

if( strcmp(maskValues{2}, 'Sign LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Sign LMS');
end

if( strcmp(maskValues{2}, 'Sign Regressor LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Sign Regressor LMS');
end

if( strcmp(maskValues{2}, 'Sign Sign LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Sign Sign LMS');
end

if( strcmp(maskValues{2}, 'Complex Sign LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Complex Sign LMS');
end

if( strcmp(maskValues{2}, 'Normalized LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Normalized LMS');
end

if( strcmp(maskValues{2}, 'Variable Step LMS') == 1);
    set_param([thisBlock '/Subsystem/Weight Update Algorithm'],'BlockChoice','Variable Step LMS');
end


