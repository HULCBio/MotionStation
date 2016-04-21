%% Demonstrate methods for saving and loading data acquisition objects.
%    DEMODAQ_SAVE illustrates how your data acquisition session can be
%    saved between MATLAB sessions.  This demo gives two methods for saving
%    your data acquisition session setup.
%
%    The first method is to use the SAVE command to save the data
%    acquisition  objects to a MAT-file and the LOAD command to load the
%    data acquisition  objects from the MAT-file back into the MATLAB
%    workspace.  This portion  of the demo illustrates how more than one
%    object in the MATLAB workspace  can point to the same object in the
%    data acquisition engine and how  loading a data acquisition object
%    that currently exists in the data  acquisition engine can effect data
%    acquisition objects that exist in  the MATLAB workspace.
%    
%    The second method is to use the OBJ2MFILE command to convert the data
%    acquisition object to the equivalent MATLAB code to create the object.
%    The data acquisition object can be recreated in a later MATLAB session
%    by running the M-file created by OBJ2MFILE.
%
%    See also ADDCHANNEL, DAQ/PRIVATE/SAVE, DAQ/PRIVATE/LOAD, OBJ2MFILE,
%             DAQHELP, DAQDEVICE/DELETE, DAQ/PRIVATE/CLEAR.
%
%    MP 8-22-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.6.2.5 $  $Date: 2003/08/29 04:45:22 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this example, you will learn about saving analog input 
% objects, and converting analog input objects to the 
% equivalent MATLAB commands.
%
% To get started, an analog input object with two channels 
% is created. 
ai = analoginput('winsound');
ch = addchannel(ai, [1 2], {'Left';'Right'});

%%
% The analog input object Tag, UserData, and SampleRate properties 
% are assigned values.
ai.Tag = 'ai1';
ai.UserData = [1 4 2];
ai.SampleRate = 20000;

%%
% You can save an analog input object to a MAT-file 
% with MATLAB's built-in SAVE command.
save fname ai
delete(ai);

%%
% You can recreate the object when the MAT-file is loaded
% back into the MATLAB workspace with MATLAB's built-in 
% LOAD command.
% 
% When loading an object into the MATLAB workspace, it  
% is important to remember that all copies of an object 
% in the workspace reference (point to) the same
% object in the data acquisition engine. 
load fname
ai
%

%%
% There are two variables, ai1 and ai, in the MATLAB 
% workspace. However, there is only one object in the 
% data acquisition engine that both ai and ai1 point to.
% Therefore, if you modify a property of ai1, the same 
% property is modified in the variable ai.
ai1 = ai;          % referencing the same object

whos ai1 ai
%

%%
% Originally, ai's UserData property is defined as follows:
% 
% >> ai.UserData;
% 
% Now, let's modify ai1's UserData property to a new 
% array.
% 
% >> ai1.UserData = [3 5 1];
% 
% Now, let's check ai's UserData property value.
orig_ai = ai.UserData     % Original ai
ai1.UserData = [3 5 1];   % Modified ail
modif_ai = ai.UserData    % Verify ai
%

%%
% When loading an analog input object, MATLAB will first  
% determine if the object already exists in the data 
% acquisition engine. If it does exist, the object being
% loaded simply points to the object in the data acquisition
% engine. 
% 
% However, if any properties are different between 
% the object being loaded and the object that already exists
% in the engine, all properties will be modified to correspond
% to the object that is being loaded.
save fname ai      % let's save the analog input object

%%
% Let's assign the original values for the analog input Tag, UserData, 
% and SampleRate properties to a new variable.
original_Tag = ai.Tag;
original_UserData = ai.UserData;
original_SampleRate = ai.SampleRate;

%%
% Now let's assign new values to these properties.
ai.Tag = 'myai1';
ai.UserData = [1 4 2];
ai.SampleRate = 24000;

%%
% When the file fname.mat is loaded, MATLAB determines  
% that the analog input object being loaded already exists 
% in the data acqusition engine. MATLAB also determines
% that three property values differ between the object 
% being loaded and the object that exists in the data 
% acquisition engine. These three properties are modified 
% to correspond to the object that is being loaded.
load fname

