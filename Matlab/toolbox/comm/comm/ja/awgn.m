% AWGN  白色ガウスノイズを信号に付加
% Y = AWGN(X,SNR) は、白色ガウスノイズを X に付加します。SNR は、dB 単位
% で入力します。X のパワーは、0 dBW と仮定しています。X が複素数の場合、
% AWGN は複素数ノイズを付加します。
%
% Y = AWGN(X,SNR,SIGPOWER) は、SIGPOWER が数値の場合、信号のパワーを 
% dBW 単位で表し、SIGPOWER が 'measured'の場合、AWGN は、ノイズを付加する
% 前に、信号のパワーを測ります。
%
% Y = AWGN(X,SNR,SIGPOWER,STATE) は、RANDN の状態を STATE にリセットします。
%
% Y = AWGN(..., POWERTYPE) は、SNR と SIGPOWERの単位を設定します。
% POWERTYPE は、'db'、または、'linear' のいずれかを設定することができます。
% POWERTYPE が'db'の場合、SNRは、dB で測定され、SIGPOWERは、dBW で測定
% されます。 POWERTYPE が'linear'の場合、SNRは比として測定され、SIGPOWER  
% は、ワットで測定されます。
%
% 例題: X のパワーを0 dBW とし、10dB のSNR をもつようにノイズを付加します。
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0);
%
% 例題: X のパワーを0 dBW とし、RANDN のシードを1234と設定し、10dB のSNR を
%       もつようにノイズを付加します。
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,10,0,1234);
%
% 例題: X のパワーを3ワットに設定し、線形 SNR を4になるようにノイズを
%       付加します。
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,3,'linear');
%
% 例題: AWGN を使って、X のパワーを測定するために、RANDN のシードを1234と設定
%       し、線形 SNR を4になるようにノイズを付加します。
%            X = sqrt(2)*sin(0:pi/8:6*pi);
%            Y = AWGN(X,4,'measured',1234,'linear');
%
%   参考 WGN, RANDN.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:09 $ 
