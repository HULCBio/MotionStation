% SOUNDSC   音声としてのベクトルのスケーリングと再生
% 
% SOUNDSC(Y,...) は、データが切り取られずに可能な限り大きい音で再生される
% ように、スケーリングされることを除けば、SOUND(Y,...) と同じです。データ
% の平均値を、データから除去します。
%
% SOUNDSC(Y,...,SLIM)は、SLIM = [SLOW SHIGH] のとき、SLOW と SHIGH の間の 
% Yの値を、[-1,1] の範囲全体に写像します。この範囲外のものは、取り込みません。
% デフォルト値は、SLIM = [MIN(Y) MAX(Y)] です。
%
% 参考：SOUND, WAVPLAY, WAVRECORD.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:45:14 $

