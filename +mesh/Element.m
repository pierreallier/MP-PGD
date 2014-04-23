classdef Element
    %Element A class to handle Element data. It's a virtual class and need
    %to be subclassed to implement specific elements.
    properties (Constant, Abstract)
        shapes; % The list of shape functions
        nb_nodes; % The number of nodes in this element
        local_nodes_coors; % The coordinates of the nodes in the local basis (rows = nodes)
    end
    
    properties
        nodes = {}; % List of nodes of the element
    end
    
    methods
        function this = Element(nodes)
            %Element constructor Takes as input a list (cell) of the nodes
            %connected by this element
            if iscell(nodes)
                this.nodes = nodes(:)';
            end
        end
        
        function shapes = getShapes(this)
            %getShapes Return the shapes of the element in a list (cell)
            shapes = this.shapes;
            for i=1:length(shapes)
                shapes{i} = shapes{i}.setJacobian(this.jacobian);
            end
        end
        
        function handle = jacobian(this)
            %jacobian Return the jacobian (function handle)
            s = cell2mat(cellfun(@(x) x.coor(:),this.nodes,'UniformOutput',false));
            if length(this.nodes{1}.coor) > size(this.local_nodes_coors,2)
                %s = ; %TODO
            end
            handle = @(a) cell2mat(cellfun(@(N) N.localDiff(a)', this.shapes,'UniformOutput',false))*s';
        end
        
        function val = detJ(this,a)
            %detJ Return the determinant of the jacobian at a certain coor
            f = this.jacobian;
            val = det(f(a));
        end
        
        function g_coor = local2global(this, l_coor)
            %local2global Compute the global coordinates based on the local coordinates
            %l_coor given 
            g_coor = zeros(size(l_coor,1),length(this.nodes{1}.coor));
            for i=1:size(l_coor,1)
                coor = cellfun(@(N,x) N.exp(l_coor(i,:))*x.coor,this.shapes,this.nodes,'UniformOutput',false);
                g_coor(i,:) = sum(cell2mat(coor),2);
            end
        end
    end 
end