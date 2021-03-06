function TriJEGap4Ec(Ej,Ec,alpha,varargin)
% TriJEGap4alpha plots the three-junction flux qubit energy gap - energy difference
% between the lowest two (four actually) energy levels at the symmetric flux
% bias point (0.5 flux quantum) for different alpha values. See ref.
% jc: critical current density, unit: muA/mum^2
% c: junction capacitance per mu^2, unit: fF/mum^2
% S: junction area of the bigger junctions(area of one junction), unit: mu^2
% alpha: s/S, s is the junction area of the small junction.
% alpha: must be an array !
% beta: beta_Q in  ref.
% Ref.: Robertson et al., Phys. Rev. Letts. B 73, 174526 (2006).
% example:
% TriJEGap4alpha(jc,c,S,alpha,beta)
% Author: Yulin Wu <mail4ywu@gmail.com>
% Date: 2011/5/3
clc;
FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;
beta = 0; % beta need must be zero, because n_m = 1 is used below.
if nargin > 4
    beta = varargin{1};
end
Ej = 10*S*jc*1e-6*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
Ec = ee^2./(2*S*c*1e-15)/PlanksConst/1e9;   % Unit: GHz.
N = length(alpha);
if N<2
    error('alpha is not an array, impossible to plot a curve !')
end
EGap = zeros(1,N);
disp('Calculating, please wait ...');
matlabpool;
parfor ii = 1:N
        EL = TriJFlxQbtEL(Ej,Ec,alpha(ii),beta,0,0,0.5,10,20,1,4);  % since beta = 0;
        EGap(ii) = (EL(3) + EL(4) - EL(2) -EL(1))/2;
end
matlabpool close;
clc;
figure(int32(1e5*rand()));
YMAX = max(EGap);
axis([min(alpha),max(alpha),0,YMAX]);
plot(alpha,EGap);
xlabel('\alpha');
ylabel('\Delta (GHz)');
title(['J_c: ', num2str(jc), '\muA/\mum^2;  c:',num2str(c), 'fF/\mum^2;  \beta:', num2str(beta)]);



