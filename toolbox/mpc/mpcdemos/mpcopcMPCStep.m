function mpcopcMPCStep(eventSrc, eventData, gread, gwrite, model)

% Copyright 2004 The MathWorks, Inc.

persistent state;

s = size(model);
smo = size(model,'mo');

%% Read measured outputs
values = gread.Item.Value;
u = zeros(s(2),1); 
for k=1:length(values)
    if ~isempty(values{k})
       u(k) = double(values{k});
    end
end

%% Simulate one mpc step
if isempty(state)
   state = mpcstate(model);
end
y = mpcmove(model,state,u(1:smo),u(smo+1:end));



%% Write result to MVs
writeasync(gwrite,num2cell(y));