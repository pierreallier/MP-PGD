classdef Quadrangle4 < mesh.Element
    %Quadrangle4 A Quadrangle element with 4 nodes
    %
    % 4  3
    % +--+
    % |  |
    % |  |
    % +--+
    % 1  2
    %
    properties (Constant)
        shapes = {mesh.ShapeFunction(2,@(x) 1/4*(x(:,1)-1).*(x(:,2)-1), @(x) 1/4*[(x(:,2)-1) (x(:,1)-1)]), ...
                  mesh.ShapeFunction(2,@(x) 1/4*(x(:,1)+1).*(x(:,2)-1), @(x) 1/4*[(x(:,2)+1) (x(:,1)-1)]), ...
                  mesh.ShapeFunction(2,@(x) 1/4*(x(:,1)+1).*(x(:,2)+1), @(x) 1/4*[(x(:,2)+1) (x(:,1)+1)]), ...
                  mesh.ShapeFunction(2,@(x) 1/4*(x(:,1)-1).*(x(:,2)+1), @(x) 1/4*[(x(:,2)-1) (x(:,1)+1)])};
        nb_nodes = 4;
        local_nodes_coors = [0 0;1 0;1 1;0 1];
    end
    
    methods
        function this = Quadrangle4(nodes)
            this = this@mesh.Element(nodes);
        end
    end
end