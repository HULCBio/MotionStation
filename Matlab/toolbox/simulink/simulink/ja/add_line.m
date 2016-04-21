% ADD_LINE   Simulinkシステムにラインを付加
%
% ADD_LINE('SYS','OPORT','IPORT') は、システムに対する直線を、指定したブロッ
% ク出力端子'OPORT'から指定したブロック入力端子'IPORT'に追加します。'
% OPORT'と 'IPORT' は、ブロック名と端子識別子から構成される 'block/port' 形
% 式の文字列です。ほとんどのブロック端子は、'Gain/1'や'Sum/2'のように、上から
% 下または左から右に番号付けすることによって識別します。Enable,Trigger,
% State端子は、'subsystem_name/Enable'や 'Integrator/State'のように名前で識
% 別されます。
%
% ADD_LINE('SYS',POINTS) は、セグメント化したラインをシステムに付加します。
% POINTS 配列の各行は、ラインセグメント上の点のx座標とy座標を指定します。
% 原点は、ウィンドウの左上隅にあります。
% 信号は、最初の行で定義した点から最終行で定義した点まで流れます。
% 新しいラインの開始が既存のラインの出力またはブロックに近い場合に接続が行
% われます。同様に、ラインの終端が既存の入力に近い場合に接続が行われます。
%
% ADD_LINE('SYS','OPORT','IPORT', 'AUTOROUTING','ON') は、ADD_LINE('SYS','
% OPORT','IPORT') と同様に、任意のブロックを回り込むように直線で結線します。
% デフォルトは 'off' です。
%
% 例題:
%
% add_line('mymodel','Sine Wave/1','Mux/1')
%
% は、Sine Waveブロックの出力とMuxブロックの最初の入力を、間のブロックを
% mymodelシステムにラインを追加します。
%
% add_line('mymodel','Sine Wave/1','Mux/1','autorouting','on')
%
% は、Sine Waveブロックの出力とMuxブロックの最初の入力を、間のブロックを
% 回り込むように直線で結線して接続するように、mymodel システムにラインを
% 追加します。
%
% add_line('mymodel',[20 55; 40 10; 60 60])
%
% は、(20,55)から(40,10),(60,60)まで伸びるラインをmymodelシステムに追加 しま
% す。(60,60).
%
%
% 参考 : DELETE_LINE.


% Copyright 1990-2002 The MathWorks, Inc.
