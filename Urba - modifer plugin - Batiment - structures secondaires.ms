
------------- declaration en global car erreurs "plugin no active machin..." -----
global str_plan
global str_facade_modele

global str_facadeParam_murPlein, str_facadeParam_baieSimple, str_facadeParam_baie
global str_facade, str_facade_composant



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

-----------------------	MODELE	-------------------------------------------------------------------------------------------------------------
struct str_facade_modele (
		
		id				= "#FAC_MOD_",			---- "MOD" : modele -----------
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





-----------------------	PARAMETRIQUES	-------------------------------------------------------------------------------------------------------------
struct	str_facadeParam_murPlein (
		private
			----- membres communs --------------
			m_compo,								---- le composant parant	
	
			m_construction,
			m_geo,
			
		public
			id				= "#FAC_PMP_",		
			
			dialog 		= 		rollout dialog "Mur plein" width:180 height:70	(
										local m_compo
										local m_rollPrt
										local m_param
										
										edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
										GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:37 align:#left
										label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
										spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										
										fn actualiser =(
											spn_longueur.value 	= 	m_compo.longueur
											edt_nom.text 			=	m_compo.nom
										)

										on spn_longueur changed val do (
											m_compo.longueur = val		
											m_rollPrt.actualiser ()
										)
										on edt_nom	 entered txt 	do	(
											m_compo.nom = txt
											m_rollPrt.actualiser ()
										)
										
									),
							
		---- membres  spécifiques	----------
		
		------ fonctions -------
			fn actualiser 			_compo		_construc	= (
				m_construction 		= _construc
				m_geo					=	m_construction.geo_ptr
				m_compo 				= _compo
			),
			
			fn initialiser 			_compo		_construc	= (
				
				actualiser 			_compo		_construc	
				
				m_compo.nom 		= "Mur plein"
				m_compo.longueur 	= 100
				m_compo.hauteur 	= 100
			),
			fn initialiser_dialog 	roll_prt 	=(
				dialog.m_compo 	= m_compo
				dialog.m_rollPrt	= roll_prt
				dialog.m_param	=	this
				dialog.actualiser()
			),
			
			
		------ CONSTRUIRE -------
			fn construire	 _id_pt_bas		_id_pt_ht		_normDir		_this = (
				
				local pt1 =  polyop.getVert 	_this.delegate		_id_pt_bas	
				local pt2 = pt1 + _normDir * m_compo.longueur
				
				m_construction.creer_mur 	_id_pt_bas		_id_pt_ht	pt2 	_this	 
				/* 
				local pt1 =  polyop.getVert 	_this.delegate		_id_pt_bas	
				local pt2 = pt1 + _normDir * m_compo.longueur
				local hauteur	=	_this.niveaux_hauteur 
				
				local pts_pos_esp = 	#()		
				append pts_pos_esp 	( pt2 )
				append pts_pos_esp 	( pt2 + [0,0,hauteur] )
				
				local pts_ids_esp = m_geo.creer.points  pts_pos_esp 	_this
				append pts_ids_esp 	( _id_pt_ht )
				append pts_ids_esp 	( _id_pt_bas )
				
				m_geo.creer.edges  	pts_ids_esp 	_this	--	fermer:true		
				m_geo.creer.face  	pts_ids_esp 	_this
				
				pt_bas 	= pts_ids_esp[1]
				pt_ht		= pts_ids_esp[2]
				
				#(pt_bas, pt_ht) */
			),
			
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		
		
)

struct	str_facadeParam_baieSimple (
		
		private
			----- membres communs --------------
			m_compo,								---- le composant parant	
			m_construction,
			m_geo,
	
		public
	
			---- membres  spécifiques	----------
			allege_hauteur 		= 	100,
			allege_use				=	true,
			hauteur_use			=	true,
			mur_profondeur		= 	20,
			
			----- membres communs --------------
			id				= "#FAC_PBS_",		
			dialog 		= 		
									rollout dialog "Baie simple" width:180 height:115
									(
										local m_compo
										local m_rollPrt
										local m_param
										
										edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
										
										label 'lbl19' "Longeur:" pos:[13,37] width:49 height:13 align:#left
										spinner 'spn_longueur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										label 'lbl21' "Hauteur:" pos:[13,53] width:49 height:13 align:#left
										spinner 'spn_hauteur' "" pos:[96,52] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										GroupBox 'grp1' "Générale" pos:[6,21] width:167 height:85 align:#left
										label 'lbl24' "Allège:" pos:[13,68] width:49 height:13 align:#left
										spinner 'spn_allege' "" pos:[96,67] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										checkbutton 'ckb_hauteur' "" pos:[79,51] width:17 height:17 toolTip:"Toute hauteur Valeur négative pour descendre depuis plafond" align:#left
										checkbutton 'ckb_allege' "" pos:[79,67] width:17 height:17 align:#left
										label 'lbl29' "Profondeur:" pos:[13,84] width:59 height:13 align:#left
										spinner 'spn_profondeur' "" pos:[96,83] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										
										fn actualiser =(
													spn_longueur.value 			= 	m_compo.longueur
													edt_nom.text 					=	m_compo.nom
													spn_profondeur.value 		=	m_param.mur_profondeur	
													ckb_hauteur.checked		=	m_param.hauteur_use 
													ckb_allege.checked			=	m_param.allege_use
													if not ckb_hauteur.checked then (
														spn_hauteur.enabled 	= true
														spn_hauteur.value 		=	m_compo.hauteur 
													) else (
														spn_hauteur.enabled 			= false
														spn_hauteur.indeterminate 	=	true
													)
													if not ckb_allege.checked then (
														spn_allege.enabled 				= true
														spn_allege.value 					=	m_param.allege_hauteur 
													) else (
														spn_allege.enabled 				= false
														spn_allege.indeterminate 		=	true
													)
												)

										on edt_nom entered txt 	do	(
													m_compo.nom = txt
													m_rollPrt.actualiser ()
												)
										on spn_longueur 		changed 	val 	do	m_compo.longueur 					= val	
										on spn_hauteur 		changed 	val 	do	m_compo.hauteur 					= val	
										on spn_allege 			changed 	val 	do	m_param.allege_hauteur 	= val
										on spn_profondeur 	changed 	val 	do	m_param.mur_profondeur	= val
										on ckb_hauteur 		changed 	state do	(
											m_param.hauteur_use 	= state
											actualiser ()
										)
										on ckb_allege 			changed 	state do	(
											m_param.allege_use 	= state											
											actualiser ()
										)
									)
									,
			
			
		------ fonctions -------
			fn actualiser 			_compo		_construc	= (
				m_construction 		= _construc
				m_geo					=	m_construction.geo_ptr
				m_compo 				= _compo
			),
			
			fn initialiser 			_compo		_construc	= (
				
				actualiser 			_compo		_construc	
				
				m_compo.nom 		= "Baie simple"
				m_compo.longueur 	= 100
				m_compo.hauteur 	= 100
			),
			
			fn initialiser_dialog 	roll_prt 	=(
				dialog.m_compo 	= m_compo
				dialog.m_rollPrt	= roll_prt
				dialog.m_param	=	this
				dialog.actualiser()
			),
			
		------ CONSTRUIRE -------
			fn construire	 _id_pt_bas		_id_pt_ht		_normDir		_this = (
				
				
				
				/*	------------    SCHEMA  	BAIE -----------------------------------------------------
																							
																							
						PTHT	____________________________	6				
							|													|																						
							|													|																						
							|		10	_______________________	|	_	9																			
				vec_rtmb	|	  /	|											|	  /	|																																				
							|	/	|											|	/	|																			
							|  /	|											|  /	|
							4	_____________________________	5		|																	
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
							|		|											|		|																			
				vec_ht	|		7	_______________________	|	_	8																		
							|	  /												|	  /																				
							|	/												|	/ vec_prof																				
							|  /												|  /																			
							3	_____________________________	2				
							|													|																						
				vec_allege |													|																						
							|													|																					
							|													|																						
						PTBAS_____________________________	1	
												vec_longueur
				
				
				*/	----------------------------------------------------------------------------------------
				
				
				---- LA BAIE -----------------------------------------------------------------------
				-------	Les vecteurs generaux 	--------
				local vec_allege 		= if allege_use 	then 	[0,0,0] 
																	else		[0,0,1] *	allege_hauteur
				local vec_rtmb 		= if hauteur_use 	then 	[0,0,0] 
																	else		[0,0,1] *	( _this.niveaux_hauteur - (allege_hauteur + m_compo.hauteur ) )
				local vec_ht 			= [0,0,1] * _this.niveaux_hauteur - ( vec_allege + vec_rtmb ) 
				local vec_longueur 	= _normDir * m_compo.longueur
				local norm_prof		= _normDir * rotateZ ( matrix3 1 ) 90
				local vec_prof			=  norm_prof * mur_profondeur
				
				
				-------	Creation des points 	--------
				--- mur d'allege ----
				local pt_bas 	= polyop.getVert 	_this.delegate		_id_pt_bas	
				local pt_1 		= pt_bas	+  vec_longueur
				local pt_2 		= pt_1		+  vec_allege
				local pt_3 		= pt_bas	+ 	vec_allege
				
				local pt_4 		= pt_3		+ 	vec_ht
				local pt_5 		= pt_4		+ 	vec_longueur
				local pt_6 		= pt_5		+ 	vec_rtmb
				local pt_7 		= pt_3		+ 	vec_prof
				local pt_8 		= pt_2		+ 	vec_prof
				local pt_9 		= pt_5		+ 	vec_prof
				local pt_10		= pt_4		+ 	vec_prof
				local pt_ht 	= polyop.getVert 	_this.delegate		_id_pt_ht	
				
				local pts_pos 	= #( pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
				local pts_ids 	= m_geo.creer.points 	pts_pos		_this
				/* 
				-------	Creation des edges 	--------
				m_geo.creer.edges 		#(	_id_pt_bas, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 _this
				m_geo.creer.edges 		#(	pts_ids[2], 		pts_ids[8], 		pts_ids[7] , 	pts_ids[3] )		 _this
				m_geo.creer.edges 		#(	pts_ids[5], 		pts_ids[9], 		pts_ids[10] , 	pts_ids[4] )		 _this
				m_geo.creer.edges 		#(	pts_ids[8], 		pts_ids[9])		 _this
				m_geo.creer.edges 		#(	pts_ids[7], 		pts_ids[10])	 _this
				m_geo.creer.edges 		#(	pts_ids[5], 		pts_ids[6], 		_id_pt_ht , 	pts_ids[4] )		 _this
				 */
				-------	Creation des faces 	--------
				m_geo.creer.face 		#(	_id_pt_bas, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 _this
				m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[8], 		pts_ids[7] , 	pts_ids[3] )		 _this
				m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[4], 		pts_ids[10] , 	pts_ids[9] )		 _this
				m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[5], 		pts_ids[9], 		pts_ids[8] )		 _this
				m_geo.creer.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10], 	pts_ids[4] )		 _this
				m_geo.creer.face 		#(	pts_ids[7], 		pts_ids[8], 		pts_ids[9], 		pts_ids[10] )		 _this
				m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[6], 		_id_pt_ht , 	pts_ids[4] )		 _this
				
				pts_results = #(pts_ids[1] , pts_ids[6])
				
				
				
				
				---- MENUISERIE CADRE -----------------------------------------------------------------------
				
				
				pts_results
				
				
			),
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		
)
struct	str_facadeParam_baie (
		
		private
			----- membres communs --------------
			m_compo,								---- le composant parant	
			m_construction,
			m_geo,
	
		public
	
			---- membres  spécifiques	----------
			allege_hauteur 				= 	100,
			allege_use						=	true,
			hauteur_use					=	true,
			mur_profondeur				= 	20,
			
			menuis_largeur				=	7.,
			menuis_epaisseur				=	3.,			
			menuis_divisions				=	0,
	
			menuis_allege_use			=	false,
			menuis_allege_ht				=	100,
			menuis_trav_use				=	false,
			menuis_trav_ht				=	210,			
			menuis_ouvrant_use			=	true,
			menuis_double_use			=	true,
			
			tablette_use					= true,
			tablette_hauteur 				= 5,
			tablette_debord 				= 5,
			tablette_cote 					= 5,
			
			volet								= false,
			coffre							= false,
			
			----- membres communs --------------
			id				= "#FAC_PBT_",		
			dialog 		= 		
									rollout dialog "Baie tablette" width:200 height:360
									(
										local m_compo
										local m_rollPrt
										local m_param
										
										edittext 'edt_nom' "" pos:[7,3] width:186 height:16 align:#left
										
										label 'lbl19' "Longeur:" pos:[11,37] width:49 height:13 align:#left
										spinner 'spn_longueur' "" pos:[116,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										label 'lbl21' "Hauteur:" pos:[11,53] width:49 height:13 align:#left
										spinner 'spn_hauteur' "" pos:[116,52] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										GroupBox 'grp1' "Générale" pos:[6,21] width:187 height:85 align:#left
										label 'lbl24' "Allège:" pos:[11,68] width:49 height:13 align:#left
										spinner 'spn_allege' "" pos:[116,67] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										checkbutton 'ckb_hauteur' "" pos:[96,51] width:17 height:17 toolTip:"Toute hauteur Valeur négative pour descendre depuis plafond" align:#left
										checkbutton 'ckb_allege' "" pos:[96,67] width:17 height:17 align:#left
										label 'lbl29' "Profondeur:" pos:[11,84] width:59 height:13 align:#left
										spinner 'spn_profondeur' "" pos:[116,83] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										
										
										
										GroupBox 'grp_divers' "Divers" pos:[6,239] width:187 height:114 align:#left
										checkbox 'chk_tablette' "Tablette" pos:[10,254] width:59 height:16 align:#left
										label 'lbl_tablette_hauteur' "Hauteur:" pos:[11,269] width:49 height:13 align:#left
										spinner 'spn_tablette_hauteur' "" pos:[116,268] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										label 'lbl_tablette_debord' "Débord:" pos:[11,284] width:49 height:13 align:#left
										spinner 'spn_tablette_debord' "" pos:[116,283] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										label 'lbl_tablette_cote' "Cotés:" pos:[11,300] width:59 height:13 align:#left
										spinner 'spn_tablette_cote' "" pos:[116,299] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										checkbox 'chk_volets' "Volets" pos:[10,317] width:47 height:16 align:#left
										checkbox 'chk_coffreStore' "Coffre store" pos:[10,331] width:81 height:16 align:#left
										GroupBox 'grp_menuiseries' "Menuiseries" pos:[6,110] width:187 height:127 align:#left
										label 'lbl_menuis_divisions' "Divisions:" pos:[11,154] width:50 height:13 align:#left
										spinner 'spn_menuis_divisions' "" pos:[116,153] width:70 height:16 range:[1,100000,0] type:#integer scale:1 align:#left
										label 'lbl_allege_hauteur' "Hauteur:" pos:[11,184] width:50 height:13 align:#left
										spinner 'spn_allege_hauteur' "" pos:[116,183] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										checkbox 'chk_allege' "Allège" pos:[10,169] width:48 height:16 align:#left
										label 'lbl_traverse_hauteur' "Hauteur:" pos:[11,215] width:50 height:13 align:#left
										spinner 'spn_traverse_hauteur' "" pos:[116,214] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										checkbox 'chk_traverse' "Traverse" pos:[10,200] width:64 height:16 align:#left
										label 'lbl_menuis_epaisseur' "Epaisseur:" pos:[11,139] width:51 height:13 align:#left
										spinner 'spn_menuis_epaisseur' "" pos:[116,138] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										label 'lbl_menuis_largeur' "Largeur:" pos:[11,124] width:42 height:13 align:#left
										spinner 'spn_menuis_Largeur' "" pos:[116,123] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
										
										fn actualiser =(
													spn_longueur.value 			= 	m_compo.longueur
													edt_nom.text 					=	m_compo.nom
													spn_profondeur.value 		=	m_param.mur_profondeur	
													ckb_hauteur.checked		=	m_param.hauteur_use 
													ckb_allege.checked			=	m_param.allege_use
													if not ckb_hauteur.checked then (
														spn_hauteur.enabled 	= true
														spn_hauteur.value 		=	m_compo.hauteur 
													) else (
														spn_hauteur.enabled 			= false
														spn_hauteur.indeterminate 	=	true
													)
													if not ckb_allege.checked then (
														spn_allege.enabled 				= true
														spn_allege.value 					=	m_param.allege_hauteur 
													) else (
														spn_allege.enabled 				= false
														spn_allege.indeterminate 		=	true
													)
													
													chk_tablette.checked 				= m_param.tablette_use
													lbl_tablette_hauteur.enabled 		= m_param.tablette_use
													spn_tablette_hauteur.enabled 	= m_param.tablette_use
													lbl_tablette_cote.enabled 			= m_param.tablette_use
													spn_tablette_cote.enabled 		= m_param.tablette_use
													spn_tablette_debord.enabled 	= m_param.tablette_use
													lbl_tablette_debord.enabled 		= m_param.tablette_use
													
													spn_profondeur.value 					=	m_param.mur_profondeur
													spn_tablette_hauteur.value 			=	m_param.tablette_hauteur
													spn_tablette_debord.value 			=	m_param.tablette_debord
													spn_tablette_cote.value 			=	m_param.tablette_cote
													
													spn_tablette_hauteur.indeterminate = not m_param.tablette_use
													spn_tablette_cote.indeterminate 	= not m_param.tablette_use
													spn_tablette_debord.indeterminate 	= not m_param.tablette_use
													
												)
										on edt_nom entered txt 	do	(
														m_compo.nom = txt
														m_rollPrt.actualiser ()
													)
										on spn_longueur changed val 	do
											m_compo.longueur 					= val
										on spn_hauteur changed val 	do
											m_compo.hauteur 					= val
										on spn_allege changed val 	do
											m_param.allege_hauteur 	= val
										on ckb_hauteur changed state do		(
													m_param.hauteur_use 	= state
													actualiser ()
												)
										on ckb_allege changed state do	(
													m_param.allege_use 	= state											
													actualiser ()
												)
																				
										on chk_tablette changed state do (
													m_param.tablette_use 	= state											
													actualiser ()
												)
												
										
										on spn_profondeur changed val 	do
											m_param.mur_profondeur	= val
										on spn_tablette_hauteur changed val 	do
											m_param.tablette_hauteur 					= val
										on spn_tablette_debord changed val 	do
											m_param.tablette_debord 	= val
										on spn_tablette_cote changed val 	do
											m_param.tablette_cote	= val
										on spn_menuis_divisions changed val 	do
											m_compo.hauteur 					= val
										on spn_allege_hauteur changed val 	do
											m_compo.hauteur 					= val
										on spn_traverse_hauteur changed val 	do
											m_compo.hauteur 					= val
										on spn_menuis_epaisseur changed val 	do
											m_compo.hauteur 					= val
										on spn_menuis_Largeur changed val 	do
											m_compo.hauteur 					= val
									)
									,
			
		------ CONSTRUIRE -------
			fn construire	 _id_pt_bas		_id_pt_ht		_normDir		_this = (
				
				---- LA BAIE -----------------------------------------------------------------------
				
				local vec_allege 		= if allege_use 	then 	[0,0,0] 
																	else		[0,0,1] *	allege_hauteur
				local vec_rtmb 		= if hauteur_use 	then 	[0,0,0] 
																	else		[0,0,1] *	( _this.niveaux_hauteur - (allege_hauteur + m_compo.hauteur ) )				
				local norm_prof		= _normDir 	* rotateZ ( matrix3 1 ) 90				
				local vec_prof					=  norm_prof 	* 	mur_profondeur				
				local vec_ht 					= 	[0,0,1] 		* 	_this.niveaux_hauteur - ( vec_allege + vec_rtmb  ) 
				local vec_longueur 			= _normDir 	* 	m_compo.longueur		
				
				-------	Placement des points 	--------
				local pt_bas 	= polyop.getVert 	_this.delegate		_id_pt_bas		
				local pt_ht 	= polyop.getVert 	_this.delegate		_id_pt_ht		
				
				local pt_1 		= pt_bas	+  vec_longueur
				local pt_2 		= pt_1		+  vec_allege
				local pt_3 		= pt_bas	+ 	vec_allege
				
				local pt_4		= pt_3		+ 	vec_ht
				local pt_5		= pt_2		+ 	vec_ht
				local pt_6		= pt_5		+ 	vec_rtmb
				
				local pt_7		= pt_3		+ 	vec_prof
				local pt_8		= pt_2		+ 	vec_prof
				local pt_9		= pt_5		+ 	vec_prof
				local pt_10		= pt_4		+ 	vec_prof	
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
				local pts_ids 	= m_geo.creer.points 	pts_pos		_this
				
				----- pour plus tard, ...  le raccord avec les menuiseries, et return -----
				local pts_results = #(pts_ids[1] , pts_ids[6])
				local ids_pts_racc_menuis =#(pts_ids[7], pts_ids[8], pts_ids[9], pts_ids[10])
				
				-------	Creation des faces 	--------
				m_geo.creer.face 		#(	_id_pt_bas, 	pts_ids[1], 		pts_ids[2], 		pts_ids[3] )		 _this				
				m_geo.creer.face 		#(	pts_ids[3], 		pts_ids[2], 		pts_ids[8] , 	pts_ids[7] )		 _this				
-- 				m_geo.creer.face 		#(	pts_ids[7], 		pts_ids[8], 		pts_ids[9] , 	pts_ids[10] )		 _this
				m_geo.creer.face 		#(	pts_ids[10], 	pts_ids[9], 		pts_ids[5], 		pts_ids[4] )		 _this
				m_geo.creer.face 		#(	pts_ids[4], 		pts_ids[5], 		pts_ids[6], 		_id_pt_ht )			 _this		
				
				m_geo.creer.face 		#(	pts_ids[3], 		pts_ids[7], 		pts_ids[10],   	pts_ids[4] )		 _this					
				m_geo.creer.face 		#(	pts_ids[8], 		pts_ids[2], 		pts_ids[5],   	pts_ids[9] )		 _this		
				
				
				
				
				
				
				
				--- CADRE MENUISERIE ----------------------------------------------------------------------------------------------------------------		
				
				local vec_men_ep			= norm_prof	*	menuis_epaisseur
				local vec_men_lrg			=	_normDir		*	menuis_largeur
				local vec_men_ht			=	[0,0,1] 		*	menuis_largeur
				local vec_men_allegeHt	 =	[0,0,1] 		*	menuis_allege_ht
				local vec_men_travHt		=	[0,0,1] 		*	menuis_trav_ht
				
				-------	Placement des points 	--------
				local pt_A	= polyop.getVert 	_this.delegate		ids_pts_racc_menuis[1]		
				local pt_B	= polyop.getVert 	_this.delegate		ids_pts_racc_menuis[2]		
				local pt_C	= polyop.getVert 	_this.delegate		ids_pts_racc_menuis[3]		
				local pt_D	= polyop.getVert 	_this.delegate		ids_pts_racc_menuis[4]
				
				local pt_1		= pt_A		+ 	vec_men_lrg 	+ 	vec_men_ht
				local pt_2		= pt_B		- 	vec_men_lrg 	+ 	vec_men_ht
				local pt_3		= pt_C		- 	vec_men_lrg 	- 	vec_men_ht
				local pt_4		= pt_D		+ 	vec_men_lrg 	- 	vec_men_ht
				
				local pt_5		= pt_1		+ 	vec_men_ep
				local pt_6		= pt_2		+ 	vec_men_ep
				local pt_7		= pt_3		+ 	vec_men_ep
				local pt_8		= pt_4		+ 	vec_men_ep
				
				
				--- creation des points --------------
				local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
				local pts_ids 	= m_geo.creer.points 	pts_pos		_this
				
				----- pour plus tard, ... 
				local pts_pourOuvrant	= #( pt_5, pt_6, pt_7, pt_8  )
-- 				local ids_pts_pourOuvrant = #(pts_ids[5], 		pts_ids[6], 		pts_ids[7], 		pts_ids[8])
				
				---- cadre ------
				m_geo.creer.face 		#(	ids_pts_racc_menuis[1]	, 			ids_pts_racc_menuis[2]	, 			ids_pts_racc_menuis[3]	, 			ids_pts_racc_menuis[4]	 ,
													pts_ids[4], 		pts_ids[3], 		pts_ids[2], 		pts_ids[1] , 	
													pts_ids[4], 		ids_pts_racc_menuis[4]	 )		 _this				
				
				m_geo.creer.face 		#(	pts_ids[1], 	pts_ids[2], 	pts_ids[6],   	pts_ids[5]  )			 _this		
				m_geo.creer.face 		#(	pts_ids[6], 	pts_ids[2], 	pts_ids[3],   	pts_ids[7]  )			 _this		
				m_geo.creer.face 		#(	pts_ids[7], 	pts_ids[3], 	pts_ids[4],   	pts_ids[8]  )			 _this		
				m_geo.creer.face 		#(	pts_ids[1], 	pts_ids[5], 	pts_ids[8],   	pts_ids[4]  )			 _this		
				
				--- la face du fond -----------
-- 				m_geo.creer.face 		#(	pts_ids[5], 	pts_ids[6], 	pts_ids[7],   	pts_ids[8]  )			 _this		
				
				
				
													
													
													
				
				
				--- TABLETTE  ----------------------------------------------------------------------------------------------------------------		
				if tablette_use do (
					
					local vec_tab_ht		= 	[0,0,1] 		* tablette_hauteur
					local vec_tab_deb	= -norm_prof 	* tablette_debord
					local vec_tab_cote	= _normDir 	* tablette_cote					
					
					-------	Placement des points 	--------
					local pt_1 		= pt_bas	+  vec_allege 	- 	vec_tab_ht		-	vec_tab_cote	+ vec_tab_deb
					local pt_2 		= pt_1		+  2 * vec_tab_cote 				+	vec_longueur 	
					local pt_3 		= pt_2		+ 	vec_tab_ht				
					local pt_4		= pt_1		+ 	vec_tab_ht
					
					local pt_5		= pt_1		-	vec_tab_deb
					local pt_6		= pt_2		-	vec_tab_deb			
					local pt_7		= pt_3		-	vec_tab_deb
					local pt_8		= pt_4		-	vec_tab_deb
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8, pt_9, pt_10 )
					local pts_ids 	= m_geo.creer.points 	pts_pos		_this
					
					-------	Creation des faces 	--------
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )		 _this				
					m_geo.creer.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 _this				
					m_geo.creer.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 _this
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4], 		pts_ids[8] )		 _this
					m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7], 		pts_ids[3] )		 _this		
					
				)
				
				
				
				
				---  ALLEGE  ----------------------------------------------------------------------------------------------------------------	
				if menuis_allege_use do (
					
					-------	Placement des points 	--------
					local pt_1 		= pt_bas	+ 	[0,0,1] * menuis_allege_ht	- 	2 * vec_men_ht	 + vec_men_lrg + vec_prof
					local pt_2 		= pt_1		+	vec_longueur 			- 2 * vec_men_lrg 
					local pt_3 		= pt_2		+  2 * vec_men_ht	
					local pt_4		= pt_1		+ 	2 * vec_men_ht
					
					local pt_5		= pt_1		+	vec_men_ep
					local pt_6		= pt_2		+	vec_men_ep			
					local pt_7		= pt_3		+	vec_men_ep
					local pt_8		= pt_4		+	vec_men_ep
					
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
					local pts_ids 	= m_geo.creer.points 	pts_pos		_this
					
					
					-------	Creation des faces 	--------
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[2], 		pts_ids[1] )		 _this				
					m_geo.creer.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[4] )		 _this				
					m_geo.creer.face 		#(	pts_ids[4], 		pts_ids[3], 		pts_ids[7] , 	pts_ids[8] )		 _this
					
					-- la face vitre du bas
					local pts_pos 	= #( 	 pts_pourOuvrant[1], pts_pourOuvrant[2] ,pt_6 , pt_5)
					local pts_ids 	= m_geo.creer.points 	pts_pos		_this
					m_geo.creer.face 		#(pts_ids[1], 		pts_ids[2]	, 		pts_ids[3] , 	pts_ids[4] )		 _this
					
					----- pour plus tard, ... 
					pts_pourOuvrant[1]		= pt_8
					pts_pourOuvrant[2]		= pt_7
					
				)
				
				
				
				--- OUVRANT  ----------------------------------------------------------------------------------------------------------------	
				if menuis_ouvrant_use do (
					
					
					-------	Placement des points 	--------
					local pt_1		= pts_pourOuvrant[1]
					local pt_2		= pts_pourOuvrant[2]
					local pt_3		= pts_pourOuvrant[3]
					local pt_4		= pts_pourOuvrant[4]
					
					local pt_5		= pt_1		+ 	vec_men_lrg 	+ 	vec_men_ht
					local pt_6		= pt_2		- 	vec_men_lrg 	+ 	vec_men_ht
					local pt_7		= pt_3		- 	vec_men_lrg 	- 	vec_men_ht
					local pt_8		= pt_4		+ 	vec_men_lrg 	- 	vec_men_ht
					
					local pt_9		= pt_5		+ 	vec_men_ep
					local pt_10		= pt_6		+ 	vec_men_ep
					local pt_11		= pt_7		+ 	vec_men_ep
					local pt_12		= pt_8		+ 	vec_men_ep
					
					local pts_pourOuvrant	= #( pt_9, pt_10, pt_11, pt_12  )
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 , pt_9, pt_10, pt_11, pt_12 )
					local pts_ids 	= m_geo.creer.points 	pts_pos		_this
					
					---- cadre ------
					
					m_geo.creer.face 		#(	pts_ids[1]	, pts_ids[2], pts_ids[3], pts_ids[4], pts_ids[8], pts_ids[7], pts_ids[6], pts_ids[5], pts_ids[8], pts_ids[4] )		 _this				
					
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[10],   	pts_ids[9]  )			 _this		
					m_geo.creer.face 		#(	pts_ids[10], 	pts_ids[6], 		pts_ids[7],   	pts_ids[11]  )			 _this		
					m_geo.creer.face 		#(	pts_ids[12], 	pts_ids[11], 	pts_ids[7],   	pts_ids[8]  )			 _this		
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[9], 		pts_ids[12],   	pts_ids[8]  )			 _this		
-- 					
-- 					----vitrage
					m_geo.creer.face 		#(	pts_ids[9], 		pts_ids[10], 		pts_ids[11],   	pts_ids[12]  )			 _this		
					
					
				)
				
				
				--- DOUBLE  ----------------------------------------------------------------------------------------------------------------	
				if menuis_double_use do (
					
					local largeur_vitre = distance	pts_pourOuvrant[1] 	pts_pourOuvrant[2] 
					
					-------	Placement des points 	--------
					local pt_1		= pts_pourOuvrant[1]  + _normDir * largeur_vitre/2	- vec_men_lrg - vec_men_ep
					local pt_2		= pt_1 + 2 * vec_men_lrg
					local pt_3		= pts_pourOuvrant[4]  + _normDir * largeur_vitre/2	+ vec_men_lrg - vec_men_ep
					local pt_4		= pt_3  - 2 * vec_men_lrg
					
					local pt_5		= pt_1		+ 	vec_men_ep
					local pt_6		= pt_2		+ 	vec_men_ep
					local pt_7		= pt_3		+ 	vec_men_ep
					local pt_8		= pt_4		+ 	vec_men_ep
					
					--- creation des points --------------
					local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
					local pts_ids 	= m_geo.creer.points 	pts_pos		_this
					
					---- faces ------
					m_geo.creer.face 		#(	pts_ids[2], 		pts_ids[6], 		pts_ids[7],   	pts_ids[3]  )			 _this		
					m_geo.creer.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[3],   	pts_ids[4]  )			 _this		
					m_geo.creer.face 		#(	pts_ids[5], 		pts_ids[1], 		pts_ids[4],   	pts_ids[8]  )			 _this		
