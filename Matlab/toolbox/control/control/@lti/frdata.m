function [response,freq,Ts,Td] = frdata(sys,flag)
%FRDATA  Quick access to frequency response data.
%
%   [RESPONSE,FREQ] = FRDATA(SYS) returns the response data and
%   frequency samples of the frequency response data (FRD) model SYS.
%
%   For a single model SYS with Ny outputs and Nu inputs, at Nw frequencies,
%   RESPONSE is a Ny-by-Nu-by-Nw array where the (I,J,K) element specifies
%   the response from input J to output I at frequency FREQ(K).  FREQ
%   is a column vector of length Nw which contains the frequency
%   samples of the FRD.
%
%   [RESPONSE,FREQ,TS] = FRDATA(SYS) also returns the sample time TS.  Other
%   properties of SYS can be accessed with GET or by direct structure-like 
%   referencing (e.g., SYS.Ts)
%
%   For a single SISO model SYS, the syntax
%       [RESPONSE,FREQ] = FRDATA(SYS,'v')
%   returns the RESPONSE as a column vector rather than a
%   3-dimensional array.
%
%   For an S1-by-S2-...-by-Sn array SYS of FRD models, each with Ny outputs
%   and Nu inputs at Nw frequency points, RESPONSE is an array of size
%   [Ny Nu Nw S1 S2 ... Sn], where RESPONSE(:,:,K,p1,p2,...,pn)
%   specifies the reponse of the model SYS(:,:,p1,p2,...,pn) at frequency
%   FREQ(K).
%
%   See also FRD, GET, LTIMODELS, LTIPROPS.

%       Author(s): P. Gahinet, S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.7 $  $Date: 2002/04/10 05:50:55 $

error('FRDATA is applicable to FRD models only.');