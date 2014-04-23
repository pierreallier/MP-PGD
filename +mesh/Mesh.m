classdef Mesh < handle
    %Mesh An interface to handle FEM Mesh.
    properties
        nodes = {}; % List of all the nodes of the mesh
        elems = {}; % List of all the elements of the mesh
        mesh_dim = 0; % Dimension of the mesh 
        field_dim = 0; % Dimension of the unknown field
    end
    
    methods
        function this = Mesh(dim, field_dim)
            %Mesh Construct a mesh object
            %
            %	Require the dimension of mesh and the dimension of the unknown field
            %
            this.mesh_dim = dim;
            this.field_dim = field_dim;
        end
        
        function n = nbDdl(this)
            %nbDdl Compute the number of degree of freedom of the mesh
            n = this.field_dim * length(this.nodes);
        end
        
        function n = nbElems(this)
            %nbElems Compute the number of elements in this mesh
            n = length(this.elems);
        end
        
        function n = nbNodes(this)
            %nbNodes Compute the number of nodes in this mesh
            n = length(this.nodes);
        end
        
        function node = addNode(this, coor)
            %addNode Add a new node to this mesh at a given position.
            %
            %   Add a new node to a mesh at a given position coor and return 
            %   the object created. If the dimension of the position is lower 
            %   than the dimension of the  mesh, some extra zeros are added. 
            %   Otherwise, the position vector is truncated to the mesh 
            %   dimension.
            %
            coor = coor(:);
            node = mesh.Node(length(this.nodes)+1,[coor(1:min(this.mesh_dim,length(coor)));zeros(this.mesh_dim - length(coor),1)]);
            this.nodes{length(this.nodes)+1} = node;
        end
        
        function list_nodes = addNodes(this, coors)
            %addNodes Add a list of nodes to this mesh at given positions. 
            %
            %   Add a list of nodes to a mesh at positions coors given in a 
            %   matrix format where the rows are the nodes coordinates and 
            %   return the list of object created (cell). If the dimension of
            %   the position is lower than the dimension of the mesh, some 
            %   extra zeros are added. Otherwise, the position vector is 
            %   truncated to the mesh dimension.
            %
            list_nodes = cell(size(coors,1),1);
            for i=1:size(coors,1)
                list_nodes{i} = this.addNode(coors(i,:));
            end
        end
        
        function elem = addElem(this, elem)
            %addElem Add an element object to this mesh.
            %
            %   Add an element object elem created with the correct type of 
            %   element constructor (tress2, triangle3 ...)
            %
            if isa(elem,'mesh.Element')
                this.elems{length(this.elems)+1} = elem;
            else
                warning('Mesh.addElem:BadInput','Unknown element - skipped');
            end
        end
        
        function elems = addElems(this, elems)
            %addElemshelp  add a list (cell) of element objects to this mesh.
            %
            %   Add a list (cell) of element objects elems created with the 
            %   correct type of element constructor (tress2, triangle3 ...)
            %
            for i=1:length(elems)
                this.addElem(elems{i});
            end
        end
        
        function [elem, index] = getElem(this, id)
            %getElem get the i-th element object and his global index.
            %
            %   Return the id-th element object and the global index in the 
            %   FEM matrix / vectors
            %
            if id <= length(this.elems)
                elem = this.elems{id};
                nodes_id = cellfun(@(node) node.id,this.elems{id}.nodes);
                index = cell2mat(cellfun(@(x) (x-1)*this.field_dim+1:x*this.field_dim,num2cell(nodes_id),'UniformOutput',false));
            else
                error('Mesh.getElem:BadInput','Overfull index');
            end
        end
    end
end