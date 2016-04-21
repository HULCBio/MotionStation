function mpcopcPlantStep(eventSrc, eventData, gread, gwrite, model)

% Copyright 2004 The MathWorks, Inc.

persistent state;

s = size(model);

%% Read measured outputs
values = gread.Item.Value;
u = zeros(s(2),1); 
for k=1:length(values)
    if ~isempty(values{k})
       u(k) = double(values{k});
    end
end

%% Simulate one plant step
if isempty(state)
   state = zeros(size(model.a,1),1);
end
y = model.c*state+model.d*u;
state = model.a*state+model.b*u;

%% Write result to MVs
writeasync(gwrite,num2cell(y));