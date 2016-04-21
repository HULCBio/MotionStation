% CWT 　　連続1次元ウェーブレット係数
% COEFS = CWT(S,SCALES,'wname') は、引数 'wname' で設定したウェーブレットを使っ
% て、実数、正の SCALES に対する入力ベクトル S の連続ウェーブレット係数を計算し
% ます。
%
% COEFS = CWT(S,SCALES,'wname','plot') は、連続ウェーブレット変換係数を計算し、
% さらにプロット表示します。
%
% COEFS = CWT(S,SCALES,'wname',PLOTMODE) は、連続ウェーブレット変換係数を計算し、
% さらにプロット表示します。係数は、PLOTMODE を使って、カラー表示を行います。
% 
%   PLOTMODE = 'lvl' (スケール毎) または、
%   PLOTMODE = 'glb' (すべてのスケール) または、
%   PLOTMODE = 'abslvl'、または、'lvlabs'(絶対値及びスケール毎)
%   PLOTMODE = 'absglb'、または、'glbabs'(絶対値及びすべてのスケール)
%
% CWT(...,'plot') は、CWT(...,'absglb') と同義です。
%
% COEFS = CWT(S,SCALES,'WNAME',PLOTMODE,XLIM) は、連続ウェーブレット変換係数を計
% 算し、プロット表示します。係数は、XLIM = [L R],1 < = L 及び R < = length(S) の
% 範囲で、PLOTMODE により色付けされます。
%
% a = SCALES(i) の場合、b = 1 から ls = length(S) の範囲でウェーブレット係数 
% C(a,b) が計算され、与えられた SCALE ベクトルの順番で COEFS(i,:) に記憶されま
% す。出力引数 COEFS は、la 行 ls 列の行列で、ここで、la は、SCALES の長さを指
% しています。
%
% 例題:適切な使用例を以下に記載しておきます。
%      t = linspace(-1,1,512);
%      s = 1-abs(t);
%      c = CWT(s,1:32,'meyr');
%      c = CWT(s,[64 32 16:-2:2],'morl');
%      c = CWT(s,[3 18 12.9 7 1.5],'db2');
%
% 参考： WAVEDEC, WAVEFUN, WAVEINFO, WCODEMAT.



%   Copyright 1995-2002 The MathWorks, Inc.
