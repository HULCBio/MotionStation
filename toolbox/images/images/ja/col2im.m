% COL2IM    �s��̗���u���b�N�ɍĔz��
% A = COL2IM(B,[M N],[MM NN],'distinct') �́AB �̂��ꂼ��̗���A�傫�� 
% MM �s NN ��̍s�� A ���쐬���邽�߁A�d�Ȃ�̂Ȃ� M �s N ��̃u���b�N��
% �Ĕz�񂵂܂��BB = [A11(:) A12(:);A21(:) A22(:)] �ŁA�e�񂪒��� M*N ��
% �ꍇ�AA = [A11 A12;A21 A22] �ɂȂ�܂��B�����ŁAAij �́AM �s N ��̍s
% ��ł��B
% 
% A = COL2IM(B,[M N],[MM NN],'sliding') �́A�s�x�N�g�� B ��傫��(MM-M+1)
% �s(NN-N+1)��̍s��ɍĔz�񂵂܂��BB �́A�傫��1�s(MM-M+1)*(NN-N+1)���
% �x�N�g���łȂ���΂Ȃ�܂���B�ʏ�AB �́A������k����֐�(���Ƃ��΁ASUM)���g�� IM2COL(...,'sliding') �̏o�͂̏������ʂɂȂ�܂��B
% 
% COL2IM(B,[M N],[MM NN]) �́ACOL2IM(B,[M N],[MM NN],'sliding') �Ɠ�����
% ���B
% 
% �N���X�T�|�[�g
% -------------
% B �́Alogical �����l�ł��BA ��B�Ɠ����N���X�ł��B
% 
% �Q�l�FBLKPROC, COLFILT, IM2COL, NLFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
