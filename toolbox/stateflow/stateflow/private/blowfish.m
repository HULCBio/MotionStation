function blowfish(method,machineName)
% a quick m-prototype to encrypt models.
% most of it will move into c shortly.

% Copyright 2002 The MathWorks, Inc.

switch(method)
   case {'encode','decode'}
      %ok
   otherwise,
      error('methodName must be ''decode'' or ''encode''');
end

machineId = sf_force_open_machine(machineName);

charts = sf('get',machineId,'machine.charts');

for i=1:length(charts)
   blowfish_chart(method,charts(i));
end


function blowfish_chart(method,chart)

states = sf('get',chart,'chart.states');
transitions = sf('get',chart,'chart.transitions');

sf('TurnOffPrototypeSync',1);
sf('TurnOffTruthTableUIUpdates',1);
sf('TurnOffEMLUIUpdates',1);

for i=1:length(states)
   blowfish_object(method,states(i),'state.labelString');
   blowfish_object(method,states(i),'state.eml.script');
   blowfish_object(method,states(i),'state.description');
end

for i=1:length(transitions)
   blowfish_object(method,transitions(i),'transition.labelString');
   blowfish_object(method,transitions(i),'transition.description');
end

sf('TurnOffPrototypeSync',0);
sf('TurnOffTruthTableUIUpdates',0);
sf('TurnOffEMLUIUpdates',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blowfish_object(method,objectId,propName)
   propVal = sf('get',objectId,propName);
   newVal = sf('BlowFish',method,'evil',propVal);
   sf('set',objectId,propName,newVal);
   
   
