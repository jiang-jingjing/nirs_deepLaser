function Data2fit = y_nirfast_global(x, ~, paras) 
 
 
optprop = x ./paras.scaler 

val.mus   = optprop(1);
val.mus  = optprop(2);
mesh = paras.mesh;
region_no = unique(mesh.region);
cfg = paras.cfg;
gCFT = paras.gCFT;
mesh = set_mesh(mesh,region_no,val);
 
data = femdata_stnd_TR(mesh, ...
        cfg.tend,cfg.tstep,'field', 'BiCGStab_GPU');

Data2fit = applyIRF(gCFT, data.tpsf, cfg.timeGates);

Data2fit = Data2fit./max(Data2fit);
% Data2fit = log(abs(Data2fit));
% Data2fit = Data2fit(paras.tInterval);

end