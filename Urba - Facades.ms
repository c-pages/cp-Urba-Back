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
rollout roll_urba_facades "Urba - Facades" width:250 height:390
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
-- 	local m_log
	
	---- RCM -----
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_facades.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	
	listbox 'lbx_sequence' "Séquence:" pos:[11,48] width:212 height:7 align:#left
	

	editText 'edt_elem_nom' "" pos:[73,185] width:147 height:16 align:#left
	label 'lbl_elem_nom' "Nom:" pos:[21,185] width:52 height:15 align:#left

	editText 'edt_elem_fichier' "" pos:[73,218] width:132 height:16 align:#left
	label 'lbl_elem_fichier' "Fichier:" pos:[21,218] width:52 height:15 align:#left
	button 'btn_elem_fichier' "..." pos:[206,219] width:16 height:16 align:#left
	spinner 'spn_elem_largeur' "" pos:[74,202] width:146 height:15 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl_elem_largeur' "Largeur:" pos:[21,201] width:52 height:15 align:#left
	button 'btn_supprimer' "-" pos:[207,48] width:16 height:16 align:#left
	button 'btn_ajouter' "+" pos:[192,48] width:16 height:16 align:#left
	groupBox 'grp_prop' "Propiétés de l'élément :" pos:[11,166] width:223 height:171 align:#left
	button 'btn_descendre' "v" pos:[223,79] width:16 height:16 align:#left
	button 'btn_monter' "^" pos:[223,64] width:16 height:16 align:#left
	editText 'edt_nom_facade' "" pos:[65,27] width:157 height:16 align:#left
	label 'lbl_nom_facade' "Nom:" pos:[12,27] width:52 height:15 align:#left
	groupBox 'grp_notes' "Notes:" pos:[16,234] width:214 height:98 align:#left
	label 'lbl_notes' "..." pos:[33,251] width:174 height:76 align:#left
	
	button 'btn_annuler' "Annuler" pos:[12,348] width:90 height:16 align:#left
	button 'btn_enregistrerSous' "Enregistrer sous" pos:[144,361] width:90 height:16 align:#left
	button 'btn_enregistrer' "Enregistrer" pos:[144,346] width:90 height:16 align:#left
	
	
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
		
		
		
		
		--- liste sequence ------------
		local lstTmp =#()
		for elem in m_prt.sequence.elements do
			append lstTmp 	elem.nom
		lbx_sequence.items = lstTmp
		
		--- les proprietes ----------		
		local prop_enable = lbx_sequence.selection != 0
		grp_prop.enabled  			= prop_enable
		
		edt_elem_nom.enabled  	= prop_enable
		lbl_elem_nom.enabled  		= prop_enable
		grp_notes.enabled  			= prop_enable
		lbl_notes.enabled  			= prop_enable
		
		edt_elem_fichier.enabled  	= prop_enable
		btn_elem_fichier.enabled  	= prop_enable
		lbl_elem_fichier.enabled  	= prop_enable
		
		spn_elem_largeur.enabled  = prop_enable
		lbl_elem_largeur.enabled  	= prop_enable
		
		if prop_enable then (
			local elem = m_prt.sequence.elements[ lbx_sequence.selection ]
-- 			debug "elem" var:elem
			edt_elem_nom.text 					= elem.nom
			case classOf elem of (
				str_urba_elem_model: (
					edt_elem_fichier.text 		= elem.fichier
					spn_elem_largeur.value  	= elem.largeur
				)
				str_urba_elem_espace: (
					edt_elem_fichier.enabled  	= false
					btn_elem_fichier.enabled  	= false
					lbl_elem_fichier.enabled  	= false
					
					edt_elem_fichier.text 		= ""				
					spn_elem_largeur.value  	= elem.largeur
				)
				str_urba_elem_repart: (
					edt_elem_fichier.enabled  	= false
					btn_elem_fichier.enabled  	= false
					lbl_elem_fichier.enabled  	= false
					
					spn_elem_largeur.enabled  = false
					lbl_elem_largeur.enabled  	= false
					
					edt_elem_fichier.text 		= ""					
					spn_elem_largeur.value  	= 0			
				)
			)
			
		) else (
			edt_elem_nom.text 			= ""		
			edt_elem_fichier.text 		= ""						
			spn_elem_largeur.value  	= 0	
			
		)
		
		
		
		
		
		--- le nanager de sequence ----------
		btn_supprimer.enabled  	= prop_enable
		btn_descendre.enabled  	= prop_enable
		btn_monter.enabled  		= prop_enable
		
		if lbx_sequence.selection == 1 do 
			btn_monter.enabled  		= false
				
		if lbx_sequence.selection == lbx_sequence.items.count do 
			btn_descendre.enabled  		= false
		
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		
		m_drag 		= str_drag 	m_prt:roll_urba_facades		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba - Facades"
		m_titre.setCouleur (color 255	255	255)
		
		/* 
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		*/
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	
	
	
	on btn_descendre 	pressed  do (
		lbx_sequence.selection += 1
		m_prt.descendre 	( lbx_sequence.selection - 1)
	)
	on btn_monter 		pressed  do (
		lbx_sequence.selection -= 1
		m_prt.monter 	 	( lbx_sequence.selection + 1 )
	)
	on btn_supprimer 	pressed  do m_prt.supprimer 		lbx_sequence.selection
	on btn_ajouter 		pressed  do (
		
		rcmenu menu_ajouter 
		(
			menuItem m_model			"Modèle"  
			menuItem m_esp				"Espacement"  
			menuItem m_repartl			"Répartition"  
			
			on m_model 		picked do	
				urba.facades.creer_model 				( lbx_sequence.selection +1 )		fichier:"C:\\Users\\Windows\\AppData\\Local\\Autodesk\\3dsMax\\2017 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\facades\\fenetre 1.max"			
			on m_esp 		picked do	
				urba.facades.creer_espacement 	( lbx_sequence.selection +1 )
			on m_repartl 		picked do	
				urba.facades.creer_repartition 		( lbx_sequence.selection +1 )
		)  -- fin RCMenu
		
		popUpMenu menu_ajouter
	
	)
	
	
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
	
	on lbx_sequence selected sel do
