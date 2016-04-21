function commblkseqsignlms
% commblkeqsignlms.
% This function will propogate the user choice of weight update from the
% mask down to the generic equalizer block

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/01 18:59:28 $

% % get the mask values of the generic equalizer block
 genEq = [ gcb '/Equalizer '];
% maskVal = get_param(genEq,'MaskValues');

maskType = get_param(gcb,'MaskType');
if(findstr(maskType, 'Linear') )
    maskVal{1} = 'Linear';
else
    maskVal{1} = 'DFE';
end


thisMaskval = get_param(gcb,'MaskValues');
alg = thisMaskval{1};

if(strcmpi(alg,'Sign LMS'))
    maskVal{2} = 'Sign LMS';
end

if(strcmpi(alg,'Sign Regressor LMS'))
    maskVal{2} = 'Sign Regressor LMS';
end

if(strcmpi(alg,'Sign Sign LMS'))
    maskVal{2} = 'Sign Sign LMS';
end

if(strcmpi(alg,'Complex Sign LMS'))
    maskVal{2} = 'Complex Sign LMS';
end

set_param(genEq,'MaskValues',maskVal);
 

