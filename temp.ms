/* 
--------------------------------------------------------------------------------------------------------------------------------
fn find_intersection z_node 	node_to_z 	=(
	local testRay = ray node_to_z.pos [0,0,-1]
	local nodeMaxZ = z_node.max.z
	testRay.pos.z = nodeMaxZ + 0.0001 * abs nodeMaxZ
	intersectRay z_node testRay
)
for i in selection do				(
	int_point = find_intersection target_mesh i
	if int_point != undefined then i.pos = int_point.pos
)
--------------------------------------------------------------------------------------------------------------------------------
 */



struct str_equationPlan (
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="str_equationPlan",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		a,
		b,
		c,
		d,
		normal ,
		
		fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
			
			debug "creerFrom_2vecs_et_1Point"
			---le vec normal du plan-----
			local norm1 = normalize _vec1
			local norm2 = normalize _vec2		
			normal =  cross    norm2 	norm1
			
			--- definition equation ---------
			a = normal.x
			b = normal.y
			c = normal.z		
			d = -( a*_point.x + b*_point.y + c*_point.z )
			
			debug "a" var:a
			debug "b" var:b
			debug "c" var:c
			debug "d" var:d
		),
		fn projeter_point_verticalement 		_pt 	=(
			debug "projeter_point_verticalement"
			local result = copy _pt
			result.z =  -( a*_pt.x + b*_pt.y + d ) / c
			result
			
		),
		

		fn get_intersection_segment	_segPt1		_segPt2			=(
			
			local k	= -( a * _segPt1.x 		+	b * _segPt1.y 	+	c * _segPt1.z 	+ d ) 	/	( a * ( _segPt2.x -  _segPt1.x ) + b * ( _segPt2.y -  _segPt1.y )  + c * ( _segPt2.z -  _segPt1.z )  )

			local ptResult 	= [0,0,0]
			ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
			ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
			ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
			
			ptResult
			
		),
		fn segment_coupe	_segPt1		_segPt2			=(
			
			local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
			-- debug-------
			point pos:pointIntersect isSelected:true
			
			local vecSeg 	= ptsSeg[2] - ptsSeg[1] 
			local vecInter = pointIntersect - ptsSeg[1] 
			
			if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
				true
			else
				false
			
		)
		
		
		
		
)

/* 
fn get_intersection_seg_plan	_segPt1		_segPt2		_plan		=(
	
	local k	= -( _plan.a * _segPt1.x 		+	_plan.b * _segPt1.y 	+	_plan.c * _segPt1.z 	+ _plan.d ) 	/	( _plan.a * ( _segPt2.x -  _segPt1.x ) + _plan.b * ( _segPt2.y -  _segPt1.y )  + _plan.c * ( _segPt2.z -  _segPt1.z )  )

	local ptResult 	= [0,0,0]
	ptResult.x 			=  _segPt1.x + k * ( _segPt2.x 	-  _segPt1.x )
	ptResult.y 			=  _segPt1.y + k * ( _segPt2.y 	-  _segPt1.y )
	ptResult.z 			=  _segPt1.z + k * ( _segPt2.z 	-  _segPt1.z )
	
	ptResult
	
) */


fn segment_coupe_plan	_segPt1		_segPt2		_plan	=(
	
	local pointIntersect = (get_intersection_seg_plan 	_segPt1		_segPt2 	_plan	)
	-- debug-------
	point pos:pointIntersect isSelected:true
	
	local vecSeg 	= ptsSeg[2] - ptsSeg[1] 
	local vecInter = pointIntersect - ptsSeg[1] 
	
	if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
		true
	else
		false
	
)

------------------------
ptsPlan 	= #( $Point001.pos, $Point003.pos, $Point002.pos )
ptsSeg 	= #( $Point004.pos, $Point005.pos )
vec1 		= ptsPlan[2] - ptsPlan[1] 
vec2 		= ptsPlan[3] - ptsPlan[1] 
plan 		= str_equationPlan ()
plan.creerFrom_2vecs_et_1Point		vec1 	vec2	ptsPlan[1] 

---------------------------
plan.segment_coupe	ptsSeg[1]		ptsSeg[2]






/* 
lst =#()
for pos in #([-3412.44,1785.15,19.9154], [-3135.7,1497.75,69.752], [-3135.7,1497.75,69.752], [-3412.44,1785.15,19.9154]) 
do append lst ( point pos:pos )
select lst




$.EditablePoly.SetSelection #Face #{206..206}


 */








 /* 

struct str_equationPlan (
	a,
	b,
	c,
	d,
	normal ,
	fn creerFrom_2vecs_et_1Point	_vec1 	_vec2  	_point	=(
		
		---le vec normal du plan-----
		local norm1 = normalize _vec1
		local norm2 = normalize _vec2		
		normal =  cross    norm2 norm1
		
		--- definition equation ---------
		a = normal.x
		b = normal.y
		c = normal.z		
		d = -( a*_point.x + b*_point.y + c*_point.z )
		
	),
	fn projeter_point_verticalement 		_pt 	=(
		
		local result = _pt
		result.z =  -( a*_pt.x + b*_pt.y + d ) / c
		result
		
	)
)

pt_0 = $Point001.pos
pt_1 = $Point002.pos
pt_2 = $Point003.pos

pt_aProjeter = $Point004.pos

vec1 = pt_1 - pt_0
vec2 = pt_2 - pt_0

planPlan = str_equationPlan ()
planPlan.creerFrom_2vecs_et_1Point		vec1	vec2	pt_0
pt_result = planPlan.projeter_point_verticalement 	pt_aProjeter

ptnd = point pos:pt_result
select ptnd




 */






/* 
fn get_normal_2vecs  vec1	vec2	=(


	norm1 = normalize vec1
	norm2 = normalize vec2

	vec3 =  cross    norm2 norm1

	vec3
)



vec3 = get_normal_2vecs vec1 vec2

ptnd = point pos:( pt_0 + vec3 * 10 )
select ptnd


 */




