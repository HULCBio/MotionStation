% SPRANDN   �X�p�[�X���K���z�����s��
% 
% R = SPRANDN(S) �́AS �Ɠ����X�p�[�X�\�����������K���z������v�f�Ƃ���
% �s����o�͂��܂��B
%
% R = SPRANDN(m,n,density) �́A�����_���� m �s n ��̃X�p�[�X�s��ŁA�ق�
% density*m*n�̐��K���z�����[���v�f�������܂��BSPRANDN �́A���x����
% �����ł����A�傫���s����쐬���܂��Bm*n �������������薧�x���傫����΁A
% �v���������̂�����[�������Ȃ��s����쐬���܂��B
%
% R = SPRANDN(m,n,density,rc) �́A�������̋t�����ق� rc �Ɠ������Ȃ�܂��B
% R �́A�����N1�̍s��̘a����\������܂��B 
%
% rc ������ lr < =  min(m,n) �̃x�N�g���̏ꍇ�AR �͍ŏ��� lr �̓��ْl�� 
% rc �ŁA���͂��ׂă[���ɂȂ�܂��B���̏ꍇ�AR �͗^����ꂽ���ْl������
% �Ίp�s��ɁA�����_���ȕ��ʉ�]��K�p���č���܂��BR �́A�����̈ʑ��I
% �\����A�㐔�I�\���������Ă��܂��B
%
% �Q�l�FSPRAND, SPRANDSYM.


%   Rob Schreiber, RIACS, and Cleve Moler, MathWorks, 9/10/90.
%   Revised 1/28/91, 2/12/91, RS; 8/12/91, CBM.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:34 $
