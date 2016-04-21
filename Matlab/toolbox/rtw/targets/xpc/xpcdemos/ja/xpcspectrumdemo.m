% XPCSPECTRUMDEMO xPC Targetを使用してスペクトルアナライザのデモを使用する方法
%
%   スペクトルアナライザのデモは、Simulink モデルファイルxpcdspspectrum.mdl
%   に含まれています。このデモを使用するためには、DSP blocksetが必要です。
%   さらに、TargetScopeを動作可能とした状態で、xPC Target PCが動作している
%   必要があります 。
%
%   デモは、512サンプルのバッファを使用して、入力信号の高速Fourier変換
%   (FFT)を表示することにより、スペクトルアナライザを模倣します。 
%   入力信号は、2つの正弦波の重ね合わせで、1つは、振幅0.6で周波数250 Hzであり、
%   もう一方は、振幅0.25で周波数600 Hzです。その結果、xPC Target PC モニタ上
%   に、タイプTargetのスコープを表示します。
%
%   MATLAB コマンドラインでつぎのように入力して、スペクトルアナライザのデモを、
%　 開くことができます。
%   >> xpcdspspectrum
%　 Simulink WindowからTools|Real-Time Workshop|Buildを選択して、このモデルを、
%   ビルドし、ターゲットPCにダウンロードすることができます。これにより、
%   さらに、MATLAB ワークスペースで、'tg' と呼ばれる変数が作成されます。
%   これは、ターゲットアプリケーションと通信するために使用されるxpcオブジェクト
%   です。
%
%   その後、つぎのように入力できます
%   >> start(tg)
%   コマンドラインMATLAB で、アプリケーションを起動し、入力信号の周波数スペクト
%   ルを表示します。
%
%   つぎのコマンド
%
%   >> s1amp = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Amplitude');
%   >> s1fre = getparamid(tg, ...
%               'Sine Wave f=250Hz, amp= 0.6', 'Frequency');
%   >> s2amp = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Amplitude');
%   >> s2fre = getparamid(tg, ...
%               'Sine Wave f=600Hz, amp= 0.25', 'Frequency');
%
%   を実行し、さらに、つぎのコマンド
%   >> set(tg, s1amp, 0.3);
%   >> set(tg, s1fre, 300);
%   >> set(tg, s2amp, 0.55);
%   >> set(tg, s2fre, 500);
%   を使用することにより、入力信号パラメータを、アプリケーションの実行中に
%   変えることができます。こうして、変化する信号を、リアルタイムで、モニタ
%　 することが可能になります。コマンドsetは、振幅と周波数を変えて、シミュレ
%   ーションを繰り返すことを可能にします。
%
%   'xPC Target Spectrum Scope' ブロックの詳細は、ブロック上を右クリックし、
%   'Look under mask'を選択することにより、調べられます。これにより、どのように
% 　スペクトルアナライザの機能が達成されるかが示されます。



%   Copyright (c) 1996-2000 The MathWorks, Inc. All Rights Reserved.
