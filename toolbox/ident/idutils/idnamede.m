function [ynared,unared,yind,uind,exnared,exind] = idnamede(sys)
%function [ynared,unared,yind,uind] = idnamede(sys)
% SYS a cell array of systems
% YNARED: A cell array of distinct OutputNames from all the SYS's
% UNARED: A cell array of distinct InputNames from all the SYS's
% yind(ks,kna) = The outputindex number for system ks and YNARED name # kna,
% i.e. SYS{ks}.OutputName(yind(ks,kna)) = YNARED{kna}
% uind dito for InputName
% if yind(ks,kna)==0 YNARED(kna) is not present in SYS{ks}


%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:56 $

uname =[];
yname =[];
for ks = 1:length(sys)
   uname = [uname;pvget(sys{ks},'InputName')];
   yname = [yname;pvget(sys{ks},'OutputName')];
end
remna = uname;
unared = [];
while ~isempty(remna)
   unared = [unared;remna(1)];
   remna = remna(find(~strcmp(remna(1),remna)));
end

remna = yname;
ynared = [];
while ~isempty(remna)
   ynared = [ynared;remna(1)];
   remna = remna(find(~strcmp(remna(1),remna)));
end
yind = zeros(length(sys),length(ynared));
uind = zeros(length(sys),length(unared));

for ks=1:length(sys)
   for kna = 1:length(ynared)
      ka = find(strcmp(ynared{kna},pvget(sys{ks},'OutputName')));
      if ~isempty(ka)
         yind(ks,kna) = ka;
      end
   end
   for knb= 1:length(unared)
      kb = find(strcmp(unared{knb},pvget(sys{ks},'InputName')));
      if ~isempty(kb)
         uind(ks,knb) = kb;
      end
   end
   
end
if isa(sys{1},'iddata')
   exname =[];
   for ks = 1:length(sys)
      exname = [exname;pvget(sys{ks},'ExperimentName')];
   end
   remna = exname;
   exnared = [];
   while ~isempty(remna)
      exnared = [exnared;remna(1)];
      remna = remna(find(~strcmp(remna(1),remna)));
   end
   
   exind = zeros(length(sys),length(exnared));
   
   for ks=1:length(sys)
      for kna = 1:length(exnared)
         ka = find(strcmp(exnared{kna},pvget(sys{ks},'ExperimentName')));
         if ~isempty(ka)
            exind(ks,kna) = ka;
         end
      end
   end
end
