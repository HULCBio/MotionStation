% INTERP2   2�������(table lookup)
% 
% ZI = INTERP2(X,Y,Z,XI,YI) �́A�s�� XI �� YI ���̓_��2�����֐� Z �̒l 
% ZI �����߂邽�߂ɕ�Ԃ��s���܂��B�s�� X �� Y �́A�f�[�^ Z ���^������
% �_���w�肵�܂��B
%
% XI �́A�s�x�N�g���ł��\���܂���B���̏ꍇ�A��v�f�����̒l�ł���s���
% �l�����܂��B���l�ɁAYI �͗�x�N�g���ł��\�킸�A�s�v�f�����̒l�ł���
% �s��ƍl�����܂��B
%
% ZI = INTERP2(Z,XI,YI) �́A[M,N] = SIZE(Z) �̂Ƃ��AX = 1:N ���� Y = 1:M 
% �ł���Ɖ��肵�܂��BZI = INTERP2(Z,NTIMES) �́A�ċA�I�� NTIMES ��A
% �v�f�Ԃ̕�Ԃ��J��Ԃ����Ƃɂ��AZ ���g�����܂��BINTERP2(Z) �́A
% INTERP2(Z,1) �Ɠ����ł��B
%
% ZI = INTERP2(...,'method') �́A��Ԏ�@���w�肵�܂��B�f�t�H���g�́A
% ���`��Ԃł��B�g�p�\�Ȏ�@�͈ȉ��̒ʂ�ł��B
%
%   'nearest'  - �ŋߖT�_�ɂ����
%   'linear'   - ���`���
%   'cubic'    - �L���[�r�b�N���
%   'spline'   - �X�v���C�����
%
%
% ZI = INTERP2(...'method',EXTRAPVAL) �́AX �� Y �ō쐬���ꂽ�̈�̊O����
% ZI �̗v�f�ɑ΂��Ďg�p����O�}�@�ƃX�J���[�l���w�肷��̂Ɏg���܂��B
% �������āAZI �́AY �܂��� X �̂��ꂼ��ɂ��쐬����Ă��Ȃ��AYI �܂���
% XI �̂����ꂩ�̒l�ɂ��� EXTRAPVAL �ɓ������Ȃ�܂��B�g�p����� EXTRAPVAL
% �ɑ΂��āA���\�b�h���w�肳��Ȃ���΂Ȃ�܂���B�f�t�H���g�̃��\�b�h��
% 'linear' �ł��B
%
% ���ׂĂ̕�Ԗ@�ŁAX �� Y �͒P���֐��ŁA(MESHGRID �ō쐬�������̂�
% ���l��)�i�q�`�łȂ���΂Ȃ�܂���B2�̒P���x�N�g�����^�����Ȃ��ꍇ�A
% interp2 �́A����������I�ɔz�u���܂��BX �� Y �́A���Ԋu�łȂ��ꍇ��
% ����܂��B
%
% ���Ƃ��΁APEAKS �̑e���ߎ����쐬���A�ׂ������b�V���ŕ�Ԃ��܂��B
% 
%     [x,y,z] = peaks(10); [xi,yi] = meshgrid(-3:.1:3,-3:.1:3);
%     zi = interp2(x,y,z,xi,yi); mesh(xi,yi,zi)
%
% ���� X, Y, Z, XI, YI �̃T�|�[�g�N���X  
%      float: double, single
% 
% �Q�l�FINTERP1, INTERP3, INTERPN, MESHGRID, GRIDDATA.


%   Copyright 1984-2004 The MathWorks, Inc.

