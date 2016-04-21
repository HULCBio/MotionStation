% INTERPN   N�������(table lookup)
% 
% VI = INTERPN(X1,X2,X3,...,V,Y1,Y2,Y3,...) �́A�z�� Y1, Y2, Y3...�̓_��
% N�����֐� V �̒l VI �����߂邽�߂ɕ�Ԃ��s���܂��BN�����z�� V �ɑ΂��āA
% INTERPN �� 2*N+1�̈������g���ČĂяo����܂��B�z�� X1, X2, X3...�́A
% �f�[�^ V ���^������_���w�肵�܂��B�͈͊O�̒l�́ANaN�Ƃ��ďo�͂���
% �܂��BY1, Y2, Y3...�́A�����T�C�Y�̔z��܂��̓x�N�g���łȂ���΂Ȃ�܂���B
% �x�N�g�������������T�C�Y�łȂ��A���������݂���(�� �s�x�N�g���Ɨ�x�N�g��)
% �ꍇ�́AMESHGRID �ɓn����A�z��Y1, Y2, Y3 ���쐬���܂��BINTERPN �́A
% 2�����ȏ��N�����z��ɑ΂��ċ@�\���܂��B
%
% VI = INTERPN(V,Y1,Y2,Y3,...) �́AX1 = 1:SIZE(V,1),X2 = 1:SIZE(V,2)...��
% ���肵�܂��BVI = INTERPN(V,NTIMES) �́A�ċA�I�� NTIMES ��A�v�f�Ԃ�
% ��Ԃ��J��Ԃ����Ƃɂ��AV ���g�����܂��B
% VI = INTERPN(V) �́AINTERPN(V,1) �Ɠ����ł��B
%
% VI = INTERPN(...,'method') �́A��Ԏ�@���w�肵�܂��B�f�t�H���g�́A
% ���`��Ԃł��B�g�p�\�Ȏ�@�͈ȉ��̒ʂ�ł��B
% 
%   'linear'  - ���`���
%   'cubic'   - �L���[�r�b�N���
%   'nearest' - �ŋߖT�_�ɂ����
%   'spline'  - �X�v���C�����
%   
% VI = INTERPN(...,'method',EXTRAPVAL) �́AX1,X2,... �ō쐬���ꂽ�̈�̊O����
% VI �̗v�f�ɑ΂��Ďg�p����O�}�@�ƒl���w�肷��̂Ɏg���܂��B�������āAVI ��
% X1,X2,... �̂��ꂼ��ɂ��쐬����Ă��Ȃ��AY1,Y2,.. �̂����ꂩ�̒l�ɂ��� 
% EXTRAPVAL �ɓ������Ȃ�܂��B�g�p����� EXTRAPVAL �ɑ΂��āA���\�b�h���w�肳��
% �Ȃ���΂Ȃ�܂���B�f�t�H���g�̃��\�b�h�� 'linear' �ł��B
%
% INTERPN�́AX1, X2, X3...���P���֐��ŁA(NDGRID �ō쐬�������̂Ɠ��l
% ��)�i�q�`�łȂ���΂Ȃ�܂���BX1, X2, X3...�́A���Ԋu�łȂ��ꍇ��
% ����܂��B
%
% �f�[�^���͂̃T�|�[�g�N���X: 
%      float: double, single
%
% �Q�l INTERP1, INTERP2, INTERP3, NDGRID.

%   Copyright 1984-2004 The MathWorks, Inc.

