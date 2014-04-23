classdef Node
    %Node A class to handle Node data
    properties
        id = 0; % The global mesh id of the node
        coor = []; % the global coordinates of the node
    end
    
    methods
        function this = Node(id,coor)
            %Node constructor Require the coordiantes coor of the node in
            %the global space.
            this.id = id;
            this.coor = coor(:);
        end
    end
end