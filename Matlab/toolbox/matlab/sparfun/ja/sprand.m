% SPRAND   �X�p�[�X��l���z�����s��
% 
% R = SPRAND(S) �́AS �Ɠ����X�p�[�X�\���������A��l���z������v�f�Ƃ���
% �s����o�͂��܂��B
%
% R = SPRAND(m,n,density) �́A�����_���� m �s n ��̃X�p�[�X�s��ŁA�ق�
% density*m*n �̈�l���z�����[���v�f�������܂��BSPRAND �́A�傫���āA
% ���x���������s����쐬���܂��Bm*n �������������薧�x���傫����΁A�v����
% �����̂�����[�������Ȃ��s����쐬���܂��B
%
% R = SPRAND(m,n,density,rc) �́A�������̋t�����ق� rc �Ɠ������Ȃ�܂��B
% R �́A�����N1�̍s��̘a����\������܂��B
%
% rc ������ lr < =  min(m,n) �̃x�N�g���̏ꍇ�AR �͍ŏ��� lr �̓��ْl�� 
% rc �ŁA���͂��ׂă[���ɂȂ�܂��B���̏ꍇ�AR �͗^����ꂽ���ْl������
% �Ίp�s��ɁA�����_���ȕ��ʉ�]��K�p���č���܂��BR �́A�����̈ʑ��I
% �\����A�㐔�I�\���������Ă��܂��B
%
% �Q�l�FSPRANDN, SPRANDSYM.


%   Rob Schreiber, RIACS, and Cleve Moler, MathWorks, 9/10/90.
%   Revised 1/28/91, 2/12/91, RS; 8/12/91, CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:33 $
