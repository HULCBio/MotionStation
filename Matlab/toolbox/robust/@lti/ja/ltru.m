% LTRU 連続時間LQG/LTR制御シンセシス (プラント入力で)
%
% [ss_f,svl] = ltru(ss_,Kc,Xi,Th,r,w,svk)、または、
% [af,bf,cf,df,svl] = ltru(A,B,C,D,Kc,Xi,Th,r,w,svk) は、プラント入力に
% おいて、プラントノイズの無限大極限において、LQGループ伝達関数がLQSFル
% ープ伝達関数に収束するようなLQG/LTRを生成します。
% 
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> Kc(Is-A) B   (as r --> INF)
%
% 入力: システム(A,B,C,D)、または("mksys"で生成される)システム
%       行列ss_LQSF
%               Kc        -- ゲイン  
%  (オプション) svk(MIMO) -- (Kc inv(Is-A)B)の特異値
%  (オプション) svk(SISO) -- 完備ナイキストプロットの
%                            [re im;re(逆順) -im(逆順)]
%               w         -- 周波数点
%               Xi        -- プラントノイズの分散
%               Th        -- センサノイズの分散
%               r         -- リカバリゲインの集合を含む行ベクトル
%                            (nr: rの長さ)。 
%                            各イタレーションで、 Xi <-- Xi + r*B*B';
%  出力: svl       -- 全てのリカバリ点での特異値プロット
%        svl(SISO) -- ナイキスト軌跡 svl = [re(1:nr) im(1:nr)]
%        最終的な状態空間コントローラ (af,bf,cf,df).



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
