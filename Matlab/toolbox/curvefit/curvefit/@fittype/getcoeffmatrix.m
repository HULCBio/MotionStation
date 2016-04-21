function  FITTYPE_OBJ_A_ = getcoeffmatrix(FITTYPE_OBJ_,varargin)  
% GETCOEFFMATRIX Compute linear coefficients matrix.

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.7.2.2 $  $Date: 2004/02/01 21:41:39 $

CELL_A_ = linearexprs(FITTYPE_OBJ_);
FITTYPE_OBJ_XDATA_ = varargin{end};
varargin(end) = [];
if ~isempty(varargin)
    FITTYPE_PROBPARAMS = varargin;
else
    FITTYPE_PROBPARAMS = {}; 
end
FITTYPE_OBJ_A_ = zeros(length(FITTYPE_OBJ_XDATA_),length(CELL_A_));
FITTYPE_OBJ_NUMCOEFF = numcoeffs(FITTYPE_OBJ_);
FITTYPE_INPUTS_(FITTYPE_OBJ_NUMCOEFF+1:FITTYPE_OBJ_NUMCOEFF+length(FITTYPE_PROBPARAMS)) = FITTYPE_PROBPARAMS; % syntax from fittype/feval so assignData works
FITTYPE_INPUTS_{FITTYPE_OBJ_NUMCOEFF+length(FITTYPE_PROBPARAMS)+1} = FITTYPE_OBJ_XDATA_; % syntax from fittype/feval so assignData works on prob param

if (isempty(FITTYPE_OBJ_.Aexpr))
    FITTYPE_OBJ_A_ = [];
else
    eval(FITTYPE_OBJ_.assignData);
    eval(FITTYPE_OBJ_.assignProb);

    for FITTYPE_OBJ_I_ = 1:length(CELL_A_)
        FITTYPE_OBJ_catch = ['error(''curvefit:getcoeffmatrix:linearTermError'', ', ...
                                    ' ''Error in fittype linear term',...
                ' ==> %s\n??? %s'',CELL_A_{FITTYPE_OBJ_I_},lasterr)'];
        FITTYPE_OBJ_SYMVARS = cfsymvar(CELL_A_{FITTYPE_OBJ_I_});
        if isempty(strmatch(FITTYPE_OBJ_.indep,FITTYPE_OBJ_SYMVARS)) % constant term
            FITTYPE_OBJ_A_(:,FITTYPE_OBJ_I_) = eval(CELL_A_{FITTYPE_OBJ_I_},FITTYPE_OBJ_catch)*ones(length(FITTYPE_OBJ_XDATA_),1);
        else
            FITTYPE_OBJ_A_(:,FITTYPE_OBJ_I_) = eval(CELL_A_{FITTYPE_OBJ_I_},FITTYPE_OBJ_catch);
        end
    end
end