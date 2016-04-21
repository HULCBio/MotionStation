% FREQZPLOT は、周波数応答データをプロットします。
% FREQZPLOT(H,W) は、ベクトルW(ラジアン/サンプル)で設定した周波数で計算
% した周波数応答をプロットします。H が行列の場合、FREQZPLOT は、H の列
% に適用され、各列単位で一つの周波数応答を作成します。周波数ベクトル W
% の長さは、行列 H の行数と同じになります。
%   
% FREQZPLOT(H,W,S) は、種々のプロットオプションで変更可能な付加的なプロ
% ット操作情報を指定します。H, W, S は、[H,W,S] = FREQZ(B,A,...) から得
% られます。
%
% S は、つぎのプロット操作オプションをもつ構造体です。
%
%   S.XUNITS: (文字列) - プロット用の周波数(x-軸)の単位
%                        'rad/sample' (デフォルト), 'Hz', 'kHz', 'MHz',
%                        'GHz', あるいは、ユーザ設定文字列のいずれか
%
%   S.YUNITS: (文字列) - プロット用のゲイン(y-軸)の単位
%                        'db' (デフォルト), 'linear', 'squared'
%                        のいずれか
%
%   S.PLOT:   (文字列) - プロットタイプ。'both' (デフォルト), 'mag',
%                        'phase' のいずれか
%
%   S.YPHASE: (文字列) - 位相に対するy軸のスケール
%                        'degrees'(デフォルト)、あるいは、'radians'
%                        のいずれか
%
%   STRを上述の文字列オプションとして、FREQZPLOT(H,W,STR)は、
%   プロットの1つのオプションを指定する、簡単な方法です。
%   たとえば、FREQZPLOT(H,W,'mag')は、振幅のみプロットします。
%
% 例題：
%      nfft = 512; Fs = 44.1; % Fs は、kHz 単位
%      [b1,a1]  = cheby1(5,0.4,0.5);
%      [b2,a2]  = cheby1(5,0.5,0.5);
%      [h1,f,s] = freqz(b1,a1,nfft,Fs);
%      h2       = freqz(b2,a2,nfft,Fs);  % 同じ nfft と Fs を使用
%      h = [h1 h2];
%      s.plot   = 'mag';     % ゲインプロットのみ
%      s.xunits = 'khz';     % 周波数の単位のラベル化
%      s.yunits = 'squared'; % ゲインの二乗のプロット
%      freqzplot(h,f,s);     % 2つの Chebyshev フィルタの応答の比較
%
% 参考：FREQZ, INVFREQZ, FREQS, GRPDELAY.



%   Copyright 1988-2002 The MathWorks, Inc.
