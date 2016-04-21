function schema
%SCHEMA  Schema for fixed model class.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $ $Date: 2002/04/10 04:55:07 $


% Register class 
c = schema.class(findpackage('sisodata'),'fixedmodel');

% Define properties
schema.prop(c,'Name','string');    % Model name
schema.prop(c,'Model','MATLAB array');  % Model (LTI object) 
schema.prop(c,'Zero','MATLAB array');   % Model zeros
schema.prop(c,'Pole','MATLAB array');   % Model poles
schema.prop(c,'Gain','double');    % Model gain
schema.prop(c,'StateSpace','MATLAB array');   % State-space model

