% GM, 2017/6/22
if exist('ustcaddaObj','var')
    ustcaddaObj.close()
end
if (~isempty(instrfind))
    fclose(instrfind);
    delete(instrfind);
end
clear all
clc
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('E:\settings');
QS.SU('Ming');
QS.SS('s180212');
% QS.SS('s170921');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
% qubits = {'q2'};
%%
%  qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};%,'q11','q12'
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9'};%
% dips =[6.74e9];
 dips =[6.593 6.633 6.677 6.724 6.762 6.799 6.84 6.881 6.925]*1e9; % by qubit index % 6.79964 6.80196
%dips = [6.423 6.491 6.582]*1e9; % by qubit index
%%
app.RE