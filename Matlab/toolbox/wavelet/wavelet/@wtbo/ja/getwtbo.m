%GETWTBO   �I�u�W�F�N�g�t�B�[���h�̓��e���擾
%   [FieldValue1,FieldValue2, ...] = ...
%       GETWTBO(O,'FieldName1','FieldName2', ...) �́AWavelet Toolbox ��%   �C�ӂ̃I�u�W�F�N�g O �Ŏw�肳���t�B�[���h�̓��e���o�͂��܂��B
%
%   �ŏ��ɁAO ����������܂��B���s�����ꍇ�A�T�u�I�u�W�F�N�g�Ɖ��ʂ̍\��%   �t�B�[���h�����ׂ��܂��B
%
%   ���:
%     t = ntree(2,3);   % t �́ANTREE �I�u�W�F�N�g�ł��B
%     [o,wtboInfo,tn,depth] = getwtbo(t,'order','wtboInfo','tn','depth');
%
%     t = wpdec(rand(1,120),3,'db3');  % t �́AWPTREE �I�u�W�F�N�g�ł��B%     [o,tn,Lo_D,EntName] = getwtbo(t,'order','tn','Lo_D','EntName');

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 03-Jun-97.


%   Copyright 1995-2002 The MathWorks, Inc.
