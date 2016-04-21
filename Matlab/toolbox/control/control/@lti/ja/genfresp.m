% GENFRESP   MIMO���f���̎��g���O���b�h�Ɖ����f�[�^���쐬
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) �́A��������
% ���ꂽ���g���O���b�h W ��ŁA�P��MIMO���f�� SYS�̎��g�������̑傫��
% MAG �ƈʑ� PH(���W�A��)���v�Z���܂��B
%
% GRADE �� FGRIDSPEC �́A�ȉ��̂悤�ɃO���b�h�Ԋu�Ɩ��x�𐧌䂵�܂��B
%
%  GRADE and FGRIDSPEC control the grid density and span as follows:
%    GRADE          1 :  Nyquist �v���b�g(�ł��ׂ���)
%                   2 :  Nichols �v���b�g  
%                   3 :  Bode �v���b�g
%                   4 :  Sigma �v���b�g
%    FGRIDSPEC     [] :  �����I�Ɍ��܂�ш�
%            'decade' :  �����I�Ɍ��܂�ш� + 10^k �_���܂ރO���b�h 
%         {fmin,fmax} :  ���[�U��`�̑ш� (�O���b�h�͂��̑ш�ɂ�����܂�)
%
% �\���� FOCUSINFO �́A�����̊e�]����\�����邽�߂ɁA�I�΂ꂽ���g���ш��
% �܂݂܂�(FOCUSINFO.Range(k,:) �́Ak�Ԗڂ̕]���ɑ΂��đI�΂ꂽ���̂ł�)
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) �́ASYS 
% �̊eI/O �̑g�ɑ΂��āA��_�A�ɁA�Q�C����^���܂��B
%
% �Q�l : FREQRESP, BODE, NYQUIST, NICHOLS.


%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
