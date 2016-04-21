% POLYEIG   �������̌ŗL�l���
% 
% [X,E] = POLYEIG(A0,A1,..,Ap) �́Ap ���̑������ŗL�l���������܂��B
% 
%     (A0 + lambda*A1 +  ... + lambda^p*Ap)*x = 0.   
% 
% ���͂́Ap+1 �̐����s�� A0�AA1�A...�AAp �ŁA���ׂē��� n ���ł��B�o�͂́A
% n �s n*p ��̍s�� X �ŁA���̗�͌ŗL�x�N�g���ł��B�o��E �́A������ n*p ��
% �x�N�g���ŁAE �̗v�f�͌ŗL�l�ł��B
% 
%    for j = 1:n*p
%        lambda = E(j)
%        x = X(:,j)
%        (A0 + lambda*A1 + ... + lambda^p*Ap)*x�́A�قƂ��0�ł��B
%     end
%
% E = POLYEIG(A0,A1,...,Ap) �́A���� n*p �̃x�N�g���ŁA���̗v�f�͑���
% ���ŗL�l���̌ŗL�l�ł��B
% 
% ����ȏꍇ
%     p = 0�Apolyeig(A) �� �W���̌ŗL�l���ŁAeig(A) �ł��B
%     p = 1�Apolyeig(A,B) �͈�ʉ����ꂽ�ŗL�l���ŁAeig(A,-B) �ł��B
%     n = 1�A�X�J�� a0�A...�Aap �ɑ΂��� polyeig(a0,a1,..,ap) �͕W���̑���
%            �����ŁAroots([ap .. a1 a0]) �ł��B
%
% A0 �� Ap �̗����������łȂ���΁A���͐��ݓI�Ɉ����������ɂȂ��
% ���B���_�I�ɁA���͑��݂��Ȃ����A��ӓI�ł͂���܂���B���߂�ꂽ���́A
% ���m�ł͂Ȃ��ꍇ������܂��BA0 �� Ap �̂����ꂩ1�ł������̏ꍇ�́A
% ���͗ǂ���Ԃł����A�ŗL�l�̂������̓[���܂��͖�����ɂȂ�ꍇ��
% ����܂��B
%
% [X,E,S] = POLYEIG(A0,A1,..,AP) �́A�ŗL�l�ɑ΂���������́A���� P*N ��
% �x�N�g�����o�͂��܂��BA0 ����� AP �̏��Ȃ��Ƃ�1�́A�����ł���K�v��
% ����܂��B
% ���������傫�����Ƃ́A��肪�����̌ŗL�l�����ꍇ�ɋ߂����Ƃ��Ӗ����܂��B
%
% �Q�l EIG, COND, CONDEIG.

%   Nicholas J. Higham and Francoise Tisseur
%   Copyright 1984-2004 The MathWorks, Inc.
