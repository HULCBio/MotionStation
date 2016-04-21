function varargout=addmuxchannel(object,chanIDs)
%ADDMUXCHANNEL Add channels when using MUX boards.
%
%    ADDMUXCHANNEL(OBJECT) adds as many channels to OBJECT as
%    is physically possible based on the number of multiplexer
%    boards associated with the National Instruments' analog input
%    object.  For 1 Mux board, 64 channels are available.  For 2
%    boards, 128 channels are available and for 4 boards 256 channels
%    are available.
%
%    ADDMUXCHANNEL(OBJECT,CHANIDS) adds as many channels as are
%    specified by CHANIDS.  CHANIDS refers to the channel IDs on the 
%    MIO board itself.  This means that for one Mux board, adding
%    channel ID 0 will actually add 4 channels.  Please refer to the AMUX-64T 
%    User Manual for more information on what Mux channels can be added based  
%    on what channel IDs are requested and the number of Mux boards associated 
%    with the hardware.
%
%    CHANNELS=ADDMUXCHANNEL(...) returns the handle to every channel that was
%    added.
%
%    Notes:
%    1) When calling this function, any existing channels on the object are deleted
%       before new channels are created.
%    2) The OBJECT's NumMuxBoard property must be set to a value between 1 and 4
%       before calling this function.
%
%    See also MUXCHANIDX.

%   LPD
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.4 $  $Date: 2003/08/29 04:39:24 $

ArgChkMsg = nargchk(1,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:addmuxchannel:argcheck', ArgChkMsg);
end

if ~isa(object,'analoginput') | ~strcmp(daqhwinfo(object,'AdaptorName'),'nidaq'),
   error('daq:addmuxchannel:invalidadaptor', 'ADDMUXCHANNEL only works with National Instruments'' AnalogInput objects.');
end

inputType=get(object,'InputType');
if strcmp(lower(inputType),'differential'),
   maxChanID=7;
else
   maxChanID=15;
end
if nargin==1,
   if strcmp(lower(inputType),'differential'),
      chanIDs=0:7;
   else
      chanIDs=0:15;
   end
else
    if ~isa(chanIDs,'double') || isempty(chanIDs),
        error('daq:addmuxchannel:invalidchannel',  'CHANIDs must be a vector of unique integer values between 0 and 7 (differential)/ 15 (single-ended).')
    end
end

chanIDs=floor(chanIDs);
if any(chanIDs>maxChanID | chanIDs<0) || (length(chanIDs)~=length(unique(chanIDs))),
    error('daq:addmuxchannel:invalidchannel', 'CHANIDs must be a vector of unique integer values between 0 and 7 (differential)/ 15 (single-ended).')
end

numMux=get(object,'NumMuxBoards');

if numMux==0,
    error('daq:addmuxchannel:invalidnummux', 'NumMuxBoards value must be between 1 and 4.');
end

ct=0;

for outLp=1:length(chanIDs),
   for inLp=1:4*numMux,
      ct=ct+1;
      %muxChan=rem(inLp-1,4);
      switch floor((inLp-1)/4)
      case 0,
         %val=(chanIDs(outLp))*4+muxChan;
         val=(chanIDs(outLp))*4+inLp-1;
         mux='1';
      case 1,
         %val=(chanIDs(outLp))*4+muxChan+64;
         val=(chanIDs(outLp))*4+inLp-5;
         mux='2';
      case 2,
         %val=(chanIDs(outLp))*4+muxChan+128;
         val=(chanIDs(outLp))*4+inLp-9;
         mux='3';
      case 3,
         %val=(chanIDs(outLp))*4+muxChan+192;
         val=(chanIDs(outLp))*4+inLp-13;
         mux='4';
      end
      %name=['MuxChan_' int2str(chanIDs(outLp)) '_' int2str(val)];
      muxChanIDs(ct,1)=outLp-1;
	   name{ct,1}=['Mux_' mux '_Chan_' int2str(val)];
      
   end
end

delete(get(object,'Channel'));
addchannel(object,muxChanIDs,name);

if nargout,
   varargout{1}=get(object,'Channel');
end
