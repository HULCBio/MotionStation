% GENFRESP   MIMO���f���̎��g���O���b�h�Ɖ����f�[�^���쐬
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) �́A��������
% ���ꂽ���g���O���b�h W ��ŁA�P��MIMO���f�� SYS �̎��g�������̑傫��MAG 
% �ƈʑ� PH(���W�A��)���v�Z���܂��B
% 
% GRADE �� FGRIDSPEC �́A�O���b�h�Ԋu�Ɩ��x�𐧌䂵�܂��B
%    GRADE               FRD���f���ɑ΂��Ė�������܂�
%    FGRIDSPEC     [] :  �����I�Ɍ��܂�ш�
%            'decade' :  �����I�Ɍ��܂�ш� + 10^k �_���܂ރO���b�h
%         {fmin,fmax} :  ���[�U��`�̑ш�(�O���b�h�́A���̑ш�ɂ���
%                        ���܂�)
%
% �\���� FOCUSINFO �́A�����̊e�]����\�����邽�߂ɑI�΂ꂽ���g���ш��
% �܂݂܂��B(FOCUSINFO.Range(k,:) �́Ak�Ԗڂ̕]���ɑ΂���I�΂ꂽ�ш�ł�)
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) �́ASYS 
% �̊eI/O�̑g�ݍ��킹�ɑ΂����_�A�ɁA�Q�C�����^���܂��B
%
% �Q�l : FREQRESP, BODE, NYQUIST, NICHOLS.


%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
