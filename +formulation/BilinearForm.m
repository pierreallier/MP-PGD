function A = BilinearForm(mesh, expression)

    A = sparse(mesh.nbDdl(),mesh.nbDdl());

    for i=1:mesh.nbElems()
        [elem,index] = mesh.getElem(i); % element and the ddl index
        shapes = elem.getShapes(); % shapes functions
        [ag,wg] = formulation.gaussPoints(elem); % gauss points and weights in the local coor
        xg = elem.local2global(ag); % gauss points in the global coor
        
        Ae = cell(length(shapes));
        for j=1:length(wg)
            for k=1:length(shapes)
                for l =1:length(shapes)
                    if j == 1
                        Ae{k,l} = 0;
                    end
                    Ae{k,l} = Ae{k,l} + elem.detJ(ag(j,:))*wg(j)*expression(ag(j,:),xg(j,:),shapes{k},shapes{l});
                end
            end 
        end
        A(index,index) = A(index,index) + cell2mat(Ae);
    end

end