%%
% Let's compare the Tag properties.
ai.Tag
original_Tag
%

%%
% Let's compare the UserData properties.
ai.UserData
original_UserData
%

%%
% Let's compare the SampleRate properties.
ai.SampleRate
original_SampleRate
%

%%
% Similarly, channels will be added or deleted from an 
% object that exists in the MATLAB workspace if the loaded 
% object references the same object in the data acquisition 
% engine and has a different number of channels.
save fname ai

%%
% Now, let's delete the second channel from analog input ai.
% Note that the object, ai, now only has one channel.
delete(ai.Channel(2));

ai.Channel  % verify one channel present
%

%%
% However, after loading fname.mat, ai will have the
% original channel setup since this was the channel 
% configuration saved to fname.mat.
load fname 
ai.Channel  % verify original channel setup  
%

%%
% In summary, objects that exist in the MATLAB workspace 
% can be modified by an object that is being loaded if: 
% 
%  - The two objects point to the same object in the data 
%    acquisition engine. 
%  - The two objects have different property values. 
% 
% Property values of the object that is being loaded have 
% precedence over the property values of the objects that 
% currently exist in the MATLAB workspace. Therefore, the 
% object that is being loaded may change the properties of
% objects that exist in the MATLAB workspace.
delete fname.mat   % removing the saved file

%%
% You can convert an analog input object to M-code using 
% the OBJ2MFILE command. By default, the resulting M-file
% will use the 'set' syntax for setting property values.
% 
% A MAT-file with the same name as the M-file will also be
% created if: 
% 
%  - You assign a value to the UserData property. 
%  - Any of the callback properties are defined as a cell array.
% 
% The MAT-file will contain the data stored by the UserData 
% property as well as the cell array stored by the callback 
% property.
obj2mfile(ai, 'fnameai');  % convert the ai object to M-code
%

%%
% The resulting M-file appears below. Note the first line  
% following the on-line help indicates the time the M-file 
% was created.
type fnameai.m

%%
% The object is recreated by typing the name of the M-file  
% at the MATLAB command prompt.
delete(ai);
ai = fnameai
%

%%
% You can pass a third input argument to OBJ2MFILE which  
% specifies the syntax used in the M-file. The possible 
% values are 'set', 'dot', and 'named'. The default 
% value is 'set'.
delete fnameai.m
delete fnameai.mat
obj2mfile(ai, 'fname', 'set');  % SET arguement used
type fname.m
%

%%
% Using the 'dot' notation:
delete fname.m
delete fname.mat
obj2mfile(ai, 'fname', 'dot');  % DOT arguement used
type fname.m
%

%%
% You can use the 'named' syntax only if the channel's  
% ChannelName property is defined. Otherwise, an error will
% occur.
delete fname.m
delete fname.mat
obj2mfile(ai, 'fname', 'named');  % NAMED arguement used
type fname.m
%

%%
% By default, the resulting M-file will contain the commands 
% for setting those properties which are not set to their 
% default values. If you would like the M-file to contain
% commands for each property, you can pass a fourth input 
% argument, 'all', to OBJ2MFILE.
delete fname.m
delete fname.mat
obj2mfile(ai, 'fname', 'dot', 'all');
type fname.m
%

%%
% It is also possible to convert only a channel to M-code 
% rather than the entire analog input object. 
% 
% For example, you can use the following commands to create  
% an M-file that includes only those channel properties not  
% set to their default values using the default 'set' notation.
delete fname.m
delete fname.mat
chan = ai.Channel;
obj2mfile(chan, 'fname');
type fname.m
%

%%
% If you wanted to create an M-file that defines all 
% properties using the 'named' syntax, the following 
% command is used.
delete fname.m
obj2mfile(chan, 'fnamechan', 'named', 'all');
type fnamechan.m
%

%%
% The channels are recreated by typing the name of the  
% M-file with an analog input object as an input argument
% at the MATLAB command prompt.
delete(ai);
ai = analoginput('winsound');
which fnamechan;
chan = fnamechan(ai)   % recreate the channel
%

%%
% Lastly, delete the analog input object and remove saved data acqusition
% files.
delete(ai)
delete fnamechan.m
