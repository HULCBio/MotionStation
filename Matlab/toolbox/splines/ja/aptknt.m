% APTKNT   �K�؂Ȑߓ_��
%
% APTKNT(TAU,K) �́A���ׂĂ� i �ɂ��āATAU(i) < TAU(i+K-1) �ƂȂ�^��
% ��ꂽ�񌸏��Ȑߓ_�� KNOTS ��Ԃ��܂��BKNOTS ��Schoenberg-Whitney����
%
%            KNOTS(i) <  TAU(i)  <  KNOTS(i+K) , i=1:length(TAU)
%
% �𖞂����܂�(�������A�ŏ��ƍŌ�̐ߓ_�ɑ΂��Ă͓����֌W�ƂȂ�܂�)�B
% ����ɂ���āA�ߓ_�� KNOTS �𔺂�K���̃X�v���C����Ԃ��A�f�[�^�T�C�g 
% TAU �ɂ�����C�ӂ̃f�[�^�ɑ΂��Ĉ�ӂȕ�Ԃ������Ƃ��ۏ؂���܂��B
% ������ K �͂��̂悤�ɗ^�����܂��B
%              K  :=  min(K,length(TAU))  
%
% �Ⴆ�΁A�����ɑ������� x �ƑΉ����� y ��^�����ꍇ�A
%
%      sp = spapi(aptknt(x,k),x,y);
%
% �́A���ׂĂ� i �� f(x(i)) = y(i) �𖞂������� min(k,length(x)) ��
% �X�v���C�� f ��^���܂�(�܂��A�������ʂ� spapi(k,x,y) �ɂ���Ă�����
% ��܂�)�B
% �������Ȃ���A�ɂ߂ĕs�ϓ��� x �ɑ΂��āA���̃X�v���C���̌��肪�K�؂�
% �������ꂸ�ɕ�ԓ_���痣�ꂽ���ɂ������ȋ����ɂȂ��肤�邱�Ƃ�
% ���ӂ��Ă��������B
%
% �����_�ł́A�����őI�����ꂽ�ߓ_��́AOPTKNT �� '�œK��' �ߓ_�̌J��
% �Ԃ������肷�邽�߂Ɏg��ꂽ��������ł��B
%
% �Q�l : AUGKNT, AVEKNT, NEWKNT, OPTKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