-- 										
					
				)
				
				
				
				pts_results
				
			),
			
			
		------ fonctions -------
			fn actualiser 			_compo		_construc	= (
				m_construction 		= _construc
				m_geo					=	m_construction.geo_ptr
				m_compo 				= _compo
			),
			
			fn initialiser 			_compo		_construc	= (
				
				actualiser 			_compo		_construc	
				
				m_compo.nom 		= "Baie tablette"
				m_compo.longueur 	= 100
				m_compo.hauteur 	= 100
			),
			
			fn initialiser_dialog 	roll_prt 	=(
				dialog.m_compo 	= m_compo
				dialog.m_rollPrt	= roll_prt
				dialog.m_param	=	this
				dialog.actualiser()
			),
			
		----- events ------------------------------------------
		on create do 	
			for i= 1 to 10 do id += ( random 0 9 ) as string	
		
)







-----------------------	FACADE	-------------------------------------------------------------------------------------------------------------
struct str_facade_composant (
		
		id							= "#FAC_CMP_",						---- "CMP" : composant -----------
		nom 						=	"Composant de façade",
		
		type						= #Espacement,		--->	#Espacement		#LongueurFixe		#Modele		#Parametrique
		
		longueur					=	0.,	
		hauteur					= 	0.,
		
		modeles					=	#(),
		modeles_probas		=	#(),
		
		param					= 	#(),				
		
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
		
		probabilite				=	100,
		
		etages_use_min		=	false,
		etages_nbre_min		= 	0,
		etages_use_max		=	false,
		etages_nbre_max		=	0,
	
		longueur_use_min		=	false,
		longueur_nbre_min	= 	0,
		longueur_use_max	=	false,
		longueur_nbre_max	=	0,
		
		murs						=	1,			---- (les deux ,gouttereaux, pignons )
		mode						=	1,			---- (repeter, etrier, centrer)
		
		sequence				=	#(),
		sequence_longueur	=0
		
) 










