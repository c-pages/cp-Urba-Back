

struct str_constr_outils (
		
		---- manipulation de tableaux ----
		fn ComparerTableaux 	first 	second =
		(
			result = true
			if first.count != second.count then
				result = false
			else
				for i = 1 to first.count do
					if first[i] != second[i] do result = false
			result
		),
		fn virerDoublonsDansTableau  _tab = (
			for i = 1 to _tab.count do
			(
				for j = _tab.count to i+1 by -1 do
				(
					test = ( ComparerTableaux  _tab[i] _tab[j] )
					if test do
					(
						deleteItem _tab j
					)
				)--end j loop
			)--end i loop
		),
		
		
		
		
		
		
		---- groupes de selection  ----
		fn grouperFaces 	_node 	_faces 	_nom 	=(
			if _node.faces[_nom] == undefined  
							then		_node.faces[_nom] = 	_faces
							else		(								
								tabFaces = for face in _node.faces[_nom] collect face.index
								tabFaces += _faces
								_node.faces[_nom] = tabFaces
							)
		),
		fn degrouperFaces 	_node 	_facesARetirer 	_nom 	=(
			if _node.faces[_nom] != undefined  do		(								
				tabFaces = for face in _node.faces[_nom] collect 	face.index
					for  _face in _facesARetirer do (
						idItem = findItem tabFaces   _face
						if idItem >0 do deleteItem 	tabFaces  idItem
					)
				_node.faces[_nom] = tabFaces
			)
		),
		
		
		
		---- manipulation des selection  ----
		fn etendreSelecFaces		_node 	_faces	= (
			
			_faces_a_retirer = _faces 		---- ( polyop.getFaceSelection  _node ) as array
			_node.EditablePoly.GrowSelection ()
			_facesExtension	= ( polyop.getFaceSelection  _node ) 
			for face in _faces_a_retirer 	do _facesExtension	[face] 	= false
			polyop.setFaceSelection  _node 	_facesExtension	
			
		),
		
		fn facesDuDessous		_node	_faces	=	(
			
			local _selectBack 	= 	polyop.getFaceSelection  _node 
			local	_facesDuBas 	= #()
			for _face in _faces do (
				polyop.setFaceSelection  	_node 	#(_face)
				outils.etendreSelecFaces 	_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	
						then _faceDuBas = _faceCadre
					else	if ( outils.centreDeLaFace	_node	_faceCadre ).z  <  (outils.centreDeLaFace	_node	_faceDuBas ).z 	
						then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			polyop.setFaceSelection  _node 	_selectBack
			
			for _face in _facesDuBas do
				format "face : %  centre Z : % \n" 	_face	( outils.centreDeLaFace	_node	_face )
			
			
			_facesDuBas
		),		
		fn BACKfacesDuDessous		_node	_faces	=	(
			
			local	_facesDuBas = #()
			for _face in _faces do (
				polyop.setFaceSelection  _node 	#(_face)
				outils.etendreSelecFaces 		_node 	#(_face)
				facesCadre = polyop.getFaceSelection  _node
				local		_faceDuBas
				for _faceCadre in facesCadre do 
					if _faceDuBas == undefined 	then _faceDuBas = _faceCadre
						else	if ( outils.centreDeLaFace		_node		_faceCadre ).z  <  (outils.centreDeLaFace		_node		_faceDuBas ).z 	then _faceDuBas = _faceCadre
				
				append _facesDuBas _faceDuBas
			)
			
			format "Faces du bas : %\n" _facesDuBas
			_facesDuBas
		),
		
		fn faceLaPlusProche		_node		_faces		_ptReference 	= (							
			local faceLaPlusProche
			local distMin = 1000000000000.0
			for faceTmp in _faces do (
				centreFaceTmp 		= 		outils.centreDeLaFace		_node		faceTmp
				dist = length 	(  	centreFaceTmp - _ptReference )
				if dist < distMin do (
					distMin = dist
					faceLaPlusProche = faceTmp
				)
			)
			faceLaPlusProche
		),
		
		---- selection par taille ----
		fn arreteLaPlusPetite		_node		_listeArretes	= (
			
			local arretePlusPetite,  longMin
			
			for arrete in _listeArretes do (
				listePoints = polyop.getEdgeVerts  	_node	arrete
				pt1 = _node.verts[listePoints[1]]
				pt2 = _node.verts[listePoints[2]]
				longueurArrete =  length ( pt1.position	- pt2.position  )
				
				if longMin == undefined do (
					longMin = longueurArrete					
					arretePlusPetite = arrete
				)
				
				if longueurArrete < longMin do (
					longMin = longueurArrete
					arretePlusPetite = arrete
				)
				
			) -- fin for do --
			
			arretePlusPetite
			
		),
		fn arretesLesPlusPetites		_node		_listeArretes	 nbre: = (
			
			local _arretesPlusPetites,  longMin
			local _nbresArretes = floor ( (_listeArretes as array).count / 2 )
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresArretes	= floor ( (_listeArretes as array).count / 2 )
				else		_nbresArretes	= nbre
				
			while _result.count < _nbresArretes do (
				local _arreteAAJouter = arreteLaPlusPetite		_node		_listeArretes
				
				deleteItem	_listeArretes 	_arreteAAJouter
				append 		_result  		_arreteAAJouter
			)
			
			_result
			
		),		
		fn facesLesPlusPetites	_node	_faces	nbre: =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 1000000000000000000000000000.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face <= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),		
		fn facesLesPlusGrandes	_node	_faces	nbre:  =(
			local _nbresFaces 
			local _result = #()
			
			if nbre == unsupplied 
				then		_nbresFaces	= floor ( (_faces as array).count / 2 )
				else		_nbresFaces	= nbre
			
			while _result.count != _nbresFaces do (
				local _min = 0.0
				local _faceAAJouter
				for _face in _faces do (
					if polyop.getFaceArea _node _face >= _min  and (findItem _result _face ) == 0 do (
						_faceAAJouter 	= _face
						_min 				= polyop.getFaceArea _node _face 
					)
				)
				append _result 	_faceAAJouter
			)
			_result
		),
		
		
		---- selection par position ----
		fn faceLaPlusHaute 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute = undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  > ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			faceHaute
		),		
		fn faceLaPlusBasse 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute == undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			 faceHaute
		),
		
		
		---- meusures ----
		fn ZMinFace 	_node  _listeFaces = (
			
			local pointLePlusBas
			
			for face in _listeFaces do (
				listePoints = polyop.getFaceVerts  	_node	face
				for IDpt in listePoints do (
					pt = _node.verts[IDpt]
					if pointLePlusBas == undefined do pointLePlusBas = pt.position.z
					if pointLePlusBas > pt.position.z do pointLePlusBas = pt.position.z
				)
			)			
			 	pointLePlusBas			
		),
		fn largeurFace 	_node _face = (
			local listePoints = polyop.getFaceVerts  	_node	_face
			local result = 0
			for  i=1 to listePoints.count-1 do (
				pt_1 = _node.verts[ listePoints[ i ] ]				
				for  j=i+1 to listePoints.count do (				
					pt_2 	= _node.verts[ listePoints[ j ] ]
					dist 		= length ( pt_2.position - pt_1.position )
					if pt_1.position.z == pt_2.position.z and dist > result
						do result = dist
				)
			)
			 result
		),
		fn hauteurFace 	_node 	_face = (
			local _listePoints = polyop.getFaceVerts  	_node	_face
			local _result = 0, _mini = 10000000000, _maxi = 0
			for  _pt in _listePoints 	do (
				_pt = _node.verts[ _pt ]		
				if _pt.position.z < _mini 	do _mini 	= _pt.position.z
				if _pt.position.z > _maxi 	do _maxi 	= _pt.position.z
			)
			_result = _maxi  - _mini
			_result
		),
		
		
		fn centreDeLaFace	_node	_face = (
			
			local versionMax = true
			local centre = [0,0,0]
			
			---- la version max fait  une position  moyenne de tout les points , => pb si 5points sur  la face par ex ----
			if versionMax then
				centre = polyop.getFaceCenter _node _face
			
			---- debut de version centre perso qui deconne ----
			else (
				
				local listePoints 							= polyop.getFaceVerts  	_node	_face
				local pointsAlignesVerticalement	= #()
				local ptsResult 								= #()
				local coinHtG, coinHtD, coinBsG, coinBsD
				
				---- regrouper les points alignés verticalement	----
				for  i=1 to listePoints.count do (
					
					local	ID_pt_1 	= listePoints[ i ] 
					local	pt_1 		= _node.verts[ ID_pt_1 ]				
					local resultTmp = #( ID_pt_1 )
					
					for  j=1 to listePoints.count do (
						ID_pt_2 = listePoints[ j ] 					
						pt_2 = _node.verts[ ID_pt_2 ]
						
						if floor (  pt_1.position.x * 10 )	== floor ( pt_2.position.x * 10 ) do 
							if floor ( pt_1.position.y * 10 ) == floor ( pt_2.position.y * 10 ) do 
								appendIfUnique resultTmp 		ID_pt_2
						
					)
					sort resultTmp
					
					if resultTmp.count > 1 do 	append 	 	pointsAlignesVerticalement 		resultTmp
					
				)
				
				virerDoublonsDansTableau  pointsAlignesVerticalement 
				
				---- selection dans chaque groupe de points du plus haut et du plus bas	----
				for listPts in pointsAlignesVerticalement do (
					---- min ----
					local minZ, maxZ
					for ptID in listPts do (
						if minZ == undefined do minZ = ptID
						if maxZ == undefined do maxZ = ptID
						
						if _node.verts[ ptID ].position.z > _node.verts[ minZ ].position.z   do minZ =ptID
						if _node.verts[ ptID ].position.z < _node.verts[ maxZ ].position.z  do maxZ =ptID
						
					)
					append ptsResult minZ
					append ptsResult maxZ
				)
				
				sort ptsResult
				
				---- moyenne des points hauts et bas	----
				if ptsResult.count != 0 do (
					for IDpt in ptsResult do  (
						centre += _node.verts[ IDpt ].position
						format "_node.verts[ IDpt ].position : %\n" _node.verts[ IDpt ].position
					)
					centre = centre / ptsResult.count
	-- 				format "	=>	centre : %\n" centre
				)
						format "face : %\n" 	_face
				format "	=>	centre : %\n" centre
				
				centre
			)
		) -- fin else
		
)	-- fin struct outils






