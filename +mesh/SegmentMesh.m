function x = SegmentMesh(list_nodes)

    x = mesh.Mesh(1,1);
    old_node = x.addNode(list_nodes(1));
    
    for i=2:length(list_nodes)
        new_node = x.addNode(list_nodes(i));
        x.addElem(mesh.Tress2({old_node,new_node}));
        old_node = new_node;
    end

end