function out = defuzz(x, mf, type)
% DEFUZZ Defuzzify membership function.
%   Synopsis
%   out = defuzz(x,mf,type)
%   Description
%   defuzz(x,mf,type) returns a defuzzified value out, of a membership function
%   mf positioned at associated variable value x, using one of several
%   defuzzification strategies, according to the argument, type. The variable
%   type can be one of the following.
%   centroid: centroid of area method.
%   bisector: bisector of area method.
%   mom: mean of maximum method.
%   som: smallest of maximum method.
%   lom: largest of maximum method.
%   If type is not one of the above, it is assumed to be a user-defined
%   function. x and mf are passed to this function to generate the defuzzified
%   output.
%   Examples
%   x = -10:0.1:10;
%   mf = trapmf(x,[-10 -8 -4 7]);
%   xx = defuzz(x,mf,'centroid');
%
%   Try DEFUZZDM for more examples.

%   Roger Jang, 6-28-93 ,10-5-93, 9-29-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/14 22:20:23 $

x = x(:);
mf = mf(:);
if length(x) ~= length(mf),
    error('Sizes mismatch!');
end
data_n = length(x);
 
if strcmp(type, 'centroid'),
    total_area = sum(mf);
    if total_area == 0,
        error('Total area is zero in centroid defuzzification!');
    end
    out = sum(mf.*x)/total_area;
    return;
elseif strcmp(type, 'bisector'),
        total_area = sum(mf);
    if total_area == 0,
        error('Total area is zero in bisector defuzzification!');
    end
        tmp = 0;
        for k=1:data_n,
                tmp = tmp + mf(k);
                if tmp >= total_area/2,
                        break;
                end
        end
    out = x(k);
    return;
elseif strcmp(type, 'mom'),
        out = mean(x(find(mf==max(mf))));
    return;
elseif strcmp(type, 'som'),
        tmp = x(find(mf == max(mf)));
        [junk, which] = min(abs(tmp));
    out = tmp(which); 
    return;
elseif strcmp(type, 'lom'),
        tmp = x(find(mf == max(mf)));
        [junk, which] = max(abs(tmp));
    out = tmp(which); 
    return;
else
    % defuzzification type is unknown
    % We assume it is user-defined and evaluate it here
    evalStr=[type '(x, mf)'];
    out = eval(evalStr);
    return;
end
