
struct str_plan (
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="str_plan",
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
			
-- 			debug "creerFrom_2vecs_et_1Point"
			---le vec normal du plan-----
			local norm1 = normalize _vec1
			local norm2 = normalize _vec2		
			normal =  cross    norm2 	norm1
			
			--- definition equation ---------
			a = normal.x
			b = normal.y
			c = normal.z		
			d = -( a*_point.x + b*_point.y + c*_point.z )
			
-- 			debug "a" var:a
-- 			debug "b" var:b
-- 			debug "c" var:c
-- 			debug "d" var:d
		),
		fn projeter_point_verticalement 		_pt 	=(
-- 			debug "projeter_point_verticalement"
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
		fn coupe_segment	_segPt1		_segPt2			=(
			
			local pointIntersect = get_intersection_segment 	_segPt1		_segPt2 		
			-- debug-------
-- 			point pos:pointIntersect isSelected:true
			
			local vecSeg 	= _segPt2 - _segPt1
			local vecInter = pointIntersect - _segPt1
			
			if dot vecSeg vecInter >0 and length vecSeg > length vecInter then
				true
			else
				false
			
		)
		
		
		
		
)

------------------------------------------------------------------------------------------------------------------------------------


struct str_facade_modele (
		
		id				= "#FAC_MOD_",
		nom 			=	"Modèle",
		
		verts 		= #(),
		edges		= #(),
		faces			= #(),		
		SMs			= #(),
		matIDs		= #(),
		
		longueur 	=  0.,
		hauteur		=	0.,
		
		----- events ------------------------------------------
		on create do (			
			---- generation de l'id unique -------
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		)

)



struct	str_facade_param_baieSimple (
	
	---- membres ----------
	pos_hauteur 	= 100,
	profondeur		= 20,
	
	
	---- fonctions ----------
	fn creer 	_faces 	_this	=(
		
	)
	
	
	
)



------------------------------------------------------------------------------------------------------------------------------------
struct	str_facade_parametrique	(
	
		---- parametres communs --------
		id				= "#FAC_PARAM_",
		
		longueur		=	100,
		hauteur		=	100,
		
		params,		---- reçoit struct portant les parametres les parametres
-- 		creer,		---- reçoit la fonction de creation utilisant les parametre 		
		
		----- events ------------------------------------------
		on create do (			
			---- generation de l'id unique -------
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		)
)






------------------------------------------------------------------------------------------------------------------------------------
struct str_facade_composant (
		
		id							= "#FAC_CMP_",
		nom 						=	"Composant de façade",
		
		type						= #Espacement,		--->	#Espacement		#LongueurFixe		#Modele
		
		longueur					=	0.,	
		modeles					=	#(),
		modeles_probas		=	#(),
		
		----- events ------------------------------------------
		on create do (
			---- generation de l'id unique -------
			if type == #Espacement then 
				id = "#FAC_CMP_ESP"
			else
				for i= 1 to 10 do id += ( random 0 9 ) as string	
		)
	
)

 
 

------------------------------------------------------------------------------------------------------------------------------------

struct str_facade (
		
		nom 						=	"Façade",
		
		etages_use_min		=	false,
		etages_nbre_min		= 	0,
		etages_use_max		=	false,
		etages_nbre_max		=	0,
	
		murs						=	1,			---- (les deux ,gouttereaux, pignons )
		mode						=	1,			---- (repeter, etrier, centrer)
		
		sequence				=	#()
		
) 