function LTImodel = getLTImodel(this, Name);

% Copyright 2003 The MathWorks, Inc.

% Operate on the MPCModels node ("this") to extract the LTI model having
% the designated name.

% Larry Ricker

if isempty(Name)
    warning('"Model" was empty in call to getLTImodel');
    LTImodel = [];
else
    LTImodel = this.getModel(Name).Model;
    if isempty(LTImodel)
        warning(sprintf('Could not find requested LTI model:  "%s"', ...
            Name));
    end
end

