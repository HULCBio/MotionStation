%% Introduction to analog input objects.
%    DEMOAI_INTRO illustrates a basic data acquisition session using
%    an analog input object.  This is demonstrated by configuring
%    analog input properties, adding a channel to the analog input 
%    object and acquiring and plotting data from the analog input object.
% 
%    See also ANALOGINPUT, ADDCHANNEL, GETDATA, PEEKDATA, DAQDEVICE/SET,
%             DAQDEVICE/GET, DAQDEVICE/START, STOP, DAQHELP, PROPINFO.
%
%    LD 4-19-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.8.2.6 $  $Date: 2004/03/30 13:03:56 $

%%
% First find any open DAQ objects and stop them.
openDAQ=daqfind;
for i=1:length(openDAQ),
  stop(openDAQ(i));
end

%%
% In this example you will acquire data from the sound card on your
% computer.  To get started, you first need to verify that your environment
% is set up so that you can record data with your sound card. If you are
% unsure about this, refer to Appendix A of the Data Acquisition Toolbox
% User's Guide.

%%
% To acquire data from your sound card, you need a data source, a data
% sensor, and a data sink. 
% In this demonstration:
% 
% The data source - is the sound input to the  sound card. This sound 
% can come from a variety of sources including your voice, your hands 
% clapping, or a CD in your computer. 
% 
% The sensor - is a microphone on  your computer and 
% 
% The sink - is a channel associated with an analog input object.  
% 
% Now let's create an analog input object and add a single channel to it. 
ai = analoginput('winsound');
addchannel(ai, 1);

%%
% Now, let's set up the analog input object so that we acquire 5 seconds of 
% data at 8000 Hz as soon as the object is started. 
ai.SampleRate = 8000;
ai.SamplesPerTrigger = 40000;
ai.TriggerType = 'Immediate';

%%
% With the analog input object set up, let's start it and then get the data
% that it collects. If your sound card is set up to collect data from the 
% microphone, then you should whistle or clap you hands just after you
% continue to the next demo screen. This will introduce something other
% than random noise into the data you are collecting. 
start(ai)
[d,t] = getdata(ai);

%%
% Now that you're done collecting data, plot it.
plot(t,d);
zoom on

%%
% Previously, you used the GETDATA function to collect 5 seconds of data.
% The only  problem is that GETDATA is a "blocking" function. This means
% that it will wait until all 5 seconds of data have been collected. For
% many applications, this is not what you want. The solution to this is to
% use the PEEKDATA function. For this example, let's configure an
% unlimited number of triggers and use PEEKDATA to see what is happening. 
ai.TriggerRepeat = inf;
start(ai);
pause(0.3);
pd1 = peekdata(ai,8000);
pause(0.3);
pd2 = peekdata(ai,8000);
pause(0.3);
pd3 = peekdata(ai,8000);
%

%%
% Notice that the PEEKDATA function didn't block and that it returns only
% data that is available. We asked for 8000 samples but did not
% necessarily get that many.
whos pd1 pd2 pd3

%%
% This completes the introduction to analog input objects. Since the analog
% input object is no longer needed, you should:
%
% First stop the analog input object from running using the STOP command.
% Lastly, delete it with the DELETE command to free memory and other 
% physical resources. 
stop(ai);
delete(ai);

