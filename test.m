import mesh.*

% Create mesh
x = Mesh(2,1);

% Add nodes
n1 = x.addNode([0 0 1]);
n2 = x.addNodes([2 0;0 2]);

% Create element and add it to the mesh
e1 = x.addElem(Triangle3({n1,n2{:}}));

