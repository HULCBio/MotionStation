%RESAMPLE  信号のサンプリングレートを変更します。
% このルーチンは、Signal Processing Toolboxを必要とします。
%
% DR = RESAMPLE(DATA,P,Q) は、オリジナルのサンプリングレートの P/Q 倍で
% IDDATA オブジェクト DATA をリサンプリングします。DR は IDDATA オブジェ
% クトで、DATA の P/Q 倍の長さの信号です。P/Q が整数でない場合、P/Q を正
% の無限大方向へ丸め (ceil(P/Q)) を行います。P と Q は、正の整数でなけれ
% ばいけません。リサンプリングは、(DATA.InterSampleに基づく)入力データ内
% 部のサンプリング手法に基づいて計算されます。
%
% RESAMPLE は、リサンプリング過程で、DATA にアンチエイリアス(ローパス)FIR
% フィルタを適用し、フィルタの遅延を補償します。DR = RESAMPLE(DATA,P,Q,N)
% と実行することで、フィルタ次数 N を指定できます。N の値を大きくすると、
% 精度は高くなりますが計算時間が長くなります。区分的線形入力や区分的定数入
% 力の内挿のためには、N = 0 にします。
%
% SIGNAL PROCESSING TOOLBOX のルーチン RESAMPLE が使用されます。詳細は、
% HELP RESAMPLE を参照してください。
%
% 類似のルーチンとして IDRESAMP があり、このルーチンでは、Signal Processing
% Toolbox を必要としません。
%
% 参考:  IDFILT


 

%   Copyright 1986-2001 The MathWorks, Inc.
