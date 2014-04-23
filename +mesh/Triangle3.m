classdef Triangle3 < mesh.Element
    %Triangle3 A Triangle with 3 nodes elements 
    %
    % + 3
    % |\
    % | \
    % +--+
    % 1  2
    %
    properties (Constant)
        shapes = {mesh.ShapeFunction(2,@(x) 1-x(:,1)-x(:,2), @(x) [-1 -1] + 0*[x(:,1) x(:,1)]), ...
                  mesh.ShapeFunction(2,@(x) x(:,1), @(x) [1 0] + 0*[x(:,1) x(:,1)]), ...
                  mesh.ShapeFunction(2,@(x) x(:,2), @(x) [0 1] + 0*[x(:,1) x(:,1)])};
        nb_nodes = 3;
        local_nodes_coors = [0 0;1 0;0 1];
    end
    
    methods
        function this = Triangle3(nodes)
            this = this@mesh.Element(nodes);
        end
    end
end