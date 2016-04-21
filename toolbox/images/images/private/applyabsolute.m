function out = applyabsolute(in,cspace,source_wp,dest_wp)
% out = applyabsolute(in,cspace,source_wp,dest_wp)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/01/26 05:57:38 $

% Convert input data to doubles for these calculations
data_class = class(in);
is_not_double = ~strcmp(data_class,'double');
if is_not_double
    in = encode_color(in,cspace,data_class,'double');
end

% The conversion to absolute is a scaling for xyz, but if the data
% is LAB, we need to do lab2xyz then xyz2lab.
if strcmp(cspace,'xyz')
    scale_factor = source_wp ./ dest_wp;
    out = [in(:,1) * scale_factor(1),...
           in(:,2) * scale_factor(2),...
           in(:,3) * scale_factor(3)];
else
    out = xyz2lab(lab2xyz(in,source_wp),dest_wp);
end

% Encode the data back to what it was
if is_not_double
    out = encode_color(out,cspace,'double',data_class);
end