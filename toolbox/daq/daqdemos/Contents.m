% Data Acquisition Toolbox - Data Acquisition Demos.
%
% Data acquisition demos.
%   daqschool        - Launch command line Data Acquisition Toolbox tutorials.
%   demodaq_callback - Introduction to data acquisition callback functions.
%   demodaq_intro    - Introduction to Data Acquisition Toolbox.
%   demodaq_save     - Methods for saving and loading data acquisition objects.
%   daqtimerplot     - Example callback function that plots the data acquired.
%
% Analog input demos.
%   daqrecord        - Record data from the specified adaptor.
%   demoai_channel   - Introduction to analog input channels.
%   demoai_fft       - FFT display of an incoming analog input signal.
%   demoai_intro     - Introduction to analog input objects.
%   demoai_logging   - Demonstrate data logging.
%   demoai_trig      - Demonstrate the use of immediate, manual and software 
%                      triggers.
%   daqscope         - Example oscilloscope for the Data Acquisition Toolbox.
%   
% Analog output demos.
%   daqplay          - Output data to the specified adaptor.
%   daqsong          - Output data from HANDEL.MAT to a sound card.
%   demoao_channel   - Introduction to analog output channels.
%   demoao_intro     - Introduction to analog output objects.
%   demoao_trig      - Demonstrate the use of immediate and manual triggers.
%   daqfcngen        - Example function generator for the Data Acquisition 
%                      Toolbox.
%
% Digital I/O demos.
%    demodio_intro   - Introduction to digital I/O objects.
%    demodio_line    - Introduction to digital I/O lines.
%    diopanel        - Display digital I/O panel.
%
% Documentation examples.
%    daqdoc3_1       - Configure an analog input object and use GETDATA.
%    daqdoc4_1       - Configure an analog input object, use GETDATA, and
%                      perform a fft on acquired data.
%    daqdoc4_2       - Configure an analog input object, use GETDATA, and
%                      perform a fft on acquired data.
%    daqdoc5_1       - Display analog input data using polling and PEEKDATA.
%    daqdoc5_2       - Display analog input data using polling, PEEKDATA, and
%                      GETDATA.
%    daqdoc5_3       - Configure analog input software trigger.
%    daqdoc5_4       - Configure analog input software trigger with delay.
%    daqdoc5_5       - Configure analog input repeating software trigger.
%    daqdoc5_6       - Demonstrate callback properties with a repeating trigger.
%    daqdoc5_7       - Configure TimerFcn and TimerPeriod to display data.
%    daqdoc5_8       - Configure analog input engineering units properties.
%    daqdoc6_1       - Configure analog output object and use PUTDATA.
%    daqdoc6_2       - Configure analog output object and use PUTDATA.
%    daqdoc6_3       - Configure analog output object to send data repeatedly.
%    daqdoc6_4       - Configure analog output callback properties.
%    daqdoc6_5       - Configure analog output callback properties.
%    daqdoc6_6       - Configure analog output engineering units properties.
%    daqdoc7_1       - Configure digital I/O object to write and read values.
%    daqdoc7_2       - Configure digital I/O object to generate timer events.
%    daqdoc8_1       - Demonstrate DAQREAD.
%    daqdocfft       - Calculate the fft of data input.
%
% See also ANALOGINPUT, ANALOGOUTPUT, DIGITALIO.
%

% MP 5-29-98
% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.11.2.5 $  $Date: 2003/08/29 04:44:43 $
