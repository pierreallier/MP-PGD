function A = LinearForm(mesh, expression)

    A = sparse(mesh.nbDdl(),1);

    for i=1:mesh.nbElems()
        [elem,index] = mesh.getElem(i); % element and the ddl index
        shapes = elem.getShapes(); % shapes functions
        [ag,wg] = formulation.gaussPoints(elem); % gauss points and weights in the local coor
        xg = elem.local2global(ag); % gauss points in the global coor
        
        Ae = cell(length(shapes),1);
        for j=1:length(wg)
            for k=1:length(shapes)
                if j == 1
                    Ae{k} = 0;
                end
                Ae{k} = Ae{k} + elem.detJ(ag(j,:))*wg(j)*expression(ag(j,:),xg(j,:),shapes{k});
            end 
        end
        A(index) = A(index) + cell2mat(Ae);
    end

end