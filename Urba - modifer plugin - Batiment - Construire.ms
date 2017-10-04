

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
		
		
		---- tester la selection pour la mise a jour du rollout	----
		fn estValide	=	(
			
			if (selection as array).count != 1  				do return false
			_node = ( selection as array )[1]
			if classOf _node != Editable_Poly  				do return false
			if subobjectLevel != 4 								do return false
			_faces = (  polyop.getFaceSelection  _node  ) as array 
			if _faces.count == 0									do return false
			
			return true
			
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
			
			return 	arretePlusPetite
			
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
			return faceHaute
		),		
		fn faceLaPlusBasse 	_node 	_faces = (
			local  faceHaute 
			for faceID in _faces do (
				if faceHaute == undefined do faceHaute = faceID
				if  ( polyop.getFaceCenter 	_node 	faceID ).z  < ( polyop.getFaceCenter 	_node	faceHaute ).z do
					 faceHaute = faceID
			)
			return faceHaute
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
			return 	pointLePlusBas			
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
			return result
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
	
		
		
		
		---- OUVERTURES ----
		fn baies 		_faces	ht_fenetre		_this	= (
			
			undo "construction : bais" on (
				with redraw off (
					
					---- Selection des faces (deja selectionnées dans la version de base)	----
					polyop.setFaceSelection  _node 	_faces
					
					--- declarations	----
					local _facesBais			= #()
					local _facesSelection 	= _faces
					
					---- MatID mur	----
					_node.EditablePoly.setMaterialIndex 		matID.mur	 	1
					
					---- DECOUPES HORIZONTALES	----
					polyop.setEdgeSelection  _node #()					
					for face in  _facesSelection do (
						
						local hauteurFace 		= outils.hauteurFace 	_node	face
						local largeurFace			= outils.largeurFace		_node	face
						local hauteurFaceMin	= prefs.ht_fenetre
						local largeurFaceMin	= prefs.larg_Fenetre + prefs.ep_mur
						local Zmin 					= outils.ZMinFace 		_node 	#(face)						
						local hauteurLinteau 	= if prefs.ht_fenetre > hauteurFace then hauteurFace else prefs.ht_fenetre
						
						-- Selection de la face a tailler --
						polyop.setFaceSelection  	_node 	#(face)
						
						---- Découpe de l'allège	----
						_node.slice [0,0,1] [0,0,Zmin + prefs.ht_allege ] 	flaggedFacesOnly:true
						
						if hauteurLinteau != hauteurFace then (
							---- Découpe du linteau	----
							_node.slice [0,0,1] [0,0,Zmin + hauteurLinteau ] 	flaggedFacesOnly:true
							
							---- DECOUPES VERTICALES	----
							-- Selection de la face à découper --
							facesTmp 		= 	polyop.getEdgeFaces		_node	( _node.GetNumEdges	() )
							nouvelleFace 	=	outils.faceLaPlusBasse 	_node 	facesTmp							
							polyop.setFaceSelection  _node		#( nouvelleFace  )
						) 
						
						local centreFace 		= 		outils.centreDeLaFace		_node	face							
						local normalFace 		= ( polyop.getFaceNormal _node face ) 
						local normalFaceRotZ	= normalFace * rotateZMatrix 90 
						local largeurFace 		= outils.largeurFace 		_node 	face
						local origine				= centreFace + normalFaceRotZ * ( -largeurFace/2 + prefs.ep_mur )
						local origineSlice 		= origine - _node.pos
						local transl_fenetre		= normalFaceRotZ * prefs.larg_Fenetre
						local transl_plein			= normalFaceRotZ * prefs.esp_fenetre
						local translation			= [0,0,0]
						local nbr_fenetre 		= 0
						local nbr_fenetreMax	=	if prefs.nbr_fenetre == 0 then 1 else prefs.nbr_fenetre
						local dimensionMin 		= transl_fenetre  + normalFaceRotZ *	prefs.ep_mur
						
						
						while  length ( translation +  dimensionMin ) < largeurFace and nbr_fenetre < nbr_fenetreMax 	do (
							
							---- Slice debut fenetre ----
							_node.slice 	normalFaceRotZ 	( origineSlice + translation )  	flaggedFacesOnly:true
							
							---- Actualiser translation	----
							translation += transl_fenetre	
							
							---- Slice fin fenetre ----
							polyop.setEdgeSelection  _node		#()
							_node.slice 	normalFaceRotZ 	( origineSlice + translation ) 	flaggedFacesOnly:true
							
							----	Ajout de la face de la fenetre dans la liste pour extrusion epaisseur du mur	----
							derniereArrete 	=	(( polyop.getEdgeSelection  	_node ) as array )[1]
							if derniereArrete != undefined do (
								facesTmp 			= 	polyop.getEdgeFaces			_node		derniereArrete
								faceAAjouter 		= outils.faceLaPlusProche		_node 	facesTmp	origine
								append 	_facesBais		faceAAjouter 
							)
							---- Actualiser nombre de fenetre créées	----
							if prefs.nbr_fenetre != 0 do  nbr_fenetre += 1
							
							---- Actualiser translation	----
							translation += transl_plein
							
						)	-- fin du while --	
						
					)	-- fin du for
					
					---- Extrusion epaisseur du mur ----
					polyop.setFaceSelection  _node		_facesBais
					_node.faceExtrudeHeight 	= -prefs.ep_mur
					_node.extrusionType 			= 1
					_node.EditablePoly.buttonOp #Extrude
					
					---- le nom de la selection des faces ----
					outils.grouperFaces	_node		(( polyop.getFaceSelection  _node ) as array) 		"const_baies" 	
					
					---- retirer de groupe "facades"	----
					outils.degrouperFaces 	_node 	_facesSelection 	"const_facades" 
					
					---- MatID verre	----
					_node.EditablePoly.setMaterialIndex 		matID.verre	 	1
					
				) -- fin redraw off
				
				redrawViews() 
				
			)	-- fin undo
			
		),
	
		
		
		------------ FACADES-------------------------
		fn ssBassement  	_this		&z	=(
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_ssBassement	_this
			z += ep_ssBassement
			
			geo_ptr.creerFacesContour	 	_this.trace_courant		z 	ep_dalle	_this
			z += ep_dalle
			
		),
		fn RdC 					_this		&z	=(
			
			geo_ptr.creerFacesContour	 _this.trace_courant		z 	_this.niveaux_hauteur			_this	
			z += _this.niveaux_hauteur	
			
		),
		fn creer_sequence		_pt1		_pt2			&z 		_facade		_this			=(
-- 			debug "creer sequence()"
			
			local longueurFacade 		= distance _pt1 _pt2
			local normDir					=	normalize ( _pt2 - _pt1)
			local rot 						= get_angle_vecteur		normDir
			local longueur_sequence 	= 0
			local sequence 				= _facade.sequence 		
			local nbr_espacemts 		= 0
			
			for composant 	in sequence do	(
				longueur_sequence += composant.longueur
				if composant.type == #Espacement do
					nbr_espacemts += 1
			)
			
			
			---- si la sequence est vide on fait une grosse facette ----
			if longueur_sequence == 0 or longueurFacade < longueur_sequence then (	
				
				geo_ptr.creerFaceVerticale 		_pt1		_pt2 	z 	_this
				
			) else (
			
				

				local pt1 			= 	_pt1
				local pt2		
				local nbrRepetitions 		
				local longueur_restant 			
				local longueur_espacement 	
				
				
				local b_espacer = false
				case _facade.mode of (
					1:  	(	--- Repeter ----
						nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )	
						longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts )
					)
					2: 	(	--- Etirer ----
						nbrRepetitions				= 1						
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / ( 2	+ nbr_espacemts )

					)
					3: 	(	--- Centrer ----					
						nbrRepetitions				= 1		
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / 2
						
					)
					4:	(	--- Espacer ----	
						nbrRepetitions				= floor ( longueurFacade / longueur_sequence )
						longueur_restant 			= longueurFacade - longueur_sequence * (nbrRepetitions )		
						longueur_espacement 	= longueur_restant / ( nbrRepetitions +1 + nbr_espacemts )
						b_espacer = true
					)						
				)
			
				
				
				--- le premier espacement --------
				pt2		=	pt1 + normDir * longueur_espacement						
				geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this
				pt1 = pt2
				
				for i = 1 to nbrRepetitions do (
					
					--- la sequence --------
					for composant in sequence do (
						
						case composant.type    of (
							#Espacement:		(
								pt2		=	pt1 + normDir * longueur_espacement					
								geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this
								pt1 = pt2
							)
							#LongueurFixe:	(
								pt2		=	pt1 + normDir * composant.longueur	
								if composant.longueur>distance _pt2	pt1   do		pt2	=	_pt2							
								geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this
								pt1 = pt2
							)
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
										
										pt2	=	_pt2							
										geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this
										pt1 = pt2
									) else (
									---- sinon, pose du modele -----
										local modeleTmp_id				=	_this.facades.get_modele_idParam		modele.id		_this
										local modele_node 				= modeles_import[modeleTmp_id]
										
										local nv_modele 		= copy modele_node
										
										rotate nv_modele (angleaxis rot [0,0,1])
										nv_modele.pos 				= pt1
										nv_modele.pos.z 				= z
										
										_this.delegate.attach	nv_modele		modele_node
										
										
										-----	facette du dessus -----
										pt2 = pt1 + normDir * modele.longueur								
										local hauteurQuiReste = 	_this.niveaux_hauteur 	- modele.hauteur								
										local nvlFace = geo_ptr.creerFaceVerticale 	pt1 	pt2 	( z + modele.hauteur	 )		_this 		ht:hauteurQuiReste	
										pt1 = pt2
									)
								) -- fin if modele undeinde
								
								
							) -- fin modele
						) -- fin case ---------------
						
						
					
					) --- fin de la sequence -----
				
					if b_espacer do (
						pt2		=	pt1 + normDir * longueur_espacement						
						geo_ptr.creerFaceVerticale 		pt1		pt2 	z 		_this 
						pt1 = pt2
		
					)
					
				)  --- fin de la repetition
				
				--- le dernier espacement --------
				pt2		=	pt1 + normDir * longueur_espacement						
				geo_ptr.creerFaceVerticale 		pt1		_pt2 	z 		_this 
						
						
			)
						
						
				/* 
				local version_creationPoly = false
										if version_creationPoly then (
											
											---- Version  creation du poly -----
											
											local transf_mtrx =  matrix3 1
											rotateZ 		transf_mtrx		rot
											translate	transf_mtrx		pt1
											translate	transf_mtrx		[0,0,z]
											
											local facesDuNodeAvant 	= polyop.getNumFaces _this.delegate
											_this.facades.scan.creer_objet		modele	_this		transf_mtrx:transf_mtrx
											
										) */
				
				
				
				
				
				
				
				
				
				
						/* 
						
						--- choix du model ----
						local ids_modelsTmp = #()
						for i = 1 to composant.modeles.count do
							append ids_modelsTmp 	i
						
						local longueurAvantFin = distance _pt2	pt1
						
						---- si on a pas de model -----
						if ids_modelsTmp.count == 0  then (
							pt2		=	pt1 + normDir * composant.longueur						
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this
							pt1 = pt2
							
						) else if longueurAvantFin <  composant.longueur then (
							pt2		=	_pt2					
							geo_ptr.creerFaceVerticale 		pt1		pt2 	z 	_this 
							pt1 = pt2
						
						
						) else (
							
							
							---- on tire au hasare le modele parmis ceux qui restent ------------
							local probaTotal = 0
							for id in ids_modelsTmp do 
								probaTotal += composant.modeles_probas[id]
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
							 */
