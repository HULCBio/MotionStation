% MARCUMQ   ��ʉ� Marcum Q �֐�
%
% MARCUMQ(A,B,M) �́A���̂悤�ɒ�`������ʉ� Marcum Q �֐��ł��B
%
%      Q_m(a,b) = 1/a^(m-1) * integral from b to inf of
%                 [x^m * exp(-(x^2+a^2)/2) * I_(m-1)(ax)] dx
%
% a,b �� m �́A�����ŁA�񕉂ł��Bm �͐����ł��B
%
% MARCUMQ(A,B) �́A���Ƃ��ƁAMarcum �ɂ��ꗗ�ɂ��ꂽ���̂ŁAM = 1 ��
% �΂��ē��ʂȂ��̂ł��B�����āA���΂��΁A�T�u�X�N���v�g�Ȃ��� Q(a,b) ��
% �L�q����邱�Ƃ�����܂��B


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:59 $
