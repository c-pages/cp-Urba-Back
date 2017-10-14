----------- Tracé du batiment et autres manipulations----------------
struct str_trace (
		geo_ptr,
		-----------------  Opérations diverses ----------------------
		fn surface 							_trace 	_this =(
			--- on creer une face sur le tracé ---------
			local faceTemp = geo_ptr.creerFace 	_trace  _this	--nd:nvNode
			
			--- pour utiliser cette fonction : ------
			local result = polyop.getFaceArea  delegate faceTemp
			
			--- on supprime la face, verts et edges créés--------
			polyop.deleteFaces 	delegate faceTemp
			
			result
		),
		fn edge_lePlusGrand			_trace 	=(
			local longueurEdgeMax = 0
			local	resultPts = #()
			for i = 1 to _trace.count do (
				local j = i+1
				if j > _trace.count  do j = 1
				local pt 			= _trace[	i ]
				local pt_suivant	= _trace[	j ]
				local longueurEdge = distance	pt	pt_suivant
				if longueurEdge > longueurEdgeMax do (
					longueurEdgeMax = longueurEdge
					resultPts = #(pt, pt_suivant)
				)
			)
			resultPts
		),
		fn pointLePlusHautsurY 		_trace	=(
			local maxi = _trace[1].y
			local result_id = 1
			for i = 1 to _trace.count do (
				local pt = _trace[	i ]
				if  pt.y > maxi do ( 
					maxi = pt.y
					result_id = i
				)
			)
			
	-- 			debug "pointLePlusHautsurY"	var:result_id
			result_id
		),
		fn est_sensPositif 				_trace 	=(
			
			local result 				= true
			local id_pointHaut 	=  pointLePlusHautsurY  	_trace
			
			local	id_pt_1 		= id_pointHaut - 1 	---- le point d'avant
			local	id_pt_ori 		= id_pointHaut 		---- le point origine
			local	id_pt_2 		= id_pointHaut + 1	---- le point d'apres
			
			-- Boucler limite nombre des points
			if id_pt_1 < 1 do id_pt_1 = _trace.count
			if id_pt_2 > _trace.count  do id_pt_2 = 1
			
			local	pt_1 		= _trace [	id_pt_1		]
			local	pt_ori 		= _trace [	id_pt_ori	]
			local	pt_2 		= _trace [	id_pt_2		]

			local	vec1 =  normalize ( pt_1 - pt_ori )
			local	vec2 =  normalize ( pt_2 - pt_ori )
			
			if vec2.x > vec1.X do result = not result
			
			result
			
		),
		fn reverse 						_trace 	=(
			local result =#()
			for i= _trace.count to 1 by -1 do 
				append result _trace[i]
			result
		),
			
		-----------------  Axe P ----------------------
		fn mtrx_axeP			_trace  							=(
			
			local ptsEdgeLePlusLong 	= edge_lePlusGrand	_trace
			
			local axeVecteur 		= 	normalize (ptsEdgeLePlusLong[2] - ptsEdgeLePlusLong[1])
			local axeMtrx				=  ( matrixFromNormal		axeVecteur )
			
			if axeMtrx.row1	==	[0,0,-1]  then 				
				axeMtrx =  (rotateYMatrix 180) *(rotateXMatrix 180) *  (rotateZMatrix -90) * axeMtrx
			 else if axeMtrx.row1	==	[0,0,1] do
				axeMtrx =  (rotateYMatrix 180)  *(rotateXMatrix 180)  * (rotateZMatrix 90) * axeMtrx
			
			axeMtrx		
		),
		fn BB_axeP			_trace  		_mtrxAxe  	=(
			
			local pt1 = _trace[1] * inverse _mtrxAxe
			local xMin = xMax = pt1.x
			local yMin = yMax = pt1.y
			local zMin = zMax = pt1.z
			
			for i = 2 to _trace.count do (
				local pt = _trace[i] * inverse _mtrxAxe
				if pt.x < xMin 		do xMin 		= pt.x
				if pt.x > xMax 	do xMax 	= pt.x
				if pt.y < yMin 		do yMin 	= pt.y
				if pt.y > yMax 	do YMax 	= pt.y
				if pt.z < zMin 		do zMin 		= pt.z
				if pt.z > zMax 	do zMax 	= pt.z
			)
			
			#([xMin, yMin, zMin]*  _mtrxAxe, [xMax, yMax, zMax]*  _mtrxAxe)
			
		),
		fn vec_axeP			_this		_vec 				=(
			
			local mtrx_Direction = _this.axeP_mtrx.rotationpart as matrix3
			local vec_direction = [0,0,1] * mtrx_Direction
			
			local vec1_dir = normalize _vec	
			
			local valTest =  abs  (dot  vec_direction	vec1_dir ) 
			
			if valTest	 > cos 45 then 
				#parallele
			else 
				#perpendiculaire
			 
		),
	
		
		----- MURS -----------------
		fn est_pignon 		_id	_this	= (
-- 			findItem _this.idtrace_pignons 	_id 	!= 0
			
			local j = _id+1
			if j > _this.trace_courant.count do j = 1
			
			orientation = vec_axeP	_this		(_this.trace_courant[j]-_this.trace_courant[_id])
			if orientation == #perpendiculaire then true else false
			
		),
		/* fn actualiser_pignonsEtGouttereaux  _this =(
			
			_this.idtrace_pignons 		=#()
			_this.idtrace_gouttereaux 	=#()
			
			for i =1 to _this.trace_courant.count do (
				local j = i+1
				if j > _this.trace_courant.count do j = 1
				
				local orientation = vec_axeP	_this		(_this.trace_courant[j]-_this.trace_courant[i])
				case orientation of (
					#perpendiculaire: 	append 	_this.idtrace_pignons			i
					#parallele: 				append 	_this.idtrace_gouttereaux	i
				)
				
			)
		), */
		
		fn actualiser_axeP	  _this	=(
			
			local mtrxTmp 			= mtrx_axeP  _this.trace_original 	
			rotateZ	mtrxTmp		_this.axeP_orientation
			_this.axeP_mtrx 			= mtrxTmp		
			_this.axeP_BB				=	BB_axeP		_this.trace_courant 		_this.axeP_mtrx
			
-- 			actualiser_pignonsEtGouttereaux _this
			
		),
		
		
		
		
		-----------------  Optimisation ----------------------
		fn orthonormer 	_this		=(
			
			local mtrx_AP = _this.axeP_mtrx
			
			for i = 1 to _this.trace_courant.count do (
				
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt = _this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = _this.trace_courant[j] *  inverse mtrx_AP 
				local vec_moyenne 
				
				local estPignon = est_pignon i _this
				if not estPignon then (
					local moyenneX = ( pt_suivant.x - pt.x ) /2					
					vec_moyenne = [moyenneX,0,0] * _this.seuil_ortho / 100
				) else  (
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					 vec_moyenne = [0,0,moyenneZ] * _this.seuil_ortho / 100
				) 
				
				pt 			= _this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
				pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
				
				_this.trace_courant[i] = pt *   mtrx_AP 
				_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
			)
		/* 	--- les Gouttereaux  --
			for i = 1 to _this.trace_courant.count do (
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt = _this.trace_courant[i]	* inverse  mtrx_AP 
				local pt_suivant = _this.trace_courant[j] *  inverse mtrx_AP 
				
				local estPignon = findItem _this.idtrace_pignons i != 0 
				if  estPignon then (
					
					local moyenneZ = ( pt_suivant.z - pt.z ) /2					
					local vec_moyenne = [0,0,moyenneZ] * _this.seuil_ortho / 100
					pt 			= _this.trace_courant[i]	* inverse  mtrx_AP  + vec_moyenne 
					pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  - vec_moyenne 
					
					_this.trace_courant[i] = pt *   mtrx_AP 
					_this.trace_courant[j] = pt_suivant  *   mtrx_AP 
				) 
			) */
			
	-- 			result
		),
		fn souder 			_this		=(
			
			local i = 1
			while i <=_this.trace_courant.count do (
				local j= i+1
				if j > _this.trace_courant.count  do j =1
				local pt 			= _this.trace_courant[i]
				local ptSuivant 	= _this.trace_courant[j]
				if distance pt ptSuivant <= _this.seuil_souder do (
					deleteitem _this.trace_courant j
					_this.trace_courant[i] = ( pt + ptSuivant ) / 2
					i = 1
				)
				i+=i
			)
			
		),
		fn optimiser 		_this		=(
			
			local i = 1
			while i <= _this.trace_courant.count do (
				
				local h = i - 1
				if h < 1  do h = _this.trace_courant.count
				local j= i+1
				if j > _this.trace_courant.count  do j =1
				local ptDAvant 	= _this.trace_courant[h]
				local pt 			= _this.trace_courant[i]
				local ptSuivant 	= _this.trace_courant[j]
				
				local vec1 = normalize (ptDAvant - pt)
				local vec2 = normalize (ptSuivant - pt)
				
				local anglePt = acos(dot vec1 vec2)			
				if 	anglePt >= 180 - _this.seuil_optimiser  then (
					deleteitem _this.trace_courant i
					i = 0
				)
				dot
				i +=1
			)

			result
		),
		fn chercher_alignements		_idTest		_this		=(
			
			local seuil 			= _this.seuil_aligner	
			local mtrx_AP 	= _this.axeP_mtrx
			local pt_test					= _this.trace_courant[_idTest]		* inverse  mtrx_AP
			local result =#()
		
				
			for i = 1  to _this.trace_courant.count do (
				local j = i + 1
				if j > _this.trace_courant.count do j = 1
				local pt 					= _this.trace_courant[i]	* inverse  mtrx_AP
				local pt_suivant 			= _this.trace_courant[j]	* inverse  mtrx_AP
				
				if est_pignon  	_idTest	_this	 and est_pignon i 	_this 					do 	(
					
					if abs ( pt_test.z - pt.z ) < seuil do (
	-- 					format 	"	---->proches sur X !!!\n"
						appendIfUnique result i
					)
					if abs ( pt_test.z - pt_suivant.z ) < seuil do (
	-- 					format 	"	---->proches sur X Suiovant    !!!\n"
						appendIfUnique result i
					)
				)
				
				if not est_pignon  	_idTest	_this	 and not est_pignon i _this 	do (
					
					if abs ( pt_test.x - pt.x ) < seuil do (
	-- 					format 	"	---->proches sur X !!!\n"
						appendIfUnique result i
					)
					if abs ( pt_test.x - pt_suivant.x ) < seuil do (
	-- 					format 	"	---->proches sur X Suiovant    !!!\n"
						appendIfUnique result i
					)
				)
				
			)
				
				

			result
		),
		fn aligner				_this		=(	
			
			local mtrx_AP 	= _this.axeP_mtrx
			
			for i = 1 to   _this.trace_courant.count  do (
				
				local aligns = 	chercher_alignements		i		_this	
				
				local pt_moyenne = [0,0,0]
				for id_align in aligns do 
					pt_moyenne += _this.trace_courant[id_align]	* inverse  mtrx_AP
				pt_moyenne /=  aligns.count
				
				for id_align in aligns where  not est_pignon  	id_align		_this	 do (
					local pt 			= _this.trace_courant[id_align]	* inverse  mtrx_AP  
					local j = id_align + 1
					if j > _this.trace_courant.count do j = 1
					local pt_suivant 	= _this.trace_courant[j]	* inverse  mtrx_AP  
					local vec_moyenne1 	= pt_moyenne	 - pt
					local vec_moyenne2 	= pt_moyenne	 - pt_suivant
					local vec_align1 		= [vec_moyenne1.x,0,0] 
					local vec_align2 		= [vec_moyenne2.x,0,0] 
					
					pt 			= _this.trace_courant[id_align]	* inverse  mtrx_AP  	+ vec_align1 
					pt_suivant 	= _this.trace_courant[j]			* inverse  mtrx_AP  	+ vec_align2
					_this.trace_courant[id_align] = pt *   mtrx_AP 
					_this.trace_courant[j] = pt_suivant *   mtrx_AP 
					
				)
				
			)
		),
		
		
		
		
		
		
		
		fn intersection 	_pt_orig 	_pt_2 		_pt_seg_1 	_pt_seg_2  	_this	 =(
			local pt_result
			local seuil = 1
			
			local vec_proj		= _pt_orig - _pt_2
			local vec_seg		= _pt_seg_1 - _pt_seg_2
			
			local norm_proj		= normalize vec_proj
			local norm_seg		= normalize vec_seg
			local dot_proj_seg 	= dot norm_proj norm_seg
			
			
			--- si pas parallele -------------------------
			local a1, b1, a2, b2 
			local d1_vert = false
			local d2_vert = false
			if dot_proj_seg != 1 and dot_proj_seg != -1 do (
				
-- 				format "pas parallele"
				
				--- données pour les eaquations de droite y = ax + b ----
				-- droite projeté----------------------
				if (( _pt_orig.z *1000) as integer /1000  == ( _pt_2.z *1000) as integer /1000) then (
					-- horizontale --
					a1 = 0
					b1 	= _pt_orig.z 
				) else if (( _pt_orig.x *1000) as integer /1000  == ( _pt_2.x *1000) as integer /1000) then (
					-- verticale --s
					a1 	= 1
					b1 	= _pt_orig.z - _pt_orig.x
					d1_vert = true
				) else (
					a1 	= (_pt_orig.z - _pt_2.z ) / (_pt_orig.x - _pt_2.x)
					b1 	= _pt_orig.z - a1*_pt_orig.x
				)		
				-- droite reception
				if _pt_seg_1.z == _pt_seg_2.z then (
					-- horizontale --
					a2 = 0
					b2 	= _pt_seg_1.z 
				) else if _pt_seg_1.x == _pt_seg_2.x then (
					-- verticale --
					a2 	= 1
					b2 	= _pt_seg_1.z - _pt_seg_1.x
					d2_vert = true
				) else (
					a2 	= (_pt_seg_1.z - _pt_seg_2.z ) / (_pt_seg_1.x - _pt_seg_2.x)
					b2 	= _pt_seg_1.z - a2*_pt_seg_1.x
				)
				
				
				
				
				local x, y
-- 				if a1 != a2 then (
				if 	d1_vert then (
					if not d2_vert do (
						x =   _pt_orig.x
						y =   a2 * x + b2
					)
				) else 	if 	d2_vert then (
					if not d1_vert do (
						x =   _pt_seg_1.x
						y =   a1 * x + b1
					)
				) else (
						x =   ( b2 - b1 ) / (a1  - a2 )
						y =   a1 * x + b1
				)
-- 				)
				
				-- si on a un point on verifie la suite -----------------------------
				if x != undefined do (
					
					local pt_proj  = [x,0,y]
					
-- 					--- si le point projeté
-- 					if distance pt_proj  	_pt_seg_1 > seuil  and distance pt_proj  	_pt_seg_2 > seuil  do (
-- 						
-- 						format ", sup au seuil"*
					
						--- si projection est dans le bon sens ----------
						if   dot  ( normalize ( _pt_orig - _pt_2 ) )  (  normalize (   pt_proj - _pt_orig) )   > 0 do (
							
-- 							format ", on est dans le bon sens"
							local precision = 1000
							local dist_seg 		= ( ( distance _pt_seg_1 	_pt_seg_2 ) * precision as integer ) / precision
							local dist_ptProj 		= ( ( distance _pt_seg_1 	pt_proj 		+ distance _pt_seg_2 	pt_proj ) * precision as integer ) / precision							
-- 							format "( dist_seg: %,  dist_ptProj:%)" dist_seg  dist_ptProj
							
							if  dist_ptProj  as string == dist_seg as string  do (
-- 								format "PROJECTION ! \n"
-- 								format ", et on est dans le segment !"
								pt_result 	= pt_proj
							)
						)
-- 					)
				)
				
-- 				format "\n"
			)
			pt_result
		),
		
		
		
		
		fn boucler 	_array	_id_item 		=(
			
			
			if _id_item >	_array.count do _id_item = mod _id_item _array.count
			if _id_item < 1 do _id_item += _array.count
			_id_item as integer
		),
		
		
		
		
		fn trouver_pt 		_arraydePts  	_pt 	 =(
			local result = 0
			local seuil = 1
			local i = 1
			while i <= _arraydePts.count and  result == 0 do (
				local pt  =_arraydePts[i]
				if distance 	pt  _pt < seuil do
					result = i
				i+=1
			)
-- 			format "pt_est_dejaPresent :%\n" result
			result
		),
		fn pt_est_dejaPresent 		_arraydePts  	_pt 	 =(
			local result = ( trouver_pt	_arraydePts	_pt ) != 0
			result
		),
		
		
		
		fn projeter_trace		_this 		=(
			
			local mtrx_AP 	= _this.axeP_mtrx
			local seuil = 5
			local result
			local trace 		= _this.trace_courant
			local trace_temp =  for item in trace collect item
			
			local est_subdivise_total = false
			while not est_subdivise_total do (
				
				local est_subdivise = false
				local est_trouve = false
				
				local i = 1
				while i <=  trace_temp.count and not est_trouve do (
					
					local id_direction_suiv		=  boucler trace_temp  (i+1)
					local id_direction_prec		= 	boucler trace_temp  (i-1)
					
					local pt_orig		= 	trace_temp[ i ]	* 	inverse  	mtrx_AP  
					local pt_suiv		=	trace_temp[ id_direction_suiv  ]  * 	inverse  	mtrx_AP
					local pt_prec		= 	trace_temp[ id_direction_prec  ] * 	inverse  	mtrx_AP
					
					---- les segments a tester------------
					local compteur_segment = 0
					while compteur_segment <  trace_temp.count  - 2 and not est_trouve do (
						
						--- le segment -----
						local id_seg_1 	= boucler trace_temp  ( i + compteur_segment + 1 )
						local id_seg_2 	= boucler trace_temp  ( i + compteur_segment + 2	)
						
						local pt_seg_1	= trace_temp[ id_seg_1 ]	* 	inverse  	mtrx_AP
						local pt_seg_2	= trace_temp[ id_seg_2 ] 	* 	inverse  	mtrx_AP 
						
						--- la projection 1 -------
						local pt_proj = intersection 	pt_orig		pt_suiv		pt_seg_1	 	pt_seg_2	_this	
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						--- la projection 2 -------
						local pt_proj = intersection 	pt_orig		pt_prec		pt_seg_1	 	pt_seg_2	_this
						
						if pt_proj != undefined  do (	
							
							if distance pt_proj 	pt_seg_1 > seuil and  distance pt_proj 	pt_seg_2 > seuil do (
								if not pt_est_dejaPresent   trace_temp  	( pt_proj	* 	mtrx_AP )	 do ( 
									local id_place = trouver_pt	 trace_temp  ( pt_seg_1 * 	mtrx_AP )
									insertItem			( pt_proj	* 	mtrx_AP )	trace_temp 	( id_place + 1 )
									est_subdivise = est_trouve = true
								)
							)
						)
						
						compteur_segment +=  1
					) -- fin while compteur_segment
					
					i += 1
					
				) -- fin while i  --
				
				if not est_subdivise do est_subdivise_total = true
				
			) -- fin while not est_subdivise_total
			
			_this.trace_courant = trace_temp
			
		),
		
		
		
		fn chercher_pt_a90degGauche	_id_pt  	vec_pt		_this =(
			
			local seuil = 1
			
-- 			format "chercher_pt_a90degGauche: %\n" _id_pt
			local vertexSurLigne = #()
			local mtrx_AP 		= _this.axeP_mtrx
			
-- 			local id_pt_preced 	= boucler 	_this.trace_courant	(_id_pt - 1)
			local pt 				= _this.trace_courant[ _id_pt ] 			* 	inverse  	mtrx_AP	
-- 			local pt_preced 		= _this.trace_courant[ id_pt_preced ] * 	inverse  	mtrx_AP	
			
-- 			local vec_pt 			= pt - pt_preced
			local norm_pt 		= normalize vec_pt
			
			local mtrx_rotateZ90	=	rotateY	(matrix3 1)	90
			local norm_test 			= norm_pt * mtrx_rotateZ90
			
			local pt_virtuel 			= pt + norm_test
			
			local a,b
			local verticale 		= false
			if (( pt.z *1000) as integer /1000  == ( pt_virtuel.z *1000) as integer /1000) then (
				-- horizontale --
				a = 0
				b = pt.z 
			) else if (( pt.x *1000) as integer /1000  == ( pt_virtuel.x *1000) as integer /1000) then (
				-- verticale --
				a 	= 1
				b 	= pt.z - pt.x
				verticale = true
			) else (
				a 	= (pt.z - pt_virtuel.z ) / (pt.x - pt_virtuel.x)
				b 	= pt.z - a1*pt.x
			)		
			
			
			if not verticale then (
				for i=1 to _this.trace_courant.count do (
					local pt_test = _this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.z - ( pt_test.x * a + b ) ) < seuil do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "norm_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			) else (
				for i=1 to _this.trace_courant.count do (
					local pt_test = _this.trace_courant[i] * 	inverse  	mtrx_AP	
					-- y = a*x + b
					if  abs ( pt_test.x - pt.x ) < seuil  do (
						
						local dot_test_dir = dot (normalize (pt_test - pt ))  norm_test
-- 						format "dot_test_dir: %\n" dot_test_dir
-- 						format "vec_pt: %\n" (normalize vec_pt )
						if pt_test != pt and dot_test_dir > 0 do 
							append vertexSurLigne i
						
					)
				)
			)
			
-- 			format "->	vertexSurLigne: %\n" vertexSurLigne
			vertexSurLigne
			local result 
			local dist_min = 0
			for id_pt_test in vertexSurLigne do (
				local pt_test = _this.trace_courant[ id_pt_test ] 			* 	inverse  	mtrx_AP	
				local dist_test = distance pt pt_test
				if  dist_test < dist_min or dist_min == 0 do (
					result = id_pt_test
					dist_min = dist_test
				)
			)
			
-- 			format "->	result: %\n" result
			result
			
		),
		
		
		
		
		
		fn subdiviser		_this 		=(
			
			local seuil 			= 1
			local mtrx_AP 	= _this.axeP_mtrx
			local trace 		= _this.trace_courant
			
			--- creer la face tracé pour tester intersection ------------
			local node_surface = convertToPoly ( mesh() )
			geo_ptr.vider	_this	nd:node_surface
			geo_ptr.creerFace	_this.trace_courant	_this	nd:node_surface
			
			for i = 1 to  trace.count 	do (
-- 				format "------------------------- i: % ----------------------------\n" i
				local est_trouve 		=false 
				local pt_orig			= 	trace[ i ]	* 	inverse  	mtrx_AP  	

				local id_pt_preced 	= boucler 	trace	( i - 1)
				local pt_preced 		= trace[ id_pt_preced ] * 	inverse  	mtrx_AP	

				local vec_pt 			= pt_orig - pt_preced		
				local id_pt_1, id_pt_2, id_pt_3, id_pt_4
				id_pt_1	= chercher_pt_a90degGauche	i 	vec_pt	_this 
				if id_pt_1 != undefined then (
					
-- 					format "->	id_pt_1: %\n"	id_pt_1
					local norm 		= vec_pt * (rotateY	(matrix3 1)	90 )
					id_pt_2				= chercher_pt_a90degGauche	id_pt_1 	norm	_this 
				)  
				
				if id_pt_2 != undefined then (
-- 					format "->	id_pt_2: %\n"	id_pt_2
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	180 )
					id_pt_3 				= chercher_pt_a90degGauche	id_pt_2 	norm	_this 
				)  
				
				if id_pt_3 != undefined then (
-- 					format "->	id_pt_3: %\n"	id_pt_3
					local norm	 	= vec_pt * (rotateY	(matrix3 1)	270 )
					id_pt_4 				= chercher_pt_a90degGauche	id_pt_3 	norm	_this 
				)  
				
				if id_pt_4 == i do est_trouve = true
					
				if est_trouve do (
					
-- 					format "------------->  RECTANGLE : %, %, %, %\n"	id_pt_1 id_pt_2 id_pt_3 id_pt_4
					/* 
					--- on verifie si le rectangle est dans le tracé -------------
					local bary = ( (pt_orig + pt_rect_1 + pt_rect_2 + pt_dernCoin ) / 4 ) * 	 	mtrx_AP  
					bary.z +=10
					ray_test = ray bary	 [0,0,-1]
					local ray_result = intersectRay 		node_surface		ray_test
					format"est dans le tracé : %\n" (ray_result != undefined )
					
					
					
					local sp = splineShape name:("i: " + i as string )
					addnewSpline sp
					addKnot sp 1 #corner #line ( pt_orig			* 	mtrx_AP )
					addKnot sp 1 #corner #line ( pt_rect_1		* 	mtrx_AP )
					addKnot sp 1 #corner #line ( pt_rect_2		* 	mtrx_AP )
					addKnot sp 1 #corner #line ( pt_dernCoin		* 	mtrx_AP )
					close sp 1
					updateShape sp */
				)
			) -- fin while i  --
			
			delete node_surface
			
		),
		
		
		fn decouper 		_this 		=(
			
			--- on  les points projetés au tracé --------
			projeter_trace 		_this
			
			--  points concaves -----------------
			subdiviser	_this
			
		
		),
		
	
	
		
		
		
		------------tracé du batiment ---------------
		fn fromSpline 		_shapeNvtrace 	= (
			
			local trace_absolu					=#()
			local subSplineOuvertes 		=#()
			local nvtraceTMP 					=  copy _shapeNvtrace
			local id_premiertraceFerme 	= 0
			
			--- on ne prend que la premiere spline fermée-----
			convertToSplineShape nvtraceTMP
			local b_trouve = false
			for idSpline = 1 to (numSplines nvtraceTMP) while not b_trouve	do
				if isClosed  nvtraceTMP	idSpline	then	(
					id_premiertraceFerme = idSpline
					b_trouve = true
				)
			
			---- si on a trouvé la spline --------------------
			if id_premiertraceFerme != 0 do (
				
				---- mise a jour de trace_courant -----------
				for id_pt = 1 to ( numKnots 	nvtraceTMP 	id_premiertraceFerme ) do	 (
					ptSpline = ( getKnotPoint 	nvtraceTMP 	id_premiertraceFerme 	id_pt ) 
	-- 				ptSpline.z = 0
-- 					debug "ptSpline" var:ptSpline
					append trace_absolu 	 ptSpline
				)
				
				--- on fait tourner les spline dans le meme sens ----
				if not est_sensPositif 	trace_absolu 	 do
					trace_absolu = reverse		trace_absolu
			)
			
			--- suppression de tracée temp -------------
			delete nvtraceTMP
			
			trace_absolu
		),
	
		 
		fn actualiser 	_this 	=(
			
			-- ? ! ? ! ? ! ---------
			geo_ptr.vider 	_this		
			-- ? ! ? ! ? ! ---------
			
			_this.trace_courant = _this.trace_original as array
			actualiser_axeP 	_this
			
			---- orthonormer -----------
			if _this.trace_ortho 			do	orthonormer	_this
			if _this.trace_souder		do	souder			_this
			if _this.trace_optimiser 	do	optimiser		_this
			if _this.trace_aligner 		do	aligner 			_this 	
			if _this.trace_decouper 	do	decouper 		_this 		
			
		),
		
		fn definir	 	_shapeNvtrace  		_thisNode		=(
			
			local trace_absolu					= fromSpline 	_shapeNvtrace
			if trace_absolu.count > 0 do (
				
				-- on vide les tableaux ----
				_thisNode.trace_original 			=#()
				_thisNode.trace_courant			=#()
				
				_thisNode.transform = (matrix3 1)
				ResetPivot 			_thisNode
				
				---- centrer le pivot ----
				local pt_sommeDesPts = 0
				for pt in trace_absolu do
					pt_sommeDesPts += pt
				local pt_centre = pt_sommeDesPts / trace_absolu.count
				_thisNode.pos = pt_centre
				
				---- actualiser les tracés ----
				for pt in trace_absolu do (
					append _thisNode.trace_original			( pt * inverse _thisNode.transform )
					append _thisNode.trace_courant 		( pt * inverse _thisNode.transform )
				)
				
				--- Axe principal-------------------coordsys
				_thisNode.a_un_trace 			= true
				
				----- calcul de la surface du trace_courant ------
				_thisNode.surface = surface 		_thisNode.trace_courant	_thisNode
			)
			actualiser  _thisNode
		)
		
) -- fin struct TRACE ---------

