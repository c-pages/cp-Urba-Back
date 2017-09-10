/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################


##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
	
########################################################################################################################*/

(




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
	
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[roll_urba_facades.width - 20,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	
	listbox 'lbx1' "Séquence:" pos:[11,48] width:211 height:7 align:#left
	

	editText 'edt_elem_nom' "" pos:[73,185] width:147 height:16 align:#left
	label 'lbl_elem_nom' "Nom:" pos:[21,185] width:52 height:15 align:#left

	editText 'edt_elem_fichier' "" pos:[73,218] width:132 height:16 align:#left
	label 'lbl_elem_fichier' "Fichier:" pos:[21,218] width:52 height:15 align:#left
	spinner 'spn_elem_largeur' "" pos:[74,202] width:146 height:15 range:[0,1e+13,0] scale:1 align:#left
	label 'lbl_elem_largeur' "Largeur:" pos:[21,201] width:52 height:15 align:#left
	button 'btn_fichier' "..." pos:[206,219] width:16 height:16 align:#left
	button 'btn_supprimer' "-" pos:[207,48] width:16 height:16 align:#left
	button 'btn_ajouter' "+" pos:[192,48] width:16 height:16 align:#left
	groupBox 'grp1' "Propiétés de l'élément :" pos:[11,166] width:223 height:171 align:#left
	button 'btn_descendre' "v" pos:[223,79] width:16 height:16 align:#left
	button 'btn_monter' "^" pos:[223,64] width:16 height:16 align:#left
	editText 'edt_nom_facade' "" pos:[65,27] width:157 height:16 align:#left
	label 'lbl_nom_facade' "Nom:" pos:[12,27] width:52 height:15 align:#left
	groupBox 'grp2' "Notes:" pos:[16,234] width:214 height:98 align:#left
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
		local lstTmp =#()
		for elem in m_prt.sequence.elements do
			append lstTmp 	elem.nom
		lbx1.items = lstTmp
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
	
	
	on btn_nv_model 	pressed  do	(
		local nvElem = m_prt.sequence.creer_model 	fichier:"C:\\Users\\Windows\\AppData\\Local\\Autodesk\\3dsMax\\2017 - 64bit\\ENU\\scripts\\cp-Urba\\lib\\facades\\fenetre 1.max"
		actualiser ()
	)
	on btn_nv_espace 	pressed  do	(
		local nvElem = m_prt.sequence.creer_espacement ()
		actualiser ()
	)
	on btn_nv_repart 	pressed  do	(
		local nvElem = m_prt.sequence.creer_repartition ()
		actualiser ()
	)
	
	
	
	
	on lbx1 selected sel do
(
	
	)
	on lbx1 doubleClicked sel do
(
	
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
		
		
		
		---- FENETRE -----
		fn ouvrir =(			
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
			--- Actiualiser position pour reouverture prochaine ----
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)

try 
	destroydialog test.m_dialog 
catch ()

test = str_urba_facades ()
test.ouvrir ()



)






