%BITSHIFT �r�b�g�P�ʂ̃V�t�g
% C = BITSHIFT(A,K) �́AA �̒l�� K �r�b�g�V�t�g�����l���o�͂��܂��B
% A �́A�ʏ�A�����Ȃ������ł��BK �r�b�g�V�t�g���邱�Ƃ́A2^K �̏�Z��
% �s�����ƂƓ����ł��BK �͕��̒l�ɂȂ邱�Ƃ��ł��A����́A�E�ւ̃V�t�g�A
% 2^ABS(K) �̏��Z�A�����Ɋۂ߂邱�Ƃɑ������܂��B�V�t�g�ɂ�� C ���A
% A �̕����Ȃ������N���X�̃r�b�g���I�[�o�[�t���[����ꍇ�A�I�[�o�[�t���[
% �����r�b�g�͗��Ƃ���܂��B
% A ���{���x�̕ϐ��̏ꍇ�A���̒l�́A0 ���� BITMAX �̊Ԃ̐����ł���
% �K�v������A�I�[�o�[�t���[�́A53 �r�b�g�𒴂���ƋN����܂��B
%
% C = BITSHIFT(A,K,N) �́AA ���{���x�̏ꍇ�AN �r�b�g�I�o�[�t���[��
% �N�����A�I�[�o�[�t���[�����r�b�g�͗��Ƃ���܂��BN �́A53 �ȉ���
% �Ȃ���΂Ȃ�܂���BN�@�Ƃ��āABITSHIFT(A,K,8) �܂��� 2 �̑��̗ݏ�
% ���g�p����̂ł͂Ȃ��AA �Ƃ���BITSHIFT(UINT8(A),K) �܂��� �K����
% �����Ȃ������̃N���X���g�p���邱�Ƃ��������Ă��������B
%
% ���:
% ���ׂĂ̔�[���r�b�g���I�[�o�[�t���[����܂ŁA�����Ȃ� 16 �r�b�g�l��
% �r�b�g���J��Ԃ����ɃV�t�g���܂��B�o�߂��o�C�i���ŒǐՂ��Ă��������B
%
%    a = intmax('uint16');
%    disp(sprintf('Initial uint16 value %5d is %16s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:16
%       a = bitshift(a,1);
%       disp(sprintf('Shifted uint16 value %5d is %16s in binary',...
%          a,dec2bin(a)))
%    end
%
% �{���x�ϐ��œ����������J��Ԃ��܂��B
%
%    a = double(intmax('uint16'));
%    disp(sprintf('Initial double value %5d is %16s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:16
%       a = bitshift(a,1,16);
%       disp(sprintf('Shifted double value %5d is %16s in binary',...
%          a,dec2bin(a)))
%    end
%
% �{���x�ϐ������̃f�t�H���g�� 53 �r�b�g�ŃI�[�o�[�t���[�����邱�ƂƂ�
% �Ⴂ�ɒ��ӂ��Ă��������B�ȒP�̂��߂ɁA���� 3 ���V�t�g���܂��B
%
%    a = double(intmax('uint16'));
%    disp(sprintf('Initial double value %16.0f is %53s in binary', ...
%       a,dec2bin(a)))
%    for i = 1:18
%       a = bitshift(a,3);
%       disp(sprintf('Shifted double value %16.0f is %53s in binary',...
%          a,dec2bin(a)))
%    end
%
% �Q�l BITAND, BITOR, BITXOR, BITCMP, BITSET, BITGET, BITMAX, INTMAX.

%   Copyright 1984-2004 The MathWorks, Inc. 
