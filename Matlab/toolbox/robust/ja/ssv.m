% [MU,LOGD] = SSV(A,B,C,D,W)
% SSV(A,B,C,D,W,K) �A�܂��́A
% (A,B,C,D,W,K,OPTION)
% [MU,LOGD] = SSV(SS_,...)
% ssv�́A���x�N�g��w���̊e�X�̎��g���ł�
%        G(jw) = C * inv(jwI-A) * B + D
% �̍\�������ْl(ssv)�̏�E���܂ލs�x�N�g��MU���쐬���܂��B
% ����:
%     A,B,C,D  -- p�sq��̓`�B�֐��s��G(s)�̏�ԋ�ԍs��
%     W        -- MU���쐬�������g���̃x�N�g��
% �I�v�V��������:
%     K  -- �s�m�����̃u���b�N�T�C�Y -- �f�t�H���g�́AK=ones(q,2)�ł��B
%           K�́An�s1��܂���n�s2��s��ŁA���̍s��ssv���]�������
%           �s�m�����̃u���b�N�T�C�Y�ł��BK �́Asum(K) == [q,p]��
%           �������Ȃ���΂Ȃ�܂���Bi�Ԗڂ̕s�m�����������̏ꍇ�A
%           K(i,:) = [-1 -1]�Ɛݒ肵�܂��BK��1�Ԗڂ̗�݂̂��^����ꂽ�ꍇ�A
%           �s�m�����u���b�N��K(:,2)=K(:,1)�̂悤�ɐ����ɂȂ�܂��B
%
%     OPTION  -- MU�̌v�Z�@�ŁA'psv'(�œK�Ίp�X�P�[�����O���ꂽPerron�A
%                �f�t�H���g)�A'osborne', 'perron', 'muopt'(�����̂݁A
%                ���f���̂݁A���݂����s�m�����ɑ΂���搔�A�v���[�`)
%                �̂����̂����ꂩ�ł��B
% �o��:
%     MU      -- MU��bode�v���b�g
%     LOGD    -- �œK�Ίp�X�P�[�����O���ꂽD (�l�́Aexp(LOGD)�ł�)



% Copyright 1988-2002 The MathWorks, Inc. 
