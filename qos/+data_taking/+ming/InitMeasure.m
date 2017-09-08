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
QS.SS('s170906');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
qubits = {'q1','q2','q3','q4','q5'};%,'q6','q7','q8','q9','q10'
% qubits = {'q3','q4','q5','q6','q7','q8','q10'};
dips = [6.69 6.742 6.804 6.616 6.575]*1e9; % by qubit index

app.RE