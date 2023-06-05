function net_conv = get_net_conv(params)
net=load(params.mdnet_file);
if isfield(net,'net'), net = net.net; end
net_conv.layers = net.layers(1:10);
clear net;
if params.use_gpu
    net_conv = vl_simplenn_move(net_conv, 'gpu') ;
else
    net_conv = vl_simplenn_move(net_conv, 'cpu') ;
end
end