-- 							debug "tirage" var:tirage
-- 							debug "probaTotal" var:probaTotal
-- 							debug "modeleTmp_idUnique" var:modeleTmp_idUnique
							
							
-- 							local modeleTmp_idUnique  	= modelsTmp[1]
-- 							local modeleTmp_id				=	_this.facades.get_modele_idParam		modeleTmp_idUnique		_this
-- 							local modele_node 				= modeles_import[modeleTmp_id]
							
							/* 
							local nv_modele 		= copy modele_node
							
							rotate nv_modele (angleaxis rot [0,0,1])
							nv_modele.pos 				= pt1
							nv_modele.pos.z 				= z
							 */
							/* 
							
							local hauteur_modele 			= modele.hauteur
							local largeur_modele 			= modele.longueur
							
							local version_creationPoly = false
							if version_creationPoly then (
								local transf_mtrx =  matrix3 1
								rotateZ 		transf_mtrx		rot
								translate	transf_mtrx		pt1
								translate	transf_mtrx		[0,0,z]
								
								
								local facesDuNodeAvant 	= polyop.getNumFaces _this.delegate
								_this.facades.scan.creer_objet		modele	_this		transf_mtrx:transf_mtrx
							) else (
								
								local modeleTmp_id				=	_this.facades.get_modele_idParam		modele.id		_this
								local modele_node 				= modeles_import[modeleTmp_id]
								
								local nv_modele 		= copy modele_node
								
								rotate nv_modele (angleaxis rot [0,0,1])
								nv_modele.pos 				= pt1
								nv_modele.pos.z 				= z
								
								_this.delegate.attach	nv_modele		modele_node
							
								
								
								
							)
							
							
							
							
							-----	facette du dessus -----
							pt2 = pt1 + normDir * largeur_modele
							
							local hauteurQuiReste = 	_this.niveaux_hauteur 	- hauteur_modele
							
							local nvlFace = geo_ptr.creerFaceVerticale 	pt1 	pt2 	( z + hauteur_modele )		_this 		ht:hauteurQuiReste	
							
							pt1 = pt2
							
							 */
				
