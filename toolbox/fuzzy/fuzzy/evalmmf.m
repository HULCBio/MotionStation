function out = evalmmf(x, mf_para, mf_type)
%EVALMMF Multiple membership functions evaluation.
%   EVALMMF(X, MF_PARA, MF_TYPE) returns a matrix whose i-th row
%   is the membership grades of MF with type MF_TYPE(i,:) and
%   parameters MF_PARA(i,:).
%   If MF_TYPE is a single string, it will be used for all evaluation.
%
%   For example:
%
%       x = 0:0.2:10;
%       para = [-1 2 3 4; 3 4 5 7; 5 7 8 0; 2 9 0 0];
%       type = str2mat('pimf', 'trapmf', 'trimf', 'sigmf');
%       mf = evalmmf(x, para, type);
%       plot(x', mf');
%       set(gcf, 'name', 'evalmmf', 'numbertitle', 'off');
%
%   See also DSIGMF, GAUSS2MF, GAUSSMF, GBELLMF, EVALMF, PIMF, PSIGMF,
%   SIGMF, SMF, TRAPMF, TRIMF, ZMF.

%       Roger Jang, 7-14-94.
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/14 22:20:35 $

if size(mf_type, 1) == 1,
    mf_type = mf_type(ones(size(mf_para, 1), 1), :);
end

x = x(:)';
out = zeros(size(mf_type, 1), length(x));

for i = 1:size(mf_type, 1)
    out(i,:) = evalmf(x, mf_para(i,:), deblank(mf_type(i,:)));
end