----------- Construction des batiments----------------------------------------------------------------------
struct str_construire (
	
		------------ DEBUG	-------------------------------------------------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="urba | str_construire",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		fn logout 	_txt  var:	 param:    =(
			::ecrire 	_txt  	var:var	 param:param	prefix:m_dbgPrefix	script:"URBA"
			
		),
		
		
		
		---- Membres ---------------------------------------------
		geo_ptr,		
		outils						=	str_constr_outils (),
		
		modeles_import 		=#(),		
		
		---- constantes------------------
		ep_ssBassement 	= 	100,
		ep_dalle 			= 20,
		ep_mur	 			= 20,
		ep_couvertine	 	= 5,
		
		
		
		
		
		---- Fonctions ---------------------------------------------
		---- Outils ----
		fn get_hauteurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local hauteur = BB[2].z -  BB[1].z 
			hauteur
		),
		fn get_largeurNodeModele 	_nd	=(
			local  BB = nodeGetBoundingBox 	_nd	(matrix3 1)
			local largeur = BB[2].x -  BB[1].x 
			largeur
		),
		fn get_angle_vecteur 	vec	=(
			
			local result = 0
			local angle_tan = atan ( vec.y / vec.x )
			
			if vec.x >=0 then (
				if vec.y >= 0 then 	result = angle_tan
				else 	result = 360 + angle_tan
			) else (		
				if vec.y >= 0 then 	result = 180 + angle_tan
				else result = 180 + angle_tan
			)
			
			result
		),		
	
		
		
		
		---- Composant parametrique	 ----
		fn baie_simple 		_params	 	_pt1 		_norm	_this		= (
			local longueur = _params.m_composant.longueur
			local pt2 = 
			
			---- creation de l'allege ---------
			geo_ptr.creerFaceVerticale	_pt1		pt2 	z 	_this
		),
		
		
		
		
		------------ TOITURES-------------------------		
		fn toitPentes 		_this		&z	_nbrePentes	=(
			
			local	 mtrx_axeP	=	_this.axeP_mtrx
			local	 BB_axeP	=	_this.axeP_BB
			translate mtrx_axeP	BB_axeP[1]
			
			local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
			local largeur 		=	diag_axeP.x
			local longeur 		= 	diag_axeP.z
			local hauteur 		= largeur * tan _this.toit_pente		--	largeur /2 --* random .3 1.5
			
			local nvlsFaces 	= #()
			case _nbrePentes of (
				1: ( ---------- 1 PENTE ----------------------------------------------------------------------------------------------------
						--- gestion de l'angle de la pente .... ----
	-- 						hauteur = hauteur/4
						
						local pt_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )
						
						local vec1 = pt_1 - pt_0
						local vec2 = pt_2 - pt_0
						
						local pt_Origine = pt_0
						pt_Origine.z =  z + _this.toit_hauteur
	-- 						point pos:pt_Origine	 isSelected:true
					
						local plan_pente = str_plan ()
						plan_pente.creerFrom_2vecs_et_1Point	vec1	vec2		pt_Origine
						
						local pointsPente = #()
						local pointsMurs   =#()
						for i = 1 to  _this.trace_courant.count do (
							
							local j = i+1
							if j >  _this.trace_courant.count  do j = 1
							
							--- point Mur ----
							local pt 			= 	_this.trace_courant[i]	
							append pointsMurs  pt		
							
							local pt_result = plan_pente.projeter_point_verticalement 	pt
	-- 						pt_result.z += _this.toit_hauteur
							append pointsPente  pt_result
							
						)
						
						--- creation de la face du dessus ----
						append nvlsFaces ( geo_ptr.creerFace  	pointsPente 	_this	)
						
						---- creation des raccord mur ----------
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j >  pointsMurs.count  do j = 1
							
							local ptMur1 		= pointsMurs[i]
							local ptMur2 		= pointsMurs[j]
							local ptPente3 	= pointsPente[j]
							local ptPente4	= pointsPente[i]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							append nvlsFaces ( geo_ptr.creerFace  	pointsRaccord 	_this)
						)
					
				)
				2: (---------- 2 PENTES ----------------------------------------------------------------------------------------------------
					
					
						--- Plan de la Pente 1  ----
						local pt_P1_0 = (  [0,0,0]  *  mtrx_axeP )
						local pt_P1_1 = (  [0,0,longeur]  *  mtrx_axeP )
						local pt_P1_2 = (  [largeur ,hauteur,0]  *  mtrx_axeP )	
					
						local vecP1_1 = pt_P1_1 - pt_P1_0
						local vecP1_2 = pt_P1_2 - pt_P1_0
						
						local pt_Origine = pt_P1_0
						pt_Origine.z =  z + _this.toit_hauteur
						local plan_pente1 = str_plan ()
						plan_pente1.creerFrom_2vecs_et_1Point	vecP1_1		vecP1_2		pt_Origine
					
					
					
						--- Plan de la Pente 1  ----
						local pt_P2_0 = (  [largeur,0,longeur]  *  mtrx_axeP )
						local pt_P2_1 = (  [largeur,0,0]  *  mtrx_axeP )
						local pt_P2_2 = (  [0 ,hauteur,longeur]  *  mtrx_axeP )			
					
						local vecP2_1 = pt_P2_1 - pt_P2_0
						local vecP2_2 = pt_P2_2 - pt_P2_0
						
						local pt_Origine = pt_P2_0
						pt_Origine.z =  z + _this.toit_hauteur
						local plan_pente2 = str_plan ()
						plan_pente2.creerFrom_2vecs_et_1Point	vecP2_1		vecP2_2		pt_Origine
					
						--- Plan verticale faitage ------
						local pt_F_0 = (  [largeur /2 ,0,0]  *  mtrx_axeP )
						local pt_F_1 = (  [largeur /2 ,0,longeur]  *  mtrx_axeP )
						local pt_F_2	=	pt_F_0 + [0,0,100]				
						
						local vec_F_1 = pt_F_1 - pt_F_0
						local vec_F_2 = pt_F_2 - pt_F_0				
						
						local pt_Origine = pt_F_0
						pt_Origine.z =  z 
						
						local plan_verticaleFaitage = str_plan ()
						plan_verticaleFaitage.creerFrom_2vecs_et_1Point	vec_F_1		vec_F_2		pt_Origine
						
						
						
						---- creation des liste des points-----------
						local pointsPente = #()
						local pointsPente1 = #()
						local pointsPente2 = #()
						local pointsMurs   =#()
						for i = 1 to  _this.trace_courant.count do (
							
							local j = i+1
							if j >  _this.trace_courant.count  do j = 1
							
							
							--- point Mur ----
							local pt 			= 	_this.trace_courant[i]	
							pt.z = z
							append pointsMurs  pt		
							
							--- point pente ----
							local pt_pente1 = plan_pente1.projeter_point_verticalement 	pt
							local pt_pente2 = plan_pente2.projeter_point_verticalement 	pt
							if pt_pente1.z < pt_pente2.z then (
								append pointsPente  	pt_pente1
								append pointsPente1 	pt_pente1
								
							) else  (
								append pointsPente  	pt_pente2
								append pointsPente2  	pt_pente2
							)
							
							--- point mur - faitage ----
							local pt_suivant 	= 	_this.trace_courant[j]	
							pt_suivant.z = z
							local intersect = plan_verticaleFaitage.coupe_segment	pt 	pt_suivant							
							if intersect do (
								local pt_faitage_mur = plan_verticaleFaitage.get_intersection_segment 	pt 	pt_suivant
								append pointsMurs  	pt_faitage_mur
								local pt_faitage_pente = plan_pente1.projeter_point_verticalement 	pt_faitage_mur
								append pointsPente  pt_faitage_pente
								
								
								append pointsPente1 	pt_faitage_pente
								append pointsPente2 	pt_faitage_pente
							)
							
							
							
						)
						
						
						
						
						--------- creation des geometries ---------------------
						--- les murs ----
						for i = 1 to pointsMurs.count  do (
							
							local j = i+1
							if j > pointsMurs.count do j = 1
							
							local ptMur1 		= pointsMurs[ i ]
							local ptMur2 		= pointsMurs[ j ]
							local ptPente3 	= pointsPente[ j ]
							local ptPente4	= pointsPente[ i ]
							
							local pointsRaccord = #(ptMur1, ptMur2, ptPente3, ptPente4)
							append nvlsFaces ( geo_ptr.creerFace  	pointsRaccord 	_this)
						) 
						
						
						--- les pentes -----
						append nvlsFaces ( geo_ptr.creerFace  		pointsPente1 	_this)
						append nvlsFaces ( geo_ptr.creerFace  		pointsPente2	_this)
						
						
				)
			)
		),		
		fn acrotere			_this		_face		= (
			
			--- les murs -----
			polyop.bevelFaces _this.delegate 	#(_face) 	0 	-ep_mur
			local faceAExtruder = #{_face+1..(polyop.getNumFaces _this.delegate)} as array
			polyop.extrudeFaces  _this.delegate 	faceAExtruder 	_this.toit_hauteur
			
			--- la couvertine  -----
			polyop.bevelFaces _this.delegate 	faceAExtruder		0 	ep_couvertine
			polyop.extrudeFaces _this.delegate 	faceAExtruder		ep_couvertine
			
		),		
		fn toit 				_this		&z =(
			case _this.toit_type of (
				1: (	---- PLAT	----
					local trace_courant = for pt in _this.trace_courant collect [pt.x,pt.y,z]
					geo_ptr.creerFace		trace_courant		_this
				)
				2: (	---- ACROTERE	----
					
-- 					local trace_courant 		= _this.trace_courant
					
					/* --- dalle ---
					if ep_dalle  != 0 do (
						geo_ptr.creerFacesContour	_this.trace_courant 	z 	ep_dalle
						z += ep_dalle
					)  */
					
					--- creation de la facette globale-----
					local trace_courant 		= for pt in _this.trace_courant collect [pt.x,pt.y,z]
					local faceDuToit 	= geo_ptr.creerFace		trace_courant		_this
					
					acrotere	_this	faceDuToit
					
				)
				3: (	---- 1 PAN	----
					toitPentes			_this		&z  1
				)
				4: (	---- 2 PANS	----
					toitPentes			_this		&z  2
				)
			)
		),		
		
		
		
		
		------------ FACADES-------------------------
		fn ssBassement  	_this		&z	=(
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_ssBassement	_this
			z += ep_ssBassement
			
-- 			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_dalle	_this
-- 			z += ep_dalle
			
		),
		fn RdC 					_this		&z	=(
			
			geo_ptr.creerFacesContour	 _this.trace_courant		z 	_this.niveaux_hauteur			_this	
			z += _this.niveaux_hauteur	
			
		),
		
		
		
		
		fn creer_mur 	_pt_bas		_pt_ht	_pt2 	_this	 ht:	matId:	= (
			local hauteur
-- 			debug "creer_mur"
-- 			debug "_pt_bas" var:_pt_bas
-- 			debug "_pt2" var:_pt2
-- 			debug "(distance _pt2 _pt_bas )" var:(distance _pt2 	(polyop.getvert _this.delegate _pt_bas ) )
			if ht != unsupplied then	hauteur = ht
				else hauteur 	=	_this.niveaux_hauteur 
			
			local pts_pos_esp = 	#()		
			append pts_pos_esp 	( _pt2 )
			append pts_pos_esp 	( _pt2 + [0,0,hauteur] )
			
			local pts_ids_esp = geo_ptr.creer.points  pts_pos_esp 	_this
			append pts_ids_esp 	( _pt_ht )
			append pts_ids_esp 	( _pt_bas )
			
			geo_ptr.creer.edges  pts_ids_esp 	_this	--	fermer:true		
			local nvlFace = geo_ptr.creer.face  	 pts_ids_esp 	_this
			
			--- mat ID -----
			if matId != unsupplied do
				polyop.setFaceMatID	 _this.delegate		nvlFace	  matId
			
			local pt_bas 	= pts_ids_esp[1]
			local pt_ht		= pts_ids_esp[2]
			
			#(pt_bas, pt_ht)
		),
		
		
		
		fn creer_sequence		_pt1		_pt2		_facade		_this			=(
			
			
-- 			-------- DEBUG----------------------
-- 			local chrono_debut = timeStamp ()
-- 			-------- DEBUG----------------------
			
			--- passerelle ----------
			local get_murPlein = _this.facades.get_murPlein
			
			
			------------ ANALYSE ------------------------
			local pt_bas, pt_ht	 
			
			local longueurFacade 		= distance _pt1 _pt2
			local normDir					=	normalize ( _pt2 - _pt1)
			local rot 						= get_angle_vecteur		normDir
			local longueur_sequence 	= _facade.sequence_longueur
			local sequence 				= _facade.sequence 		
			local b_espacer 				= _facade.mode == 4
			
			local nbr_espacemts 		= 0
			for compo in sequence do
				if compo.type == #Parametrique do
					if findString compo.param[1].id "#FAC_PES" != undefined do
						nbr_espacemts += 1
					
			local nbrRepetitions 		
			local longueur_restant 			
			local longueur_espacement 			
			case _facade.mode of (
				1:  	(	--- Repeter ----
					nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbrRepetitions )
					b_espacer = false
				)
				2: 	(	--- Etirer ----
					nbrRepetitions				= 1						
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions 	
					longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts * nbrRepetitions )

				)
				3: 	(	--- Centrer ----					
					nbrRepetitions				= 1		
					longueur_restant 			= longueurFacade - longueur_sequence * nbrRepetitions 	
					longueur_espacement 	= longueur_restant / (  nbr_espacemts * nbrRepetitions )
					
				)
				4:		(	--- Espacer ----	
					nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
					longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
					longueur_espacement 	= longueur_restant / ( 1 + nbr_espacemts * nbrRepetitions)
				)						
			)
			
			------------ CONSTRUCTION ------------------------
			
			---- pour les balcons --------
			local 	balcon_aConstruire = undefined
			local 	balcon_pt_debut 	, balcon_ptID_debut
			
			--- les 3 premiers points --------				
			local pt_accroche_1 	= 	_pt1
			local pt_accroche_2 	= 	pt_accroche_1 + [0,0,_this.ep_dalle]
			local pt_accroche_3 	= 	pt_accroche_2 + [0,0,_this.niveaux_hauteur]
			
			local ptsIDs_accroche 		= ( geo_ptr.creer.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	 _this	)
			
			
			--- si c'est pas en mode centrer ...
			----- le premier espacement ------------
			if _facade.mode != 3 do (
				
				--- Composant 'Mur plein' temporaire	------
				local compoTmp = get_murPlein		longueur_espacement 		_this
				ptsIDs_accroche = compoTmp.param[1].construire	 ptsIDs_accroche		normDir		_this 
				
			)
			
			----- les repetitions de sequence ------------------
			for i = 1 to nbrRepetitions do (
				
				--- la sequence --------
				for composant in sequence do (
					
					-------- DEBUG----------------------
					local chrono_debut_compo = timeStamp ()
					-------- DEBUG----------------------
					
					case composant.type    of (
						 #Modele:			(
							
							---- on tire au hasare le modele  ------------
							local probaTotal = 0
							for proba in composant.modeles_probas do 
								probaTotal += proba
							local tirage = random  1.  probaTotal
							local modele
							local trouve = false
							local id = 1
							local probacourant = 0
							while not trouve and probacourant <= probaTotal	do (
								probacourant += composant.modeles_probas[id]
								if tirage < probacourant do (
									trouve = true
									modele = composant.modeles[id]
								)
								id += 1
							)
							
							if modele != undefined then	(
								
								-- si le modele est trop long on met un mur plein ----------
								pt2 = pt1 + normDir * modele.longueur	
								if composant.longueur>distance _pt2	pt1   then (	
									
									pt2		=	_pt2							
									local pts_accroche = creer_mur 	pt_bas		pt_ht		pt2 		_this		
									pt_bas 	= pts_accroche[1]
									pt_ht		= pts_accroche[2]
									
									pt1 = pt2
									
								) else (
								---- sinon, pose du modele -----
									local modeleTmp_id		=	_this.facades.get_modele_idParam		modele.id		_this
									local modele_node 		= modeles_import[modeleTmp_id]
									local nv_modele 			= copy modele_node
									
									rotate nv_modele (angleaxis rot [0,0,1])
									nv_modele.pos 				= pt1
									nv_modele.pos.z 				= z
									
									_this.delegate.attach	nv_modele		modele_node
									
									
									-----	facette du dessus -----
									pt2 = pt1 + normDir * modele.longueur								
									local hauteurQuiReste = 	_this.niveaux_hauteur 	- modele.hauteur	
									
									local pts_accroche = creer_mur 	pt_bas		pt_ht		pt2 		_this		ht:hauteurQuiReste	
									pt_bas 	= pts_accroche[1]
									pt_ht		= pts_accroche[2]	
									
									pt1 = pt2
								)
							) -- fin if modele undeinde
							
							
						) -- fin modele 
						#Parametrique: 	(
							local pts_accroche 
							local est_espacement 	= findString composant.param[1].id "#FAC_PES" != undefined
							local est_Balcon_deb 	= findString composant.param[1].id "#FAC_PBD" != undefined
							local est_Balcon_fin 	= findString composant.param[1].id "#FAC_PBF" != undefined
							
							---  ESPACEMENT  ----------
							if 	est_espacement 	then (
								
								--- Composant 'Mur plein' temporaire	------
								local compoTmp = get_murPlein		longueur_espacement 		_this
								ptsIDs_accroche = compoTmp.param[1].construire	 ptsIDs_accroche		normDir		_this 
								
							---  BALCON  ----------
							) else 	if est_Balcon_deb then  (
								balcon_ptID_debut 	= ptsIDs_accroche[1]	
								balcon_pt_debut 		= polyop.getVert 	_this.delegate		ptsIDs_accroche[1]	
								balcon_aConstruire 	= composant
							) else if 	est_Balcon_fin 	then (
								balcon_aConstruire.longueur 			= distance	(polyop.getVert 	_this.delegate		ptsIDs_accroche[1]	) 	balcon_pt_debut
								balcon_aConstruire.param[1].construire	 #(balcon_ptID_debut, ptsIDs_accroche[2], ptsIDs_accroche[3])		normDir		_this 
								balcon_aConstruire.longueur 			= 0
								balcon_aConstruire = undefined
							---  DEFAULT  ----------
							) else (
								
								ptsIDs_accroche = composant.param[1].construire	 ptsIDs_accroche		normDir		_this 		est_DansBalcon:(balcon_aConstruire != undefined )
								
							)
						) -- fin 	#Parametrique
						
					) -- fin case ---------------
					
					
					-------- DEBUG----------------------
					local chrono_fin_compo = timeStamp ()