-- 			) else 
-- 				geo_ptr.creerFaceVerticale 		_pt1		_pt2 	z 		_this.niveaux_hauteur 
	
			
		),
		fn etages 				_this				&z	=(
			
			
			local facesDunEtage =#()
			
			
			
			for n_etage = 0 to _this.niveaux_nbre  do (
				
				local facades_possibles =#()
				
				--- on filtre par etages ---------------
				for fcade in _this.facades.facades_total 		do (					
					if fcade.etages_use_min then (
						if n_etage	>= fcade.etages_nbre_min  do (
							if fcade.etages_use_max then (
								if n_etage <= fcade.etages_nbre_max   do 	
									append facades_possibles fcade
							)	else (
								append facades_possibles fcade
							)
						)
					) else (
						append facades_possibles fcade
					)
				)
			
				
-- 					debug "facades_possibles" var:facades_possibles
				---- si on  a pas de facades ------
				if 	facades_possibles.count == 0 then (
					---- on remplis avec murs pleins ------------
					local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	_this.niveaux_hauteur 	_this
					facesDunEtage  += nvlsFaces		
					z += _this.niveaux_hauteur
					
					
				---- sinon on a des facades -----------
				) else (
					
					
					local listePts = _this.trace_courant
					
					for i_pt = 1 to listePts.count do	 (
						
						local facadesTmp =  facades_possibles
												
						--- on chope les deux points du segment de la facade ---
						local pt_1 = listePts[i_pt]
						local pt_2 
						if i_pt == listePts.count then
							pt_2 = listePts[1]
						else pt_2 =  listePts[i_pt + 1 ]
						
						--- si c'est un pignon -----
						if _this.trace.est_pignon	i_pt	_this then (							
							facadesTmp = for facde in facades_possibles where facde.murs != 2	collect  facde
						---  c'est un gouttereau -----
						) else (
							facadesTmp = for facde in facades_possibles where facde.murs != 3	collect  facde							
						)
						
						if facadesTmp.count >0 then (
-- 							debug "on a une facade"
							local facadeTmp = facadesTmp[1]
							if facadeTmp.sequence.count > 0 then
								creer_sequence		pt_1		pt_2			&z 	facadeTmp		_this	
							else 	geo_ptr.creerFaceVerticale 		pt_1		pt_2 	z 	_this
						) else 	geo_ptr.creerFaceVerticale 		pt_1		pt_2 	z 	_this
						
						
						
					)
					z += _this.niveaux_hauteur
				)
				
				
				
				
				--- dalle plancher ---
				if ep_dalle  != 0 do (
					local nvlsFaces = geo_ptr.creerFacesContour	_this.trace_courant	z 	ep_dalle	_this
					facesDunEtage  += nvlsFaces
					z += ep_dalle
				) 
				
			) --- fin boucle etages -------------
				
				
			
			
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
		fn acrotere		_this		_face		= (
			
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
			toit				_this	&zCourant
			local chrono_toit					= timeStamp ()	
			
			local chrono_retirerImport		= timeStamp ()	
			retirer_modelesImports ()
			
			local chrono_total				= timeStamp ()	
			
			debug "Construire bâtiment"
			debug "			import" var:(   (chrono_import - chrono_debut ) / 1000.0)
			debug "			ssBassement" var:(   ( chrono_ssBassement - chrono_import ) / 1000.0)
			debug "			etages" var:(   (chrono_etages - chrono_ssBassement ) / 1000.0)
			debug "			toit" var:(   (chrono_toit - chrono_etages ) / 1000.0)
			debug "			cleaner import" var:(   (chrono_total - chrono_toit ) / 1000.0)
			debug "		-----	TOTAL" var:(   (chrono_total - chrono_debut ) / 1000.0)
			
			redrawViews () 
		)
	
	
) ---- fin struct construire ------------------


























