% LTRY 連続時間LQG/LTR制御シンセシス (プラント出力で).
%
% [ss_f,svl] = ltry(ss_,Kf,Q,R,q,w,svk)、または、
% [af,bf,cf,df,svl] = ltry(A,B,C,D,Kf,Q,R,q,w,svk) は、プラント出力にお
% いて、状態 wtの無限大極限において、LQGループ伝達関数がKBFループ伝達関
% 数に収束するようなLQG/LTRを生成します。
% 
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> C(Is-A) Kf   (as q ---> INF)
%
% 入力: システム(A,B,C,D)、または("mksys"で生成される)システム行列ss_    
% 
%               Kf        -- カルマンフィルタゲイン
%  (オプション) svk(MIMO) -- (C inv(Is-A)Kf)の特異値
%  (オプション) svk(SISO) -- 完備ナイキストプロットの
%                            [re im;re(逆順) -im(逆順)]
%               w --- 周波数点
%               Q --- 状態重み, R -- 制御重み
%               q --- リカバリゲインの集合を含む行ベクトル
%                    (nq: qの長さ). 
%                     各イタレーションで、 Q <-- Q + q*C'*C;
%  出力: svl       -- 全てのリカバリ点での特異値プロット
%        svl(SISO) -- ナイキスト軌跡 svl = [re(1:nq) im(1:nq)]
%        最終的な状態空間コントローラ (af,bf,cf,df).
%



% Copyright 1988-2002 The MathWorks, Inc. 
