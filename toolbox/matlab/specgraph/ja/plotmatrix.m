% PLOTMATRIX   �U�z�}�̕`��
% 
% PLOTMATRIX(X,Y) �́AY �̗�ɑ΂��� X �̗�̎U�z�}��`�悵�܂��BX ��
% P�sM��ŁAY ��P�sN��̏ꍇ�APLOTMATRIX �́AN�sM��̍s�񂩂�Ȃ鎲��
% �o�͂��܂��B
% PLOTMATRIX(Y) �́A�Ίp������ HIST(Y(:,i)) �Œu���������邱�Ƃ������΁A
% PLOTMATRIX(Y,Y) �Ɠ����ł��B
%
% PLOTMATRIX(...,'LineSpec') �́A������ 'LineSpec' �̃��C���̎d�l���g���܂��B
% '.' �́A�f�t�H���g�ł�(�g�p�\�Ȓl�ɂ��ẮAPLOT ���Q�Ƃ��Ă�������)�B  
%
% PLOTMATRIX(AX,...) ��GCA�̑����BigAx�Ƃ���AX���g���܂��B
%
% [H,AX,BigAx,P,PAx] = PLOTMATRIX(...) �́A�쐬���ꂽ�I�u�W�F�N�g��
% �n���h���ԍ�����Ȃ�s���H�ɁA�X�̕⏕���̃n���h���ԍ�����Ȃ�s��� 
% AX �ɕ⏕�������傫����(���o�s��)�̃n���h���ԍ��� BigAx �ɁA�q�X�g
% �O�����v���b�g�ɑ΂���n���h���ԍ�����Ȃ�s��� P �ɁA�q�X�g�O������
% ���̃X�P�[���𐧌䂷�����̎��̃n���h���ԍ�����Ȃ�s��� PAx ��
% �o�͂��܂��BBigAx �ͤ�����R�}���h TITLE�AXLABEL�AYLABEL �����̍s���
% ���S�ɔz�u�����悤�ɁACurrentAxes�Ƃ��Ďc����܂��B
%
% ���:
% 
%       x = randn(50,3); y = x*[-1 2 1;2 0 1;1 -2 3;]';
%       plotmatrix(y)


%   Clay M. Thompson 10-3-94
%   Copyright 1984-2002 The MathWorks, Inc. 