(
	actualiser ()
	)
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
				
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		sequence = str_urba_facadeMgr(),
		
		fn actualiser = m_dialog.actualiser (),
		
		
		
		fn supprimer _id	=(
			sequence.supprimer _id
			actualiser ()
		),
		fn monter _id =(
			sequence.monter _id
			actualiser ()
		),
		fn descendre _id =(
			sequence.descendre _id
			actualiser ()
		),
		
		
		
		
		fn creer_model _idPos	fichier: =(
			sequence.creer_model 	fichier:"C:\\Users\\Windows\\AppData\\Local\\Autodesk\\3dsMax\\2017 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\facades\\fenetre 1.max"
			sequence.deplacer 	sequence.elements.count	_idPos
			m_dialog.lbx_sequence.selection += 1
			actualiser ()
		),
		fn creer_espacement _idPos	=(
			sequence.creer_espacement ()
			sequence.deplacer 	sequence.elements.count	_idPos
			m_dialog.lbx_sequence.selection += 1
			actualiser ()
		),
		fn creer_repartition _idPos	=(
			sequence.creer_repartition ()
			sequence.deplacer 	sequence.elements.count	_idPos
			m_dialog.lbx_sequence.selection += 1
			actualiser ()
		),
		
		
		
		
		
		fn estOuvert = m_estOuvert,
			
		---- fenetre -----
		fn ouvrir =(			
			m_estOuvert 		= true	
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
						
		),
		
		fn fermer  =(	
			m_estOuvert 		= false
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)

-- 	try 
-- 		destroydialog test.m_dialog 
-- 	catch ()

-- 	urba_moduleFacade = str_urba_facades ()
-- 	urba_moduleFacade.ouvrir ()



-- 	)






