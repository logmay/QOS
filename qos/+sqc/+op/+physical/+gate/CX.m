function g = CX(control_q, target_q)
	% CNOT
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	import sqc.op.physical.gate.*
	g = Y2p(target_q)*CZ(control_q,target_q)*Y2m(target_q);
end
