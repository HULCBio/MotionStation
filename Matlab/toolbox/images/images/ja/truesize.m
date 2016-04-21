% TRUESIZE   イメージの表現サイズを調整
%   TRUESIZE(FIG,[MROWS NCOLS]) は、イメージの表現サイズを調整します。
%   FIG は、1つのイメージを含む Figure か、または、カラーバーを伴った
%   イメージかのどちらかです。[MROWS MCOLS] は、イメージが占有するスク
%   リーン上の領域をピクセル単位で設定する1行2列のベクトルです。
%
%   TRUESIZE(FIG) は、イメージの高さと幅を、[MROWS MCOLS] を使って設定
%   します。各イメージピクセルがスクリーン上の1ピクセルとして表現され
%   ます。
%
%   Figure の引数を省略すると、TRUESIZE は、カレント Figure に作用しま
%   す。
%
%   注意
%   ----
%   ツールボックスの優先順位の 'Truesize Warning' が 'on' の場合、イ
%   メージがスクリーンに適合するには大きすぎるときに、TRUESIZE は、
%   ワーニングを表示します(イメージ全体は表示されますが、本来のサイズ
%   より小さくなります)。'TruesizeWarning' が'off' の場合、TRUESIZE は
%   ワーニングを表示しません。IMSHOW を使う場合のように、間接的に 
%   TRUESIZE を呼び出すときでさえ、この優先順位を適用するので注意して
%   ください。
%
%   参考：IMSHOW, IPTSETPREF, IPTGETPREF



%   Copyright 1993-2002 The MathWorks, Inc.
