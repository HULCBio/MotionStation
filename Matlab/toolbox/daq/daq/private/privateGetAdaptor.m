function [adaptorStr, obj, names] = privateGetAdaptor(subsystem)
%PRIVATEGETADAPTOR Return possible constructors based on installed hardware.
%
%    [ADAPTORSTR, OBJ, NAMES] = PRIVATEGETADAPTOR(SUBSYSTEM) returns the 
%    possible constructors, ADAPTORSTR, based on the installed hardware
%    and the given subsystem, SUBSYSTEM.  OBJ is the first data acquisition
%    object that can be created from ADAPTORSTR.  NAMES is a list of 
%    channel names for OBJ.
%
%    Example:
%      [adaptorStr, obj, name] = privategetadaptor('analoginput')
%      would return:
%        adaptorStr = {'winsound0', 'nidaq1'};
%        obj = analoginput('winsound');
%        name = {'Channel1' 'Channel2'};
%
%    PRIVATEGETADAPTOR is a helper function for DAQSCOPE, DAQFCNGEN, and DIOPANEL.
%

%    MP 01-12-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:42:19 $


% Determine the list of adaptors for the popup.
daqInfo = daqhwinfo;
adaptors = daqInfo.InstalledAdaptors;
allconstructor = {};
alladaptor = {};

% Determine which adaptors have a subsystem constructor.
for i = 1:length(adaptors)
   index = [];
   try
      adaptorInfo = daqhwinfo(adaptors{i});
      constructor = adaptorInfo.ObjectConstructorName;
   catch
      constructor = [];
   end
   for j = 1:numel(constructor)
      if isempty(findstr(subsystem, constructor{j}))
         index = [index j];
      end
   end
   constructor(index) = [];
   allconstructor = [allconstructor(:)' constructor(:)'];
   alladaptor = [alladaptor repmat(adaptors(i),1,length(constructor))];
end

% Parse the allconstructor variable and extract the ids.
id = {};
for i = 1:length(allconstructor)
   indexid1 = find(allconstructor{i} == ',');
   indexid2 = find(allconstructor{i} == ')');
   if strcmp(allconstructor{i}(indexid1+1), '''')
      id = {id{:} allconstructor{i}(indexid1+2:indexid2-2)};
   else	
      id = {id{:} allconstructor{i}(indexid1+1:indexid2-1)};
   end	
end

% Create the pop-up string - {adaptor id}
adaptorStr = '';
if strcmp(subsystem,'analoginput')
    %for demo DAQSCOPE
    for i = 1:length(alladaptor)  
        if ~strcmp(alladaptor{i},'winsound')
            obj1 = feval(subsystem, alladaptor{i}, id{i});
            objInfo1 = daqhwinfo(obj1);
            %check if the device has a differential input  type
            if ~isempty(objInfo1.DifferentialIDs)
                adaptorStr = [adaptorStr; {[alladaptor{i} ' ' id{i} ' ' '(Differential)']}];
            end
            %check if the device has a single-ended input  type
            if ~isempty(objInfo1.SingleEndedIDs)
                adaptorStr = [adaptorStr; {[alladaptor{i} ' ' id{i} ' ' '(SingleEnded)']}];
            end
            delete(obj1);
            clear obj1;
        else %winsound
            adaptorStr = [adaptorStr; {[alladaptor{i} ' ' id{i} ' ']}];
        end
    end
else
    %for demo DAQFCNGEN and DIOPANEL.
    for i = 1:length(alladaptor)  
        adaptorStr = [adaptorStr; {[alladaptor{i} ' ' id{i}]}];
    end
end

% In case no adaptors are registered.
if isempty(adaptorStr)
   adaptorStr = ' ';
end

if ~isempty(alladaptor)
   % Create an object for the first adaptor listed in the popup.
   try
      obj = feval(subsystem, alladaptor{1}, id{1});
      
      if ~strcmp(subsystem, 'digitalio')
         if strcmp(lower(alladaptor{1}), 'winsound')
            set(obj, 'SampleRate', 44100);
         end
         
         % Determine the number of channels allowed for the first adaptor.
         objInfo = daqhwinfo(obj);
         
         % Derermine the channel IDs.
         % Construct the channel names - based on the hardware ids.
         if strcmp(lower(alladaptor{1}), 'winsound')
            names = {'Channel1 (Left)';'Channel2 (Right)'};
         else
            if strcmp(subsystem, 'analoginput') 
               if ~isempty(objInfo.DifferentialIDs)
                   set(obj, 'InputType', 'Differential');
                   channelIDs = objInfo.DifferentialIDs;
               elseif ~isempty(objInfo.SingleEndedIDs)
                   set(obj, 'InputType', 'SingleEnded');
                   channelIDs = objInfo.SingleEndedIDs;
               end
            elseif strcmp(subsystem, 'analogoutput')
                channelIDs = objInfo.ChannelIDs;             
            end
            names = makenames('Channel', channelIDs);
         end
      end
   catch
      obj = [];
      names = '';
   end
else
   obj = [];
   names = '';
end
