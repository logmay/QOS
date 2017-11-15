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
QS.SS('s171110');
% QS.SS('s170921');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
% qubits = {'q2'};
%%
 qubits = {'q1','q3','q4','q5','q6','q7','q8','q9','q10'};%,'q2','q11','q12'
%qubits = {'q7','q8','q9'};
% dips =[6.74e9];
 dips =[6.60881 6.64365 6.66111 6.678 6.695 6.70973 6.72978 6.74796 6.76496]*1e9; % by qubit index % 6.79964 6.80196
%dips = [6.423 6.491 6.582]*1e9; % by qubit index
%%
app.RE