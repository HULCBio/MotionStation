function S = freqresp(LoopData,w)
%FREQRESP  Computes the frequency responses of P,H and
%          of the normalized compensators F and C.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 04:53:54 $

% RE: W assumed in rad/sec
Gr = freqresp(LoopData.Plant.zpk,w);
Hr = freqresp(LoopData.Sensor.zpk,w);
Fr = freqresp(zpk(LoopData.Filter,'norm'),w);
Cr = freqresp(zpk(LoopData.Compensator,'norm'),w);
S = struct('G',Gr(:),'H',Hr(:),'F',Fr(:),'C',Cr(:));
	