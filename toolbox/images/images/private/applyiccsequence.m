function out = applyiccsequence(in,sequence)
%APPLYICCSEQUENCE Evaluates data through an 'icc' cform.
%   out = applyiccsequence(in,c);

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:57:41 $
%   Author:  Scott Gregory, Toshia McCabe 11/04/02
%   Revised: Toshia McCabe 12/02/02
 
cform_names = fields(sequence);
num_cforms = length(cform_names);

% Apply source cform (s)
for k = 1:num_cforms
    out = applycform(in,sequence.(cform_names{k}));
    in = out;
end
