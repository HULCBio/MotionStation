% EVAL   MATLAB�\������������̎��s
% 
% EVAL(s) �́As ��������̂Ƃ��A����������܂��̓X�e�[�g�����g�Ƃ��Ď��s
% ���܂��B
%
% EVAL(s1,s2) �́A�G���[��߂炦��@�\��񋟂��܂��B����́A������ s1 ��
% ���s���A���Z����������ƌ��ʂ��o�͂��܂��B���Z���G���[�ɂȂ�ƁA���ʂ�
% �o�͂���O�ɕ����� s2 ���]������܂��B����́AEVAL('try','catch') ��
% �l�����܂��B���s���� 'try' �ɂ���ďo�͂��ꂽ�G���[������́ALASTERR 
% �ɂ���Ď��o���܂��B
% 
% [X,Y,Z,...] = EVAL(s) �́A������ s �̒��̕\������o�͈�����߂��܂��B
%
% EVAL �̓��͕�����́A�����ʓ��̕����I�ȕ������ϐ���A�����č쐬
% ����܂��B���Ƃ��΁A
%
% �ϐ� M1����M12�܂ł̈�A�̍s����쐬���邽�߂ɂ́A
%
%     for n = 1:12
%        eval(['M' num2str(n) ' = magic(n)'])
%     end
%
% ���̗�ł́A�I������M-�t�@�C���X�N���v�g�����s���܂��B�s��D�̍s��
% �ݒ肳��镶����́A���ׂē��������łȂ���΂Ȃ�܂���B
% 
%       D = ['odedemo '
%            'quaddemo'
%            'fitdemo '];
%       n = input('Select a demo number: ');
%       eval(D(n,:))
%
% �Q�l�FFEVAL, EVALIN, ASSIGNIN, EVALC, LASTERR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:55 $
%   Built-in function.
