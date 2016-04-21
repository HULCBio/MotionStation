%BLUETOOTH_INIT Initializes variables for Bluetooth Voice Transmission
% demo (bluetooth_voice.mdl)

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $  $Date: 2004/04/12 23:01:33 $

% Set input wave sample rate to be 8kHz
Input_Fs=8000;
sigin = wavread('bluetooth_input.wav');

% Coefficients for speech interpolation
[y,interp_coeffs]=interp(ones(1,10),8);

% Header Information 
% Header_Info=[Slave_Address;Packet_Type;Flow_Control;ARQ;Sequence];
Slave_Address= [1 0 1]';
Packet_Type= [1 0 1 0]';
Flow_Control= [1];
ARQ=[1];
Sequence=[1];
Access_Code=zeros(72,1); Access_Code(1:2:72)=1;

% Initialize 1,0,1,0, sequence
One_Zero_Payload=zeros(240,1);
One_Zero_Payload(1:2:240)=1;

% Set Seeds
hop_seed=randseed(1);
awgn_channel_seed=randseed(2);
awgn_802_seed=randseed(3);
rate_802_seed=randseed(4);
data_seed=randseed(5);

% Hop frequency if fixed
fixed_hop_freq=20;

% Assign payload bits
Num_Payload_Bits=80;




