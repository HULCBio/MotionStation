% APTKNT   適切な節点列
%
% APTKNT(TAU,K) は、すべての i について、TAU(i) < TAU(i+K-1) となる与え
% られた非減少な節点列 KNOTS を返します。KNOTS はSchoenberg-Whitney条件
%
%            KNOTS(i) <  TAU(i)  <  KNOTS(i+K) , i=1:length(TAU)
%
% を満たします(ただし、最初と最後の節点に対しては等号関係となります)。
% これによって、節点列 KNOTS を伴うK次のスプライン空間が、データサイト 
% TAU における任意のデータに対して一意な補間をもつことが保証されます。
% ここで K はつぎのように与えられます。
%              K  :=  min(K,length(TAU))  
%
% 例えば、厳密に増加する x と対応する y を与えた場合、
%
%      sp = spapi(aptknt(x,k),x,y);
%
% は、すべての i で f(x(i)) = y(i) を満たす次数 min(k,length(x)) の
% スプライン f を与えます(また、同じ結果は spapi(k,x,y) によっても得ら
% れます)。
% しかしながら、極めて不均等な x に対して、このスプラインの決定が適切に
% 調整されずに補間点から離れた非常におかしな挙動につながりうることに
% 注意してください。
%
% 現時点では、ここで選択された節点列は、OPTKNT の '最適な' 節点の繰り
% 返しを決定するために使われた初期推定です。
%
% 参考 : AUGKNT, AVEKNT, NEWKNT, OPTKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
