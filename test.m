import mesh.*

% Create mesh
x = Mesh(2,1);

% Add nodes
n1 = x.addNode([0 0 1]);
n2 = x.addNodes([2 0;0 2]);

% Create element and add it to the mesh
e1 = x.addElem(Triangle3({n1,n2{:}}));

% Compute matrix of the problem
K = BilinearForm(x,@(a,x,N1,N2) N1.globalDiff(a)'*N2.globalDiff(a));
M = BilinearForm(x,@(a,x,N1,N2) N1.exp(a)'*N2.exp(a));

f = LinearForm(x,@(a,x,N1) x(1)*x(2)*N1.exp(a));

u = zeros(3,1);
u(3) = K(3,3)\f(3);