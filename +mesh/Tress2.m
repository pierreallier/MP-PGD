classdef Tress2 < mesh.Element
    %Tress2 A Tress with 2 nodes elements 
    %
    % +-----+
    % 1     2
    %
    properties (Constant)
        shapes = {mesh.ShapeFunction(1,@(x) (1-x(:,1))/2,@(x) -1/2+0*x(:,1)), ...
                  mesh.ShapeFunction(1,@(x) (1+x(:,1))/2,@(x) 1/2+0*x(:,1))};
        nb_nodes = 2;
        local_nodes_coors = [-1;1];
    end
    
    methods
        function this = Tress2(nodes)
            this = this@mesh.Element(nodes);
        end
    end
end