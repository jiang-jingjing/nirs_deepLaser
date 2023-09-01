function mesh = generate_mesh_2D(thickness)
sizevar.xc=54;
sizevar.yc=thickness./2;
sizevar.width= 110;
sizevar.height=thickness;
sizevar.dist=1;
create_mesh('/media/jiang/WD10T/Data/Projects/DeepLaser2023/PhantomData202308/Rectangle-stnd-mesh','Rectangle',sizevar,'stnd');
clear sizevar ffaces opt_params optimize_status
mesh_tmp = load_mesh('/media/jiang/WD10T/Data/Projects/DeepLaser2023/PhantomData202308/Rectangle-stnd-mesh');
mesh_tmp.link =[ 1 1 1;];
mesh_tmp.source.coord =[50 0];
mesh_tmp.source.num = (1:size([50 0],1))';
mesh_tmp.source.fwhm = zeros(size([50 0],1),1);
mesh_tmp.source.fixed =0;
mesh_tmp.source.distributed =0;
mesh_tmp.meas.coord =[50 thickness];
mesh_tmp.meas.num = (1:size([50 50],1))';
mesh_tmp.meas.fixed =0;
mesh_tmp = minband_opt(mesh_tmp);
save_mesh(mesh_tmp,'/media/jiang/WD10T/Data/Projects/DeepLaser2023/PhantomData202308/Rectangle-stnd-mesh');
clear mesh_tmp
mesh = load_mesh('/media/jiang/WD10T/Data/Projects/DeepLaser2023/PhantomData202308/Rectangle-stnd-mesh');
end