-- 						debug "creer_sequence		compo" var:composant.nom
-- 						debug "creer_sequence		durée compo" var:(   (chrono_fin_compo - chrono_debut_compo ) / 1000.0)
					-------- DEBUG----------------------
				
					
					
				) --- fin de la sequence -----
		
				if b_espacer do (
					
					--- Composant 'Mur plein' temporaire	------
					local compoTmp = get_murPlein		longueur_espacement 		_this
					ptsIDs_accroche = compoTmp.param[1].construire	 ptsIDs_accroche		normDir		_this 
					
	
				)
				
			)  --- fin de la repetition
			
			
			if not b_espacer and  _facade.mode != 3 do (
				
				
				--- le dernier espacement --------				
				--- Composant 'Mur plein' temporaire	------
				local compoTmp = get_murPlein		longueur_espacement 		_this
				ptsIDs_accroche = compoTmp.param[1].construire	 ptsIDs_accroche		normDir		_this 
				
			)
			
-- 			-------- DEBUG----------------------
-- 			local chrono_fin = timeStamp ()
-- 			debug "creer_sequence		durée TOTAL" var:(   (chrono_fin - chrono_debut ) / 1000.0)
-- 			-------- DEBUG----------------------
			
		),
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		fn filtrer_facades_parEtages   	_facades 		_etageCourant	 =(
			
			local facades_result =#()
			
			--- on filtre par etages ---------------
			for fcade in _facades 		do (					
				if fcade.etages_use_min then (
					if _etageCourant	>= fcade.etages_nbre_min  do (
						if fcade.etages_use_max then (
							if _etageCourant <= fcade.etages_nbre_max   do 	
								append facades_result fcade
						)	else (
							append facades_result fcade
						)
					)
				) else (
					append facades_result fcade
				)
			)
			
-- 			debug "...............................filtrer_facades_parEtages" 
-- 			debug "...............................facades_result" var:facades_result
			facades_result
		),
		
		fn filtrer_facades_parMurs		_facades	_mur_longueur		_id_pt		_this		=(
			
			local facades_result 		= #()			
			local est_pignon				= _this.trace.est_pignon	_id_pt	_this
			
			---- si la sequence peut rentrer sur le segment de facade ------------
			for fcde in _facades where fcde.sequence_longueur != 0 and fcde.sequence_longueur < _mur_longueur do (
				---- si la facade est limité en longueur min -----
				if not fcde.longueur_use_min or fcde.longueur_use_min	 and 	fcde.longueur_nbre_min < _mur_longueur do
					---- si la facade est limité en longueur max -----
					if not fcde.longueur_use_max or fcde.longueur_use_max	 and 	fcde.longueur_nbre_max > _mur_longueur do (
						---- si la facade est sur le bon type de mur -----
						case  fcde.murs of (
							1: append facades_result fcde
							2: if not est_pignon do append facades_result fcde
							3: if est_pignon do append facades_result fcde
						)
					)
			)
	
			facades_result
			
		),
		
		
		
		fn choisir_parProbas		_liste	 = (
			local result 	
			
			local probaTotal = 0
			for elem in _liste do 
				probaTotal += elem.probabilite
			local tirage = random  1.  probaTotal
			local trouve = false
			local id = 1
			local probacourant = 0
			if _liste.count > 0 do (
				while not trouve and probacourant <= probaTotal	do (
					probacourant += _liste[id].probabilite
					if tirage < probacourant do (
						trouve = true
						result = _liste[id]
					)
					id += 1
				)
			)
			result
		),
		
		
		fn etages 				_this				&z	=(
			
			local z_initial = copy z
			
			--- passerelle ----------
			local get_murPlein = _this.facades.get_murPlein
			
			for ssTrace_string in _this.sousTraces do (
					z  = z_initial
					
					local sousTrace = str_ssTrace ()
					_this.trace.datasMgr.set_datas_string 		ssTrace_string 		sousTrace 		_this
-- 				set_datas_string 		_datas_string 		_element 	
				
			
				---- boucle étages ---------------------
				for n_etage = 0 to sousTrace.etages  do (
					
					--- filtre par etages ---------------
					local facades_etages 				= 	filtrer_facades_parEtages		_this.facades.facades_total 	n_etage
					local on_a_une_facade_etage 	= facades_etages.count > 0
					local listePts 							= for idPt in sousTrace.trace collect _this.trace_courant[idPt]
					
					---- boucle  murs ---------------------
					for id_pt = 1 to listePts.count do	 (
						
						local on_a_une_facade_mur = false
						
						--- les 2 points du mur ----------
						local pt_mur_1 = listePts[ id_pt ]
						local pt_mur_2						
						if id_pt == listePts.count 	then	pt_mur_2 = listePts[ 1 ]
															else	pt_mur_2 = listePts[ id_pt + 1 ]
						pt_mur_1.z = pt_mur_2.z = z
						
						local	mur_longueur 		= distance pt_mur_1 	pt_mur_2
						local	norm_mur 			= normalize ( pt_mur_2 -	pt_mur_1 )
						
						---- si on  a des facades ------
						if 	on_a_une_facade_etage  do (
						
							---  filtre par  murs  ---------------
							local facades_mur		=	filtrer_facades_parMurs		facades_etages	mur_longueur	id_pt		_this	
							
							---  filtre par probabilités  ---------------						
							local facade_choisi 		= choisir_parProbas		facades_mur	
							
							---- on lance les construction ----------------
							if facade_choisi != undefined and facade_choisi.sequence.count > 0 then (
							--- si on a une facade, on construit la sequence --------------
								creer_sequence		pt_mur_1		pt_mur_2	 facade_choisi		_this	
								on_a_une_facade_mur = true
							)  
							
						) 
						
						if not  on_a_une_facade_mur do (
						--- sinon un mur plein --------------
							
							--- Composant 'Mur plein' temporaire	------
							local pt_accroche_1 	= 	pt_mur_1 
							local pt_accroche_2 	= 	pt_mur_1 + [0,0,_this.ep_dalle]
							local pt_accroche_3 	= 	pt_accroche_2 + [0,0,_this.niveaux_hauteur]	
							
							local ptsIDs_accroche 	= ( geo_ptr.creer.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	 _this	)
							
							local compoTmp = get_murPlein		mur_longueur 		_this
							ptsIDs_accroche 	= compoTmp.param[1].construire	 ptsIDs_accroche		norm_mur		_this 
							
						)
						
					)
					
					z += _this.niveaux_hauteur + _this.ep_dalle
					
					/* --- dalle plancher ---
					if ep_dalle  != 0 do (
						local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	ep_dalle	_this
						facesDunEtage  += nvlsFaces
						z += ep_dalle
					)  */
					
				) --- fin boucle etages -------------
				
				toit				_this		&z
				
			)
			
-- 			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	_this.ep_dalle	_this
-- 			z += ep_dalle
			
		),
		
		
		
		--------- MODELES -----------------
		fn importer_modeles		_this		=(
			modeles_import =#()
			for modele in _this.facades.modeles_total	 do (
				--- nouveau node -----
				local 	nvNode = convertToPoly (mesh ())
				append 	modeles_import		nvNode
				polyop.deleteFaces	nvNode	(#{1..25} as array)		
					
				_this.facades.scan.creer_objet		modele	_this		ndDest:nvNode
			)
		),
		fn retirer_modelesImports	=(			
			for modele in modeles_import	 do delete modele
			modeles_import =#()
		),
		
		
		
		--------- BATIMENT -----------------
		fn batiment 	_this =(
			with redraw OFF (
				undo off (
					
					local chrono_debut = timeStamp ()
					
					---- creation de la surface de base -------
					geo_ptr.vider 	_this
					
					importer_modeles		_this	
					
					local chrono_import = timeStamp ()		--- chrono_debut) / 1000.0
					
					
					local zCourant = -( ep_ssBassement + ep_dalle )
					
					ssBassement 	_this	&zCourant
					local chrono_ssBassement		= timeStamp ()	
					etages			_this	&zCourant
					local chrono_etages				= timeStamp ()	
-- 					toit				_this	&zCourant
					local chrono_toit					= timeStamp ()	
					
					local chrono_retirerImport		= timeStamp ()	
					retirer_modelesImports ()
					
					local chrono_total				= timeStamp ()	
					
					debug "Construire bâtiment"
					debug "			import" var:(	(   (chrono_import - chrono_debut ) / 1000.0)	as string + "s." )
					debug "			ssBassement" var:( (   ( chrono_ssBassement - chrono_import ) / 1000.0)	as string + "s." )
					debug "			etages" var:( (   (chrono_etages - chrono_ssBassement ) / 1000.0)	as string + "s." )
					debug "			toit" var:(  (  (chrono_toit - chrono_etages ) / 1000.0)	as string + "s." )
					debug "			cleaner import" var:(  (  (chrono_total - chrono_toit ) / 1000.0)	as string + "s." )
					debug "		-----	TOTAL" var:(  (  (chrono_total - chrono_debut ) / 1000.0)	as string + "s." )
					debug "		-----	nbre de verts" var:(  _this.mesh.verts.count )
					
				)
				displayTempPrompt ("Bâtiment construit en " +  (  (chrono_total - chrono_debut ) / 1000.0)	as string + "s." ) 10000
			)
			redrawViews () 
		)
	
	
		/* ****************  BACK -****************************************
		fn etagesBACK 				_this				&z	=(
			
			--- passerelle ----------
			local get_murPlein = _this.facades.get_murPlein
			
			
			local facesDunEtage =#()
			
			---- boucle étages ---------------------
			for n_etage = 0 to _this.niveaux_nbre  do (
				
				--- filtre par etages ---------------
				local facades_etages 				= 	filtrer_facades_parEtages		_this.facades.facades_total 	n_etage
				local on_a_une_facade_etage 	= facades_etages.count > 0
				local listePts 							= _this.trace_courant
				
				---- boucle  murs ---------------------
				for id_pt = 1 to listePts.count do	 (
					
					local on_a_une_facade_mur = false
					
					--- les 2 points du mur ----------
					local pt_mur_1 = listePts[ id_pt ]
					local pt_mur_2						
					if id_pt == listePts.count 	then	pt_mur_2 = listePts[ 1 ]
														else	pt_mur_2 = listePts[ id_pt + 1 ]
					pt_mur_1.z = pt_mur_2.z = z
					
					local	mur_longueur 		= distance pt_mur_1 	pt_mur_2
					local	norm_mur 			= normalize ( pt_mur_2 -	pt_mur_1 )
					
					---- si on  a des facades ------
					if 	on_a_une_facade_etage  do (
					
						---  filtre par  murs  ---------------
						local facades_mur		=	filtrer_facades_parMurs		facades_etages	mur_longueur	id_pt		_this	
						
						---  filtre par probabilités  ---------------						
						local facade_choisi 		= choisir_parProbas		facades_mur	
						
						---- on lance les construction ----------------
						if facade_choisi != undefined and facade_choisi.sequence.count > 0 then (
						--- si on a une facade, on construit la sequence --------------
							creer_sequence		pt_mur_1		pt_mur_2	 facade_choisi		_this	
							on_a_une_facade_mur = true
						)  
						
					) 
					
					if not  on_a_une_facade_mur do (
					--- sinon un mur plein --------------
						
						--- Composant 'Mur plein' temporaire	------
						local pt_accroche_1 	= 	pt_mur_1 
						local pt_accroche_2 	= 	pt_mur_1 + [0,0,_this.ep_dalle]
						local pt_accroche_3 	= 	pt_accroche_2 + [0,0,_this.niveaux_hauteur]	
						
						local ptsIDs_accroche 	= ( geo_ptr.creer.points   #( pt_accroche_1 , pt_accroche_2 , pt_accroche_3 )	 _this	)
						
						local compoTmp = get_murPlein		mur_longueur 		_this
						ptsIDs_accroche 	= compoTmp.param[1].construire	 ptsIDs_accroche		norm_mur		_this 
						
					)
					
				)
				
				z += _this.niveaux_hauteur + _this.ep_dalle
				
				
			) --- fin boucle etages -------------
				
				
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	_this.ep_dalle	_this
			z += ep_dalle
			
		)
		
		*********************** BACK **********************************/
		
) ---- fin struct construire ------------------


























