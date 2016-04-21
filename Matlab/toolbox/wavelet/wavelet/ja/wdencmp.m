% WDENCMP 　ウェーブレットを使った雑音除去または圧縮
% WDENCMP は、ウェーブレットを使って、信号またはイメージの雑音除去または圧縮処理
% を行います。
%
% [XC,CXC,LXC,PERF0,PERFL2] = WDENCMP('gbl',X,'wname',N,THR,SORH,KEEPAPP) は、グ
% ローバルな正のスレッシュホールド値 THR を使って、スレッシュホールド処理したウ
% ェーブレット係数により得られた入力信号X(1次元または2次元)の雑音除去または圧縮
% されたバージョン XC を出力します。付加的な出力引数 [CXC,LXC] は、XC のウェーブ
% レット分解構造です。PERFO や PERFL2 は、L^2 回復や圧縮スコアを % で表示したも
% のです。[C,L] が、X のウェーブレット分解構造を定義している場合、PERFL2 = ...
% 100*(CXC のベクトルノルム/C のベクトルノルム)^2 が成立します。
% ウェーブレット分解は、レベル N で実行され、'wname' は、ウェーブレット名を含む
% 文字列です。また、SORH ('s' または 'h') は、ソフトスレッシュホールドか、ハード
% スレッシュホールドを行うものです(詳細は、WTHRESH を参照)。KEEPAPP = 1 の場合、
% Approximation 係数にはスレッシュホールドが適用されず、他の場合は適用されます。
%
% WDENCMP('gbl',C,L,W,N,THR,SORH,KEEPAPP) は、上述のものと同じオプションを使って、
% 同じ出力引数を出力します。しかし、ウェーブレット 'wname' を使って、レベル N で
% 雑音除去または圧縮された信号の入力ウェーブレット分解構造 [C,L] から直接得るこ
% とができます。
%
% 1次元で、'lvd' オプションの場合：
% WDENCMP('lvd',X、'wname',N,THR,SORH)、または、WDENCMP('lvd',C,L、'wname',...
% N,THR,SORH) は、上述のオプションを使って、同じ出力引数を出力しますが、ベクトル
% THR に含まれるレベルに依存したスレッシュホールドを用いることができます(THR は
% 長さが N です)。また、Approximation には適用されません。
%
% 2次元で、'lvd' オプションの場合:
% WDENCMP('lvd',X、'wname',N,THR,SORH)、または、WDENCMP('lvd',C,L、'wname',...
% N,THR,SORH) は、THR は、3方向、水平、対角、垂直に関するレベルに依存するスレッ
% シュホールド値を含む3行 N 列の行列です。
%
% 参考： DDENCMP, WAVEDEC, WAVEDEC2, WDEN, WPDENCMP, WTHRESH.



%   Copyright 1995-2002 The MathWorks, Inc.
