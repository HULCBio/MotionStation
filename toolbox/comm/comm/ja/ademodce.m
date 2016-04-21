% ADEMODCE    アナログベースバンド復調
%
% Z = ADEMODCE(Y, Fs, METHOD...) は、変調信号の複素包絡線 Y を復調します。
% Y の標本化周波数は、Fs (Hz)です。METHOD とそれ以降に配置しているパラ
% メータについての情報と、特定の復調法の使用方法について情報を得るには、
% MATLABプロンプトで、つぎのいずれかのコマンドを入力してください。
% 
%     詳細はタイプしてください  復調法
%     ademod amdsb-tc           % 伝送搬送波を伴う両側波帯振幅復調
%     ademod amdsb-sc           % 両側波帯搬送波抑圧振幅復調
%     ademod amssb              % 単側搬送波抑圧振幅復調
%     ademod qam                % 直交振幅復調
%     ademod fm                 % 周波数復調
%     ademod pm                 % 位相復調
%
% 参考： AMODCE, DMODCE, DDEMODCE, AMOD, ADEMOD.


%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.6.4.1 $
%       This function calls ademodce.hlp for further help.
