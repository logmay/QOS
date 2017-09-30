function varargout = readoutStability(varargin)
% measure the statebility of readout signal

fcn_name = 'data_taking.public.xmon.readoutStability'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'reptime',1e4,'r_avg',[],'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if ~isempty(args.r_avg) 
    q.r_avg=args.r_avg;
end

X2 = gate.X(q);
R = measure.resonatorReadout_ss(q);
R.state = 2;
R.delay = X2.length;

function procFactory(a)
	proc = X2;
    proc.Run();
end

y = expParam(@procFactory);
y.name = [q.name,' Readout repeat times'];

s2 = sweep(y);
s2.vals = 1:args.reptime;
e = experiment();
e.sweeps = s2;
e.measurements = R;
e.name = 'Readout Repeat stability';
e.datafileprefix = sprintf('%s_rep', q.name);

if ~args.gui
    e.showctrlpanel = false;
    e.plotdata = false;
end
if ~args.save
    e.savedata = false;
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
e.Run();
varargout{1} = e;
end