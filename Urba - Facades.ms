/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################


##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	
########################################################################################################################*/

-- (


-- global urba_moduleFacade


------------------------------------------------------------------------------
----------	Fichiers annexes						--------------------------
------------------------------------------------------------------------------
include "$userScripts\cp - GLOBAL\UI.ms"
include "$userScripts\cp - GLOBAL\DragDialog.ms"

include "$userScripts\cp-Urba\Urba - Structures - 2.ms"


------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_urba_facades "Urba | Facades" width:279 height:273
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
-- 	local m_log
	
	local uis_facade, uis_element
	
	---- RCM -----
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_facades.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	

	button 'btn_supprimer_facade' "-" pos:[244,22] width:21 height:21 align:#left
	button 'btn_ajouter_facade' "+" pos:[224,22] width:21 height:21 align:#left
	dropdownList 'ddl_facades' "" pos:[9,22] width:216 height:21 align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	
	label 'lbl_sequence' "Séquence:" pos:[11,66] width:52 height:14 align:#left
	listbox 'lbx_sequence' "" pos:[11,81] width:239 height:7 align:#left

	label 'lbl_model' "Modèle:" pos:[21,229] width:52 height:15 align:#left
	spinner 'spn_elem_largeur' "" pos:[75,214] width:179 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
	label 'lbl_elem_largeur' "Largeur:" pos:[21,213] width:52 height:15 align:#left
	button 'btn_supprimer_element' "-" pos:[236,65] width:16 height:16 align:#left
	button 'btn_ajouter_element' "+" pos:[221,65] width:16 height:16 align:#left
	GroupBox 'grp_prop' "Propriétés de l'élément :" pos:[11,181] width:253 height:78 align:#left
	button 'btn_descendre' "v" pos:[250,94] width:16 height:16 align:#left
	button 'btn_monter' "^" pos:[250,79] width:16 height:16 align:#left
	edittext 'edt_nom_facade' "" pos:[118,46] width:147 height:16 align:#left
	label 'lbl_nom_facade' "Nom:" pos:[12,46] width:52 height:15 align:#left
	
	dropdownList 'ddl_Type' "" pos:[77,194] width:178 height:21 align:#left
	label 'lbl_type' "Type:" pos:[21,196] width:30 height:15 align:#left
	
	dropdownList 'ddl_model' "" pos:[77,229] width:178 height:21 align:#left
	
	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	
	fn actualiser = (
		
		--- les presets facades ----------
		local listTmp =#()
		local presetsFacades = m_prt.presets.get ()
		for preset in presetsFacades do
			append listTmp preset.nom
		ddl_facades.items = listTmp
		
		local prop_enabled = true
		if presetsFacades.count ==0 do prop_enabled = false
		
		for ui in uis_facade do
			ui.enabled = prop_enabled
		
		
		
		if m_prt.facadeCourante == undefined then (
			btn_supprimer_facade.enabled = false
		) else (
			
			btn_supprimer_facade.enabled = true
			edt_nom_facade.text = m_prt.facadeCourante.nom
			
			--- la sequence d'elements ----------
			local listTmp =#()
			local presetsElements 	= m_prt.facadeCourante.elements
			for id_elem in presetsElements do (
				
				local preset = m_prt.elementsDeFacade.get_parIdUnique	id_elem
				local nomItem =ddl_type.items[preset.type]
				case preset.type of (
					2:	nomItem += " : " + preset.largeur as string + " cm."
					3:	nomItem += " : ..."
				)
				
				append listTmp nomItem
				
			)
			
			lbx_sequence.items 		= listTmp
			
		)
		
		
		if lbx_sequence.selection == 0 then
			prop_enabled = false
		else (
		)
		
		for ui in uis_element do
			ui.enabled = prop_enabled
		
		
		if m_prt.elementCourant != undefined do (
			
			ddl_Type.selection = m_prt.elementCourant.type
			case m_prt.elementCourant.type of (
				1:	(	--- Extensible ----
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						lbl_model.enabled = false
						ddl_model.enabled = false
						spn_elem_largeur.Indeterminate = true
					)
				2:	(	--- largeur fixe ----
						lbl_model.enabled = false
						ddl_model.enabled = false
						spn_elem_largeur.Indeterminate = false
						spn_elem_largeur.value = m_prt.elementCourant.largeur
					)
				3:	(	--- model ----
						lbl_elem_largeur.enabled = false
						spn_elem_largeur.enabled = false
						spn_elem_largeur.Indeterminate = true
					)
			)
		)
		
		
		
		if 	lbx_sequence.selection == 0  do 
			btn_supprimer_element.enabled = false
		
		if lbx_sequence.selection <= 1 do
			btn_monter.enabled = false		
		if lbx_sequence.selection == lbx_sequence.items.count do
			btn_descendre.enabled = false
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_facades		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Facades"
		m_titre.setCouleur (color 255	255	255)
		
		/* 
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		*/
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		uis_facade = #(lbl_sequence, lbx_sequence, lbl_nom_facade, edt_nom_facade, btn_monter, btn_descendre, btn_supprimer_element, btn_ajouter_element)
		uis_element = #(grp_prop, lbl_type, ddl_Type, lbl_elem_largeur, spn_elem_largeur, lbl_model, ddl_model)
	
	

		ddl_type.items = #(	"|<-->|  Extensible", 
									"|------|  Largeur fixe", 
									"|===|  Modèle 3D" )
		

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	on ddl_facades 				selected  	val 	do 	m_prt.selectionner_id 	val
	
	
	on btn_descendre 	pressed  do (
		lbx_sequence.selection += 1
		m_prt.descendre 	( lbx_sequence.selection - 1)
	)
	on btn_monter 		pressed  do (
		lbx_sequence.selection -= 1
		m_prt.monter 	 	( lbx_sequence.selection + 1 )
	)
	on btn_supprimer_element 	pressed  do m_prt.supprimer_element	lbx_sequence.selection	
	on btn_ajouter_element 		pressed  do m_prt.ajouter_element ()
	
	on btn_ajouter_facade 		pressed  do m_prt.ajouter_facade ()	
	on btn_supprimer_facade 		pressed  do m_prt.supprimer_facade 	ddl_facades.selection
	
	
	on spn_elem_largeur 		changed 	val		do 	m_prt.set_elemLargeur		val
	
	
	
	on edt_nom_facade 		entered  	txt 		do 	m_prt.changerNom		txt
	
	/* 
	
	on btn_nv_model 	pressed  do	
		m_prt.creer_model 	fichier:"C:\\Users\\Windows\\AppData\\Local\\Autodesk\\3dsMax\\2017 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\facades\\fenetre 1.max"
	on btn_nv_espace 	pressed  do	
		m_prt.creer_espacement ()	
	on btn_nv_repart 	pressed  do	
		m_prt.creer_repartition ()
	
	 */
	
		on edt_elem_nom entered text do (
			m_prt.sequence.elements[ lbx_sequence.selection ].nom = text
			actualiser ()
		)
	
	on ddl_Type		selected sel do	m_prt.set_elemType 			sel
	on lbx_sequence selected sel do	m_prt.selectionnerElem_id 		sel
	on lbx_sequence doubleClicked sel do
(
	actualiser ()
	
	)
	
	
	---- Drag ----
	on roll_urba_facades lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_urba_facades lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_urba_facades mouseMove _pos 	do
		m_drag.suivreSouris ()
	
	---- Fermer ----
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_urba_facades (
	------------ DEBUG	----------------------------------------------------------------------------------
	m_debug = true,
	m_dbgPrefix ="Urba | Facades",
	fn debug 	_txt  var:	 param:    =(
		try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
		catch ()
	),
	
	private
		m_estOuvert 		= false,
		------------  Membres	----------------------------------------------------------------------------------
	public
		
		---- pointeurs ----
		m_dialog				= roll_urba_facades ,		---- le rollout ----
		m_dialogPos 		= [100,100],
		
		col_fenetreFond	= color  68   68  68, 	----  ----
		col_fenetreTxt		= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer 	= #(	openBitMap ico_btnFermer_R ,		-- Repos ----
										openBitMap ico_btnFermer_S ,		-- Survol ----
										openBitMap ico_btnFermer_P 			-- Pressé ----
										),
				
	public
		------------	STRUCTURES DIVERSES 		------------------------------------------------------------------------------------------
		---- le struct principale parent ----
		m_urba,
	
		---- le manager de presets des facades ----
		presets 	= str_presetsMGR 	preset_type:	str_urba_preset_facade	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Facade",
		
		
		elementsDeFacade = str_presetsMGR 	preset_type:	str_urba_preset_elementFacade	\
												fichier:			m_urba.fichier_presets	\
												prefixUnique:	"Element_facade",
		
		
		---- la facade actuelement selectionnée ----
		facadeCourante,
		elementCourant,
		
										
										
										
										
	----------------------------------------------------------------------------------------------------------
	------------  Fonctions	------------------------------------------------------------------------------
	----------------------------------------------------------------------------------------------------------

	public
	------------	UI		------------------------------------------------------------------------------------------
		fn actualiser 	= if m_estOuvert do m_dialog.actualiser (),
		fn selectionner 	_preset 	=(
			local id_preset = presets.trouver_ID 	_preset
			facadeCourante = _preset
			m_dialog.ddl_facades.selection = id_preset
			actualiser ()
		),
		fn selectionner_id 	_id =(
			if _id >0 do (
				facadeCourante = presets.get_preset		_id
				m_dialog.ddl_facades.selection = _id
			)
			actualiser ()
		),
		fn selectionnerElem_id 	_id =(
			if _id >0 do (
				local idUnique = facadeCourante.elements[_id]
				elementCourant = elementsDeFacade.get_parIdUnique		idUnique
				m_dialog.lbx_sequence.selection = _id
			)
			actualiser ()
		),
		fn estOuvert = m_estOuvert,
			
		
		
		fn supprimer _id	=(
-- 			sequence.supprimer _id
			actualiser ()
		),
		fn monter _id =(
-- 			sequence.monter _id
			actualiser ()
		),
		fn descendre _id =(
-- 			sequence.descendre _id
			actualiser ()
		),
		
		
		
		fn ajouter_facade =(
			local nvPreset = presets.creer_preset ()
			facadeCourante = nvPreset
			actualiser ()
		),
		fn supprimer_facade 	_id	=(
			
		),
		
		fn ajouter_element =(
			
			local nvElement = elementsDeFacade.creer_preset ()
			elementCourant = nvElement
			elementsDeFacade.sauvegarder nvElement
			append facadeCourante.elements	 nvElement.idUnique
			presets.sauvegarder facadeCourante
			
			selectionnerElem_id	(elementsDeFacade.get() ).count
			
			actualiser ()
			
		),
		fn supprimer_element 	_id	=(
			
			elementsDeFacade.supprimer_parIdUnique	facadeCourante.elements[_id]
			
			deleteItem	facadeCourante.elements 		_id
			
			presets.sauvegarder		facadeCourante			
			actualiser ()
		),
		
		
		
		
		
			
		---- fenetre -----
		fn ouvrir  pos: =(			
			m_estOuvert 		= true
			if pos != unsupplied do	m_dialogPos = pos
				
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 	 \
											fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			
			
			m_dialog.initialiser ()
			--- pour selectionner un premier élément
			if ( presets.get () ).count >0 do selectionner_id 1
			if ( elementsDeFacade.get () ).count >0 do selectionnerElem_id 1
			m_dialog.actualiser ()
			
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		),
		fn initialiser =(
			debug "initialiser"
		),
		
		
		
		fn changerNom 	_nvNom =(
			facadeCourante.nom = _nvNom
			presets.sauvegarder		facadeCourante
			actualiser ()
			m_urba.batiments.actualiser ()
		),
		fn set_elemType _type =(
			elementCourant.type = _type
			elementsDeFacade.sauvegarder		elementCourant
			actualiser ()
-- 			m_urba.batiments.actualiser ()
			
		),
		fn set_elemLargeur 	_nvlLargeur =(
			elementCourant.largeur = _nvlLargeur
			elementsDeFacade.sauvegarder		elementCourant
			actualiser ()
-- 			m_urba.batiments.actualiser ()
			
		),
		
		
		
		------------  Evenements	----------------------------------------------------------------------------------
		on create do initialiser ()
)

-- 	try 
-- 		destroydialog test.m_dialog 
-- 	catch ()

-- 	urba_moduleFacade = str_urba_facades ()
-- 	urba_moduleFacade.ouvrir ()



-- 	)






