% PDEJMPS   �A�_�v�e�B�u�\���o�̂��߂Ɍ덷��]�����܂��B
% ERRF = PDEJMPS(P,T,C,A,F,U,ALFA,BETA,M) �́A�A�_�v�e�B�u�\���o�Ŏg���
% ��덷�C���W�P�[�^�֐����v�Z���܂��BERRF �̗�́A�O�p�`�ɑΉ����A�s�́A
% PDE �V�X�e���ɂ�����قȂ�������ɑΉ����܂��B
%
% P �� T �́A���b�V���f�[�^�ł��B�ڍׂ́AINITMESH ���Q�Ƃ��Ă��������B
%
% C, A, F �́APDE �W���ł��B�ڍׂ́AASSEMPDE ���Q�Ƃ��Ă��������BC, A, F
% �́A�񂪎O�p�`�ɑΉ�����̂ŁA�g������Ȃ���΂Ȃ�܂���B
%
% U �́A��x�N�g���Ƃ��ė^������J�����g���ł��B�ڍׂ́AASSEMPDE ���Q
% �Ƃ��Ă��������B
%
% ERRF(:,K) ���v�Z���邽�߂̎��́A
% ALFA*L2K(H^M (F - AU)) + BETA SQRT(0.5 SUM((L(J)^M JMP(J))^2))
% �ł��B�����ŁAL2K �͎O�p�` K �ł� L2 �m�����ŁAH �͎O�p�`K �̐��`
% �T�C�Y�ŁAL(J) �́AJ �Ԗڂ̕ӂ̒����ł��BSUM �́A3�̕ӂ�͈͂Ƃ��A
% JMP(J) �́AJ �Ԗڂ̕ӂł̖@���̓��֐��̕ω��ł��B



%       J. Oppelstrup 10-24-94, AN 12-05-94.
%       Copyright 1994-2001 The MathWorks, Inc.
