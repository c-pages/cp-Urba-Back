fn get_edge_lePlusGrand	_spline 	_idSpline =(
	local 	longueurEdgeMax = 0
	local	resultEdgeId
	for i = 1 to ( numKnots _spline 	_idSpline) - 1 do (
		local pt 			= getKnotPoint _spline 	_idSpline 	i
		local pt_suivant	= getKnotPoint _spline 	_idSpline 	(i+1)
		local longueurEdge = distance	pt	pt_suivant
		if longueurEdge > longueurEdgeMax do (
			longueurEdgeMax = longueurEdge
			resultEdgeId = i
		)
	)
	resultEdgeId
)
fn get_axePrincipal  _spline 	_idSpline  =(
	
	local edgeLePlusLong 	= get_edge_lePlusGrand	_spline 	_idSpline 
	local pts 					= #(	getKnotPoint _spline 	_idSpline 	edgeLePlusLong, 
											getKnotPoint _spline 	_idSpline 	( edgeLePlusLong + 1) )
	local axeVecteur 		= 	normalize (pts[2] - pts[1])
	local axeMtrx				=  /* inverse */  ( matrixFromNormal		axeVecteur )
	translate	axeMtrx  pts[1]
	
	-- debug--
-- 	local ptDebug = point transform:axeMtrx	
-- 	select ptDebug
	
	
	axeMtrx
	
)


fn get_BB_axePrincipal  	_spline 	_idSpline  =(
	
	local mtrx_axePrincipal	=	get_axePrincipal 	_spline	_idSpline
	
	local pt1 = ( getKnotPoint _spline 	_idSpline 	1 ) * inverse mtrx_axePrincipal
	local xMin = xMax = pt1.x
	local yMin = yMax = pt1.y
	local zMin = zMax = pt1.z
	
	for i = 2 to ( numKnots _spline 	_idSpline) do (
		local pt = ( getKnotPoint _spline 	_idSpline 	i ) * inverse mtrx_axePrincipal
		if pt.x < xMin 		do xMin 		= pt.x
		if pt.x > xMax 	do xMax 	= pt.x
		if pt.y < yMin 		do yMin 	= pt.y
		if pt.y > yMax 	do YMax 	= pt.y
		if pt.z < zMin 		do zMin 		= pt.z
		if pt.z > zMax 	do zMax 	= pt.z
	)
	/* 
	local xMin 	= xMin 	* inverse mtrx_axePrincipal
	local xMax 	= xMax 	* inverse mtrx_axePrincipal
	local yMin 	= yMin 	z* inverse mtrx_axePrincipal
	local yMax = yMax 	* inverse mtrx_axePrincipal */
	
	-- debug--
	local ptDebug1 = point transform:mtrx_axePrincipal	pos:([xMin, yMin,zMin]*  mtrx_axePrincipal)	size:200
	local ptDebug2 = point transform:mtrx_axePrincipal	pos:([xMax, yMax,zMax]*  mtrx_axePrincipal)	size:200
	select #(ptDebug1,ptDebug2)
	
	
	#([xMin, yMin, zMin], [xMax, yMax, zMax])
)


fn creer_toiture 	_node 	_spline 		_idSpline  =(
	
)



get_BB_axePrincipal	 $Shape005 1







